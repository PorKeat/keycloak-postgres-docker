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

Here’s the **short + clean version** 👇

---

# Keycloak Theme Install (v26.3.1)

## 1. Build Theme (Local)

```bash
yarn build-keycloak-theme
```

Output:

```text
dist_keycloak/keycloak-theme-for-kc-all-other-versions.jar
```

---

## 2. Copy to Server

```bash
scp dist_keycloak/keycloak-theme-for-kc-all-other-versions.jar \
alexkgm2412@YOUR_SERVER_IP:/home/alexkgm2412/
```

---

## 3. Copy to Container

```bash
ssh alexkgm2412@YOUR_SERVER_IP

docker cp /home/alexkgm2412/keycloak-theme-for-kc-all-other-versions.jar \
keycloak:/opt/keycloak/providers/
```

---

## 4. Build & Restart

```bash
docker exec keycloak /opt/keycloak/bin/kc.sh build
docker restart keycloak
```

---

## 5. Enable Theme

```text
Realm Settings → Themes → Login Theme → keycloakify-starter
```

---

## Important

* Use: `/opt/keycloak/providers`
* Do NOT use: `/themes`
* `.jar` = provider, not a theme folder

---

# (Optional) Persistent Setup

```bash
mkdir -p keycloak/providers
cp keycloak-theme.jar keycloak/providers/
```

```yaml
volumes:
  - ./keycloak/providers:/opt/keycloak/providers
```

```bash
docker compose exec keycloak /opt/keycloak/bin/kc.sh build
docker compose restart keycloak
```

---

# Flow

```text
Local → Server → Container → Build → Restart → Enable
```
