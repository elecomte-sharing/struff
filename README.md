# STRUFF - some personal stuff for project building

Just a script-only solution for building a minimal CI service + a default integration instance of any project

## How it works

The idea is to use basic cronned scripts on your CI "server" (can be whatever you want), with docker and docker-compose installed. It will launch a git pull, run a "pipeline" script from your project where you can build, package, test, deploy, and mostly, build a docker container, and configure a running "instance" which is automatically started with docker-compose. You combine this way CI service + CD of an integration instance, just with a few script using docker.

The pipeline script is a standard bash script, with specific folders.

The "source" script is the installer. It prepares everything, including other scripts.

_WORK IN PROGRESS, THIS IS A PERSONAL TEMP SCRIPT. YOU ARE FREE TO USE IT AT YOUR OWN RISK_

## "Server" Install

(need to be sudoer)

    sudo ./install-struff.sh

Will install all what you need in $(pwd)/struff. You can put root struff/struff.sh script to $PATH or as a function. You should be sudoer when using struff (for now, will not be needed in next version).

It will create a ssh key into $(pwd)/struff/work/.ssh to copy on your github account.

The script can also be used to "update" an existing struff install : simply get last version of the script, launch it, and when asked for, hit "u"

## "Server" use

The entry point script "struff.sh" uses parameters :

    struff.sh [PROJECT NAME] [TASK] [OPTION]

[TASK] allows to launch, update, stop ... Every processes are ran with a specific user "struff-user", added to docker group. 

**To add a new projet** 

    struff.sh [PROJECT NAME] init [PROJECT GITHUB URL]
    ## For example :
    struff.sh myproj init git@github.com:elecomte-sharing/myproject.git
    
It will checkout the project into struff/work/[PROJECT NAME], and create a new instance folder. In the instance folder, folders "tmp" and "logs" are automatically created.

**To update an existing project**

    struff.sh [PROJECT NAME] update
    ## For example : 
    struff.sh myproj update

Will pull, run the project pipeline and then upgrade the instance.

**To check the installation for a project**

    struff.sh [PROJECT NAME] check

**To stop a project running instance**

    struff.sh [PROJECT NAME] stop

**To start a project running instance**

    struff.sh [PROJECT NAME] start

**To copy any file into instance folder**

_Do not attempt to copy manually files into instance folders, use this command instead :_

    struff.sh [PROJECT NAME] copy-to-instance [FILE]
    ## For example : 
    struff.sh myproj copy-to-instance ~/cfg.yml

This way you can add dedicated files on instance, for example config files to mount with docker volume

**To drop a projet** 

    struff.sh [PROJECT NAME] drop
    
Will remove working folders, instances ...

## "pipeline" model : struff.sh in your project.

Simply add a struff.sh file in your project.

Some rules on what's going on when running this script : 
* Current user has limited rights
* Current user **can use docker** (that's how you build your pipeline)
* Current working directory is root of checkout sources
* To use ref to local directory on volumn mount for docker, you can use /project
* For instance root folder you can use /instance
* For folder to use as (shared) cache you can use /cache. /cache/maven is for maven, /cache/npm for npm node_modules ...
* Docker compose is used in instance
* All resources copied in /instance from struff script can use also "/project", "/instance", "/cache" ...

**Here an example**

    #!/bin/bash

    ## MVN build
    docker run -it --rm \
        -v /cache/maven:/root/.m2 \
        -v /project:/usr/src/mymaven \
        -w /usr/src/mymaven maven:3.3-jdk-8 /bin/bash \
        -c "mvn --batch-mode install; cp /usr/src/mymaven/src/docker/* /usr/src/mymaven/target"

    ## Docker build
    docker build -t my-project:latest ./target

    ## Prepare instance
    cp /project/src/docker/docker-compose.yml /instance/docker-compose.yml

    ## Completed
    echo "my-project build completed"

With docker run command in the struff "closed" environment, you can build whatever you want. + IT IS STILL POSSIBLE TO RUN THIS SCRIPT ALONE (see further)

**Here the content of the docker-compose.yml copied by pipeline**

    version: '2'

    services:
        param-gest:
            image: my-project:latest
            restart: always
            ports:
            - 8080:8080
            volumes:
            - /instance/application.yml:/cfg/application.yml:ro
            - /instance/logs:/tmp
            - /instance/tmp:/logs
            container_name: my-project-struff

## Running pipeline script standalone

Work in progress - 3 solutions for managing the substition on "/project", "/instance" ... :

* Substitution with sed (that's what is used by struff)
* Docker in docker
* SimLink (but as the paths are in root folder ...)
