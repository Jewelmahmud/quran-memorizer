.PHONY: help build up down restart logs shell clean test

# Default target
help:
	@echo "Available commands:"
	@echo "  make build         - Build Docker image"
	@echo "  make up           - Start containers (development)"
	@echo "  make up-prod      - Start containers (production)"
	@echo "  make down         - Stop containers"
	@echo "  make restart      - Restart containers"
	@echo "  make logs         - View container logs"
	@echo "  make shell        - Open shell in container"
	@echo "  make clean        - Remove containers and volumes"
	@echo "  make test         - Run tests in container"

# Build the Docker image
build:
	docker-compose build

# Start containers in development mode
up:
	docker-compose up -d
	@echo "Backend is running at http://localhost:8000"
	@echo "API documentation at http://localhost:8000/docs"

# Start containers in production mode
up-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@echo "Backend is running at http://localhost:8000"

# Stop containers
down:
	docker-compose down

# Restart containers
restart:
	docker-compose restart

# View logs
logs:
	docker-compose logs -f backend

# Open shell in container
shell:
	docker-compose exec backend /bin/bash

# Clean up containers and volumes
clean:
	docker-compose down -v
	docker system prune -f

# Run tests
test:
	docker-compose exec backend pytest
