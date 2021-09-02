#Install Docker Engine On Ubuntu
#Reference: https://docs.docker.com/engine/install/ubuntu/

check_permission(){
    touch /bin/test.txt 2> /dev/null 1>/dev/null

    if [ $? -ne 0 ]; then
	echo "permission error, try to run  this script wih sudo option"; 
	echo ""
	echo "Example: sudo $0"
	echo ""
	exit 1; 
    fi 
    
    rm /bin/test.txt
}

update_repo(){
    	apt-get update -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	apt-key fingerprint 0EBFCD88
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    	apt-get update -y
}

clean_old_docker(){
	echo "Uninstall old version"
	apt-get -y purge docker-ce docker-ce-cli containerd.io
	rm -rf /var/lib/docker
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
	apt-get install -y docker-ce docker-ce-cli containerd.io
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
	systemctl stop docker.service
	systemctl start docker.service
	systemctl enable docker.service
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

check_permission

if [ "$1" = "clean" || "$2" = "clean" || "$3" = "clean" ]; then
    clean_old_docker
fi

update_repo
install_docker_engine_dependencies
install_docker_engine
set_docker_engine_permission
enable_docker_engine
verify_docker_engine_installation
