#!/bin/bash
# =============================================================================
# Deployment Script for DropShipping AI Agent
# Supports: Railway, Render, Fly.io, Replit, Railway
# =============================================================================

set -e

echo "=========================================="
echo "  DropShipping AI Agent Deployment"
echo "=========================================="

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect platform
detect_platform() {
    if [ -n "$RAILWAY_ENVIRONMENT" ]; then
        echo "railway"
    elif [ -n "$RENDER" ]; then
        echo "render"
    elif [ -n "$FLY_APP_NAME" ]; then
        echo "fly"
    elif [ -n "$REPLIT_DEPLOYMENT" ]; then
        echo "replit"
    else
        echo "local"
    fi
}

# Install dependencies
install_deps() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    pip install -r requirements.txt
    echo -e "${GREEN}Dependencies installed!${NC}"
}

# Initialize database
init_db() {
    echo -e "${YELLOW}Initializing database...${NC}"
    python scripts/seed_data.py
    echo -e "${GREEN}Database initialized!${NC}"
}

# Run tests
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"
    pytest tests/ -v --tb=short || true
    echo -e "${GREEN}Tests complete!${NC}"
}

# Deploy to Railway
deploy_railway() {
    echo -e "${GREEN}Deploying to Railway...${NC}"
    railway up
    echo -e "${GREEN}Deployed to Railway!${NC}"
}

# Deploy to Render
deploy_render() {
    echo -e "${GREEN}Deploying to Render...${NC}"
    render deploy
    echo -e "${GREEN}Deployed to Render!${NC}"
}

# Deploy to Fly.io
deploy_fly() {
    echo -e "${GREEN}Deploying to Fly.io...${NC}"
    fly launch --no-deploy
    fly deploy
    fly apps open
}

# Main deployment
main() {
    PLATFORM=$(detect_platform)
    echo -e "${YELLOW}Detected platform: $PLATFORM${NC}"
    
    case "$PLATFORM" in
        railway)
            install_deps
            init_db
            deploy_railway
            ;;
        render)
            install_deps
            init_db
            deploy_render
            ;;
        fly)
            install_deps
            init_db
            deploy_fly
            ;;
        replit)
            install_deps
            init_db
            ;;
        local)
            echo -e "${YELLOW}Running locally...${NC}"
            install_deps
            init_db
            echo -e "${GREEN}Start with: uvicorn backend.api.main:app --reload${NC}"
            ;;
    esac
    
    echo -e "${GREEN}=========================================="
    echo "  Deployment Complete!"
    echo "==========================================${NC}"
}

# Help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: ./deploy.sh [platform]"
    echo ""
    echo "Platforms:"
    echo "  railway    - Deploy to Railway"
    echo "  render     - Deploy to Render"
    echo "  fly        - Deploy to Fly.io"
    echo "  replit     - Deploy to Replit"
    echo "  local      - Run locally (default)"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh railway"
    echo "  ./deploy.sh render"
    echo "  ./deploy.sh"
    exit 0
fi

main
