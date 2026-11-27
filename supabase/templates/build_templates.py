"""Gera supabase/templates/{signup,recovery}_code.html (PT/EN/ES num único arquivo).

Estratégia de idioma: o app grava user_metadata.lang ('pt'|'en'|'es') no cadastro
e o GoTrue expõe isso como {{ .Data.lang }} nos templates de signup/recovery.
Sem lang (usuários antigos) cai em português. O Supabase NÃO traduz sozinho.
Uso: python supabase/templates/build_templates.py
"""
import os

T = {
 'signup': {
  'pt': dict(subj='Aprovaura: seu código de confirmação', title='Confirme seu e-mail',
    intro='Use o código abaixo no aplicativo para confirmar sua conta e começar a estudar.',
    valid='O código vale por 6 horas.', ignore='Se você não criou uma conta no Aprovaura, pode ignorar este e-mail com segurança.'),
  'en': dict(subj='Aprovaura: your confirmation code', title='Confirm your email',
    intro='Enter the code below in the app to confirm your account and start studying.',
    valid='The code is valid for 6 hours.', ignore="If you didn't create an Aprovaura account, you can safely ignore this email."),
  'es': dict(subj='Aprovaura: tu código de confirmación', title='Confirma tu correo',
    intro='Ingresa el código de abajo en la app para confirmar tu cuenta y empezar a estudiar.',
    valid='El código es válido por 6 horas.', ignore='Si no creaste una cuenta en Aprovaura, puedes ignorar este correo con tranquilidad.'),
 },
 'recovery': {
  'pt': dict(subj='Aprovaura: seu código de recuperação de senha', title='Recupere sua senha',
    intro='Use o código abaixo no aplicativo para criar uma nova senha.',
    valid='O código vale por 6 horas.', ignore='Se você não pediu a recuperação, ignore este e-mail: sua senha continua a mesma.'),
  'en': dict(subj='Aprovaura: your password recovery code', title='Reset your password',
    intro='Enter the code below in the app to create a new password.',
    valid='The code is valid for 6 hours.', ignore="If you didn't request this, ignore this email: your password stays the same."),
  'es': dict(subj='Aprovaura: tu código de recuperación de contraseña', title='Recupera tu contraseña',
    intro='Ingresa el código de abajo en la app para crear una nueva contraseña.',
    valid='El código es válido por 6 horas.', ignore='Si no lo pediste, ignora este correo: tu contraseña sigue igual.'),
 },
}
PARTNER = {  # professor cadastrado pelo administrador: define a senha pelo código (fluxo "Esqueci minha senha")
  'pt': dict(title='Bem-vindo ao Portal do Professor', cta='Criar minha senha', intro='Você foi cadastrado como professor parceiro do Aprovaura. Toque no botão abaixo para criar sua senha: você já entra no portal em seguida.',
    valid='O link vale por 6 horas e só pode ser usado uma vez. Se expirar, peça um novo convite ao administrador.', ignore='Se você não esperava este convite, pode ignorar este e-mail.'),
  'en': dict(title='Welcome to the Teacher Portal', cta='Create my password', intro='You have been registered as an Aprovaura partner teacher. Tap the button below to create your password: you will be signed in to the portal right after.',
    valid='The link is valid for 6 hours and can be used once. If it expires, ask the administrator for a new invitation.', ignore="If you weren't expecting this invitation, you can ignore this email."),
  'es': dict(title='Bienvenido al Portal del Profesor', cta='Crear mi contraseña', intro='Te registraron como profesor asociado de Aprovaura. Toca el botón de abajo para crear tu contraseña: entrarás al portal enseguida.',
    valid='El enlace es válido por 6 horas y se usa una sola vez. Si vence, pide una nueva invitación al administrador.', ignore='Si no esperabas esta invitación, puedes ignorar este correo.'),
}
FOOT = {'pt': 'Aprovaura é um produto Lucksrei Systems. Este é um e-mail automático, não responda.',
        'en': 'Aprovaura is a Lucksrei Systems product. This is an automated email, please do not reply.',
        'es': 'Aprovaura es un producto de Lucksrei Systems. Este es un correo automático, no respondas.'}

def block(d, lang):
    return f'''<p style="margin:0 0 14px;font-size:20px;font-weight:700;color:#141A45;">{d['title']}</p>
<p style="margin:0 0 20px;font-size:15px;line-height:24px;color:#3B4163;">{d['intro']}</p>
@@CODE@@
<p style="margin:0 0 12px;font-size:13px;line-height:20px;color:#6B7090;">{d['valid']}</p>
<p style="margin:0;font-size:13px;line-height:19px;color:#6B7090;">{d['ignore']}</p>'''

CODE = '''<div style="margin:22px 0;padding:18px 0;background:#F6F8FC;border:1px solid #DCDEEA;border-radius:14px;font-size:36px;line-height:42px;font-weight:700;letter-spacing:10px;text-align:center;color:#141A45;font-family:'Courier New',Courier,monospace;">{{ .Token }}</div>'''

LINK = '<p style="margin:26px 0 28px;text-align:center;"><a href="{{{{ .SiteURL }}}}/convite?th={{{{ .TokenHash }}}}" style="display:inline-block;padding:15px 34px;background:#7B6CF2;color:#FFFFFF;font-size:15px;font-weight:700;text-decoration:none;border-radius:12px;">{cta}</a></p>'

def cond(kind, key=None):
    def part(lang):
        d = T[kind][lang]; out = block(d, lang).replace('@@CODE@@', CODE) if key is None else d[key]
        if kind == 'recovery' and key is None:
            pd = PARTNER[lang]
            out = ('{{ if .Data.invite }}' + block(pd, lang).replace('@@CODE@@', LINK.format(cta=pd['cta']).replace('{{{{', '{{').replace('}}}}', '}}'))
                   + '{{ else }}' + out + '{{ end }}')
        return out
    return ('{{ if eq .Data.lang "en" }}' + part('en') + '{{ else if eq .Data.lang "es" }}' + part('es')
            + '{{ else }}' + part('pt') + '{{ end }}')

def foot():
    return ('{{ if eq .Data.lang "en" }}' + FOOT['en'] + '{{ else if eq .Data.lang "es" }}' + FOOT['es']
            + '{{ else }}' + FOOT['pt'] + '{{ end }}')

def page(kind):
    return f'''<div style="margin:0;padding:32px 16px;background:#F8FAFE;font-family:Arial,Helvetica,sans-serif;">
  <div style="max-width:440px;margin:0 auto;">
    <div style="text-align:center;padding:0 0 18px;">
      <img src="{{{{ .SiteURL }}}}/email/aprovaura-mark.png" width="56" alt="Aprovaura" style="display:inline-block;border:0;height:auto;font-size:20px;font-weight:700;color:#7B6CF2;">
      <div style="margin-top:8px;font-size:20px;font-weight:700;color:#7B6CF2;letter-spacing:.3px;">Aprovaura</div>
    </div>
    <div style="background:#FFFFFF;border:1px solid #E2DAF7;border-radius:20px;padding:30px 26px;">
{cond(kind)}
    </div>
    <p style="margin:18px 8px 0;text-align:center;font-size:12px;line-height:18px;color:#8A8EA8;">{foot()}</p>
  </div>
</div>
'''

here = os.path.dirname(os.path.abspath(__file__))
for kind in ('signup', 'recovery'):
    open(os.path.join(here, f'{kind}_code.html'), 'w', encoding='utf-8', newline='\n').write(page(kind))
    print('ok', kind)
# Assuntos por idioma (o Management API aceita um assunto só; ver docs): bilíngue curto.
