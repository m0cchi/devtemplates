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
    cd "$INSTALL_DIR"
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
    cd "${INSTALL_DIR}/${PROJECT_NAME}"
    echo 'mk_django'
    pwd
    venv/bin/pip install django
    venv/bin/django-admin startproject "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    echo "PROJECT_NAME=$PROJECT_NAME" > .env
    ../venv/bin/pip freeze > requirements.txt
    : > requirements-runtime.txt
    echo psycopg2 >> requirements-runtime.txt
    : > requirements-dev.txt
    echo psycopg2-binary >> requirements-dev.txt
}

function injection_postgres_settings(){
    cd "${INSTALL_DIR}/${PROJECT_NAME}/${PROJECT_NAME}"
    cat <<EOF >> "${PROJECT_NAME}/settings.py"

import os

DB_USER = os.environ.get('DB_USER', '$PROJECT_NAME')
DB_PASSWORD = os.environ.get('DB_PASSWORD', '${PROJECT_NAME}0')
DB_HOST = os.environ.get('DB_HOST', 'db')
DB_PORT = int(os.environ.get('DB_PORT', '5432'))
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': '$PROJECT_NAME',
        'USER': DB_USER,
        'PASSWORD': DB_PASSWORD,
        'HOST': DB_HOST,
        'PORT': DB_PORT,
    }
}

EOF
}


mkpy_project "$PROJECT_NAME"
mk_django
injection_postgres_settings

cp "$T/docker-compose.yml" .
cp "$T/Dockerfile" .
cp -r "$T/extra" extra

# bash -c "echo \"$(cat '$T/docker-compose.yml')\"" > docker-compose.yml 

