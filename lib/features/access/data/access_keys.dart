/// Chaves PÚBLICAS RSA-2048 (expoente 65537) que verificam as autorizações
/// offline emitidas por get_my_access(). A chave privada fica só no banco
/// (server_secrets) e nunca no app. Para girar a chave: gerar k2, publicar um
/// app que conheça k1 e k2, trocar a chave no servidor, e só depois remover k1.
const Map<String, String> kAccessPublicKeys = {
  'k1':
      'f245b4c4f8ffc210fa1782f4d9a862552b305c37cf0d3b892f0d819bf35d5e5bfac9bdf32a8a746ba20b1820ed543d4c8fa9aa5d948bdf733364d212dfbf6380fe7013ddf071b501a22676422698cb1f1e24eda3cc77138674cdc3120c63fa6b2f7af29df489e921700fe6f686887a9515c6da495b6d23b8f09b852ad1f03c339fdcf90406b9f70a4301f6cf6e322c27ef77b12e4b60293830ae6878ea1bbd06469120dc7e47bc2bb24746bfc8d37663bf609e0285470d6a611f6b66e28b5c3c5ad8000ed86b879c32f31c019a067b562d1d5dba0f69c7394fe72ba33cb475c1f3e7011d9cdd47abb591e004ca34e9d95f4a88896db23d16a3eb843e40d76487',
};
