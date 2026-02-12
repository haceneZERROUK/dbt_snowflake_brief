
# 🚕 NYC Taxi Data Pipeline

> Pipeline dbt + Snowflake pour analyser 15M+ trajets de taxis NYC

---

## 🎯 Quick Start

### 1. Setup Snowflake

```sql
-- Exécuter en ACCOUNTADMIN
CREATE DATABASE NYC_TAXI_DB;
CREATE SCHEMA NYC_TAXI_DB.RAW;
CREATE SCHEMA NYC_TAXI_DB.STAGING;
CREATE SCHEMA NYC_TAXI_DB.FINAL;

CREATE WAREHOUSE NYC_TAXI_WH WAREHOUSE_SIZE='X-SMALL' AUTO_SUSPEND=60;
CREATE ROLE TRANSFORM;
CREATE USER dbt DEFAULT_ROLE='TRANSFORM' DEFAULT_WAREHOUSE='NYC_TAXI_WH';
GRANT ROLE TRANSFORM TO USER dbt;

-- Droits
GRANT USAGE, OPERATE ON WAREHOUSE NYC_TAXI_WH TO ROLE TRANSFORM;
GRANT USAGE ON DATABASE NYC_TAXI_DB TO ROLE TRANSFORM;
GRANT USAGE ON SCHEMA NYC_TAXI_DB.RAW TO ROLE TRANSFORM;
GRANT SELECT ON ALL TABLES IN SCHEMA NYC_TAXI_DB.RAW TO ROLE TRANSFORM;
GRANT USAGE, CREATE TABLE, CREATE VIEW ON SCHEMA NYC_TAXI_DB.STAGING TO ROLE TRANSFORM;
GRANT USAGE, CREATE TABLE, CREATE VIEW ON SCHEMA NYC_TAXI_DB.FINAL TO ROLE TRANSFORM;
```

### 2. Configurer dbt

Créer `~/.dbt/profiles.yml` :

```yaml
NYC_TAXI:
  outputs:
    dev:
      type: snowflake
      account: VOTRE_ACCOUNT
      user: dbt
      password: VOTRE_PASSWORD
      role: TRANSFORM
      database: NYC_TAXI_DB
      warehouse: NYC_TAXI_WH
      schema: DBT_DEV
      threads: 4
```

### 3. Exécuter

```bash
pip install dbt-snowflake
dbt debug
dbt run
dbt test
dbt docs serve
```

---

## 📊 Architecture

```
RAW.yellow_taxi_trips
    ↓
STAGING.stg_yellow_taxi_trips (nettoyage + calculs)
    ↓
STAGING.clean_trips
    ↓
FINAL.daily_summary | zone_analysis | hourly_patterns
```

---

## 📁 Modèles

| Table | Description |
|-------|-------------|
| `stg_yellow_taxi_trips` | Nettoyage + enrichissement (durée, vitesse, % tip) |
| `clean_trips` | Table nettoyée |
| `daily_summary` | KPIs par jour |
| `zone_analysis` | Analyse par zone |
| `hourly_patterns` | Patterns horaires |

---

## 🧪 Commandes

```bash
dbt run                      # Tout exécuter
dbt run --select staging     # Seulement staging
dbt test                     # Tests qualité
dbt docs generate            # Doc
```

---

## 🔄 CI/CD

GitHub Actions : auto-deploy sur push `main`

**Secrets requis :**
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PASSWORD`

---

## 📈 Résultats

✅ 84% des données conservées  
✅ 5 modèles dbt  
✅ 8 tests qualité  
✅ Pipeline automatisé  
# dbt_snowflake_brief
