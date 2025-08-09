#!/bin/bash

# Onboarding Test Runner Script
# This script runs all onboarding-related tests

echo "🧪 Running Onboarding Feature Test Suite"
echo "========================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Change to project directory
cd "$(dirname "$0")"

echo -e "${BLUE}📋 Running Unit Tests...${NC}"
flutter test test/unit/features/onboarding/ || {
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
}

echo -e "${BLUE}🎨 Running Widget Tests...${NC}"
flutter test test/widget/features/onboarding/ || {
    echo -e "${RED}❌ Widget tests failed${NC}"
    exit 1
}

echo -e "${BLUE}🔗 Running Integration Tests...${NC}"
flutter test test/integration/features/onboarding/ || {
    echo -e "${RED}❌ Integration tests failed${NC}"
    exit 1
}

echo -e "${GREEN}✅ All onboarding tests passed successfully!${NC}"
echo ""
echo "📊 Test Coverage Summary:"
echo "- Domain Layer: 3 test files (entities)"
echo "- Data Layer: 1 test file (repository)"
echo "- Application Layer: 3 test files (controllers)"
echo "- Presentation Layer: 1 test file (widgets)"
echo "- Integration Layer: 1 test file (end-to-end)"
echo ""
echo "📈 Total: 9 test files covering the complete onboarding feature"
