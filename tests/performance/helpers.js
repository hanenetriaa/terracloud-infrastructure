module.exports = {
  // Fonction pour générer des données aléatoires
  generateRandomData: function(context, events, done) {
    context.vars.randomNumber = Math.floor(Math.random() * 1000);
    return done();
  },

  // Logger les temps de réponse
  logResponse: function(requestParams, response, context, ee, next) {
    console.log(`Response time: ${response.timings.response}ms for ${requestParams.url}`);
    return next();
  }
};