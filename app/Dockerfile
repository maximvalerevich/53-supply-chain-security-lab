# Hardened Node.js Alpine image
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy package files first for layer caching
COPY package*.json ./

# Install dependencies (production only)
RUN npm install --omit=dev && \
    npm cache clean --force

# Copy application source
COPY --chown=nodejs:nodejs server.js ./

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/healthz', (r) => process.exit(r.statusCode === 200 ? 0 : 1))" || exit 1

# Run the server
CMD ["node", "server.js"]
