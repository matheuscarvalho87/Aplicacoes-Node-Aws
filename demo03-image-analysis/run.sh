# Inicia sls
sls
## coloca no por enquanto ao perguntar isso 
Serverless: Would you like to enable this? No

# Inicia node dentro da pasta do serverless
npm init -y
# Instala sdk da aws
npm i aws-sdk
## ja da um deploy pra aws
sls deploy
## para saber se esta tudo certo com o ambiente
sls invoke -f hello
## invoca o local tambem para ver se esta funcionando 
sls invoke local -f hello
## dentro do serverless.yml descomenta dentro de functions(events: - httpApi:    path: /users/create   method: get)
##lembrar de dar um tab depois de descomentar pois a identação é essencial 


# Muda o nome da fução para img-analysis e coloca o novo path facil de lembrar, muda para handler.main, pois mudaremos o nome da função dentro de handler.js
functions:
  img-analysis:
    handler: handler.main
    events:
      - httpApi:
          path: analyse
          method: get
#apaga tudo em handler.js e começa a criar a class Handler, trata erro, retorna teste com statusCOde 200 e body hello
'use strict';
class Handler{
  async main(event){
    try {
      
      return{
        statusCode:200,
        body:'Hello!!!'
      }
    } catch (error) {
      console.log('Error***',error.stack)
      return{
        statusCode:500,
        body:'Internal server error'
      }
    }
  }
}
const handler = new Handler()
##Usando bind para evitar variaveis globais e chamar a função 
module.exports.main =  handler.main.bind(handler);

# invoca para teste


##adicionando primeiro a imagem, lembrar de criar a pasta img
'use strict';
const {promises:{readFile}} = require('fs')
class Handler{
  constructor({rekoSvc}){
    this.rekoSvc = rekoSvc;
  }
  async detectImageLabels(buffer){
    const result = await this.rekoSvc.detectLabels({
      Image:{
        Bytes: buffer
      }
    }).promise()

    console.log(result.Labels)
  }
  async main(event){
    try {
      const imgBuffer = await readFile('./img/cat.jpg')
      this.detectImageLabels(imgBuffer)
      return{
        statusCode:200,
        body:'Hello!!!'
      }
    } catch (error) {
      console.log('Error***',error.stack)
      return{
        statusCode:500,
        body:'Internal server error'
      }
    }
  }
}

const aws = require('aws-sdk')

const reko = new aws.Rekognition()
const handler = new Handler({
  rekoSvc : reko
})
module.exports.main =  handler.main.bind(handler);

