#!/bin/bash

# Script to fix Go modules issues
echo "🔧 Fixing Go modules..."

# Navigate to backend directory
cd backend

# Check if go.mod exists
if [ ! -f "go.mod" ]; then
    echo "❌ go.mod not found!"
    exit 1
fi

# Check if go.sum exists
if [ ! -f "go.sum" ]; then
    echo "⚠️  go.sum not found, regenerating..."
    rm -f go.sum
fi

# Clean Go module cache
echo "🧹 Cleaning Go module cache..."
go clean -modcache

# Download and verify dependencies
echo "📥 Downloading dependencies..."
go mod download

# Verify modules
echo "✅ Verifying modules..."
go mod verify

# Tidy modules
echo "🧹 Tidying modules..."
go mod tidy

# Check for any issues
echo "🔍 Checking for issues..."
go mod why

echo "✅ Go modules fixed successfully!"
echo "📋 Current dependencies:"
go list -m all

cd ..
