#!/bin/bash
# Additional test script for manual testing

set -e

echo "🧪 Running extended ZSH tests..."

# Test that zsh is functional
if ! command -v zsh >/dev/null 2>&1; then
	echo "❌ ZSH not found"
	exit 1
fi

# Test basic zsh functionality
echo "Testing basic ZSH functionality..."
if ! zsh -c "echo 'ZSH test successful'"; then
	echo "❌ Basic ZSH test failed"
	exit 1
fi

# Test that .zshrc can be sourced without errors
echo "Testing .zshrc sourcing..."
if [ -f ~/.zshrc ]; then
	if ! zsh -c "source ~/.zshrc && echo '.zshrc sourced successfully'"; then
		echo "❌ .zshrc sourcing failed"
		exit 1
    fi
else
	echo "❌ .zshrc not found"
	exit 1
fi

# Test that plugins are accessible
echo "Testing plugin availability..."
if ! zsh -c "source ~/.zshrc && which git >/dev/null"; then
	echo "❌ Basic commands not available after sourcing"
	exit 1
fi

echo "✅ All extended tests passed!"