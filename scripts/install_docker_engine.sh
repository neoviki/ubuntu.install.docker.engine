########## COMMON_CODE_BEGIN()   ########
CMD=""
CLEAN=0

ARG0=$0
ARG1=$1
ARG2=$2
ARG3=$3

os_support_check(){
    OS_SUPPORTED=0

    #Check Ubuntu 18.04 Support    
    cat /etc/lsb-release | grep 18.04 2> /dev/null 1> /dev/null
    if [ $? -eq 0 ]; then
        OS_SUPPORTED=1
    fi

    #Check Ubuntu 16.04 Support    
    cat /etc/lsb-release | grep 18.04 2> /dev/null 1> /dev/null
    if [ $? -eq 0 ]; then
        OS_SUPPORTED=1
    fi

    if [ $OS_SUPPORTED -eq 0 ]; then
	echo
	echo "Utility is not supported in this version of linux"
	echo
	exit 1
    fi

}


get_command(){
    if [ "$ARG0" == "sudo" ]; then
        CMD="$ARG1"
    else
        CMD="$ARG0"
    fi

    if [ "$ARG1" = "clean" ]; then
	CLEAN=1
    fi

    if [ "$ARG2" = "clean" ]; then
	CLEAN=1
    fi

    if [ "$ARG3" = "clean" ]; then
	CLEAN=1
    fi

}

check_permission(){
    touch /bin/test.txt 2> /dev/null 1>/dev/null

    if [ $? -ne 0 ]; then
	echo "permission error, try to run this script wih sudo option"; 
	echo ""
	echo "Example: sudo $CMD"
	echo ""
	exit 1; 
    fi 
    
    rm /bin/test.txt
}

check_utility(){
	which $1 2> /dev/null  1> /dev/null
	if [ $? -eq 0 ]; then
		echo
		echo "[ status ] $1 already installed"
		echo ""
		echo "For clean install try,"
		echo
		echo "$CMD clean"
		echo
		echo "(or)"
		echo
	        echo "sudo $CMD clean"
		echo ""
		exit 0
	fi
}

init_bash_installer(){
    os_support_check
    get_command
    check_permission
}
########## COMMON_CODE_END()   ########


update_repo(){
    	apt-get update -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	apt-key fingerprint 0EBFCD88
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    	apt-get update -y
}

stop_docker_engine(){
	systemctl stop docker.service 2>/dev/null 1>/dev/null
	sleep 5
}

clean_old_docker(){
    	if [ $CLEAN -eq 1 ]; then
		stop_docker_engine
		echo "Uninstall old version"
		apt-get -y purge docker-ce docker-ce-cli containerd.io
		rm -rf /var/lib/docker
	fi
}


install_docker_engine_dependencies(){
	echo "Installing Dependencies"
	#apt-get install -y linux-image-extra-$(uname -r)
	apt-get install -y linux-modules-extra-$(uname -r)
	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	apt-get install -y apt-transport-https
	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	apt-get install -y ca-certificates 
	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	apt-get install -y curl 
	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	apt-get install -y gnupg-agent 
	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	apt-get install -y software-properties-common

}

install_docker_engine(){
	echo "Installing Docker Engine"
	apt-get update -y

	FLAG=0
	for i in 1 2 3 4 5
	do
	    apt-get install -y docker-ce
	    if [ $? -eq 0 ]; then
		FLAG=1
	        break
	    fi
	    dpkg --configure -a
	    apt-get install -y -f  docker-ce
	    if [ $? -eq 0 ]; then
		FLAG=1
	        break
	    fi

        done

	[ $FLAG -eq 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	
	apt-get install -y docker-ce-cli
	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	apt-get install -y containerd.io
	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
}

install_docker_engine_specific_version(){
	#Install Specific Version Of Docker
	#List all docker versions
	apt-cache madison docker-ce
	#Example Output: ->  docker-ce | 5:18.09.1~3-0~ubuntu-xenial 
	#sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
	#<VERSION_STRING> looks like this -> 5:18.09.1~3-0~ubuntu-xenial.
}


set_docker_engine_permission(){
	groupadd docker &> /dev/null
	usermod -aG docker $USER 
	newgrp docker &
	sleep 10
}


enable_docker_engine(){
	#sudo systemctl restart docker
	for i in 1 2 3 4 5
	do
	    systemctl stop docker.service 
	    sleep 1
	    systemctl start docker.service
	    sleep 1
	    systemctl enable docker.service
	    if [ $? -eq 0 ]; then
		break
	    fi
	    sleep 1
	done
	#sudo chmod 666 /var/run/docker.sock
	#sudo setfacl -m user:${USER}:rw /var/run/docker.sock
	
}

verify_docker_engine_installation(){
	echo "Running Hello World Program"

	docker run hello-world &> /dev/null 
	if [ $? -eq 0 ]; then
		echo "Docker Installation Successful!"
	else
		echo "[ ERROR ] Docker Installation"
		exit 1
	fi
}

init_bash_installer

clean_old_docker
check_utility "docker"
update_repo
install_docker_engine_dependencies
install_docker_engine
set_docker_engine_permission
enable_docker_engine
verify_docker_engine_installation
