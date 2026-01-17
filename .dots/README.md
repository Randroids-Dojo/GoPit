# Dots - Task Tracking

This directory contains tasks managed by [dots](https://github.com/joelreymont/dots), a minimal CLI task tracker.

## What is dots?

Dots is a lightweight task tracker that stores tasks as plain markdown files with YAML frontmatter. Each task is a `.md` file with metadata in the frontmatter and description as markdown body.

**Key features:**
- Zero dependencies (200 KB binary)
- Plain text, git-friendly
- No database, no server
- Edit with any text editor

## Quick Start

```bash
# List all tasks
dot list

# Show task details
dot show GoPit-123

# Edit a task
dot edit GoPit-123

# Mark task as done
dot close GoPit-123

# Create new task
dot new "Task title"
```

## File Format

Each task is a markdown file with YAML frontmatter:

```markdown
---
title: Task title
status: open
priority: 2
issue-type: task
assignee: username
created-at: 2026-01-17T12:00:00Z
---

Task description in markdown format.
```

## Installation

```bash
# macOS/Linux via Homebrew
brew install joelreymont/tap/dots

# Or download binary from releases
# https://github.com/joelreymont/dots/releases
```

## Learn More

- **Repository**: [github.com/joelreymont/dots](https://github.com/joelreymont/dots)
- **Documentation**: See repo README
