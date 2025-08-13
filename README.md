# Testing GitHub Actions Workflows and Merge Strategies

This repo serves as a playground for testing GitHub Actions workflows and merge strategies.

In particular, I want to find a solution for the following scenario: 3 PRs get merged into `main` in
close succession, each triggering the same workflow that has a `concurrency group` set, so that at
most one workflow runs at a time. The behaviour of using
[`concurrency`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#concurrency)
is that

> there can be at most one running and one pending job in a concurrency group at any time

This means that when merging 3 PRs, the following will happen:

1. The first PR will trigger the workflow and it will start running.
2. The second PR will trigger the workflow but it will be _pending_ because the first workflow is
   still running.
3. The third PR will trigger the workflow again and start _pending_, but it will _cancel_ the second
   workflow, as there can be only one pending workflow.

What if we don't want to cancel the pending workflow but instead wait for it to finish before
starting the next one?

There's a long-running [discussion](https://github.com/orgs/community/discussions/5435) (> 3 years)
about this issue and it seems unlikely that GitHub will support this feature in the near future.

## Possible Solutions

- Use a
  [merge queue](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
- Use
  [branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
  to prevent merging PRs that would trigger the workflow until the previous one has finished
