#!/bin/bash -x
#Armazena a data de expiração

SAIDA="SAIDA-BASE.csv"
echo "" > $SAIDA

for baseurl in `cat base`;
do
timeout -s9 5s openssl s_client -connect $baseurl:443 -servername $baseurl 2> /dev/null | openssl x509 -noout -dates | tail -1 | tr -s " " |cut -d "=" -f2 | cut -d " " -f1,2,4 | grep CERTIFICATE
E=`echo $?`
wait


C=`echo | timeout -s9 3s  curl -LI http://${baseurl} -o /dev/null -w '%{http_code}' -s`
D=`echo | timeout -s9 3s  curl -LI https://${baseurl} -o /dev/null -w '%{http_code}' -s`

if [ $E -eq 0 ]; then
echo "\$baseurl\",\"ERRO\",\"$C\",\"$D\""
else

A=`echo |timeout -s9 3s  openssl s_client -connect $baseurl:443 -servername $baseurl 2> /dev/null | openssl x509 -noout -dates | tail -1 | tr -s " " |cut -d "=" -f2 | cut -d " " -f1,2,4`

#converte a data de expiração do certificado para o padrao Y-m-d e armazena o valor na variavel "B"
B=`date -d "$A" +"%Y-%m-%d"`
#Exibe a data atual no padrao ano-mes-dia e armazena o valor na variavel C
#C=`date +"%Y-%m-%d"`



#realiza o calculo simples
#echo "scale=0;("`date -d "$B" +%s`-`date -d "$C" +%s`")"/24/60/60|bc
if [ -z "$A" ]; then
        echo "\"$baseurl\",\"ERRO\",\"$C\",\"$D\"" >> $SAIDA
else
echo "\"$baseurl\",\"$B\",\"$C\",\"$D\"" >> $SAIDA
fi
fi

done
