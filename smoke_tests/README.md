# Tax Tribunals Downloader Smoke Tests

These are **NOT** standard cucumber features and should not be treated
as such.  They are a set of simple features used to smoke test the
application stack in various 'real' enviroments. They will not work
locally, nor will they work against the docker-container stack.

## Running

```
export DOWNLOADER_URI=https://tax-tribunals-downloader-dev.dsd.io
export SMOKETEST_USER=<MOJ SSO TT downloader smoke test user>
export SMOKETEST_PASSWORD=<MOJ SSO TT downloader smoke test user password>
bundle exec cucumber
```

### Running on CI

The script for running the Docker container on MoJ's CI is as follows:

```bash
#!/bin/bash

set -euo pipefail

docker-compose -f docker-compose-smoketests.yml up
```
