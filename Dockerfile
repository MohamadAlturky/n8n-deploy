# Stage 1: Build dependencies (if any, otherwise just install n8n)
# Using a Node.js base image
FROM node:18-alpine AS build

# Set a working directory inside the container
WORKDIR /usr/src/app

# Install n8n globally
# This command downloads and installs n8n and all its required Node.js packages.
RUN npm install -g n8n@latest

# Stage 2: Production image
FROM node:18-alpine

# Set environment variables for n8n
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV N8N_DATA_FOLDER=/home/node/.n8n
ENV N8N_CONFIG_FILES_FOLDER=/home/node/.n8n
# N8N_CONFIG_FILES_FOLDER is often the same as N8N_DATA_FOLDER

WORKDIR /home/node

# Copy n8n and its global dependencies from the build stage
# This ensures that n8n is available in the final, smaller image.
COPY --from=build /usr/local/lib/node_modules/n8n /usr/local/lib/node_modules/n8n
COPY --from=build /usr/local/bin/n8n /usr/local/bin/n8n

# Create the N8N_DATA_FOLDER and ensure the 'node' user owns it.
# The 'node' user and group already exist in the node:18-alpine base image.
RUN mkdir -p ${N8N_DATA_FOLDER} \
    && chown -R node:node ${N8N_DATA_FOLDER} \
    && chown -R node:node /usr/local/lib/node_modules/n8n \
    && chown -R node:node /usr/local/bin/n8n

# Switch to the 'node' user to run the application with less privileges
USER node

# Expose the port n8n runs on
EXPOSE ${N8N_PORT}

# Command to run n8n
CMD ["n8n", "start", "--tunnel"]