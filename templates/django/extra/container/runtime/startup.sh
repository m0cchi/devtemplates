#/usr/bin/env bash

set -e
cd $APP_DIR

pip install -r requirements.txt
pip install -r requirements-runtime.txt

python /usr/local/extra/wait_for_tcp.py db 5432 180

python manage.py migrate
python manage.py runserver 0.0.0.0:8080

