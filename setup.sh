#!/bin/bash

# Ace Mall Staff Management System - Setup Script
# This script sets up the PostgreSQL database and initializes the backend

echo "🚀 Ace Mall Staff Management System - Setup"
echo "==========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL is not installed${NC}"
    echo "Please install PostgreSQL first:"
    echo "  macOS: brew install postgresql@14"
    echo "  Ubuntu: sudo apt-get install postgresql-14"
    exit 1
fi

echo -e "${GREEN}✓ PostgreSQL found${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠ No .env file found. Creating from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file${NC}"
    echo -e "${YELLOW}Please edit .env file with your database credentials${NC}"
    exit 1
fi

# Load environment variables
source .env

echo ""
echo "📦 Database Configuration:"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with database setup? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 1
fi

# Create database if it doesn't exist
echo ""
echo "📊 Creating database..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database created/exists${NC}"
else
    echo -e "${RED}❌ Failed to create database${NC}"
    exit 1
fi

# Run schema
echo ""
echo "🏗️  Creating database schema..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/schema.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Schema created${NC}"
else
    echo -e "${RED}❌ Failed to create schema${NC}"
    exit 1
fi

# Insert roles data
echo ""
echo "👥 Inserting roles data..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/roles_data.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Roles data inserted${NC}"
else
    echo -e "${RED}❌ Failed to insert roles data${NC}"
    exit 1
fi

# Install Go dependencies
echo ""
echo "📦 Installing Go dependencies..."
go mod download

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Go dependencies installed${NC}"
else
    echo -e "${RED}❌ Failed to install Go dependencies${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Setup completed successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Review your .env file configuration"
echo "  2. Start the backend server:"
echo "     go run main.go"
echo ""
echo "  3. The API will be available at:"
echo "     http://localhost:8080"
echo ""
echo "  4. Test the health endpoint:"
echo "     curl http://localhost:8080/health"
echo ""
echo "  5. Start the Flutter app:"
echo "     cd ../ace_mall_app"
echo "     flutter run"
echo ""
