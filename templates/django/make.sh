#!/usr/bin/env bash

set -e

T="$(cd $(dirname $0); pwd)"
INSTALL_DIR="$(pwd)"
export PROJECT_NAME="$1"
shift 1

which direnv
which python
which pyenv

function eval_template(){
    bash -c "echo \"$(cat $1)\""
}

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
    source venv/bin/activate
    python -m pip install --upgrade pip
    python -m pip install poetry
}

function mk_django(){
    cd "${INSTALL_DIR}/${PROJECT_NAME}"
    echo 'mk_django'
    pwd
    pip install django
    django-admin startproject "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    echo "PROJECT_NAME=$PROJECT_NAME" > .env
    poetry init --name "$PROJECT_NAME" --description 'web application' \
           --dependency django \
           --dev-dependency  psycopg2-binary \
           --dev-dependency  isort \
           --dev-dependency  flake8 \
           --dev-dependency  yapf \
           $(:)

    poetry add -E runtime psycopg2 # --lock --optional
    poetry install
}

function injection_postgres_settings(){
    cd "${INSTALL_DIR}/${PROJECT_NAME}/${PROJECT_NAME}"
    echo "$T/django/core_models.py"
    eval_template "$T/django/settings.py" >> "${PROJECT_NAME}/settings.py"
}

function mk_core_app(){
    echo "mk_core_app"
    cd "${INSTALL_DIR}/${PROJECT_NAME}/${PROJECT_NAME}"
    python manage.py startapp core
    eval_template  "$T/django/core_models.py" >> "core/models.py"
}


mkpy_project "$PROJECT_NAME"
mk_django
injection_postgres_settings
mk_core_app

cd "${INSTALL_DIR}/${PROJECT_NAME}/${PROJECT_NAME}"

cp "$T/docker-compose.yml" .
cp "$T/Dockerfile" .
cp -r "$T/extra" extra
cp "$T/style.yapf" .style.yapf
