import { assertEquals } from 'jsr:@std/assert@1';
import { resolveEssayProvider } from './essay_provider.ts';

Deno.test('padrão, multi e google ativam a orquestração', () => {
  assertEquals(resolveEssayProvider(undefined), 'active');
  assertEquals(resolveEssayProvider(' Multi '), 'active');
  assertEquals(resolveEssayProvider('google'), 'active');
});
Deno.test('disabled, vazio e desconhecido suspendem (falha fechada)', () => {
  for (const v of ['disabled', 'off', '', 'openai', 'mock']) assertEquals(resolveEssayProvider(v), 'suspended');
});
