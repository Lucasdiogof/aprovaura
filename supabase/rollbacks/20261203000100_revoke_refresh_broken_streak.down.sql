-- Reverte a revogação (reabre a falha de zerar a sequência de outro usuário; só para diagnóstico).
grant execute on function public.refresh_broken_streak(uuid, date) to anon, authenticated;
notify pgrst, 'reload schema';
