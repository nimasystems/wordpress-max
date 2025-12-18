# WordPress-MAX

A production-ready, feature-rich WordPress Docker image based on the official WordPress image, extended with essential PHP extensions, optimization tools, and development utilities.

## Features

### PHP Extensions
- **Caching**: Redis, APCu
- **Data Formats**: YAML
- **Security**: Sodium, libsodium
- **Performance**: Memcached support
- **Image Processing**: GD, ImageMagick

### Image Optimization Tools
- OptiPNG - PNG optimization
- Gifsicle - GIF optimization
- jpegoptim - JPEG optimization
- WebP - Modern image format support
- ImageMagick - Advanced image manipulation

### Development Tools
- WP-CLI - WordPress command-line interface with bash completions
- Git
- Vim
- Midnight Commander (mc)
- ncdu - Disk usage analyzer
- Lynx - Text-based web browser

### Internationalization
Built-in locale support for:
- English (en_US.UTF-8)
- Spanish (es_ES.UTF-8)
- Bulgarian (bg_BG.UTF-8)
- German (de_DE.UTF-8)
- French (fr_FR.UTF-8)
- Italian (it_IT.UTF-8)

### Python Support
- Python 3 with pip
- Pandas
- numbers_parser

## Configuration

The image includes custom configurations for optimal WordPress performance:

### PHP Configuration
- Custom `php.ini` with production-ready settings
- APCu configuration
- Redis configuration
- YAML configuration

### Apache Configuration
- Custom web server configuration
- WordPress-specific .htaccess configuration

## Usage

### Pull from Registry

```bash
docker pull registry.nimahosts.com/nimasystems-public/wordpress-max:latest
```

### Run Container

```bash
docker run -d \
  --name wordpress \
  -p 80:80 \
  -e WORDPRESS_DB_HOST=db:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=your_password \
  -e WORDPRESS_DB_NAME=wordpress \
  registry.nimahosts.com/nimasystems-public/wordpress-max:latest
```

### Docker Compose Example

```yaml
version: '3.8'

services:
  wordpress:
    image: registry.nimahosts.com/nimasystems-public/wordpress-max:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: your_password
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: your_password
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped

  redis:
    image: redis:alpine
    restart: unless-stopped

volumes:
  wordpress_data:
  db_data:
```

### Using WP-CLI

The image includes WP-CLI for managing WordPress from the command line:

```bash
# Access the container
docker exec -it wordpress bash

# Use WP-CLI
wp --info
wp plugin list
wp theme list
wp cache flush
```

## Building

### Build Arguments

- `WORDPRESS_VERSION`: WordPress version (default: 6.9.0)
- `UID`: User ID for the app user (default: 1000)
- `GID`: Group ID for the app user (default: 1000)
- `LIBCURL_VERSION`: libcurl version (default: 4)

### Build Command

```bash
docker build \
  --build-arg WORDPRESS_VERSION=6.9.0 \
  --build-arg UID=1000 \
  --build-arg GID=1000 \
  --target runtime-prod \
  -t wordpress-max:latest .
```

### Multi-stage Build

The Dockerfile uses a multi-stage build process:

1. **build** stage: Compiles PHP extensions
2. **runtime** stage: Sets up the runtime environment with all tools and configurations
3. **runtime-prod** stage: Production-ready image

## Supported Platforms

This image is built for multiple architectures:

- **linux/amd64** - Intel/AMD 64-bit processors
- **linux/arm64** - ARM 64-bit processors (Apple Silicon, AWS Graviton, etc.)

Docker will automatically pull the correct image for your platform.

## CI/CD

Automated builds are configured via GitHub Actions:

- **Triggers**: Push to tags (v*.*.*) or manual workflow dispatch
- **Platforms**: linux/amd64, linux/arm64
- **Registry**: registry.nimahosts.com
- **Features**:
  - Automated versioning
  - BuildKit caching for faster builds
  - Automatic GitHub releases
  - Slack notifications

### Creating a Release

```bash
# Tag a new version
git tag v1.0.0
git push origin v1.0.0

# Or use manual workflow dispatch in GitHub Actions
```

## Directory Structure

```
.
├── .github/
│   └── workflows/
│       └── build.yml          # CI/CD pipeline
├── conf/
│   ├── apache/
│   │   ├── web.conf           # Apache web server config
│   │   └── wordpress-htaccess.conf
│   └── php/
│       ├── php.ini            # Main PHP configuration
│       └── conf.d/
│           ├── apcu.ini       # APCu configuration
│           ├── redis.ini      # Redis configuration
│           └── yaml.ini       # YAML configuration
└── Dockerfile
```

## Security Considerations

- The image runs as a non-root user (UID:GID configurable)
- Regular security updates applied during build
- Includes tools for monitoring and debugging
- Uses official WordPress base image for security updates

## Performance Tuning

The image is optimized for performance with:

- APCu for PHP opcode caching
- Redis support for object caching
- Pre-installed image optimization tools
- Memcached support for session/data caching
- Custom PHP.ini with production settings

## Maintenance

### Updating WordPress Version

Update the `WORDPRESS_VERSION` build argument in the Dockerfile or during build:

```bash
docker build --build-arg WORDPRESS_VERSION=6.10.0 -t wordpress-max:latest .
```

### Updating PHP Extensions

PECL extensions are defined in the build stage. To add new extensions:

1. Add required system dependencies in the build stage
2. Add the extension to the `pecl install` command
3. Copy configuration file to `conf/php/conf.d/`
4. Rebuild the image

## License

This Docker image configuration is maintained by Nima Systems.

## Maintainer

Martin Kovachev <miracle@nimasystems.com>

## Support

For issues, questions, or contributions, please open an issue in the repository.
