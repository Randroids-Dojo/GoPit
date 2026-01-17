#!/bin/bash
set -e

# migrate-dots.sh - Migrate from beads (JSONL) to dots (markdown)
#
# This script converts .beads/issues.jsonl to .dots/*.md files
# with proper YAML frontmatter.

echo "🔄 Migrating from beads to dots..."

# Check prerequisites
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required but not installed"
    echo "   Install with: apt-get install jq"
    exit 1
fi

if [ ! -f ".beads/issues.jsonl" ]; then
    echo "❌ Error: .beads/issues.jsonl not found"
    echo "   Make sure you're in the repository root"
    exit 1
fi

# Create .dots directory
mkdir -p .dots

# Count total issues
total=$(wc -l < .beads/issues.jsonl | tr -d ' ')
echo "📝 Found $total issues to migrate"

# Process each line in the JSONL file
count=0
while IFS= read -r line; do
    count=$((count + 1))

    # Extract fields using jq
    id=$(echo "$line" | jq -r '.id')
    title=$(echo "$line" | jq -r '.title')
    description=$(echo "$line" | jq -r '.description // ""')
    status=$(echo "$line" | jq -r '.status')
    priority=$(echo "$line" | jq -r '.priority // 2')
    issue_type=$(echo "$line" | jq -r '.issue_type // "task"')
    created_by=$(echo "$line" | jq -r '.created_by // ""')
    created_at=$(echo "$line" | jq -r '.created_at')

    # Map beads status to dots status
    case "$status" in
        "open") dots_status="open" ;;
        "closed") dots_status="done" ;;
        "done") dots_status="done" ;;
        "in_progress") dots_status="active" ;;
        "active") dots_status="active" ;;
        *) dots_status="open" ;;
    esac

    # Create markdown file
    filename=".dots/${id}.md"

    # Write YAML frontmatter
    cat > "$filename" << EOF
---
title: $title
status: $dots_status
priority: $priority
issue-type: $issue_type
EOF

    # Add assignee if present
    if [ -n "$created_by" ]; then
        echo "assignee: $created_by" >> "$filename"
    fi

    # Add created-at
    echo "created-at: $created_at" >> "$filename"

    # Close frontmatter
    echo "---" >> "$filename"

    # Add description as markdown body (if present)
    if [ -n "$description" ]; then
        echo "" >> "$filename"
        echo "$description" >> "$filename"
    fi

    echo "  [$count/$total] Migrated: $id - $title"
done < .beads/issues.jsonl

echo ""
echo "✅ Migration complete!"
echo "   - Created $count markdown files in .dots/"
echo "   - Source: .beads/issues.jsonl"
echo ""
echo "Next steps:"
echo "  1. Review migrated files: ls -la .dots/"
echo "  2. Install dots: See https://github.com/joelreymont/dots"
echo "  3. Test with: dot list (after dots is installed)"
echo "  4. Add .dots to git: git add .dots"
echo ""
echo "⚠️  The .beads directory has NOT been deleted."
echo "   After verifying the migration, you can remove it with:"
echo "   rm -rf .beads"
