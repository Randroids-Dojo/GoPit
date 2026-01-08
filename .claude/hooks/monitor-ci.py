#!/usr/bin/env python3
"""
Monitor CI after PR creation, merge, or push to main.

This hook is triggered after Bash commands. It detects:
1. `gh pr create` - monitors the newly created PR's checks
2. `gh pr merge` - monitors the deployment workflow on main
3. `git push` to main/master - monitors the deployment workflow

On CI failure, exits with code 2 to block Claude until properly fixed.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import time
from typing import Optional, Tuple, List

TIMEOUT_MINUTES = 15
POLL_INTERVAL_SECONDS = 30


def log(msg: str) -> None:
    """Print to stderr so Claude sees the output."""
    print(f"[CI Monitor] {msg}", file=sys.stderr)


def run_cmd(cmd: List[str], timeout: int = 60) -> Tuple[int, str, str]:
    """Run a command and return (returncode, stdout, stderr)."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except Exception as e:
        return -1, "", str(e)


def extract_pr_number(stdout: str) -> Optional[str]:
    """Extract PR number from gh pr create output."""
    # Output format: "https://github.com/owner/repo/pull/123"
    match = re.search(r"/pull/(\d+)", stdout)
    if match:
        return match.group(1)
    return None


def get_current_branch() -> Optional[str]:
    """Get current git branch name."""
    code, stdout, _ = run_cmd(["git", "branch", "--show-current"])
    if code == 0:
        return stdout.strip()
    return None


def is_push_to_main(command: str) -> bool:
    """Check if command is a push to main/master branch."""
    # Match: git push, git push origin main, git push origin master
    # Also handle: git -C /path push origin main
    push_patterns = [
        r"git\s+(?:-C\s+\S+\s+)?push\s+(?:origin\s+)?(?:main|master)\b",
        r"git\s+(?:-C\s+\S+\s+)?push\s*$",  # plain git push (might be to main)
    ]
    for pattern in push_patterns:
        if re.search(pattern, command):
            # For plain "git push", check current branch
            if "main" not in command and "master" not in command:
                branch = get_current_branch()
                return branch in ("main", "master")
            return True
    return False


def is_pr_create(command: str) -> bool:
    """Check if command creates a PR."""
    return "gh pr create" in command


def is_pr_merge(command: str) -> bool:
    """Check if command merges a PR."""
    return "gh pr merge" in command


def monitor_pr_checks(pr_number: str) -> bool:
    """
    Monitor PR checks until completion or timeout.
    Returns True if all checks pass, False otherwise.
    """
    log(f"Monitoring CI for PR #{pr_number}...")
    start_time = time.time()
    timeout_seconds = TIMEOUT_MINUTES * 60

    while time.time() - start_time < timeout_seconds:
        # Get PR check status
        code, stdout, stderr = run_cmd([
            "gh", "pr", "checks", pr_number, "--json", "name,state,conclusion"
        ])

        if code != 0:
            log(f"Failed to get PR checks: {stderr}")
            time.sleep(POLL_INTERVAL_SECONDS)
            continue

        try:
            checks = json.loads(stdout)
        except json.JSONDecodeError:
            log(f"Failed to parse checks output: {stdout}")
            time.sleep(POLL_INTERVAL_SECONDS)
            continue

        if not checks:
            log("No checks found yet, waiting...")
            time.sleep(POLL_INTERVAL_SECONDS)
            continue

        # Analyze check states
        pending = []
        failed = []
        passed = []

        for check in checks:
            name = check.get("name", "unknown")
            state = check.get("state", "").upper()
            conclusion = check.get("conclusion", "").upper()

            if state == "COMPLETED":
                if conclusion in ("SUCCESS", "SKIPPED", "NEUTRAL"):
                    passed.append(name)
                else:
                    failed.append(name)
            else:
                pending.append(name)

        # Report status
        elapsed = int(time.time() - start_time)
        log(f"[{elapsed}s] Passed: {len(passed)}, Pending: {len(pending)}, Failed: {len(failed)}")

        if failed:
            log(f"FAILED checks: {', '.join(failed)}")
            return False

        if not pending:
            log(f"All {len(passed)} checks passed!")
            return True

        time.sleep(POLL_INTERVAL_SECONDS)

    log(f"Timeout after {TIMEOUT_MINUTES} minutes")
    return False


def monitor_branch_workflow(branch: str) -> bool:
    """
    Monitor the latest workflow run for a branch.
    Returns True if workflow succeeds, False otherwise.
    """
    log(f"Monitoring CI for branch '{branch}'...")

    # Wait a moment for workflow to start
    time.sleep(5)

    start_time = time.time()
    timeout_seconds = TIMEOUT_MINUTES * 60

    while time.time() - start_time < timeout_seconds:
        # Get latest workflow run for the branch
        code, stdout, stderr = run_cmd([
            "gh", "run", "list",
            "--branch", branch,
            "--limit", "1",
            "--json", "databaseId,status,conclusion,name"
        ])

        if code != 0:
            log(f"Failed to get workflow runs: {stderr}")
            time.sleep(POLL_INTERVAL_SECONDS)
            continue

        try:
            runs = json.loads(stdout)
        except json.JSONDecodeError:
            log(f"Failed to parse runs output: {stdout}")
            time.sleep(POLL_INTERVAL_SECONDS)
            continue

        if not runs:
            log("No workflow runs found yet, waiting...")
            time.sleep(POLL_INTERVAL_SECONDS)
            continue

        run = runs[0]
        run_id = run.get("databaseId")
        status = run.get("status", "").lower()
        conclusion = run.get("conclusion", "").lower()
        name = run.get("name", "unknown")

        elapsed = int(time.time() - start_time)

        if status == "completed":
            if conclusion in ("success", "skipped", "neutral"):
                log(f"[{elapsed}s] Workflow '{name}' succeeded!")
                return True
            else:
                log(f"[{elapsed}s] Workflow '{name}' failed with conclusion: {conclusion}")
                # Show more details
                run_cmd(["gh", "run", "view", str(run_id), "--log-failed"], timeout=30)
                return False
        else:
            log(f"[{elapsed}s] Workflow '{name}' status: {status}")

        time.sleep(POLL_INTERVAL_SECONDS)

    log(f"Timeout after {TIMEOUT_MINUTES} minutes")
    return False


def main() -> int:
    """Main entry point."""
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # Not valid JSON input, ignore
        return 0

    command = data.get("tool_input", {}).get("command", "")
    stdout = data.get("tool_response", {}).get("stdout", "")
    return_code = data.get("tool_response", {}).get("returnCode", 0)

    # Only monitor if the command succeeded
    if return_code != 0:
        return 0

    # Check for PR creation
    if is_pr_create(command):
        pr_number = extract_pr_number(stdout)
        if pr_number:
            success = monitor_pr_checks(pr_number)
            if not success:
                log("CI FAILED - You must fix the issues before continuing.")
                return 2  # Block Claude
            return 0
        else:
            log("Could not extract PR number from output")
            return 0

    # Check for PR merge (triggers main branch CI)
    if is_pr_merge(command):
        log("PR merged - monitoring deployment on main...")
        success = monitor_branch_workflow("main")
        if not success:
            log("CI/DEPLOYMENT FAILED - You must fix the issues before continuing.")
            return 2  # Block Claude
        return 0

    # Check for push to main
    if is_push_to_main(command):
        success = monitor_branch_workflow("main")
        if not success:
            log("CI/DEPLOYMENT FAILED - You must fix the issues before continuing.")
            return 2  # Block Claude
        return 0

    # Not a monitored command
    return 0


if __name__ == "__main__":
    sys.exit(main())
