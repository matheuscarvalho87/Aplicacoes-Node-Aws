#instalar 
choco install serveless

#sls inicializar
##obs: o comando sls não esta rodando na minha máquina
## a ideia é que qualquer um dos dois funcionem
sls ou serveless

#Boa prática: sempre fazer deploy antes de tudo para verificar se está funcionando
serveless deploy

#invocar na AWS: vai ate a AWS e chama a função => ve os resultados, vê valor de logs ...
sls invoke -f hello

#invocar localmente, sem precisar ir na AWS
sls invoke local -f hello -l

#configurar o dashboard
sls

#logs
sls logs -f hello -t
