# UTC Student Services Portal — Phase 2 Homepage

This is the **static homepage preview**, intentionally kept separate from the currently deployed Python backend.

## Preview locally

From your Git Bash terminal, in the `utcapp-clean` repository:

```bash
cd ~/utcapp-clean/frontend
python -m http.server 8080
```

Open http://localhost:8080 in your browser. Stop the preview with `Ctrl+C`.

## Safety and integration

- This page does not enable student login, registration, or file submission. Those are clearly marked as future features.
- No AWS resources are changed merely by adding this directory.
- Keep the existing `/health`, `/db-health`, and `/documents` routes intact.
- Inspect `module/compute/app.py` before deciding how to serve this page from the existing Python backend. Do not overwrite that file blindly.
- Do not use the static preview to accept real student personal information.

## Deployment plan

1. Preview and approve the homepage locally.
2. Inspect the existing Python request handler and add safe routing for the homepage/assets.
3. Test old health, database, and S3 routes locally.
4. Update the Terraform-managed launch template and review the plan before applying.
5. Roll out carefully and verify the new homepage at `https://utc.triplearides.com/`.
