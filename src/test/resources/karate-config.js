function fn() {
  var env = karate.env || 'dev';
  karate.log('karate.env =', env);

  var file = 'classpath:config/' + env + '.json';
  var config;
  try {
    config = karate.read(file);
  } catch (e) {
    karate.fail('Ambiente "' + env + '" no encontrado. Se esperaba el archivo ' + file);
  }
  config.env = env;

  // -DbaseUrl=... sobrescribe el archivo de ambiente.
  var baseUrl = karate.properties['baseUrl'];
  if (baseUrl) config.baseUrl = baseUrl;

  // Los secretos se leen del entorno; el archivo solo trae el valor público de la demo en dev.
  var password = java.lang.System.getenv('BOOKER_PASSWORD');
  if (password) config.password = password;

  karate.configure('connectTimeout', config.connectTimeout);
  karate.configure('readTimeout', config.readTimeout);

  return config;
}
