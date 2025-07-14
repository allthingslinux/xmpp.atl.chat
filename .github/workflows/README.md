# GitHub Actions Workflows

This directory contains automated workflows for maintaining code quality and consistency in the XMPP server project.

## Shell Script Quality Workflows

### `shell-quality.yml` - Comprehensive Shell Analysis

A comprehensive workflow that performs multiple checks on shell scripts:

- **Shell Linting**: Uses `shellcheck` to detect common shell scripting issues
- **Format Checking**: Uses `shfmt` to ensure consistent formatting
- **Security Analysis**: Focuses on security-related issues in shell scripts
- **Best Practices**: Checks for common shell scripting best practices

**Triggered on**: Push/PR to main/develop branches when shell scripts are modified
**Files checked**: All `*.sh` files and the `prosody-manager` script

### `shellcheck.yml` - Simple Shellcheck and Format

A streamlined workflow focused on the essentials:

- **Shellcheck**: Uses the popular `ludeeus/action-shellcheck` action
- **Format Check**: Uses `shfmt` to verify formatting consistency

**Triggered on**: Push/PR to main/develop branches when shell scripts are modified
**Files checked**: Scripts in `./scripts/` directory and `prosody-manager`

## Configuration

### Shellcheck

- **Severity**: Error level only (warnings don't fail the build)
- **Scope**: All shell scripts in the repository
- **Format**: GCC-style output for easy IDE integration

### Shfmt (Shell Format)

- **Indentation**: 4 spaces (`-i 4`)
- **Case indentation**: Enabled (`-ci`)
- **Style**: Consistent with project conventions

## Usage

### Local Development

To run these checks locally before committing:

```bash
# Install tools
sudo apt-get install shellcheck
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Run shellcheck on all scripts
find . -name "*.sh" -o -name "prosody-manager" | xargs shellcheck

# Check formatting
shfmt -d -i 4 -ci .

# Auto-fix formatting
shfmt -w -i 4 -ci .
```

### Pre-commit Hook

Consider adding a pre-commit hook to run these checks automatically:

```bash
#!/bin/bash
# .git/hooks/pre-commit
set -e

echo "Running shellcheck..."
find . -name "*.sh" -o -name "prosody-manager" | xargs shellcheck

echo "Checking shell formatting..."
if ! shfmt -d -i 4 -ci .; then
    echo "Shell scripts need formatting. Run: shfmt -w -i 4 -ci ."
    exit 1
fi

echo "All shell script checks passed!"
```

## Workflow Selection

Choose the workflow that best fits your needs:

- **Use `shell-quality.yml`** for comprehensive analysis including security and best practices
- **Use `shellcheck.yml`** for a simpler, faster workflow focused on essential checks

You can use both workflows simultaneously or choose one based on your project requirements.
