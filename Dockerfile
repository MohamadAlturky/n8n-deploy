# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /usr/app

# Install n8n globally using npm (or just rely on npx to download it if not present)
# For npx n8n to work reliably, it's often better to have n8n available globally or locally.
# However, if you truly want npx to download it every time, you can omit the npm install.
# For persistent data, n8n needs to be able to write to its configuration and data directories.
# If you run `npx n8n`, it will usually download n8n into a global cache.
# For better control and persistence, it's often recommended to install n8n explicitly.
# Let's assume you want n8n installed for a more standard setup.
RUN npm install -g n8n@latest

# Expose the port n8n runs on
EXPOSE 5678

# Command to run n8n
# This will execute 'npx n8n' within the container.
# If n8n was installed globally, this will use that installation.
CMD ["n8n"]