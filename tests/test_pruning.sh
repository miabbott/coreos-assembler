#!/bin/bash
set -xeuo pipefail

# This test isn't standalone for now. It's executed from the `.cci.jenkinsfile`.
# It expects to be running in cosa workdir where a single fresh build was made.

# Test that first build has been pruned; create a few builds for testing.
# FIXME: Add env COSA_BUILD_DUMMY=true or something since this test is very
# expensive in CI; or better add `cosa build --shortcut=overrides` or so.
cosa build ostree --force-image
cosa build ostree --force-image
cosa build ostree --force-image
jq -e '.builds|length == 3' builds/builds.json
jq -e '.builds[2].id | endswith("0-1")' builds/builds.json

# Test pruning latest via explicit buildid
latest="$(readlink builds/latest)"
cosa prune --prune="${latest}"
# And validate it
cosa meta --get ostree-version>/dev/null
# Another build to get back to previous state
cosa build ostree --force-image

# Test --skip-prune
cosa build ostree --force-image --skip-prune
jq -e '.builds|length == 4' builds/builds.json
jq -e '.builds[3].id | endswith("0-1")' builds/builds.json

# Test prune --dry-run
cosa prune --dry-run
jq -e '.builds|length == 4' builds/builds.json
jq -e '.builds[3].id | endswith("0-1")' builds/builds.json

# Test --keep-last-n=0 skips pruning
cosa prune --keep-last-n=0
jq -e '.builds|length == 4' builds/builds.json
jq -e '.builds[3].id | endswith("0-1")' builds/builds.json

# Test prune --keep-last-n=1
cosa prune --keep-last-n=1
jq -e '.builds|length == 1' builds/builds.json
jq -e '.builds[0].id | endswith("0-4")' builds/builds.json
