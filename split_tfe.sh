#!/usr/bin/env bash
mkdir split_logs
grep '"component":"sidekiq","log":' terraform-enterprise.stdout >> split_logs/sidekiq.log
grep '"component":"nginx","log":' terraform-enterprise.stdout >> split_logs/nginx.log
grep '"component":"atlas","log":' terraform-enterprise.stdout >> split_logs/atlas.log
grep '"component":"archivist","log":' terraform-enterprise.stdout >> split_logs/archivist.log
grep '"component":"vault","log":' terraform-enterprise.stdout >> split_logs/vault.log
grep '"component":"task-worker","log":' terraform-enterprise.stdout >> split_logs/task-worker.log
grep '"component":"metrics","log":' terraform-enterprise.stdout >> split_logs/metrics.log
grep '"component":"slug-ingress","log":' terraform-enterprise.stdout >> split_logs/slug-ingress.log
grep '"component":"terraform-registry-api","log":' terraform-enterprise.stdout >> split_logs/terraform-registry-api.log
grep '"component":"atlas-ui","log":' terraform-enterprise.stdout >> split_logs/atlas-ui.log
grep '"component":"outbound-http-proxy","log":' terraform-enterprise.stdout >> split_logs/outbound-http-proxy.log
grep '"component":"terraform-registry-worker","log":' terraform-enterprise.stdout >> split_logs/terraform-registry-worker.log
grep '"component":"terraform-state-parser","log":' terraform-enterprise.stdout >> split_logs/terraform-state-parser.log
grep '"component":"licensing","log":' terraform-enterprise.stdout >> split_logs/licensing.log
grep '"component":"backup-restore","log":' terraform-enterprise.stdout >> split_logs/backup-restore.log
