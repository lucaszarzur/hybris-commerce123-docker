#!/bin/bash
#Author: Lucas Zarzur <lucas12zarzur@gmail.com>

#Variaveis
dockerNetworkName="commerce123-net"
commerce123HybrisImageName="commerce123mod"
commerce123MysqlImageName="commerce123mod-mysql"
commerce123HybrisContainerName="Commerce123-1808"
commerce123MysqlContainerName="Commerce123-mysql-57"
HYBRIS_COMMERCE123_DIR="/app/Commerce123Mod"
commerce123DockerFolder="/home/user/docker" # change this by your docker folder

pause(){
	read -p "Press [Enter] to continue..."
}

show_menu(){
	clear
	echo "==================================="
	echo "   Docker - Hybris Commerce 123"
	echo "==================================="
	echo "##   INSTALLATION   "
	echo "1 - Hybris Commerce 123 - Installation - Create Network for Hybris services"
	echo "2 - Hybris Commerce 123 - Installation - Docker Build - MySQL"
	echo "3 - Hybris Commerce 123 - Installation - Docker Run - MySQL"
	echo "4 - Hybris Commerce 123 - Installation - Docker Build - Hybris"
	echo "5 - Hybris Commerce 123 - Installation - Docker Run - Hybris"
	echo "6 - Hybris Commerce 123 - Installation - See installation logs inside container"
	echo "7 - Hybris Commerce 123 - Installation - First use - Change Solr url"
	echo -e "\n##   UTILS   "
	echo "8 - Hybris Commerce 123 - See execution logs inside container"
	echo "9 - Hybris Commerce 123 - Execute bash inside container '$commerce123HybrisContainerName'"
	echo "10 - Hybris Commerce 123 - Run '$commerce123HybrisImageName' container"
	echo "11 - Hybris Commerce 123 - Stop '$commerce123HybrisImageName' container"
	echo "12 - Hybris Commerce 123 - Ant clean all"
	echo "13 - Hybris Commerce 123 - Run Hybris (debug)"
	echo "14 - Hybris Commerce 123 - Restart Hybris (debug)"
	echo "15 - Hybris Commerce 123 - Stop Solr"
	echo "16 - Hybris Commerce 123 - Start Solr"
	echo "17 - Exit"
	echo ""
	echo "=============================================================="
}

read_options(){
echo "Choose the desired operation:"
read option

case $option in 

1)
	clear
	echo "Hybris Commerce 123 - Create Network for Hybris services..." OK
	echo ""
	echo "Executing command: docker network create $dockerNetworkName --subnet=172.100.0.0/16 --gateway=172.100.0.1"
	echo ""
	sleep 3
	docker network create $dockerNetworkName --subnet=172.100.0.0/16 --gateway=172.100.0.1
	echo ""
	pause
	;;

2)
	clear
	echo "Hybris Commerce 123 - Docker Build - MySQL..." OK
	echo ""
	echo "Executing command: docker build . -f mysql/Commerce123-mysql.Dockerfile -t $commerce123MysqlImageName:5.7"
	echo ""
	sleep 2
	cd $commerce123DockerFolder
	docker build . -f mysql/Commerce123-mysql.Dockerfile -t $commerce123MysqlImageName:5.7
	echo ""
	pause
	;;

3)
	clear
	echo "Hybris Commerce 123 - Docker Run - MySQL..." OK
	echo ""
	echo "Executing command: docker run -it -d --name $commerce123MysqlContainerName -h $commerce123MysqlContainerName --network=$dockerNetworkName --ip 172.100.0.102 $commerce123MysqlImageName:5.7"
	echo ""
	sleep 2
	cd $commerce123DockerFolder
	docker run -it -d --name $commerce123MysqlContainerName -h $commerce123MysqlContainerName --network=$dockerNetworkName --ip 172.100.0.102 $commerce123MysqlImageName:5.7
	echo ""
	pause
	;;

4)
	clear
	echo "Hybris Commerce 123 - Docker Build - Hybris..." OK
	echo ""
	echo "Executing command: docker build . -f Commerce123.Dockerfile -t $commerce123HybrisImageName:1808"
	echo ""
	sleep 2
	cd $commerce123DockerFolder
	docker build . -f Commerce123.Dockerfile -t $commerce123HybrisImageName:1808
	echo ""
	pause
	;;

5)
	clear
	echo "Hybris Commerce 123 - Docker Run - Hybris..." OK
	echo ""
	echo "Executing command: docker run -it -d --name $commerce123HybrisContainerName -h $commerce123HybrisContainerName -v $HYBRIS_COMMERCE123_DIR:$HYBRIS_COMMERCE123_DIR/  --network=$dockerNetworkName --ip 172.100.0.101 -e DB_USERNAME=docker_hybris -e DB_PASSWORD="docker_hybris" $commerce123HybrisImageName:1808"
	echo ""
	sleep 2
	cd $commerce123DockerFolder
	docker run -it -d --name $commerce123HybrisContainerName -h $commerce123HybrisContainerName -v $HYBRIS_COMMERCE123_DIR:$HYBRIS_COMMERCE123_DIR/  --network=$dockerNetworkName --ip 172.100.0.101 -e DB_USERNAME=docker_hybris -e DB_PASSWORD="docker_hybris" $commerce123HybrisImageName:1808
	echo ""
	pause
	;;

6)
	clear
	echo "Hybris Commerce 123 - See installation logs container '$commerce123HybrisContainerName'..." OK
	echo ""
	echo "Copy the command below and execute it inside the container: "
	echo "cd ~ && tail -f entrypoint.log"
	echo ""
	echo "Ready? y (yes) | n (no)"
	read ready
	
	while [ $ready != y ]
	do
		echo "So... copy the command!"
		echo ""
		echo "Ready? y (yes) | n (no)"
		read ready
	done
	
	echo "Returning..." OK
	sleep 1

	echo ""
	pause
	;;

7)
	clear
	echo "Hybris Commerce 123 - First use - Change Solr url..." OK
	echo ""
	echo "By default, Solr server are configured at HTTPS, but Solr server is usually at HTTP, not HTTPS. So, follow these steps: "
	echo ""
	echo "1 - Access the HAC: https://172.100.0.101:9002/console/scripting"
	echo "2 - Execute the Groovy in 'COMMIT': "
	echo "
	import de.hybris.platform.solrfacetsearch.model.config.SolrServerConfigModel;
  
	flexibleSearchService = spring.getBean 'flexibleSearchService'
	modelService = spring.getBean 'modelService'

	SolrServerConfigModel solrServerConfigModel = new SolrServerConfigModel();
	solrServerConfigModel.setName('Default');

	solrServerConfigModel = flexibleSearchService.getModelByExample(solrServerConfigModel)

	solrServerConfigModel.solrEndpointUrls.each{
	  println 'Before URL change: ' + it.url
	  
	  it.url = 'http://172.100.0.101:8983/solr';
	  
	  println 'After URL change: ' + it.url
	  
	  modelService.save(it)
	}
	modelService.save(solrServerConfigModel)
	"
	echo ""
	pause
	;;
	
8)
	clear
	echo "Hybris Commerce 123 - See execution logs inside container '$commerce123HybrisContainerName'..." OK
	echo ""
	todayDate=$(date -d today '+%Y%m%d')
	echo "Executing command: docker exec $commerce123HybrisContainerName tail -f $HYBRIS_COMMERCE123_DIR/hybris/log/tomcat/console-$todayDate.log"
	echo ""
	sleep 1
	docker exec $commerce123HybrisContainerName tail -f $HYBRIS_COMMERCE123_DIR/hybris/log/tomcat/console-$todayDate.log
	echo ""
	pause
	;;

9)
	clear
	echo "Hybris Commerce 123 - Execute bash inside the container '$commerce123HybrisContainerName'..." OK
	echo ""
	echo "docker exec -it $commerce123HybrisContainerName bash"
	echo ""
	sleep 1
	docker exec -it $commerce123HybrisContainerName bash
	echo ""
	pause
	;;

10)
	clear
	echo "Hybris Commerce 123 - Run '$commerce123HybrisContainerName' container..." OK
	echo ""
	echo "Run '$commerce123MysqlContainerName' before? If you configured Hybris with MySQL, it is necessary! y (yes) | n (no)"
	read prosseguir
		y=true;	
		if [ $prosseguir == y ]
			then
				echo ""
				echo "docker start $commerce123MysqlContainerName"
				echo ""
				sleep 1
				docker start $commerce123MysqlContainerName
				echo ""
			fi
	echo ""
	echo "docker start $commerce123HybrisContainerName"
	echo ""
	sleep 1
	docker start $commerce123HybrisContainerName
	echo ""
	pause
	;;

11)
	clear
	echo "Hybris Commerce 123 - Stop '$commerce123HybrisContainerName' container..." OK
	echo ""
	echo "Stop '$commerce123MysqlContainerName' before? If you configured Hybris with MySQL, it is necessary! y (yes) | n (no)"
	read prosseguir
		y=true;	
		if [ $prosseguir == y ]
			then
				echo ""
				echo "docker stop $commerce123MysqlContainerName"
				echo ""
				sleep 1
				docker stop $commerce123MysqlContainerName
				echo ""
			fi
	echo ""
	echo "docker stop $commerce123HybrisContainerName"
	echo ""
	sleep 1
	docker stop $commerce123HybrisContainerName
	echo ""
	pause
	;;
	
12)
	clear
	echo "Hybris Commerce 123 - Ant clean all..." OK
	echo ""
	echo "Executing command: docker build . -f Commerce123.Dockerfile -t $commerce123HybrisImageName:1808"
	echo ""
	sleep 1
	docker exec $commerce123HybrisContainerName /etc/init.d/hybris ant_clean_all
	echo ""
	pause
	;;

13)
	clear
	echo "Hybris Commerce 123 - Run Hybris (debug)..." OK
	echo ""
	echo "Executing command: docker exec $commerce123HybrisContainerName /etc/init.d/hybris debug"
	echo ""
	sleep 1
	docker exec $commerce123HybrisContainerName /etc/init.d/hybris debug
	echo ""
	pause
	;;

14)
	clear
	echo "Hybris Commerce 123 - Restart Hybris (debug)..." OK
	echo ""
	echo "Executing command: docker exec $commerce123HybrisContainerName /etc/init.d/hybris restart"
	echo ""
	sleep 1
	docker exec $commerce123HybrisContainerName /etc/init.d/hybris stop
	docker exec $commerce123HybrisContainerName /etc/init.d/hybris debug
	echo ""
	pause
	;;
	
15)
	clear
	echo "Hybris Commerce 123 - Stop Solr.." OK
	echo ""
	echo "Executing command: docker exec $commerce123HybrisContainerName cd $HYBRIS_COMMERCE123_DIR/hybris/bin/platform && . ./setantenv.sh && ant startSolrServer"
	echo ""
	sleep 1
	docker exec $commerce123HybrisContainerName cd $HYBRIS_COMMERCE123_DIR/hybris/bin/platform && . ./setantenv.sh && ant stopSolrServer
	echo ""
	pause
	;;

16)
	clear
	echo "Hybris Commerce 123 - Start Solr..." OK
	echo ""
	echo "Executing command: docker exec $commerce123HybrisContainerName cd $HYBRIS_COMMERCE123_DIR/hybris/bin/platform && . ./setantenv.sh && ant startSolrServer"
	echo ""
	sleep 1
	docker exec $commerce123HybrisContainerName cd $HYBRIS_COMMERCE123_DIR/hybris/bin/platform && . ./setantenv.sh && ant startSolrServer
	echo ""
	pause
	;;
	
17)
	clear
	echo "Leaving..."
	clear
	exit;
	;;
	
*)
	echo "Invalid option!"

esac
}

while true
do
	show_menu
	read_options
done
menu
