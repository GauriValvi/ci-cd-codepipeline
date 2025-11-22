<!-- .github/copilot-instructions.md - guidance for AI coding agents working on this repo -->
# Quick orientation

This repository contains a minimal AWS CodeBuild / CodeDeploy pipeline for deploying a Node.js app to an EC2 instance. The build produces `app.zip` (see `buildspec.yml`) and CodeDeploy uses `appspec.yml` to copy files to `/var/www/myapp` and run lifecycle scripts in `scripts/`.

**Key files**
- `buildspec.yml`: CodeBuild phases — `install`, `pre_build`, `build`, `post_build`. Produces `app.zip` as the artifact.
- `appspec.yml`: CodeDeploy mapping and hooks (`BeforeInstall`, `AfterInstall`, `ApplicationStart`, `ValidateService`) that call scripts in `scripts/`.
- `scripts/`: lifecycle scripts used by CodeDeploy:
  - `before_install.sh` (placeholder / currently empty)
  - `after_install.sh` (sets permissions on `/var/www/myapp`)
  - `start_server.sh` (starts `node server.js` with `nohup`)
  - `validate.sh` (performs a `curl` health check on `http://localhost:80`)

**Big picture / architecture**
- CI: AWS CodeBuild runs `buildspec.yml` and creates `app.zip`.
- CD: AWS CodeDeploy unpacks `app.zip` on target EC2 instances and applies hooks defined in `appspec.yml`.
- Runtime: The app is deployed to `/var/www/myapp` and started by `scripts/start_server.sh` (runs `node server.js` with `nohup`). Health is validated with `scripts/validate.sh` calling `curl` on port 80.

Practical implications for code edits and AI changes
- When changing startup behavior, update `scripts/start_server.sh` and ensure `appspec.yml` still references that script under `ApplicationStart`.
- File permissions matter: `after_install.sh` currently applies `chmod -R 755 /var/www/myapp`. If you add private files, update this script accordingly.
- Health check expectations: `validate.sh` checks port 80. If your code listens on another port, update `validate.sh` and `appspec.yml` hooks consistently.

Developer workflows & useful commands
- Build locally (to mimic CodeBuild):
  - `zip -r app.zip .`
- Run the app locally like the server will run on EC2:
  - `cd /path/to/repo && bash scripts/start_server.sh`
  - Check logs: `tail -f output.log`
- Run the validator locally:
  - `bash scripts/validate.sh` (exits non-zero if health check fails)
- Inspect what CodeBuild will do: open `buildspec.yml` — it currently runs `yum install -y jq || true` during `install` and zips the repo in `build`.

Project-specific conventions
- Lifecycle scripts live in `scripts/` and are referenced by relative paths in `appspec.yml`.
- Scripts are executed as `runas: root` per `appspec.yml` hooks; assume root privileges in those scripts.
- Artifacts: the build produces a single `app.zip` containing the app root (no nested artifact folder).
- Minimal dependency management: there is no `package.json` or package installation step in this repo — if you add dependencies, ensure CodeBuild installs them (e.g., `npm ci` in `buildspec.yml` or a lifecycle script).

Integration points & external systems
- AWS CodeBuild (buildspec.yml)
- AWS CodeDeploy (appspec.yml + scripts)
- EC2 target(s) — deployment path is `/var/www/myapp`

Examples to reference in code changes
- To change startup: edit `scripts/start_server.sh` and update `appspec.yml` if the hook name or location changes.
- To change health checks: edit `scripts/validate.sh` (currently `curl -f http://localhost:80`).
- To modify file permissions or ownership: edit `scripts/after_install.sh` (currently `chmod -R 755 /var/www/myapp`).

What I couldn't infer (ask the team)
- App entrypoint file `server.js` is referenced by `start_server.sh` but is not present in this repo — confirm where the Node app source is maintained and whether build steps (installing npm deps, transpilation) belong here.
- Target platform specifics (OS image, user accounts) — confirm EC2 AMI/user expectations if you need to modify `runas` or permission steps.

If anything here looks incomplete or you want different details (more local run scripts, test commands, or commit hooks), tell me which area to expand.
