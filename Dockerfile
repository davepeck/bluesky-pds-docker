# Base image for the PDS service
FROM ghcr.io/bluesky-social/pds:sha-cdc46aae58ce04a2e64dc6487152d026f4b7b92f

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
