# Tax Tribunals Downloader

[![Build
Status](https://travis-ci.org/ministryofjustice/tax-tribunals-downloader.svg?branch=master)](https://travis-ci.org/ministryofjustice/tax-tribunals-downloader)


## Running Locally

Once env variables are set up:
`rackup config.ru`

## ENV variables

Tax Tribunal Downloader requires several environment variables to be set
in order to run:

### CLOUD STORAGE

## AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_ACCESS_KEY
 The Blob Storage container where the uploads will be stored.
 
You will need to get credentials from the [azure portal](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/tt_stg_taxtribunalsazure_resource_group/providers/Microsoft.Storage/storageAccounts/stgttfilestore/containersList)

## FILES_CONTAINER_NAME and USER_CONTAINER_NAME

Enter the container names provided or create new containers in the Azure Portal [container list](https://portal.azure.com/#@HMCTS.NET/resource/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/tt_stg_taxtribunalsazure_resource_group/providers/Microsoft.Storage/storageAccounts/stgttfilestore/containersList)

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

### SENTRY_DSN

Only needed in production environments to report unhandled exceptions to Sentry.
If variable is not set, Sentry reporting will be disabled.

### Note on Azure Storage Credentials

They are picked up automatically by the `azure-storage-blob` gem if you use the environment
variables set in `env.example`.

## Testing

To set the required environment variables for testing, just copy
`.env.example` to `.env` and run your tests. It uses the `dotenv` gem,
which is setup and scoped to `spec_helper.rb`.  See the note regarding Azure
credentials, above, as well.

## Development

It is easiest to work on this app against a locally running copy of
`moj-sso`.  The `.env.example` already has settings for doing this with
a copy of `moj-sso` running on port 5000 of your localhost.  Once you
have set up `moj-sso`, you will need to create an appropriate role to
associate with your app (`.env.example` assumes `viewer`) and add users.
Follow the directions on the `moj-sso` repo to do so.
