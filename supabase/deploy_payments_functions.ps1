# Publica as Edge Functions de pagamento (Etapa 07). Requer SUPABASE_ACCESS_TOKEN (PAT) do projeto.
# Não ativa nenhum provedor: a compra só abre com payment_providers_config.enabled = true.
$ref = 'cesuqfgrtcitatxvokez'
foreach ($f in 'payments-apple','payments-google','mp-webhook','mp-checkout','payments-reconcile') {
  npx supabase functions deploy $f --project-ref $ref
}
