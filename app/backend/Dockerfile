# Using Node.js 20 Alpine for a small secure image
# Alpine reduces attack surface compared to full Debian image
# This supports Zero Trust by minimising the container footprint
FROM node:20-alpine

# Create non-root user for running the application
# Running as non-root is a security best practice and
# supports Zero Trust REQ-NCA-P3-06
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy package files first to leverage Docker layer caching
# If dependencies have not changed this layer is reused
COPY src/package*.json ./

RUN npm install --production

# Copy application code
COPY src/ .

# Switch to non-root user
USER appuser

EXPOSE 3000

CMD ["node", "index.js"]