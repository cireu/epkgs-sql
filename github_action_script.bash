#!/usr/bin/env bash

cd main || exit 1

SOURCE="../epkgs/epkg.sqlite"
DIST="epkg.sql"

test -f "${SOURCE}" || exit 1

git config --local user.email "action@github.com"
git config --local user.name "Github Action"
git remote set-url origin "https://${GH_TOKEN}@github.com/${GITHUB_REPOSITORY}"

sudo apt-get install sqlite3

# Workaround: sqlite3 dump does nothing for PRAGMAs, but user_version
# is needed for epkg to verify the database.
USER_VERSION=$(sqlite3 "${SOURCE}" "PRAGMA user_version;")
echo "PRAGMA user_version=${USER_VERSION};" > "${DIST}"
sqlite3 "${SOURCE}" .dump >> "${DIST}"

git add "${DIST}"

# If something changed, push.
git commit -m "Sync from https://github.com/emacsmirror/epkgs" && \
    git push --quiet
