'use strict';
const {get} = require('axios')
class Handler{
  constructor({rekoSvc,translatorSvc}){
    this.rekoSvc = rekoSvc;
    this.translatorSvc = translatorSvc;
  }

  //Função para traduzir o texto
  async translateText( text ){
    const params = {
      SourceLanguageCode:'en',
      TargetLanguageCode:'pt',
      Text:text
    }
    const {TranslatedText} = await this.translatorSvc.translateText(params).promise()

    return TranslatedText.split(' e ')
  }
  //Função que formata o texto de resposta
  formatTextResults(texts, workingItems){
    const finalText = []
    for(const indexText in texts){
      const nameInPortuguese = texts[indexText]
      const confidence = workingItems[indexText].Confidence
      finalText.push(
        `${confidence.toFixed(2)}% de ser do tipo ${nameInPortuguese}`
      )
    }
    return finalText.join('\n')
  }
  //Função para gerar o buffer da imagem 
  async getImageBuffer(imageUrl){
    const response = await get(imageUrl,{
      responseType:'arraybuffer'
    })
    const buffer = Buffer.from(response.data,'base64')
    return buffer
  }
  //Funcão para detectar o que esta presente na imagem
  async detectImageLabels(buffer){
    const result = await this.rekoSvc.detectLabels({
      Image:{
        Bytes: buffer
      }
    }).promise()
    
    //Pegando apenas o que tem confiança maior para não ter tantos dados
    const workingItems = result.Labels.filter(({Confidence})=> Confidence > 80);

    const names = workingItems
    .map(({Name})=>Name)
    .join(' and ')
    return { names, workingItems }
  }
  async main(event){
    try {
      // Pega a imagem direto da URL
      const { imageUrl } = event.queryStringParameters
      console.log('Downloading image...')
      const buffer = await this.getImageBuffer(imageUrl) 
      console.log('Detecting labels...')
      const {names, workingItems} = await this.detectImageLabels(buffer)
      console.log('Translating...')
      const texts = await this.translateText(names)
      console.log('handling final object... ')
      const finalText = this.formatTextResults(texts,workingItems)
      console.log('finishing... ')
      return{
        statusCode:200,
        body:`A imagem tem\n`.concat(finalText)
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
///**Factory
//Normalmente essa parte fica no inicio ca classe, aqui o instrutor gosta de deixar aqui
//pois ela vira um arquivo separado para gerenciar as instancias e passar para a classe somente o que ela precisa
//mas a titulo de conhecimento não vamos tornar aqui mais um arquivo e tornar mais complicado de aprender
//** */
const aws = require('aws-sdk')
//Serviço da aws
const reko = new aws.Rekognition()
//Função de tradução da aws
const translator = new aws.Translate()
const handler = new Handler({
  //injeta como um serviço dentro da função
  rekoSvc : reko,
  translatorSvc : translator
})
//Usando bind para evitar variaveis globais e chamar a função 
module.exports.main =  handler.main.bind(handler);
