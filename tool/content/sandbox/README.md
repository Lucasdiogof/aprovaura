# Sandbox de verificação computacional
`verificacao.codigo` escrito por agente NUNCA roda no ambiente principal. `qc.verificar_calculo` usa um contêiner descartável:
`--network none`, `--read-only`, `--cap-drop ALL`, `no-new-privileges`, `--memory 256m`, `--cpus 1`, `--pids-limit 64`, usuário sem privilégio,
sem volumes (código entra por stdin), timeout com `docker kill`, tmpfs 16m. Sem credenciais, sem repositório, sem outros projetos.
Imagem: `docker build -t aura-verif sandbox/` (sympy fixado). Sem Docker => a verificação FALHA (`verificacao_sandbox_indisponivel`);
`AURA_SANDBOX=local` força o modo antigo (subprocesso `-I`, INSEGURO, só para depuração).
