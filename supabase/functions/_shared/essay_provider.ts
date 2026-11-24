// Escolha do provedor de correção de redação. Interruptor de segurança: sem custo
// e sem migração, o dono suspende a correção externa com
//   supabase secrets set ESSAY_AI_PROVIDER=disabled   (e volta com =google)
// Suspenso: a função recusa ANTES de debitar cota ou enviar texto a terceiros;
// redação e submission nunca se perdem. Provedor desconhecido também suspende
// (falha fechada: nada é enviado a um destino não previsto).
export type EssayProviderName = 'google' | 'suspended';

export function resolveEssayProvider(raw: string | undefined | null): EssayProviderName {
  const v = (raw ?? 'google').trim().toLowerCase();
  return v === 'google' ? 'google' : 'suspended';
}
