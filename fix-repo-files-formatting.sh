#!/bin/bash

npx prettier --write .github/dependabot.yml
npx prettier --write .github/linters/.markdown-lint.yml
npx prettier --write .github/workflows/lint.yml
npx prettier --write .github/zizmor.yml
