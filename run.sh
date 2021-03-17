# 1º passo: criar o arquivo de segurança
# 2º passo: criar role de segurança na AWS utilizando o IAM

aws iam create-role \
  --role-name lambda-exemplo \
  --assume-role-policy-document file://politicas.json \
  | tee logs/role.log #o comando tee so funciona para linux

# 3º criar arquivo com conteudo e zipa
zip function.zip index.js

#4º cria lambda function
aws lambda create-function \
  --function-name hello-cli2 \
  --zip-file fileb://function.zip \
  --handler index.handler \
  --runtime nodejs14.x \
  --role arn:aws:iam::064624499359:role/lambda-exemplo \
  | tee logs/lambda-create.log

#5º invoke lambda!
  aws lambda invoke \
    --function-name hello-cli2 \
    --log-type Tail \
    logs/lambda-exec.log

#6º atualizar, zipar o arquivo index.js novamente
  aws lambda update-function-code \
  --function-name hello-cli2 \
  --zip-file fileb://function.zip \
  --publish \
  | tee logs/lambda-update.log

  #7º invokar e ver o resultado!
  aws lambda invoke \
    --function-name hello-cli2 \
    --log-type Tail \
    logs/lambda-exec.log

#REMOVER
aws lambda delete-function \
--function-name hello-cli

aws iam delete-role \
  --role-name lambda-exemplo