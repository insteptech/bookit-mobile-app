#!/bin/bash

# Navigation Migration Script
# This script helps migrate from direct GoRouter usage to NavigationService

echo "🚀 Starting Navigation Migration..."

# Create backup
echo "📦 Creating backup..."
cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)

# Function to show files that need migration
show_migration_candidates() {
    echo "📋 Files using direct GoRouter navigation:"
    echo ""
    
    echo "Files with context.go():"
    grep -r "context\.go(" lib/ --include="*.dart" | cut -d: -f1 | sort | uniq | head -10
    
    echo ""
    echo "Files with context.push():"
    grep -r "context\.push(" lib/ --include="*.dart" | cut -d: -f1 | sort | uniq | head -10
    
    echo ""
    echo "Files with context.pop():"
    grep -r "context\.pop(" lib/ --include="*.dart" | cut -d: -f1 | sort | uniq | head -10
    
    echo ""
    total_files=$(grep -r "context\.\(go\|push\|pop\)(" lib/ --include="*.dart" | cut -d: -f1 | sort | uniq | wc -l)
    echo "📊 Total files requiring migration: $total_files"
}

# Function to perform automatic migration (DRY RUN)
dry_run_migration() {
    echo "🧪 Performing dry run migration..."
    
    # Create a temporary directory for dry run
    mkdir -p migration_preview
    
    # Copy files to preview directory
    find lib/ -name "*.dart" -exec grep -l "context\.\(go\|push\|pop\)(" {} \; | while read file; do
        cp "$file" "migration_preview/$(basename "$file")"
        
        # Show what would be changed
        echo "File: $file"
        echo "Changes that would be made:"
        
        # Preview context.go replacements
        grep -n "context\.go(" "$file" | head -3
        
        echo "---"
    done
}

# Function to add imports where needed
add_navigation_service_imports() {
    echo "📥 Adding NavigationService imports..."
    
    find lib/ -name "*.dart" -exec grep -l "context\.\(go\|push\|pop\)(" {} \; | while read file; do
        # Check if NavigationService import already exists
        if ! grep -q "navigation_service.dart" "$file"; then
            # Add import after other imports
            sed -i.bak "/^import.*\.dart';$/a\\
import 'package:bookit_mobile_app/core/services/navigation_service.dart';" "$file"
            echo "✅ Added NavigationService import to: $file"
        fi
    done
}

# Function to replace navigation calls
replace_navigation_calls() {
    echo "🔄 Replacing navigation calls..."
    
    find lib/ -name "*.dart" | while read file; do
        # Replace context.go with NavigationService.go
        sed -i.bak 's/context\.go(/NavigationService.go(/g' "$file"
        
        # Replace context.push with NavigationService.push
        sed -i.bak 's/context\.push(/NavigationService.push(/g' "$file"
        
        # Replace context.pop with NavigationService.pop
        sed -i.bak 's/context\.pop(/NavigationService.pop(/g' "$file"
        
        echo "✅ Updated navigation calls in: $file"
    done
}

# Function to remove unused go_router imports
cleanup_imports() {
    echo "🧹 Cleaning up unused imports..."
    
    find lib/ -name "*.dart" | while read file; do
        # Check if file still uses GoRouter directly
        if ! grep -q "GoRoute\|GoRouter\|context\.\(go\|push\|pop\|canPop\)" "$file"; then
            # Remove go_router import if not needed
            sed -i.bak '/import.*go_router/d' "$file"
            echo "✅ Removed unused go_router import from: $file"
        fi
    done
}

# Function to validate migration
validate_migration() {
    echo "✅ Validating migration..."
    
    # Check for any remaining direct context navigation
    remaining=$(grep -r "context\.\(go\|push\|pop\)(" lib/ --include="*.dart" | wc -l)
    echo "📊 Remaining direct context navigation calls: $remaining"
    
    # Check for NavigationService usage
    nav_service_usage=$(grep -r "NavigationService\." lib/ --include="*.dart" | wc -l)
    echo "📊 NavigationService calls found: $nav_service_usage"
    
    # Check for compilation
    echo "🔍 Running Flutter analyze to check for issues..."
    flutter analyze lib/ --no-fatal-infos
}

# Main execution
case "${1:-preview}" in
    "preview")
        echo "🔍 Preview Mode - Showing migration candidates"
        show_migration_candidates
        ;;
    "dry-run")
        echo "🧪 Dry Run Mode - Showing what would change"
        show_migration_candidates
        dry_run_migration
        ;;
    "migrate")
        echo "⚠️  MIGRATION MODE - This will modify your files!"
        read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            add_navigation_service_imports
            replace_navigation_calls
            cleanup_imports
            validate_migration
            echo "✅ Migration completed!"
        else
            echo "❌ Migration cancelled"
        fi
        ;;
    "validate")
        echo "✅ Validation Mode"
        validate_migration
        ;;
    *)
        echo "Usage: $0 {preview|dry-run|migrate|validate}"
        echo ""
        echo "Commands:"
        echo "  preview  - Show files that need migration"
        echo "  dry-run  - Show what changes would be made"
        echo "  migrate  - Perform actual migration (creates backup)"
        echo "  validate - Check migration results"
        ;;
esac

echo "🎯 Migration script completed!"
