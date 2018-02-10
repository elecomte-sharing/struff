#!/bin/bash

echo "===> Struff installation script"
LOCATION="$(pwd)/struff"
TASKS="$LOCATION/tasks"
WORK="$LOCATION/work"
CACHE="$LOCATION/cache"

function _create_init_script ()
{
    echo " => Create script init.sh"
    [ -f $TASKS/init.sh ] && rm $TASKS/init.sh
    touch $TASKS/init.sh
    echo "#!/bin/bash" >>  $TASKS/init.sh
    echo "" >>  $TASKS/init.sh
    echo "CHECKOUT_FOLDER=\$1" >>  $TASKS/init.sh
    echo "INSTANCE_FOLDER=\$2" >>  $TASKS/init.sh
    echo "GIT_PROJECT=\$3" >>  $TASKS/init.sh
    echo "" >>  $TASKS/init.sh
    echo "echo \" => Create a new project \$3 at \$1\"" >>  $TASKS/init.sh
    echo "" >>  $TASKS/init.sh
    echo "git clone \$GIT_PROJECT \$CHECKOUT_FOLDER" >>  $TASKS/init.sh
    echo "mkdir -p \$INSTANCE_FOLDER/tmp" >>  $TASKS/init.sh
    echo "mkdir -p \$INSTANCE_FOLDER/log" >>  $TASKS/init.sh
    echo "" >>  $TASKS/init.sh
    echo "echo \" => Project initialized\"" >>  $TASKS/init.sh
}

function _create_check_script ()
{
    echo " => Create script check.sh"
    [ -f $TASKS/check.sh ] && rm $TASKS/check.sh
    touch $TASKS/check.sh
    echo "#!/bin/bash" >>  $TASKS/check.sh
    echo "" >>  $TASKS/check.sh
    echo "CHECKOUT_FOLDER=\$1" >>  $TASKS/check.sh
    echo "INSTANCE_FOLDER=\$2" >>  $TASKS/check.sh
    echo "" >>  $TASKS/check.sh
    echo "echo \" => Checking the project : CHECKOUT @ \$CHECKOUT_FOLDER, INSTANCE @ \$INSTANCE_FOLDER\"" >>  $TASKS/check.sh
    echo "" >>  $TASKS/check.sh
    echo "echo \" => Checkout content : \$(ls -m \$CHECKOUT_FOLDER)\"" >> $TASKS/check.sh
    echo "echo \" => Instance content : \$(ls -m \$INSTANCE_FOLDER)\"" >>  $TASKS/check.sh
    echo "" >>  $TASKS/check.sh
    echo "echo \" => Project checked\"" >>  $TASKS/check.sh
}

function _create_copy-to-instance_script ()
{
    echo " => Create script copy-to-instance.sh"
    [ -f $TASKS/copy-to-instance.sh ] && rm $TASKS/copy-to-instance.sh
    touch $TASKS/copy-to-instance.sh
    echo "#!/bin/bash" >>  $TASKS/copy-to-instance.sh
    echo "" >>  $TASKS/copy-to-instance.sh
    echo "CHECKOUT_FOLDER=\$1" >>  $TASKS/copy-to-instance.sh
    echo "INSTANCE_FOLDER=\$2" >>  $TASKS/copy-to-instance.sh
    echo "FILE_TO_COPY=\$3" >>  $TASKS/copy-to-instance.sh
    echo "" >>  $TASKS/copy-to-instance.sh
    echo "echo \" => Copying file \$FILE_TO_COPY to instance at \$INSTANCE_FOLDER\"" >>  $TASKS/copy-to-instance.sh
    echo "" >>  $TASKS/copy-to-instance.sh
    echo "cp \$FILE_TO_COPY \$INSTANCE_FOLDER" >>  $TASKS/copy-to-instance.sh
    ## Filter files copied for instance
    echo "dos2unix \$INSTANCE_FOLDER/\${\$FILE_TO_COPY##*/}" >>  $TASKS/copy-to-instance.sh
    echo "sed -i -e 's,/project,\$GIT_CHECK_FOLDER,g' \$INSTANCE_FOLDER/\${\$FILE_TO_COPY##*/}" >>  $TASKS/copy-to-instance.sh
    echo "sed -i -e 's,/instance,\$INSTANCE_FOLDER,g' \$INSTANCE_FOLDER/\${\$FILE_TO_COPY##*/}" >>  $TASKS/copy-to-instance.sh
    echo "sed -i -e 's,/cache,$CACHE,g' \$INSTANCE_FOLDER/\${\$FILE_TO_COPY##*/}" >>  $TASKS/copy-to-instance.sh
    echo "" >>  $TASKS/copy-to-instance.sh
    echo "echo \" => File copied\"" >>  $TASKS/copy-to-instance.sh
}

function _create_drop_script ()
{
    echo " => Create script drop.sh"
    [ -f $TASKS/drop.sh ] && rm $TASKS/drop.sh
    touch $TASKS/drop.sh
    echo "#!/bin/bash" >>  $TASKS/drop.sh
    echo "" >>  $TASKS/drop.sh
    echo "CHECKOUT_FOLDER=\$1" >>  $TASKS/drop.sh
    echo "INSTANCE_FOLDER=\$2" >>  $TASKS/drop.sh
    echo "" >>  $TASKS/drop.sh
    echo "echo \" => Droping an existing project at \$1\"" >>  $TASKS/drop.sh
    echo "" >>  $TASKS/drop.sh
    echo "rm -rf \$CHECKOUT_FOLDER" >>  $TASKS/drop.sh
    echo "rm -rf \$INSTANCE_FOLDER" >>  $TASKS/drop.sh
    echo "" >>  $TASKS/drop.sh
    echo "echo \" => Project droped\"" >>  $TASKS/drop.sh
}

function _create_start_script ()
{
    echo " => Create script start.sh"
    [ -f $TASKS/start.sh ] && rm $TASKS/start.sh
    touch $TASKS/start.sh
    echo "#!/bin/bash" >>  $TASKS/start.sh
    echo "" >>  $TASKS/start.sh
    echo "INSTANCE=\$2" >>  $TASKS/start.sh
    echo "" >>  $TASKS/start.sh
    echo "echo \" => Starting running instance at \$INSTANCE\"" >>  $TASKS/start.sh
    echo "" >>  $TASKS/start.sh
    echo "cd \$2" >>  $TASKS/start.sh
    echo "docker-compose up -d" >>  $TASKS/start.sh
    echo "" >>  $TASKS/start.sh
    echo "echo \" => Instance started\"" >>  $TASKS/start.sh
}

function _create_stop_script ()
{
    echo " => Create script stop.sh"
    [ -f $TASKS/stop.sh ] && rm $TASKS/stop.sh
    touch $TASKS/stop.sh
    echo "#!/bin/bash" >>  $TASKS/stop.sh
    echo "" >>  $TASKS/stop.sh
    echo "INSTANCE=\$2" >>  $TASKS/stop.sh
    echo "" >>  $TASKS/stop.sh
    echo "echo \" => Stopping running instance at \$INSTANCE\"" >>  $TASKS/stop.sh
    echo "" >>  $TASKS/stop.sh
    echo "cd \$2" >>  $TASKS/stop.sh
    echo "docker-compose stop" >>  $TASKS/stop.sh
    echo "" >>  $TASKS/stop.sh
    echo "echo \" => Instance stopped\"" >>  $TASKS/stop.sh
}

function _create_update_script ()
{
    echo " => Create script update.sh"
    [ -f $TASKS/update.sh ] && rm $TASKS/update.sh
    touch $TASKS/update.sh
    echo "#!/bin/bash" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    echo "echo \" => Updatng project with source into $1\"" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    echo "GIT_CHECK_FOLDER=\$1" >>  $TASKS/update.sh
    echo "INSTANCE_FOLDER=\$2" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    echo "cd \$GIT_CHECK_FOLDER" >>  $TASKS/update.sh
    echo "git pull" >>  $TASKS/update.sh
    echo "cp ./struff.sh ./run-struff.sh" >>  $TASKS/update.sh
    echo "dos2unix ./run-struff.sh" >>  $TASKS/update.sh
    echo "chmod +x ./run-struff.sh" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    ## prepare temp folder to instance as the location is unknown from the project pipeline
    echo "mkdir \$GIT_CHECK_FOLDER/.instance" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    ## Filter pipeline file to substitute values
    echo "sed -i -e 's,/project,\$GIT_CHECK_FOLDER,g' ./run-struff.sh" >>  $TASKS/update.sh
    echo "sed -i -e 's,/instance,\$INSTANCE_FOLDER,g' ./run-struff.sh" >>  $TASKS/update.sh
    echo "sed -i -e 's,/cache,$CACHE,g' ./run-struff.sh" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    echo "echo \" => Launching pipeline\"" >>  $TASKS/update.sh
    echo "./run-struff.sh \$GIT_CHECK_FOLDER" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    ## Filter files copied for instance
    echo "dos2unix \$GIT_CHECK_FOLDER/.instance/*" >>  $TASKS/update.sh
    echo "sed -i -e 's,/project,\$GIT_CHECK_FOLDER,g' \$GIT_CHECK_FOLDER/.instance/*" >>  $TASKS/update.sh
    echo "sed -i -e 's,/instance,\$INSTANCE_FOLDER,g' \$GIT_CHECK_FOLDER/.instance/*" >>  $TASKS/update.sh
    echo "sed -i -e 's,/cache,$CACHE,g' \$GIT_CHECK_FOLDER/.instance/*" >>  $TASKS/update.sh
    ## And now copy them to instance
    echo "cp \$GIT_CHECK_FOLDER/.instance/* \$INSTANCE_FOLDER" >>  $TASKS/update.sh
    echo "rm \$GIT_CHECK_FOLDER/.instance" >>  $TASKS/update.sh
    echo "rm ./run-struff.sh" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    echo "echo \" => Updating the integration instance\"" >>  $TASKS/update.sh
    echo "cd \$INSTANCE_FOLDER" >>  $TASKS/update.sh
    echo "docker-compose up -d" >>  $TASKS/update.sh
    echo "" >>  $TASKS/update.sh
    echo "echo \" => Update completed\"" >>  $TASKS/update.sh
}

function _create_root_script 
{
    echo " => Create root script struff.sh"
    [ -f $LOCATION/struff.sh ] && rm $LOCATION/struff.sh
    touch $LOCATION/struff.sh
    echo "#!/bin/bash" >>  $LOCATION/struff.sh
    echo "" >>  $LOCATION/struff.sh
    echo "echo \"\"" >>  $LOCATION/struff.sh
    echo "echo \"===> STRUFF - \$2\"" >>  $LOCATION/struff.sh
    echo "" >>  $LOCATION/struff.sh
    echo "INSTALL_ROOT=\"/opt/server/struff\"" >>  $LOCATION/struff.sh
    echo "PROJECT_PATH=\"\$INSTALL_ROOT/work/\$1\"" >>  $LOCATION/struff.sh
    echo "INSTANCE_PATH=\"\$INSTALL_ROOT/work/.instances/\$1\"" >>  $LOCATION/struff.sh
    echo "COMMAND_TASK=\$2" >>  $LOCATION/struff.sh
    echo "OPTION=\$3" >>  $LOCATION/struff.sh
    echo "" >>  $LOCATION/struff.sh
    echo "echo \" => Working on project \$PROJECT_PATH, with instance in \$INSTANCE_PATH\"" >>  $LOCATION/struff.sh
    echo "" >>  $LOCATION/struff.sh
    echo "COMMAND=\"\$INSTALL_ROOT/tasks/\$COMMAND_TASK.sh \$PROJECT_PATH \$INSTANCE_PATH \$OPTION\"" >>  $LOCATION/struff.sh
    echo "" >>  $LOCATION/struff.sh
    echo "sudo -u struff-user bash -c \"\$COMMAND\"" >>  $LOCATION/struff.sh
    echo "" >>  $LOCATION/struff.sh
    echo "echo \"===> STRUFF - completed\"" >>  $LOCATION/struff.sh
    echo "echo \"\"" >>  $LOCATION/struff.sh
}


## Init of all scripts
function _create_scripts ()
{
    mkdir -p $TASKS
    _create_init_script
    _create_check_script
    _create_copy-to-instance_script
    _create_drop_script
    _create_start_script
    _create_stop_script
    _create_update_script
    _create_root_script
    chmod +x $TASKS/*.sh
    chmod +x $LOCATION/struff.sh
}

## Init cache folders
function _prepare_caches ()
{
    mkdir -p $CACHE/maven
    mkdir -p $CACHE/npm
}

## Install function
function _install ()
{
    echo " => installing Struff in $LOCATION"
    mkdir -p $WORK
    mkdir -p $CACHE
    useradd  -d $WORK struff-user
    chown struff-user $WORK
    chown struff-user $CACHE
    groupadd docker
    gpasswd -a struff-user docker
    cd $WORK
    ssh-keygen -t rsa -N "" -f id_rsa
    echo ""
    echo " => Here your public key to add into github :"
    echo ""
    cat $WORK/id_rsa.pub
    echo ""
    cd $(pwd)
    _create_scripts
}

## Update function - update scripts only
function _update ()
{
    echo " => updating Struff in $LOCATION"
    _create_scripts
}

read -p " Do you wish to Install or Update Struff in $(pwd) (will be $LOCATION), or Cancel [iuc] ? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Ii]$ ]]
then
    _install
fi
if [[ $REPLY =~ ^[Uu]$ ]]
then
    _update
fi
if [[ $REPLY =~ ^[Cc]$ ]]
then
    exit
fi

echo "===> Completed"