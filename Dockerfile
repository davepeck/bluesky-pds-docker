# Base image for the PDS service
FROM ghcr.io/bluesky-social/pds:sha-6511fcbe0eb7e94939527a62b35414a361eb2080

# Install necessary packages to support the pdsadmin.sh scripts
RUN apk update && apk add --no-cache bash curl openssl jq util-linux

# Copy our slightly modified variants of the pdsadmin scripts
# You can run these as /app/pdsadmin.sh <command> <args>
# For instance, to create a new account, you can run:
#
# /app/pdsadmin.sh account create
#
# You can get an invite with:
#
# /app/pdsadmin.sh create-invite-code
WORKDIR /app
COPY pdsadmin.sh .
COPY pdsadmin/ ./pdsadmin/

# Command to start the PDS service
CMD ["node", "--enable-source-maps", "index.js"]
