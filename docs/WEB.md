# Aprovaura Web (Cloudflare Workers + Static Assets)

Padrão: `Lucasdiogof/lucksrei-web-template`. Cada app mantém Worker, Supabase e deploy próprios.

- Worker: `aura` (já publicado em `aura.lucasdiogo1234.workers.dev`; URL preservada).
- Domínio proposto: `aprovaura.lucksrei.com`. Rota em `wrangler.toml` está **comentada** até o dono autorizar DNS.
- Deploy automático: `.github/workflows/deploy.yml` (push na main; secrets `SUPABASE_*`, `CLOUDFLARE_*`).
- Build local: `bash scripts/build-web.sh` (usa `env.json`, gitignored). Deploy manual: `bash scripts/deploy-web.sh`.
- Smoke test: `bash scripts/smoke-test.sh https://aura.lucasdiogo1234.workers.dev /praticar`.
- Headers e cache: `web/_headers` (HSTS, nosniff, frame DENY, `no-cache` com ETag nos arquivos sem hash).
- `scripts/check-bundle-secrets.sh` falha o build se houver `service_role`/`sb_secret_` no bundle.
- Rollback: `npx wrangler rollback <version-id> --name aura` (lista: `npx wrangler deployments list --name aura`).

## Autenticação (inalterada)
Recuperação por código de 6 dígitos: `resetPasswordForEmail(email)` sem `redirectTo` e `verifyOTP(type: recovery)`
(`lib/features/auth/data/auth_repository_impl.dart`). Nenhum Redirect URL novo é necessário no Supabase.
Pendência externa: o Supabase embutido só envia 2 e-mails/hora; confirmar SMTP custom no projeto antes de promover o web.

## Observações
- CI fixa Flutter 3.44.1; o ambiente local usa 3.47.4. Conferir antes de confiar em diferenças de build.
- O Android/iOS não foram alterados.
