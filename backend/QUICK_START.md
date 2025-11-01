# Quick Start Guide - Docker

Get the Quran Memorizer backend running in 3 minutes!

## Prerequisites Check

Make sure you have Docker installed:

```bash
docker --version
docker-compose --version
```

If not installed, download from [docker.com](https://www.docker.com/products/docker-desktop)

## Quick Start (Development)

### Option 1: Using Make (Recommended)

```bash
cd backend
make build    # Build the Docker image
make up       # Start the containers
```

### Option 2: Using Docker Compose Directly

```bash
cd backend
docker-compose build
docker-compose up -d
```

### Verify It's Running

Open your browser and go to:
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/docs
- Health Check: http://localhost:8000/health

### View Logs

```bash
make logs
# or
docker-compose logs -f backend
```

### Stop the Container

```bash
make down
# or
docker-compose down
```

## Production Setup

For production deployment:

1. Create `.env` file from `.env.example`
2. Update secrets and configuration
3. Run:

```bash
cd backend
make up-prod
```

This will start:
- Backend with resource limits
- PostgreSQL database
- Named volumes for data persistence

## Common Tasks

### Access Container Shell

```bash
make shell
```

### Run Tests

```bash
make test
```

### Clean Everything

```bash
make clean
```

## Troubleshooting

### Port 8000 Already in Use

Change the port in `docker-compose.yml`:

```yaml
ports:
  - "8001:8000"  # Use port 8001
```

### Container Won't Start

Check logs:
```bash
docker-compose logs backend
```

Restart:
```bash
make restart
```

### Database Issues

Reset database (WARNING: deletes all data):
```bash
make clean
make up
```

## Next Steps

- Read full documentation: [DOCKER_SETUP.md](DOCKER_SETUP.md)
- Configure environment: See [.env.example](.env.example)
- Deploy to cloud: See [README.md](../README.md)

## Need Help?

1. Check the logs: `make logs`
2. Review configuration in `.env`
3. See full docs: [DOCKER_SETUP.md](DOCKER_SETUP.md)
