#!/usr/bin/env bash

set -e

T="$(cd $(dirname $0); pwd)"
INSTALL_DIR="$(pwd)"
export PROJECT_NAME="$1"
shift 1

which direnv
which python
which pyenv

function mkpy_project() {
    name="$1"
    if [ -z "$name" ]; then
        echo "empty name"
        return 1
    fi
    if [ -d "$name" ]; then
        echo "already exists $name"
        return 1
    fi

    mkdir "$1" # create project root
    cd "$1"

    if [ ! -z "$v" ]; then
        pyenv local "$v"
    fi

    python -m venv venv

    cat <<EOF >> .envrc
source venv/bin/activate
EOF
    direnv allow
    venv/bin/python -m pip install --upgrade pip
}

function mk_django(){
    echo 'mk_django'
    pwd
    venv/bin/pip install django
    venv/bin/django-admin startproject "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    echo "PROJECT_NAME=$PROJECT_NAME" > .env
    ../venv/bin/pip freeze > requirements.txt
}


mkpy_project "$PROJECT_NAME"
mk_django

cp "$T/docker-compose.yml" .
cp "$T/Dockerfile" .
cp -r "$T/extra" extra

# bash -c "echo \"$(cat '$T/docker-compose.yml')\"" > docker-compose.yml 

