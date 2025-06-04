# Stage 1: Build n8n
FROM node:18-alpine AS build

WORKDIR /usr/src/app

# Install n8n globally and its dependencies
# Use n8n-alpine as a base for a smaller image if available,
# otherwise, directly install n8n from npm.
# For simplicity and broad compatibility, we'll install from npm here.
COPY package.json package-lock.json ./
RUN npm install

# Copy n8n source code (if you're building from source or have custom additions)
# If you are using the official n8n npm package, this step might not be strictly necessary
# as npm install would handle it. However, if you are cloning n8n's repo, you would copy it here.
# For a standard deployment, the 'npm install n8n' approach is more common.
# If you are cloning n8n repo uncomment the following lines:
# COPY . .
# RUN npm install --production --ignore-scripts --prefer-offline

# Install n8n if not building from source
RUN npm install -g n8n@latest

# Stage 2: Production image
FROM node:18-alpine

# Set environment variables for n8n
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV N8N_DATA_FOLDER=/home/node/.n8n
ENV N8N_CONFIG_FILES_FOLDER=/home/node/.n8n

WORKDIR /home/node

# Copy n8n from the build stage or install it directly if not multi-stage copying
# If you installed globally in the build stage, it will be available.
# Otherwise, you would install it again here.
# Assuming global installation in build stage:
# RUN npm install -g n8n@latest # Only if you didn't install globally in stage 1

# If you want to use the build stage for smaller final image
COPY --from=build /usr/local/lib/node_modules/n8n /usr/local/lib/node_modules/n8n
COPY --from=build /usr/local/bin/n8n /usr/local/bin/n8n

# Create a dedicated user and group for n8n to run with less privileges
RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && mkdir -p ${N8N_DATA_FOLDER} \
    && chown -R node:node ${N8N_DATA_FOLDER} \
    && chown -R node:node /usr/local/lib/node_modules/n8n \
    && chown -R node:node /usr/local/bin/n8n

USER node

# Expose the port n8n runs on
EXPOSE ${N8N_PORT}

# Command to run n8n
CMD ["n8n", "start", "--tunnel"]