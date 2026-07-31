#!/bin/sh
set -e

echo "En attente de la base de données PostgreSQL (${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432})..."
until python - <<'PYEOF'
import os
import socket
import sys

host = os.environ.get("POSTGRES_HOST", "db")
port = int(os.environ.get("POSTGRES_PORT", "5432"))

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(1)
try:
    sock.connect((host, port))
except OSError:
    sys.exit(1)
finally:
    sock.close()
PYEOF
do
  sleep 1
done

echo "Base de données disponible. Application des migrations..."
python manage.py migrate --noinput

echo "Démarrage du serveur de développement Django..."
exec python manage.py runserver 0.0.0.0:8000
