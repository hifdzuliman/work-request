# Multi-stage build for React frontend
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Install curl for health check
RUN apk add --no-cache curl

# Copy built app from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create nginx runtime directories
RUN mkdir -p /run/nginx /var/cache/nginx /var/log/nginx

# Set proper permissions for nginx
RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx /run/nginx /usr/share/nginx/html

# Switch to nginx user (nginx image default user)
USER nginx

# Expose port
EXPOSE 80

# Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f http://178.128.54.249/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
