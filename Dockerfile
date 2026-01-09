FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    unzip \
    wget \
    curl

# Set working directory
WORKDIR /pb

# Download and install PocketBase
# Update this version as needed: https://github.com/pocketbase/pocketbase/releases
ARG PB_VERSION=0.23.4
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip \
    && unzip pocketbase_${PB_VERSION}_linux_amd64.zip \
    && rm pocketbase_${PB_VERSION}_linux_amd64.zip \
    && chmod +x pocketbase

# Create directories for data persistence
RUN mkdir -p /pb/pb_data /pb/pb_migrations /pb/pb_hooks

# Expose PocketBase port
EXPOSE 8090

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8090/api/health || exit 1

# Start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090"]
