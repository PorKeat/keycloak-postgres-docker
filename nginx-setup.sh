#!/usr/bin/env bash

DOMAIN="keycloak-a8s.cambostack.codes"
EMAIL="alexkgm2412@gmail.com"
CONF_SOURCE="./keycloak.nginx"

is_sourced() {
  [ "${BASH_SOURCE[0]}" != "$0" ]
}

finish() {
  code="${1:-0}"
  if is_sourced; then
    return "$code"
  else
    exit "$code"
  fi
}

run_cmd() {
  "$@"
  code=$?
  if [ $code -ne 0 ]; then
    echo "❌ Failed: $*"
    finish $code
  fi
}

main() {
  echo "🔍 Checking config file..."

  if [ ! -f "$CONF_SOURCE" ]; then
    echo "❌ keycloak.nginx not found"
    finish 1
  fi

  echo "🔍 Checking Nginx..."

  if ! command -v nginx >/dev/null 2>&1; then
    echo "📦 Installing Nginx..."
    run_cmd sudo apt update
    run_cmd sudo apt install -y nginx
  else
    echo "✅ Nginx already installed"
  fi

  echo "🔍 Checking Certbot..."

  if ! command -v certbot >/dev/null 2>&1; then
    echo "📦 Installing Certbot..."
    run_cmd sudo apt install -y certbot python3-certbot-nginx
  else
    echo "✅ Certbot already installed"
  fi

  echo "📁 Detecting config path..."

  if [ -d /etc/nginx/sites-available ]; then
    TARGET="/etc/nginx/sites-available/keycloak"
    ENABLED_TARGET="/etc/nginx/sites-enabled/keycloak"
  else
    TARGET="/etc/nginx/conf.d/keycloak.conf"
    ENABLED_TARGET=""
  fi

  echo "🧹 Cleaning old config..."
  run_cmd sudo rm -f "$TARGET"
  [ -n "$ENABLED_TARGET" ] && run_cmd sudo rm -f "$ENABLED_TARGET"

  echo "📦 Processing keycloak.nginx..."

  TMP_FILE="$(mktemp)"

  # 🔥 Remove broken SSL lines (your previous issue)
  awk '
    !/ssl_certificate / &&
    !/ssl_certificate_key / &&
    !/ssl_dhparam / &&
    !/include \/etc\/letsencrypt\/options-ssl-nginx.conf/ &&
    !/listen 443 ssl/ &&
    !/return 301 https/
  ' "$CONF_SOURCE" > "$TMP_FILE"

  run_cmd sudo cp "$TMP_FILE" "$TARGET"
  rm -f "$TMP_FILE"

  if [ -n "$ENABLED_TARGET" ]; then
    echo "🔗 Enabling site..."
    run_cmd sudo ln -sf "$TARGET" "$ENABLED_TARGET"
  fi

  echo "🧪 Testing Nginx..."
  if ! sudo nginx -t; then
    echo "❌ Nginx config invalid"
    finish 1
  fi

  echo "🔄 Restarting Nginx..."
  run_cmd sudo systemctl enable nginx
  run_cmd sudo systemctl restart nginx

  echo "🔐 Setting up SSL..."
  if ! sudo certbot --nginx \
    -d "$DOMAIN" \
    --non-interactive \
    --agree-tos \
    -m "$EMAIL" \
    --redirect; then
    echo "❌ Certbot failed"
    finish 1
  fi

  echo "✅ DONE"
  echo "🌐 https://$DOMAIN"
}

main