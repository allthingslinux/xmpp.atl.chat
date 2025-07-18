#!/bin/bash
set -euo pipefail

# ============================================================================
# MIGRATION HELPER SCRIPT
# ============================================================================
# This script helps migrate from legacy scripts to the unified CLI
# It can be used to automatically convert legacy script calls

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_DIR

show_help() {
    echo -e "${BOLD}Migration Helper Script${NC}"
    echo "Helps migrate from legacy scripts to the unified prosody-manager CLI"
    echo
    echo -e "${BOLD}Usage:${NC}"
    echo "  $0 <command> [options]"
    echo
    echo -e "${BOLD}Commands:${NC}"
    echo -e "  ${GREEN}convert${NC} <legacy_command>    Convert legacy command to new CLI"
    echo -e "  ${GREEN}scan${NC}                       Scan project for legacy script usage"
    echo -e "  ${GREEN}update-docs${NC}               Update documentation with new commands"
    echo -e "  ${GREEN}help${NC}                      Show this help message"
    echo
    echo -e "${BOLD}Examples:${NC}"
    echo "  $0 convert './scripts/dev/dev-tools.sh status'"
    echo "  $0 scan"
    echo "  $0 update-docs"
    echo
}

convert_command() {
    local legacy_cmd="$1"
    
    echo -e "${BLUE}Converting legacy command:${NC} $legacy_cmd"
    
    # Convert setup scripts
    if [[ "$legacy_cmd" == *"setup.sh"* ]]; then
        echo -e "${GREEN}New command:${NC} prosody-manager setup"
        return 0
    fi
    
    if [[ "$legacy_cmd" == *"setup-dev.sh"* ]]; then
        echo -e "${GREEN}New command:${NC} prosody-manager setup --dev"
        return 0
    fi
    
    # Convert dev-tools commands
    if [[ "$legacy_cmd" == *"dev-tools.sh"* ]]; then
        local dev_cmd
        dev_cmd=$(echo "$legacy_cmd" | sed 's/.*dev-tools\.sh[[:space:]]*//')
        
        case "$dev_cmd" in
            "status")
                echo -e "${GREEN}New command:${NC} prosody-manager dev status"
                ;;
            "urls")
                echo -e "${GREEN}New command:${NC} prosody-manager dev urls"
                ;;
            "test")
                echo -e "${GREEN}New command:${NC} prosody-manager dev test"
                ;;
            "config")
                echo -e "${GREEN}New command:${NC} prosody-manager dev config"
                ;;
            "users")
                echo -e "${GREEN}New command:${NC} prosody-manager dev users"
                ;;
            "adduser "*)
                local username
                username=$(echo "$dev_cmd" | sed 's/adduser[[:space:]]*//')
                echo -e "${GREEN}New command:${NC} prosody-manager dev adduser $username"
                ;;
            "deluser "*)
                local username
                username=$(echo "$dev_cmd" | sed 's/deluser[[:space:]]*//')
                echo -e "${GREEN}New command:${NC} prosody-manager dev deluser $username"
                ;;
            "passwd "*)
                local username
                username=$(echo "$dev_cmd" | sed 's/passwd[[:space:]]*//')
                echo -e "${GREEN}New command:${NC} prosody-manager dev passwd $username"
                ;;
            "logs"*)
                echo -e "${GREEN}New command:${NC} prosody-manager dev logs"
                ;;
            "restart"*)
                echo -e "${GREEN}New command:${NC} prosody-manager dev restart"
                ;;
            "cleanup")
                echo -e "${GREEN}New command:${NC} prosody-manager dev cleanup"
                ;;
            "backup")
                echo -e "${GREEN}New command:${NC} prosody-manager dev backup"
                ;;
            "perf")
                echo -e "${GREEN}New command:${NC} prosody-manager dev perf"
                ;;
            *)
                echo -e "${GREEN}New command:${NC} prosody-manager dev $dev_cmd"
                ;;
        esac
        return 0
    fi
    
    # Convert maintenance scripts
    if [[ "$legacy_cmd" == *"health-check.sh"* ]]; then
        echo -e "${GREEN}New command:${NC} prosody-manager health"
        return 0
    fi
    
    if [[ "$legacy_cmd" == *"renew-certificates.sh"* ]]; then
        echo -e "${GREEN}New command:${NC} prosody-manager cert renew <domain>"
        echo -e "${YELLOW}Note:${NC} You need to specify the domain name"
        return 0
    fi
    
    echo -e "${YELLOW}Unknown legacy command. Please check the migration guide.${NC}"
    return 1
}

scan_project() {
    echo -e "${BLUE}Scanning project for legacy script usage...${NC}"
    echo
    
    local found_usage=false
    
    # Scan for script references in documentation
    echo -e "${BOLD}Documentation files:${NC}"
    if find "$PROJECT_DIR" -name "*.md" -type f -exec grep -l "scripts/" {} \; 2>/dev/null; then
        found_usage=true
        echo -e "${YELLOW}Found references to legacy scripts in documentation${NC}"
    else
        echo "No legacy script references found in documentation ✓"
    fi
    echo
    
    # Scan for script references in YAML files (CI/CD)
    echo -e "${BOLD}CI/CD and configuration files:${NC}"
    if find "$PROJECT_DIR" -name "*.yml" -o -name "*.yaml" -type f -exec grep -l "scripts/" {} \; 2>/dev/null; then
        found_usage=true
        echo -e "${YELLOW}Found references to legacy scripts in YAML files${NC}"
    else
        echo "No legacy script references found in YAML files ✓"
    fi
    echo
    
    # Scan for script references in shell scripts
    echo -e "${BOLD}Shell scripts:${NC}"
    if find "$PROJECT_DIR" -name "*.sh" -type f -not -path "*/scripts/*" -exec grep -l "scripts/" {} \; 2>/dev/null; then
        found_usage=true
        echo -e "${YELLOW}Found references to legacy scripts in shell scripts${NC}"
    else
        echo "No legacy script references found in shell scripts ✓"
    fi
    echo
    
    if [[ "$found_usage" == true ]]; then
        echo -e "${YELLOW}Legacy script usage found. Consider updating to use prosody-manager CLI.${NC}"
        echo -e "${BLUE}See the migration guide: docs/migration-guide.md${NC}"
    else
        echo -e "${GREEN}No legacy script usage found! ✓${NC}"
    fi
}

update_docs() {
    echo -e "${BLUE}Updating documentation with new CLI commands...${NC}"
    echo
    
    local backup_dir="$PROJECT_DIR/docs/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup documentation files before updating
    echo "Creating backup of documentation files..."
    find "$PROJECT_DIR" -name "*.md" -type f -exec cp {} "$backup_dir/" \; 2>/dev/null || true
    
    # Update common patterns in documentation
    local updated_files=0
    
    while IFS= read -r -d '' file; do
        local temp_file
        temp_file=$(mktemp)
        local changes_made=false
        
        # Replace common script patterns
        if sed 's|./scripts/setup/setup\.sh|prosody-manager setup|g; 
                s|./scripts/setup/setup-dev\.sh|prosody-manager setup --dev|g;
                s|./scripts/dev/dev-tools\.sh status|prosody-manager dev status|g;
                s|./scripts/dev/dev-tools\.sh test|prosody-manager dev test|g;
                s|./scripts/dev/dev-tools\.sh|prosody-manager dev|g;
                s|./scripts/maintenance/health-check\.sh|prosody-manager health|g;
                s|./scripts/maintenance/renew-certificates\.sh|prosody-manager cert renew|g' "$file" > "$temp_file"; then
            
            if ! cmp -s "$file" "$temp_file"; then
                mv "$temp_file" "$file"
                changes_made=true
                ((updated_files++))
                echo "Updated: $(basename "$file")"
            else
                rm "$temp_file"
            fi
        else
            rm "$temp_file"
        fi
    done < <(find "$PROJECT_DIR" -name "*.md" -type f -print0)
    
    if [[ $updated_files -gt 0 ]]; then
        echo
        echo -e "${GREEN}Updated $updated_files documentation file(s) ✓${NC}"
        echo -e "${BLUE}Backup created in: $backup_dir${NC}"
        echo -e "${YELLOW}Please review the changes and commit them if they look correct.${NC}"
    else
        echo -e "${GREEN}No documentation updates needed ✓${NC}"
        rm -rf "$backup_dir"
    fi
}

main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "convert")
            if [[ $# -eq 0 ]]; then
                echo "Usage: $0 convert <legacy_command>"
                echo "Example: $0 convert './scripts/dev/dev-tools.sh status'"
                exit 1
            fi
            convert_command "$*"
            ;;
        "scan")
            scan_project
            ;;
        "update-docs")
            update_docs
            ;;
        "help" | "-h" | "--help")
            show_help
            ;;
        *)
            echo "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"