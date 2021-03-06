#/usr/bin/env bash

set -e

L="$(cd $(dirname $0); pwd)"

cd $APP_DIR

bash "$L/init.sh"

python /usr/local/extra/wait_for_tcp.py db 5432 180

python manage.py migrate
python manage.py runserver 0.0.0.0:8080

