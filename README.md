# sample_erpnext_custom

A sample Frappe app for the Ali-Sample sandbox, standing in for RHOS's custom app.
**Placeholder data only.** Built on ERPNext 16.37.0 / Frappe 16.36.1 (see `Containerfile`).

| Path | What it is |
|---|---|
| `sample_erpnext_custom/hooks.py` | App metadata, `required_apps`, the fixtures filter |
| `sample_erpnext_custom/fixtures/` | Customisations shipped with the app (Module = Sample ERPNext Custom) |
| `sample_erpnext_custom/tests/` | Tests run on a fresh site in CI |
| `docs/models/processes.yaml` | Made-up process map: every change and defect names a `stream/process/step` from it |
| `Containerfile` | The app on the pinned ERPNext image; built once, promoted EXP → TEST → PROD |

## The rule

Never edit ERPNext's or Frappe's own files. Customise in the desk with **Module = Sample ERPNext Custom**,
then export:

```bash
bench --site <site> export-fixtures --app sample_erpnext_custom
```

## Build the image locally

```bash
docker build -f Containerfile -t sample-erpnext-custom:local .
```

## License

MIT
