# sales-dbt

Welcome to the `sales-dbt` repository. This repo is the home for our dbt transformation logic, documentation, tests, and analytics models. It is intended for members of the data team and any stakeholders who are contributing to our dbt workflow.

## Purpose

This README explains how to set up the dbt project locally, connect it to a warehouse, run dbt commands, and contribute safely.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Repository layout](#repository-layout)
3. [Local setup](#local-setup)
4. [Configuring dbt profiles](#configuring-dbt-profiles)
5. [Common dbt commands](#common-dbt-commands)
6. [Development workflow](#development-workflow)
7. [Testing and validation](#testing-and-validation)
8. [Documentation](#documentation)
9. [Git and PR best practices](#git-and-pr-best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you start, make sure you have the following installed:

- `git`
- `python` 3.10 or newer
- `pip` or a Python package manager such as `pipenv`, `poetry`, or `venv`
- dbt core and the dbt adapter for your warehouse (for example `dbt-postgres`)
- A supported SQL warehouse or database account available for development
- A code editor such as VS Code with SQL/dbt extensions

> Note: If your team uses a shared local warehouse environment, follow the team-specific instructions for that environment.

---

## Repository layout

A dbt repo normally includes these folders and files:

- `dbt_project.yml` — dbt project configuration
- `models/` — SQL models and model directories
- `macros/` — reusable macros and helpers
- `tests/` — custom test SQL and dbt-specific tests
- `data/` — seed CSV files for dbt `seed`
- `analysis/` — optional ad hoc analysis
- `docs/` — documentation assets if present
- `packages.yml` — dbt package dependencies
- `profiles.yml` is not stored here; it lives in the user home directory (`~/.dbt/profiles.yml`)

> In this repo, the current visible files are `README.md` and `store_S002.csv`. If the project is missing expected dbt folders, please talk to the data lead before adding models.

---

## Local setup

Use a Python virtual environment to isolate dbt dependencies.

### 1. Clone the repo

```bash
git clone <repo-url> sales-dbt
cd sales-dbt
```

### 2. Create and activate a virtual environment

```bash
python -m venv .venv
source .venv/bin/activate
```

### 3. Install dbt dependencies

If your repo provides a `requirements.txt`, install from it. Otherwise, install dbt core and your adapter directly.

```bash
pip install --upgrade pip
pip install dbt-core dbt-postgres
```

If your team uses a different warehouse adapter, replace `dbt-postgres` with the correct adapter package.

### 4. Verify dbt installation

```bash
dbt --version
```

You should see output that includes `dbt-core` and the adapter package.

---

## Configuring dbt profiles

dbt stores connection configuration in `~/.dbt/profiles.yml`.

### Example `profiles.yml`

Create or update `~/.dbt/profiles.yml` with a profile matching this project name.

```yaml
sales_dbt:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5433
      user: pipeline
      password: pipeline_secret
      dbname: mandera_warehouse
      schema: analytics
      threads: 1
      keepalives_idle: 0
```

> Adjust the host, port, user, password, dbname, schema, and profile name to match your local or shared environment.

### Using environment variables

For security, prefer environment variables in `profiles.yml`:

```yaml
sales_dbt:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5433
      user: '{{ env_var("DBT_USER") }}'
      password: '{{ env_var("DBT_PASSWORD") }}'
      dbname: '{{ env_var("DBT_DBNAME") }}'
      schema: '{{ env_var("DBT_SCHEMA") }}'
      threads: 1
```

Then set these variables locally:

```bash
export DBT_USER=pipeline
export DBT_PASSWORD=pipeline_secret
export DBT_DBNAME=mandera_warehouse
export DBT_SCHEMA=analytics
```

---

## Common dbt commands

Run these from the project root.

### Check configuration

```bash
dbt debug
```

### Install package dependencies

```bash
dbt deps
```

### Compile models

```bash
dbt compile
```

### Run models

```bash
dbt run
```

Run a single model or directory:

```bash
dbt run --select path:models/staging
```

### Run tests

```bash
dbt test
```

Run tests for a specific model:

```bash
dbt test --select model_name
```

### Seed data

If the project includes seed files in `data/`:

```bash
dbt seed
```

### Generate documentation

```bash
dbt docs generate
```

Serve docs locally:

```bash
dbt docs serve
```

### View compiled SQL

```bash
dbt compile --select <model_name>
```

### Dry-run SQL parsing

```bash
dbt parse
```

---

## Development workflow

Follow these steps when contributing to the dbt repo.

1. Create a feature branch from `main`:
   ```bash
git checkout main
git pull origin main
git checkout -b feature/<short-description>
```
2. Add or update models in `models/`.
3. Add schema tests in `schema.yml` or model-specific YAML files.
4. Add documentation descriptions for new models and columns.
5. Run `dbt run` locally for the changed models.
6. Run `dbt test` for the models and tests you changed.
7. Commit with a clear message and push your branch.
8. Create a pull request and request review.

### Branch naming

Use a descriptive branch name, for example:

- `feature/add-customer-funnel-model`
- `fix/order-date-test`
- `docs/update-sales-model-description`

### What to commit

- SQL model changes
- YAML test/schema updates
- docs blocks, descriptions, and meta tags
- new macros only when needed
- package dependency changes in `packages.yml`

---

## Testing and validation

Before opening a PR, ensure the following:

- `dbt debug` passes
- `dbt run --select <changed models>` passes
- `dbt test --select <changed models>` passes
- Documentation compiles successfully with `dbt docs generate`

If possible, run the full model set for your changed domain to catch cross-model issues.

---

## Documentation

We use dbt docs to document models, sources, and columns.

- Add model descriptions in YAML files.
- Add source definitions and freshness expectations if sources are defined.
- Use `meta:` for domain-specific tags or ownership fields.
- Keep descriptions short, clear, and business-oriented.

Example:

```yaml
models:
  - name: orders
    description: "Order header facts for each customer order"
    columns:
      - name: order_id
        description: "Unique order identifier"
      - name: customer_id
        description: "Customer id linking to the customers model"
```

---

## Git and PR best practices

- Keep PRs focused on one domain or feature.
- Include a short summary of what changed and why.
- Reference related tickets or issues in the PR description.
- Link to any docs or design notes if the change is complex.
- Ask at least one other data team reviewer for a review.
- Squash or clean up local history before merging if needed.

### Review checklist

- Does the code run locally?
- Are new models documented?
- Are tests added or updated?
- Does the PR include only relevant files?
- Are package dependencies reasonable?

---

## Troubleshooting

### `dbt debug` fails

- Verify `~/.dbt/profiles.yml` profile name matches `dbt_project.yml` if applicable.
- Confirm database host, port, user, password, and schema are correct.
- Confirm the target database is running and accessible.

### Model compilation or runtime errors

- Run `dbt compile` to inspect generated SQL.
- Use `dbt run --select <model_name>` to isolate the failing model.
- Check schema names, column names, and upstream dependencies.

### Test failures

- Use `dbt test --select <model_name>` to reproduce.
- Inspect the failing test in the compiled SQL located under `target/compiled`.
- Fix the logic or add coverage as needed.

### Missing dbt model directories

If the repo is missing `models/`, `macros/`, or other expected dbt folders, confirm whether this repo is the intended dbt project root or whether the project content is stored in another branch or location.

---

## Support

If you need help, ask a data team lead or open an issue with:

- your current branch name
- the command you ran
- the exact error output
- the dbt version from `dbt --version`

---

## Notes

This repo is intended to be the source of truth for our dbt transformations. Keep it tidy, documented, and runnable locally so every contributor can make changes with confidence.
