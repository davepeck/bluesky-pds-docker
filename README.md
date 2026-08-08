# bluesky-pds-docker

The [official Bluesky documentation on self-hosting a PDS](https://atproto.com/guides/self-hosting) is a little thin. 

In addition, the [installation instructions](https://github.com/bluesky-social/pds/tree/main?tab=readme-ov-file#self-hosting-pds) make several assumptions that don't quite match my setup.

This repository contains a `Dockerfile` that you can use to get a Bluesky PDS up and running. That container includes the `pdsadmin` command; once it's up and running you can log in to create a Bluesky account.

### Where can I use this?

I happen to use [Dokku](https://dokku.com), a "personal" Heroku clone, to host a variety of low-traffic services on a [tiny cloud server](https://www.hetzner.com). 

You can [read my notes on how to self-host a Bluesky PDS with Dokku](https://davepeck.org/notes/bluesky/self-hosting-a-bluesky-pds-with-dokku/).

In addition to Dokku, this Docker file could also be used to run on Heroku, GCP Cloud Run, AWS Fargate, etc.


### Configuration

You'll need to configure the following environment variables:

- `PDS_HOSTNAME` - the DNS name of your PDS instance. This does _not_ need to match your Bluesky handle. (For instance, my `PDS_HOSTNAME` is `bsky.davepeck.dev` but my Bluesky handle is `@davepeck.org`.)
- `PDS_ADMIN_PASSWORD` - choose your own, or run `openssl rand --hex 16` locally to generate a random password.
- `PDS_JWT_SECRET` - run `openssl rand --hex 16` locally to generate a random secret.
- `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX` - run `openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32` locally to generate this.

To get Bluesky to validate email, you'll want to configure the following two environment variables:

- `PDS_EMAIL_SMTP_URL` - the URL of your SMTP server. For instance, `smtp://[user]:[password]@[smtp-server]:[port]`
- `PDS_EMAIL_FROM_ADDRESS` - the email address from which Bluesky will send email. For instance, `admin@mydomain.com`

If you're using Dokku [with my instructions](https://davepeck.org/notes/bluesky/self-hosting-a-bluesky-pds-with-dokku/), you can configure blobstore as follows:

- `PDS_BLOBSTORE_DISK_LOCATION` - set to `/pds/blocks`

You can also attach to any S3-compatible blobstore as follows:

- `PDS_BLOBSTORE_DISK_LOCATION` - set to `s3://<bucket-name>`

The remainder of the environment variables can take their default values:

```
PDS_DATA_DIRECTORY=/pds
PDS_BLOB_UPLOAD_LIMIT=52428800
PDS_BSKY_APP_VIEW_DID=did:web:api.bsky.app
PDS_BSKY_APP_VIEW_URL=https://api.bsky.app
PDS_CRAWLERS=https://bsky.network
PDS_DID_PLC_URL=https://plc.directory
PDS_REPORT_SERVICE_DID=did:plc:ar7c4by46qjdydhdevvrndac
PDS_REPORT_SERVICE_URL=https://mod.bsky.app
```

(TODO: convince myself that `PDS_DATA_DIRECTORY` only contains ephemeral data, and not configuration or state that needs to be persisted across container restarts. My [Dokku installation instructions](https://davepeck.org/notes/bluesky/self-hosting-a-bluesky-pds-with-dokku/) make the conservative assumption that we _do_ want to persist this data across restarts, by mounting a volume. But if you're using S3 for the blobstore, you might not want to do this.)

### Design and brand considerations

As of August 2026, Bluesky's PDS implementation supports a number of environment variables to customize its branding and visuals. See https://atproto.com/blog/pds-customization-and-metrics for details.

### Notes

What's up with the `pdsadmin` command "variant" included in this repository, you ask?

The [official implementation](https://github.com/bluesky-social/pds/blob/main/pdsadmin.sh) makes two assumptions that don't apply:

1. That there's a `/pds/pds.env` file that contains environment variables. With a Docker container, these should be passed in as environment variables from the outside.

2. That it makes sense to download the latest sub-command implementations from the internet every time the `pdsadmin` command is run. Frankly, I don't really know what's going on here, but I don't want it!

