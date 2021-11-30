#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 25/11/2021
# Data de atualização: 30/11/2021
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do GLPI Help Desk v9.5.x
#
# GLPI (sigla em francês: Gestionnaire Libre de Parc Informatique, ou "Free IT Equipment 
# Manager" em inglês) é um sistema gratuito de Gerenciamento de Ativos de TI, sistema de 
# rastreamento de problemas e central de atendimento. Este software de código aberto é 
# escrito em PHP e distribuído sob a Licença Pública Geral GNU.
#
# O GLPI é um aplicativo baseado na Web que ajuda as empresas a gerenciar seu sistema de 
# informações. A solução é capaz de criar um inventário de todos os ativos da organização 
# e gerenciar tarefas administrativas e financeiras. As funcionalidades dos sistemas 
# auxiliam os administradores de TI a criar um banco de dados de recursos técnicos, além 
# de um gerenciamento e histórico de ações de manutenções. Os usuários podem declarar 
# incidentes ou solicitações (com base no ativo ou não) graças ao recurso de Helpdesk.
#
# Informações que serão solicitadas na configuração via Web do GLPI
# GLPI Setup
# Select your language: Português do Brasil: OK;
# Licença: Eu li e ACEITO os termos de licença acima: Continuar;
# Início da instalação: Instalar;
# Etapa 0: Verificação do ambiente: Continuar;
# Etapa 1: Instalação da conexão com o bando de dados:
#	SQL server(MariaDB ou MySQL): localhost
#	Usuário SQL: glpi
#	Senha SQL: glpi: Continuar;
# Etapa 2: Conexão com banco de dados: glpi: Continuar;
# Etapa 3: Iniciando banco de dados: Continuar;
# Etapa 4: Coletar dados: Continuar;
# Etapa 5: Uma última coisa antes de começar: Continuar;
# Etapa 6: A instalação foi concluída: Usar GLPI
#
# Usuário/Senha: glpi/glpi - conta do usuário administrador
# Usuário/Senha: tech/tech - conta do usuário técnico
# Usuário/Senha: normal/normal - conta do usuário normal
# Usuário/Senha: post-only/postonly - conta do usuário postonly
#
# Site oficial: https://glpi-project.org/pt-br/
#
# Arquivo de configuração dos parâmetros utilizados nesse script
source 00-parametros.sh
#
# Configuração da variável de Log utilizado nesse script
LOG=$LOGSCRIPT
#
# Verificando se o usuário é Root e se a Distribuição é >= 20.04.x 
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria 
# dos erros comuns na execução
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "20.04" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é >= 20.04.x, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou a Distribuição não é >= 20.04.x ($UBUNTU)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando se as dependências do GLPI estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do GLPI, aguarde... "
	for name in mysql-server mysql-common apache2 php
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 02-dhcp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 07-lamp.sh para resolver as dependências."
            exit 1; 
            }
		sleep 5
#
# Verificando se o script já foi executado mais de 1 (uma) vez nesse servidor
# OBSERVAÇÃO IMPORTANTE: OS SCRIPTS FORAM PROJETADOS PARA SEREM EXECUTADOS APENAS 1 (UMA) VEZ
if [ -f $LOG ]
	then
		echo -e "Script $0 já foi executado 1 (uma) vez nesse servidor..."
		echo -e "É recomendado analisar o arquivo de $LOG para informações de falhas ou erros"
		echo -e "na instalação e configuração do serviço de rede utilizando esse script..."
		echo -e "Todos os scripts foram projetados para serem executados apenas 1 (uma) vez."
		sleep 5
		exit 1
	else
		echo -e "Primeira vez que você está executando esse script, tudo OK, agora só aguardar..."
		sleep 5
fi
#
# Script de instalação do GLPI no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e Configuração do GLPI no GNU/Linux Ubuntu Server 20.04.x"
echo -e "Após a instalação do GLPI acessar a URL: http://$(hostname -I | cut -d' ' -f1)/glpi/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configurando do GLPI Help Desk, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do GLPI, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (faz a função de quebra de pagina no comando apt)
	apt -y install php-curl php-gd php-intl php-pear php-imagick php-imap php-memcache php-pspell \
	php-mysql php-tidy php-xmlrpc php-mbstring php-ldap php-cas php-apcu php-json php-xml php-cli \
	libapache2-mod-php xmlrpc-api-utils &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do GLPI do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v glpi.tgz &>> $LOG
	wget $GLPI -O glpi.tgz &>> $LOG
echo -e "Download do GLPI feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando e Instalando o GLPI no site do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando tar: -z (gzip), -x (extract), -v (verbose), -f (file)
	# opção do comando mv: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose), www-data.www-data (user and group)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX, Group=R-X, Other=R-X)
	tar -zxvf glpi.tgz &>> $LOG
	mv -v glpi/ /var/www/html/glpi/ &>> $LOG
	chown -Rv www-data:www-data /var/www/html/glpi/ &>> $LOG
	chmod -Rv 755 /var/www/html/glpi/ &>> $LOG
	chmod -Rv 777 /var/www/html/glpi/files/_log &>> $LOG
echo -e "GLPI instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados do GLPI, aguarde..."
	# criando a base de dados do GLPI
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_GLPI" mysql &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando os recursos do Apache2 para suportar o GLPI, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando phpenmod: (habilitar módulos do PHP)
	# opção do comando a2enconf: (habilitar arquivo de configuração de site do Apache2)
	# opção do comando systemctl: restart (reinicializar o serviço)
	cp -v conf/glpi.conf /etc/apache2/conf-available/ &>> $LOG
	cp -v conf/glpi-cron /etc/cron.d/ &>> $LOG
	phpenmod apcu &>> $LOG
	a2enconf glpi &>> $LOG
echo -e "Recursos habilitados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Apache2 do GLPI, pressione <Enter> para continuar"
	read
	vim /etc/apache2/conf-available/glpi.conf
	systemctl restart apache2 &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de agendamento do GLPI, pressione <Enter> para continuar"
	read
	vim /etc/cron.d/glpi-cron
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do GLPI Help Desk feita com Sucesso!!!."
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=$(date +%T)
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
read
exit 1