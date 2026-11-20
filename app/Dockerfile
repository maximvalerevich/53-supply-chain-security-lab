# Hardened Node.js Alpine image (remove npm/npx/corepack to eliminate unused CLI CVE surface)
FROM node:22-alpine

# Upgrade base OS packages and strip unused package managers from runtime image
RUN apk upgrade --no-cache && \
    rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/lib/node_modules/corepack \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /usr/local/bin/corepack

# Set working directory
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy application source (zero external npm dependencies)
COPY --chown=nodejs:nodejs package.json server.js ./

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/healthz', (r) => process.exit(r.statusCode === 200 ? 0 : 1))" || exit 1

# Run the server
CMD ["node", "server.js"]
