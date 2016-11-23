# Tax Tribunals Downloader

## ENV variables

Tax Tribunal Downloader requires several environment variables to be set
in order to run:

### BUCKET_NAME

The S3 bucket where the uploads will be stored.

### USER_BUCKET_NAME

The S3 bucket where user sessions are persisted.

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

### NOTE REGARDING AWS CREDENTIALS

Credentials are not required if the downloader is run within AWS.
Permissions are handled by IAM roles.  If you need to test the app
locally, it will automatically use `ENV['AWS_ACCESS_KEY_ID']` and
`ENV['AWS_SECRET_ACCESS_KEY']` if they are set.  They **should not** be
set in the production environment.

## Testing

To set the required environment variables for testing, just copy
`.env.example` to `.env` and run your tests.  It uses the `dotenv` gem,
which is setup and scoped to `spec_helper.rb`, which keeps it from
polluting the other environments.  See the note regarding AWS
credentials, above, as well.

## Development

It is easiest to work on this app against a locally running copy of
`moj-sso`.  The `.env.example` already has settings for doing this with
a copy of `moj-sso` running on port 5000 of your localhost.  Once you
have set up `moj-sso`, you will need to create an appropriate role to
associate with your app (`.env.example` assumes `viewer`) and add users.
Follow the directions on the `moj-sso` repo to do so.
