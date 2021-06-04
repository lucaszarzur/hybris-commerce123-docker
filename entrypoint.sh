#!/bin/bash
# Deskription: Script to install hybris accelerator on docker execution
# Date: 19/05/2021
# Author: Helisandro Krepel
# Maintainer: Paulo Henrique dos Santos, Lucas Zarzur


###################### CONSTANTS #######################
LOG_FILE="$DOCKER_HOME/entrypoint.log"
########################################################


####################### METHODS ######################K#
extract_hybris(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris Commerce 123 directories (hybris)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_COMMERCE123_VERSION" 'hybris/*' -d "$HYBRIS_COMMERCE123_DIR/"  >> "$LOG_FILE"
    
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris Commerce 123 directories (installer)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_COMMERCE123_VERSION" 'installer/*' -d "$HYBRIS_COMMERCE123_DIR/"  >> "$LOG_FILE"
    
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris Commerce 123 directories (build-tools)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_COMMERCE123_VERSION" 'build-tools/*' -d "$HYBRIS_COMMERCE123_DIR/"  >> "$LOG_FILE"
    
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Hybris Commerce 123 directories (licenses)" >> "$LOG_FILE"
    unzip "$DOCKER_HOME/$HYBRIS_COMMERCE123_VERSION" 'licenses/*' -d "$HYBRIS_COMMERCE123_DIR/"  >> "$LOG_FILE"
}

extract_java(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Extracting Java" >> "$LOG_FILE"
    cd "$DOCKER_HOME"
    sudo tar -zxvf "$JAVA_VERSION_FILE"  >> "$LOG_FILE"
    sudo mv jdk1.8.0_211/ /usr/lib/jvm/java-8-oracle/ >> "$LOG_FILE"
}

set_java(){
    java_home=`echo "$JAVA_HOME"`
    if [ "$java_home" = "" ]; then
        
        extract_java
        
        export JAVA_HOME=/usr/lib/jvm/java-8-oracle/  >> "$LOG_FILE"
        source ~/.bashrc
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Setting JAVA_HOME ($JAVA_HOME)" >> "$LOG_FILE"
    else
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - JAVA_HOME ($JAVA_HOME)" >> "$LOG_FILE"
    fi;
}

set_git_options(){
    # Edit with your info
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - GIT Config" >> "$LOG_FILE"
    mkdir -p $HYBRIS_COMMERCE123_CUSTOM_DIR
    cd "$HYBRIS_COMMERCE123_CUSTOM_DIR"
    git config --global user.name "$DEVELOPER_NAME"
    git config --global user.email "$DEVELOPER_EMAIL"
    git config --global core.filemode false
    git config --global core.excludesfile ~/.gitignore
    git config --global alias.lg "log --graph --abbrev-commit --decorate --date=iso --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%cd)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --since=7.days"
    git config --global alias.st "status -sb"
    git config --global merge.ours.driver true
    git config --global pull.ff only
    git config --global merge.ff false
    git config --global http.sslVerify false
    
    echo -e "Host bitbucket.companyHostname\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

    git init >> "$LOG_FILE"
    ## Add remote local for project - uncomment next line, and edit with your project details
    #git remote add origin ssh://git@bitbucket.companyHostname:port/projectName/hybris-custom.git
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Adding repos clcbc" >> "$LOG_FILE"
    git fetch origin $BRANCH_NAME:$BRANCH_NAME >> "$LOG_FILE"
    git checkout $BRANCH_NAME
    git pull origin
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Checkout branch $BRANCH_NAME" >> "$LOG_FILE"
}

copy_installer(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Copping recipes folder to default hybris installer folder" >> "$LOG_FILE"
    cd $HYBRIS_COMMERCE123_CUSTOM_DIR >> "$LOG_FILE"
    cp -R recipes $HYBRIS_COMMERCE123_DIR/installer >> "$LOG_FILE"
}

copy_db_driver(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Coping mysql driver" >> "$LOG_FILE"
    cp "$DOCKER_HOME/$DB_DRIVER" "$HYBRIS_COMMERCE123_DIR/hybris/bin/platform/lib/dbdriver/"
}

configure_mysql_as_default_bd_local_properties(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Configuring mysql as default db - Adding the properties to local properties" >> "$LOG_FILE"

    #db.url=jdbc:mysql://hostname:port/dbName?useConfigs=maxPerformance&characterEncoding=utf8&useSSL=false
    mysql_db_properties_db_url="db.url=jdbc:mysql://localhost:3306/commerce123mod?useConfigs=maxPerformance&characterEncoding=utf8&useSSL\=false"
    mysql_db_properties_db_driver="db.driver=com.mysql.jdbc.Driver"
    mysql_db_properties_db_username="db.username="
    mysql_db_properties_db_password="db.password=$DB_PASSWORD"
    solr_properties_disable_ssl="solrserver.instances.default.ssl.enabled=false" # disable Solr SSL

    echo "$mysql_db_properties_db_url" >> "$HYBRIS_COMMERCE123_DIR/hybris/config/local.properties"
    echo "$mysql_db_properties_db_driver" >> "$HYBRIS_COMMERCE123_DIR/hybris/config/local.properties"
    echo "$mysql_db_properties_db_username" >> "$HYBRIS_COMMERCE123_DIR/hybris/config/local.properties"
    echo "$mysql_db_properties_db_password" >> "$HYBRIS_COMMERCE123_DIR/hybris/config/local.properties"
    echo "$solr_properties_disable_ssl" >> "$HYBRIS_COMMERCE123_DIR/hybris/config/local.properties" # disable Solr SSL

    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - You have configured this Docker image with USE_MYSQL_DB as TRUE, but INITIALIZE as OFF, so the properties was 
    added in local.properties, but you have to do initialize again if you want use mysql" >> "$LOG_FILE"

    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Configuring mysql as default db - Done! Do initialize in HAC!" >> "$LOG_FILE"
}

configure_mysql_as_default_bd_build_gradle(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Configuring mysql as default db - Adding the properties to build.gradle of recipe" >> "$LOG_FILE"

    DB_IP="172.100.0.102"
    
    #db.url=jdbc:mysql://hostname:port/dbName?useConfigs=maxPerformance&characterEncoding=utf8&useSSL=false
    mysql_db_properties_db_url="property 'db.url', 'jdbc:mysql://$DB_IP:3306/commerce123mod?useConfigs=maxPerformance&characterEncoding=utf8&useSSL=false'"
    mysql_db_properties_db_driver="property 'db.driver', 'com.mysql.jdbc.Driver'"
    mysql_db_properties_db_username="property 'db.username', '$DB_USERNAME'"
    mysql_db_properties_db_password="property 'db.password', '$DB_PASSWORD'"
    mysql_db_properties_db_tableprefix="property 'db.tableprefix', ''"
    mysql_db_properties_optional_tabledefs="property 'mysql.optional.tabledefs', 'CHARSET=utf8 COLLATE=utf8_bin'"
    mysql_db_properties_tabletype="property 'mysql.tabletype', 'InnoDB'"
    mysql_db_properties_allow_fractional_seconds="property 'mysql.allow.fractional.seconds', 'false'"
    solr_properties_disable_ssl="property 'solrserver.instances.default.ssl.enabled', 'false'" 
    

    ## Add the properties after match with 'localProperties' in gradle.file. Writed here in DESC order to be ASC order in gradle file
    # disable Solr SSL
    sed -i "/localProperties {/a /* Disable SSL Solr */" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle 
    sed -i "/localProperties {/a $solr_properties_disable_ssl" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a " $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    
    # add db properties
    sed -i "/localProperties {/a $mysql_db_properties_allow_fractional_seconds" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a $mysql_db_properties_tabletype" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a $mysql_db_properties_optional_tabledefs" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a $mysql_db_properties_db_tableprefix" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a $mysql_db_properties_db_password" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a $mysql_db_properties_db_username" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a $mysql_db_properties_db_driver" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a $mysql_db_properties_db_url" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle
    sed -i "/localProperties {/a /* Database */" $HYBRIS_COMMERCE123_DIR/installer/recipes/$RECIPE/build.gradle

    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Configuring mysql as default db - Done!" >> "$LOG_FILE"
}

copy_ssh_keys(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Coping SSH keys to home" >> "$LOG_FILE"
    cd $HYBRIS_COMMERCE123_DIR
    sudo cp -R ssh_keys/id_rsa $DOCKER_HOME/.ssh >> "$LOG_FILE"
    sudo cp -R ssh_keys/id_rsa.pub $DOCKER_HOME/.ssh >> "$LOG_FILE"
    # sudo cp -R ssh_keys/known_hosts $DOCKER_HOME/.ssh >> "$LOG_FILE"
}

run_installer(){
    echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Installing Recipe ($RECIPE)" >> "$LOG_FILE"
    cd "$HYBRIS_COMMERCE123_DIR/installer"
    ./install.sh -r "$RECIPE" >> "$LOG_FILE"
    
    if [ "$INITIALIZE" = 'true' ]; then
        ./install.sh -r "$RECIPE" initialize >> "$LOG_FILE"
    fi;
}

########################################################


######################### MAIN #########################
if [ "$1" = 'run' ]; then
    
    if [ ! -d "$HYBRIS_COMMERCE123_DIR/hybris/config" ]; then
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Changing permition at $HYBRIS_COMMERCE123_DIR to $HYBRIS_COMMERCE123_USER" >> "$LOG_FILE"
        sudo chown -R "$HYBRIS_COMMERCE123_USER":"$HYBRIS_COMMERCE123_USER" "$HYBRIS_COMMERCE123_DIR"  >> "$LOG_FILE"
        sudo chown -R "$HYBRIS_COMMERCE123_USER":"$HYBRIS_COMMERCE123_USER" "$DOCKER_HOME"  >> "$LOG_FILE"
        
        extract_hybris
        
        set_java

        #copy_ssh_keys

        #set_git_options

        #copy_installer

        if [ "$USE_MYSQL_DB" = 'true' ]; then
            copy_db_driver

            if [ "$INITIALIZE" = 'true' ]; then
                configure_mysql_as_default_bd_build_gradle
            else
                configure_mysql_as_default_bd_local_properties
            fi;
            
        fi;

        run_installer

        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - ant clean all" >> "$LOG_FILE"
        /etc/init.d/hybris ant_clean_all >> "$LOG_FILE"
        
        echo "##### Finished... Next Step: do your job! :) #####"  >> "$LOG_FILE"
        echo "##### P.S. Hybris is stopped #####"  >> "$LOG_FILE"
        # /etc/init.d/hybris debug
        
    else
        echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Hybris Directories (hybris, installer) already exists" >> "$LOG_FILE"
        
        set_java
        
        if [ "$INITIALIZE" == "TRUE" ]; then
            echo "`date +%d'/'%m'/'%Y' - '%H':'%M':'%S` - Installing Recipe ($RECIPE)" >> "$LOG_FILE"
            cd "$HYBRIS_COMMERCE123_DIR/installer"
            ./install.sh -r "$RECIPE" >> "$LOG_FILE"
            ./install.sh -r "$RECIPE" initialize >> "$LOG_FILE"
        fi;
    fi;
    
    sleep infinity
fi;
########################################################