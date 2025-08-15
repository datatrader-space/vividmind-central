#!/bin/bash
set -e

echo "Waiting for Postgres..."
until nc -z db 5432; do
  sleep 0.5
done
echo "Postgres is ready."

echo "Waiting for Redis..."
until nc -z redis 6379; do
  sleep 0.5
done
echo "Redis is ready."

echo "Running makemigrations..."
python manage.py makemigrations customer
python manage.py makemigrations sessionbot
python manage.py makemigrations creator

echo "Running migrate..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."
exec gunicorn vividmind.wsgi:application --bind 0.0.0.0:8000 --workers 1
