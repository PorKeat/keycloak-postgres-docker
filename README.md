# Keycloak + Postgres (Docker)

## Setup

```bash
mkdir -p secrets
echo "your_postgres_password" > secrets/postgres_password.txt
echo "your_admin_username" > secrets/kc_admin_user.txt
echo "your_admin_password" > secrets/kc_admin_password.txt

chmod 600 secrets/*
chmod 700 secrets
```

---

## Load env

```bash
export POSTGRES_PASSWORD=$(cat secrets/postgres_password.txt)
export KC_ADMIN=$(cat secrets/kc_admin_user.txt)
export KC_ADMIN_PASSWORD=$(cat secrets/kc_admin_password.txt)
```

---

## Run

```bash
docker compose up -d
```

---

## Access

```
https://keycloak-a8s.cambostack.codes
```