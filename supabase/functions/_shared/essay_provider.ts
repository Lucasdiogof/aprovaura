// Interruptor global da correção de redação por IA (segredo ESSAY_AI_PROVIDER). Sem custo e sem migração,
// o dono suspende TODA correção externa com
//   supabase secrets set ESSAY_AI_PROVIDER=disabled   (e volta com =multi ou removendo o segredo)
// Suspenso: a função recusa ANTES de debitar cota ou enviar texto a terceiros. Valor desconhecido também
// suspende (falha fechada). Quais provedores rodam e em que ordem é configuração no banco
// (essay_ai_providers), não deste segredo.
export type EssayProviderName = 'active' | 'suspended';

export function resolveEssayProvider(raw: string | undefined | null): EssayProviderName {
  const v = (raw ?? 'multi').trim().toLowerCase();
  return v === 'multi' || v === 'google' ? 'active' : 'suspended';
}
