# The app on top of the exact ERPNext image RHOS pins (ERPNext 16.37.0, Frappe 16.36.1).
# Built once in CI; the same image is promoted EXP -> TEST -> PROD.
# Keep the base digest in step with erpnext-local/versions.env (Dependabot raises PRs for this line).
FROM frappe/erpnext:v16.37.0@sha256:2cfe0764c2380838529fe55ca2f6caf0d3b05045da96bac1dbc0cd23ec654cba

LABEL org.opencontainers.image.source="https://github.com/Ali-Sample/sample-erpnext-custom"

COPY --chown=frappe:frappe . /home/frappe/frappe-bench/apps/sample_erpnext_custom

# ponytail: no `bench build` for assets; the app has no JS/CSS. Add it when the app ships front-end code.
RUN cd /home/frappe/frappe-bench \
 && env/bin/pip install --no-cache-dir -e apps/sample_erpnext_custom \
 && ls -1 apps > sites/apps.txt
