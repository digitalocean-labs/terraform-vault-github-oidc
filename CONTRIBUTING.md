# Contributing

Thank you for investing your time in contributing to our project!

When planning a contribution to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

## Pull Request Process

1. Include a detailed pull request description of the changes being made
2. Run pre-commit hooks (`pre-commit run -a`)
3. Once all outstanding comments and checklist items have been addressed, your contribution will be merged! Merged PRs will be included in the next release.

## Checklist For Contributions

1. Add a [semantics prefix](#semantic-pull-requests) to your PR or commits
2. Ensure CI tests are passing
3. Run pre-commit hooks (`pre-commit run -a`)

## Semantic Pull Requests

When generating release notes, the repository owners rely on the following conventional specs:

- `feat:` for new features
- `feat!:` for breaking changes to features
- `fix:` for bug fixes
- `improvement:` for enhancements
- `docs:`: for documentation and examples
- `refactor:`: for code refactoring
- `test:` for tests
- `chore:` for miscellaneous chores, like updating CI dependencies
