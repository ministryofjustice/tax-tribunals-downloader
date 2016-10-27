# Tax Tribunals Downloader

## ENV variables

Tax Tribunal Downloader requires several environment variables to be set
in order to run:


### ACCESS_KEY_ID

The AWS access key.

### SECRET_ACCESS_KEY

The AWS secret access key.

### BUCKET_NAME

The S3 bucket where the uploads will be stored.

### MOJSSO_ID

The access key for the MoJ Single Sign On server (MOJ SSO).

### MOJSSO_SECRET

The secret key for the MOJ SSO.

### MOJSSO_URL

The URI of the MOJ SSO.

### MOJSSO_ORG

The orgainisation given sign on rights on the MOJ SSO.

### MOJSSO_ROLE

The role given permission to download documents on the MOJ SSO.

### MOJSSO_CALLBACK_URI

The full URI, including path, of the callback endpoint the Tax Tribunal
Downloader app (the path should normally be `/oauth/callback`).

### MOJSSO_TOKEN_REDIRECT_URI

A callback parameter required by the OAuth2 `get_token` method.  It does
not have any application here, but is otherwise required.

## Testing

To set the required environment variables for testing, just copy
`.env.example` to `.env` and run your tests.  It uses the `dotenv` gem,
which is setup and scoped to `spec_helper.rb`, which keeps it from
polluting the other environments.
