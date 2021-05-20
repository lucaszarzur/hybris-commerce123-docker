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

        copy_db_driver
        
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