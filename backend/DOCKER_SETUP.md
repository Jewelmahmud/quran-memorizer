# Docker Setup Guide for Quran Memorizer Backend

This guide explains how to run the Quran Memorizer backend using Docker and Docker Compose.

## Prerequisites

- Docker Engine 20.10 or higher
- Docker Compose 2.0 or higher

## Quick Start

### Development Mode

1. **Build and start the containers:**
   ```bash
   cd backend
   make build
   make up
   ```

   Or manually:
   ```bash
   cd backend
   docker-compose build
   docker-compose up -d
   ```

2. **Access the API:**
   - API: http://localhost:8000
   - Interactive API docs: http://localhost:8000/docs
   - Alternative docs: http://localhost:8000/redoc

3. **View logs:**
   ```bash
   make logs
   ```

### Production Mode

1. **Create a `.env` file for production:**
   ```bash
   cp .env.example .env
   # Edit .env and set your production values
   ```

2. **Build and start production containers:**
   ```bash
   cd backend
   make up-prod
   ```

   Or manually:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
   ```

## Environment Variables

### Required Variables

- `DATABASE_URL`: Database connection string
- `SECRET_KEY`: Secret key for JWT tokens (change in production!)

### Optional Variables

See `.env.example` for all available configuration options.

## Docker Compose Services

### Development (docker-compose.yml)

- **backend**: Main FastAPI application
  - Port: 8000
  - Uses SQLite by default
  - Auto-reload enabled
  - Data volumes for persistence

### Production (docker-compose.prod.yml)

- **backend**: Main FastAPI application with resource limits
  - Port: 8000
  - PostgreSQL database
  - Resource limits applied
  - Health checks enabled
  
- **postgres**: PostgreSQL database
  - Port: 5432 (internal only)
  - Data persisted in named volume

## Useful Commands

### View logs
```bash
make logs              # Follow backend logs
docker-compose logs backend
```

### Access container shell
```bash
make shell
docker-compose exec backend /bin/bash
```

### Run tests
```bash
make test
docker-compose exec backend pytest
```

### Restart services
```bash
make restart
docker-compose restart
```

### Stop services
```bash
make down
docker-compose down
```

### Clean up everything
```bash
make clean
docker-compose down -v && docker system prune -f
```

## Data Persistence

### Development
- Data is stored in `./data/` directory
- Database file: `./data/quran_memorizer.db`
- Audio files: `./data/audio/`

### Production
- Uses Docker named volumes:
  - `postgres_data`: Database data
  - `audio_data`: Audio files
  - `models_data`: AI models
  - `quran_text_data`: Quran text data

### Backup Data
```bash
# Backup PostgreSQL database
docker-compose exec postgres pg_dump -U quran_user quran_memorizer > backup.sql

# Backup volumes
docker run --rm -v quran_memorizer_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz /data
```

### Restore Data
```bash
# Restore PostgreSQL database
docker-compose exec -T postgres psql -U quran_user quran_memorizer < backup.sql

# Restore volumes
docker run --rm -v quran_memorizer_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres_backup.tar.gz -C /
```

## Health Checks

The backend includes a health check endpoint at `/health`:

```bash
curl http://localhost:8000/health
```

Docker automatically monitors this endpoint. If it fails 3 times, the container is restarted.

## Building Custom Images

### Build for development
```bash
docker-compose build backend
```

### Build for production
```bash
docker-compose -f docker-compose.prod.yml build backend
```

### Build with custom tag
```bash
docker build -t quran-memorizer:latest .
```

## Troubleshooting

### Port already in use
```bash
# Change the port in docker-compose.yml or .env
ports:
  - "8001:8000"  # Use port 8001 instead
```

### Database connection issues
```bash
# Check if database is running
docker-compose ps postgres

# View database logs
docker-compose logs postgres

# Reset database (WARNING: deletes all data)
docker-compose down -v
docker-compose up -d
```

### Container won't start
```bash
# Check logs
docker-compose logs backend

# Check container status
docker-compose ps

# Restart container
docker-compose restart backend
```

### Permission issues on Windows/WSL
```bash
# Ensure volumes have correct permissions
docker-compose exec backend chown -R app:app /app/data
```

### Out of disk space
```bash
# Clean up Docker resources
docker system prune -a --volumes

# View disk usage
docker system df
```

## Advanced Configuration

### Custom Dockerfile

You can create a custom Dockerfile for production:

```dockerfile
# backend/Dockerfile.prod
FROM backend/Dockerfile AS base
# Add custom production modifications
```

### Multi-stage builds

The Dockerfile uses multi-stage builds to optimize image size. The final image is much smaller than the build stage.

### Resource limits

In production mode, resource limits are applied:
- Backend: 2 CPU cores, 4GB RAM
- PostgreSQL: 1 CPU core, 1GB RAM

Adjust these in `docker-compose.prod.yml` as needed.

## Development Tips

1. **Hot reload**: The development setup supports hot reload. Changes to Python files will automatically restart the server.

2. **Database migrations**: Run Alembic migrations inside the container:
   ```bash
   docker-compose exec backend alembic upgrade head
   ```

3. **Install new packages**: After adding to `requirements.txt`:
   ```bash
   docker-compose build backend
   docker-compose up -d
   ```

4. **Debug mode**: Set `DEBUG=True` in `.env` for detailed error messages.

## Security Considerations

1. **Change default secrets**: Always change `SECRET_KEY` in production
2. **Use environment variables**: Never commit sensitive data
3. **Enable HTTPS**: Use a reverse proxy (nginx/traefik) in production
4. **Limit network access**: Don't expose PostgreSQL port publicly
5. **Regular updates**: Keep Docker images and dependencies updated
6. **Security scanning**: Regularly scan images for vulnerabilities:
   ```bash
   docker scan quran-memorizer:latest
   ```

## Monitoring

### Health checks
```bash
# Check container health
docker-compose ps

# Manual health check
curl http://localhost:8000/health
```

### Resource usage
```bash
# View resource usage
docker stats quran_memorizer_backend quran_memorizer_db
```

### Application logs
```bash
# Real-time logs
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 backend
```

## Deployment

For production deployment:

1. Use a production-grade database (PostgreSQL)
2. Set up SSL/TLS certificates
3. Configure a reverse proxy (nginx/traefik)
4. Set up monitoring and alerting
5. Configure automated backups
6. Use secrets management for sensitive data
7. Set appropriate resource limits
8. Enable Docker security features

## Support

For issues or questions:
1. Check logs: `make logs`
2. Review configuration in `.env`
3. Check container status: `docker-compose ps`
4. Open an issue on GitHub
