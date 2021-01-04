#!/usr/bin/env bash


set -e
trap 'echo "Error"' ERR

which direnv

ls node_modules/ > /dev/null

cat <<EOF > .envrc
export PATH="$(pwd)/node_modules/.bin:\$PATH"
EOF
direnv allow

