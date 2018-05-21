#!/bin/bash

set -x

REPO='jjlin/edg-epub-mobi'
REPO_URL="https://github.com/${REPO}.git"

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

# Build EPUB version.
# The output file has the same basename as the input file (book.asciidoc).
a2x --doctype=book --format=epub --destination-dir=. --verbose \
    ./elasticsearch-definitive-guide/book.asciidoc

# Build Mobi version.
ebook-convert book.epub book.mobi

# Rename `book.<ext>` to `edg.<ext>`.
for f in book.{epub,mobi}; do
    mv ${f} edg.${f##*.}
done
