#!/bin/bash

set -ex

REPO='jjlin/edg-epub-mobi'
REPO_URL="https://github.com/${REPO}.git"
UPSTREAM_REPO='elasticsearch-definitive-guide'

# We should enter the build container in /root.
if [[ "${PWD}" != "/root" ]]; then
    echo "WARNING: unexpected working directory '$(pwd)'"
fi

# If running under Travis CI, the source repo should have been cloned to
# `/home/travis/build/${REPO}` and mounted into the container at
# `/root/${REPO}`.
#
# Otherwise, the source repo hasn't been cloned yet, so do that here.
if [[ ! -d "${REPO}" ]]; then
    git clone "${REPO_URL}" "${REPO}"
fi

# Change into the source repo dir.
cd "${REPO}"

# Clone the `elasticsearch-definitive-guide` submodule.
git submodule update --init --remote
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to clone '${UPSTREAM_REPO}' submodule"
    exit 1
fi
COMMIT=$(cd ${UPSTREAM_REPO} && git rev-parse --short=8 HEAD)

# Build EPUB version.
# The output file has the same basename as the input file (book.asciidoc).
a2x --doctype=book --format=epub --destination-dir=. --verbose \
    ./${UPSTREAM_REPO}/book.asciidoc

# Build Mobi version.
ebook-convert book.epub book.mobi

# Prepare for deployment to GitHub Pages.
export EPUB_FILE=edg-${COMMIT}.epub
export MOBI_FILE=edg-${COMMIT}.mobi
mv book.epub gh-pages/edg-${COMMIT}.epub
mv book.mobi gh-pages/edg-${COMMIT}.mobi
cd gh-pages
envsubst '${EPUB_FILE} ${MOBI_FILE}' < index.template.html > index.html
rm index.template.html
