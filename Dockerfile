# Base image with necessary tools
FROM node:18-alpine AS base
RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR /usr/src/app

# Install dependencies in a separate layer
COPY package*.json ./
RUN npm install

# Build stage
FROM base AS builder
WORKDIR /usr/src/app
COPY . .
RUN npm run build

# Production stage
FROM base AS production
WORKDIR /usr/src/app

# Set environment to production
ENV NODE_ENV=production

# Copy only necessary files from builder
COPY --from=builder /usr/src/app/.next ./.next
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package.json ./package.json

# Add a user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Expose port 3000
EXPOSE 3000

# Start the application in production mode
CMD ["npm", "start"]

# development stage
FROM base AS development
ENV NODE_ENV=development
RUN npm install 
COPY . .
CMD ["npm", "run" ,"dev"]