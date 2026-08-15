#!/usr/bin/env bash
exec gunicorn --chdir backend app:app --bind 0.0.0.0:${PORT:-5000}
