# Aplica a configuração de e-mail do Auth do AprovaAura (Management API) em FASES.
# Nada aqui roda sozinho: exige SUPABASE_ACCESS_TOKEN (PAT do dono da organização).
#
#   $env:SUPABASE_ACCESS_TOKEN = "<PAT>"
#   ./supabase/apply_auth_email_config.ps1 -Templates            # fase 1: templates + OTP 6 dígitos (seguro agora)
#   ./supabase/apply_auth_email_config.ps1 -Smtp                 # fase 2: SMTP Resend (chave lida do cofre em runtime)
#   ./supabase/apply_auth_email_config.ps1 -Activate             # fase 3: confirmação OBRIGATÓRIA (só no lançamento)
#   Remove-Item Env:SUPABASE_ACCESS_TOKEN
#
# -Activate desliga mailer_autoconfirm: a partir daí todo cadastro novo exige o
# código. NÃO rode antes de os apps com a tela de código estarem publicados
# nas lojas (ver docs/PREMIUM_PARTNERS.md, checklist de ativação).
param([switch]$Templates, [switch]$Smtp, [switch]$Activate,
      [string]$Sender = 'no-reply@lucksrei.com', [string]$SenderName = 'AprovaAura')
$ErrorActionPreference = 'Stop'
$ref = 'cesuqfgrtcitatxvokez'
if (-not $env:SUPABASE_ACCESS_TOKEN) { throw 'Defina SUPABASE_ACCESS_TOKEN primeiro.' }
if (-not ($Templates -or $Smtp -or $Activate)) { throw 'Escolha uma fase: -Templates, -Smtp ou -Activate.' }
$url = "https://api.supabase.com/v1/projects/$ref/config/auth"
$headers = @{ Authorization = "Bearer $env:SUPABASE_ACCESS_TOKEN" }
$body = @{}

if ($Templates) {
  $t = Join-Path $PSScriptRoot 'templates'
  $body.mailer_subjects_confirmation = ('Aprovaura: c{0}digo de confirma{1}{2}o / confirmation code' -f [char]0xF3,[char]0xE7,[char]0xE3)
  $body.mailer_templates_confirmation_content = [IO.File]::ReadAllText((Join-Path $t 'signup_code.html'), [Text.Encoding]::UTF8)
  $body.mailer_subjects_recovery = ('Aprovaura: c{0}digo de recupera{1}{2}o / recovery code' -f [char]0xF3,[char]0xE7,[char]0xE3)
  $body.mailer_templates_recovery_content = [IO.File]::ReadAllText((Join-Path $t 'recovery_code.html'), [Text.Encoding]::UTF8)
  $body.mailer_otp_length = 6
  $body.mailer_otp_exp = 3600
}
if ($Smtp) {
  # A chave do Resend (somente envio) vem do cofre global e nunca é impressa.
  $key = & powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.config\claude-secrets\vault.ps1" get --id resend.unassigned
  $key = ($key | Out-String).Trim()
  if (-not $key) { throw 'Chave do Resend não encontrada no cofre.' }
  $body.external_email_enabled = $true
  $body.smtp_host = 'smtp.resend.com'
  $body.smtp_port = '465'
  $body.smtp_user = 'resend'
  $body.smtp_pass = $key
  $body.smtp_admin_email = $Sender
  $body.smtp_sender_name = $SenderName
  $body.rate_limit_email_sent = 15      # e-mails/h; plano grátis da Resend = 100/dia e 3000/mês, compartilhado com a Lucksrei
}
if ($Activate) {
  $body.mailer_autoconfirm = $false
}
$json = $body | ConvertTo-Json
Invoke-RestMethod -Method Patch -Uri $url -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($json)) | Out-Null

$now = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
'mailer_autoconfirm:      ' + $now.mailer_autoconfirm
'otp_length / otp_exp:    ' + $now.mailer_otp_length + ' / ' + $now.mailer_otp_exp
'smtp_host / sender:      ' + $now.smtp_host + ' / ' + $now.smtp_admin_email
'rate_limit_email_sent:   ' + $now.rate_limit_email_sent
'signup has {{ .Token }}: ' + ($now.mailer_templates_confirmation_content -like '*{{ .Token }}*')
'recovery has {{ .Token }}: ' + ($now.mailer_templates_recovery_content -like '*{{ .Token }}*')
'ConfirmationURL (deve ser False): ' + (($now.mailer_templates_confirmation_content + $now.mailer_templates_recovery_content) -like '*ConfirmationURL*')

# O logotipo dos e-mails vem de {{ .SiteURL }}/email/aprovaura-mark.png (arquivo em web/email/,
# publicado junto com a web). Avisa se ainda nao estiver no ar; sem ele o e-mail mostra o texto alternativo.
if ($now.site_url) {
  $logo = ($now.site_url.TrimEnd('/')) + '/email/aprovaura-mark.png'
  try { $r = Invoke-WebRequest -Method Head -Uri $logo -UseBasicParsing; 'logo ' + $logo + ' -> ' + $r.StatusCode }
  catch { 'AVISO: logo ainda nao publicado em ' + $logo + ' (publique a web antes do lancamento).' }
}
