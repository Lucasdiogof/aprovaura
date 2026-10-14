# Applies the 6-digit-code recovery email to the Aprovaura Supabase project via
# the Management API and reads the result back.
#
#   $env:SUPABASE_ACCESS_TOKEN = "<personal access token>"
#   ./supabase/apply_recovery_code_template.ps1
#   Remove-Item Env:SUPABASE_ACCESS_TOKEN
#
# Only the recovery subject/content (and a 6-digit, 1-hour OTP) are patched;
# every other auth setting is left alone.
$ErrorActionPreference = 'Stop'
$ref = 'cesuqfgrtcitatxvokez'
if (-not $env:SUPABASE_ACCESS_TOKEN) { throw 'Set SUPABASE_ACCESS_TOKEN first.' }
$url = "https://api.supabase.com/v1/projects/$ref/config/auth"
$headers = @{ Authorization = "Bearer $env:SUPABASE_ACCESS_TOKEN" }
$html = [IO.File]::ReadAllText((Join-Path $PSScriptRoot "templates/recovery_code.html"), [Text.Encoding]::UTF8)

$body = @{
  mailer_subjects_recovery        = ('Aprovaura: seu c{0}digo de recupera{1}{2}o / recovery code' -f [char]0xF3,[char]0xE7,[char]0xE3)
  mailer_templates_recovery_content = $html
  mailer_otp_length               = 6
  mailer_otp_exp                  = 3600
} | ConvertTo-Json
Invoke-RestMethod -Method Patch -Uri $url -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body)) | Out-Null

$now = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
'subject:    ' + $now.mailer_subjects_recovery
'otp_length: ' + $now.mailer_otp_length
'otp_exp:    ' + $now.mailer_otp_exp
'has {{ .Token }}:           ' + ($now.mailer_templates_recovery_content -like '*{{ .Token }}*')
'has ConfirmationURL (must be False): ' + ($now.mailer_templates_recovery_content -like '*ConfirmationURL*')

