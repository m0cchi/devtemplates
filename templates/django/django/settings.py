
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

