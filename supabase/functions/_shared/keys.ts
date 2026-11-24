// Chaves modernas (sb_publishable_/sb_secret_) injetadas pela plataforma; as legadas só valem como
// reserva enquanto não forem desativadas. Nunca logar nem devolver estes valores.
const pick = (modern: string, legacy: string): string => {
  try {
    const o = JSON.parse(Deno.env.get(modern) ?? '');
    const v = o.default ?? Object.values(o)[0];
    if (typeof v === 'string' && v) return v;
  } catch { /* cai na legada */ }
  return Deno.env.get(legacy)!;
};
export const publishableKey = () => pick('SUPABASE_PUBLISHABLE_KEYS', 'SUPABASE_ANON_KEY');
export const secretKey = () => pick('SUPABASE_SECRET_KEYS', 'SUPABASE_SERVICE_ROLE_KEY');
