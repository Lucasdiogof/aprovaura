import { assertEquals } from 'jsr:@std/assert@1';
import { resolveEssayProvider } from './essay_provider.ts';

Deno.test('padrão é google (comportamento atual preservado)', () => {
  assertEquals(resolveEssayProvider(undefined), 'google');
  assertEquals(resolveEssayProvider(' Google '), 'google');
});
Deno.test('disabled, vazio e desconhecido suspendem (falha fechada)', () => {
  for (const v of ['disabled', 'off', '', 'openai', 'mock']) assertEquals(resolveEssayProvider(v), 'suspended');
});
