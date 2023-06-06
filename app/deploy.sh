#!/bin/sh
set -e

cd /var/www

# Enter maintenance mode
php artisan down

# Migrate database
php artisan migrate --force

# Clear cache
php artisan optimize

# Clear config
php artisan config:clear

# generate key
php artisan key:generate

# Exit maintenance mode
php artisan up