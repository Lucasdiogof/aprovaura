import { assertEquals } from 'jsr:@std/assert@1';
import { publishableKey, secretKey } from './keys.ts';

Deno.test('prefere a chave moderna e cai na legada só se faltar', () => {
  Deno.env.set('SUPABASE_PUBLISHABLE_KEYS', '{"default":"pub_new"}');
  Deno.env.set('SUPABASE_ANON_KEY', 'legacy_anon');
  assertEquals(publishableKey(), 'pub_new');
  Deno.env.delete('SUPABASE_SECRET_KEYS');
  Deno.env.set('SUPABASE_SERVICE_ROLE_KEY', 'legacy_srv');
  assertEquals(secretKey(), 'legacy_srv');
  Deno.env.set('SUPABASE_SECRET_KEYS', 'não-é-json');
  assertEquals(secretKey(), 'legacy_srv');
});
