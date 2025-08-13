#!/bin/bash

# Test script to simulate the concurrency scenario
# This script creates multiple commits in quick succession to trigger overlapping workflows

set -e

echo "🚀 Testing GitHub Actions Concurrency Group Behavior"
echo "This script will create multiple commits to simulate quick PR merges"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
	echo "❌ Error: Not in a git repository"
	exit 1
fi

# Check if we're on main branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
	echo "⚠️  Warning: You're not on the main branch (currently on: $current_branch)"
	echo "The workflow is configured to trigger on pushes to main"
	exit 1
fi

echo "📝 Creating test commits to trigger workflows..."
echo ""

for i in {1..3}; do
	echo "Creating commit $i/3..."
	mkdir -p testdata
	TEST_FILE=testdata/test-file-$i.txt

	echo "Test commit $i - $(date)" >>${TEST_FILE}
	git add ${TEST_FILE}
	git commit -m "Test commit $i - Trigger workflow overlap scenario

This commit is part of testing the concurrency group behavior.
Expected behavior:
- First workflow: Will run immediately
- Second workflow: Will be pending
- Third workflow: Will cancel the second and become pending

Commit created at: $(date)"

	echo "✅ Commit $i created"
	echo "🔄 Pushing commit $i to trigger workflow..."
	git push origin "$current_branch"

	# Small delay to make commits distinct
	sleep 1
done

echo ""
echo "✅ Done! Check your GitHub Actions tab to see the concurrency behavior:"
echo "   1. Go to: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo "   2. Look for the 'Test Concurrency Group Behavior' workflow runs"
echo ""
echo "Expected behavior:"
echo "   🟢 First workflow: Will run immediately and take ~5 minutes"
echo "   🟡 Second workflow: Will be pending (waiting for first to complete)"
echo "   ❌ Third workflow: Will cancel the second workflow and become pending"
