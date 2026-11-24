-- O e-mail de recuperação usa a variante "boas-vindas do professor" enquanto user_metadata.partner = true.
-- A flag deve valer só até a PRIMEIRA senha definida pelo professor: ao trocar a senha, ela é removida.
create or replace function clear_partner_invite_flag() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if new.raw_user_meta_data ? 'partner' then
    new.raw_user_meta_data := new.raw_user_meta_data - 'partner';
  end if;
  return new;
end $$;

drop trigger if exists clear_partner_invite_flag_trg on auth.users;
create trigger clear_partner_invite_flag_trg
  before update of encrypted_password on auth.users
  for each row when (old.encrypted_password is distinct from new.encrypted_password)
  execute function clear_partner_invite_flag();

-- Quem já entrou alguma vez não deve mais receber o texto de boas-vindas.
update auth.users set raw_user_meta_data = raw_user_meta_data - 'partner'
 where raw_user_meta_data ? 'partner' and last_sign_in_at is not null;
