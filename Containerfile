# The app on top of the exact ERPNext image RHOS pins (ERPNext 16.37.0, Frappe 16.36.1).
# Built once in CI; the same image is promoted EXP -> TEST -> PROD.
# Keep the base digest in step with erpnext-local/versions.env (Dependabot raises PRs for this line).
FROM frappe/erpnext:v16.55.0@sha256:15a1270f7d8d674de5facd16c3390665a12bd632f5abb846bdd67b61d7461d84

LABEL org.opencontainers.image.source="https://github.com/Ali-Sample/sample-erpnext-custom"

COPY --chown=frappe:frappe . /home/frappe/frappe-bench/apps/sample_erpnext_custom

# ponytail: no `bench build` for assets; the app has no JS/CSS. Add it when the app ships front-end code.
RUN cd /home/frappe/frappe-bench \
 && env/bin/pip install --no-cache-dir -e apps/sample_erpnext_custom \
 && ls -1 apps > sites/apps.txt
