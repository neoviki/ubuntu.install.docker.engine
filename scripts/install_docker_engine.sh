#Install Docker Engine On Ubuntu
#Reference: https://docs.docker.com/engine/install/ubuntu/


sudo apt-get update -y

echo "Uninstall old version"

sudo apt-get -y purge docker-ce docker-ce-cli containerd.io

sudo rm -rf /var/lib/docker


sudo apt-get install linux-image-extra-$(uname -r)



echo "Installing Dependencies"
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "Installing Docker Engine"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

#Install Specific Version Of Docker
#List all docker versions
#apt-cache madison docker-ce
#Example Output: ->  docker-ce | 5:18.09.1~3-0~ubuntu-xenial 


#sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
#<VERSION_STRING> looks like this -> 5:18.09.1~3-0~ubuntu-xenial.

sudo groupadd docker &> /dev/null
sudo usermod -aG docker $USER
newgrp docker 

#sudo systemctl restart docker
sudo systemctl stop docker.service
sudo systemctl start docker.service
sudo systemctl enable docker.service


#sudo chmod 666 /var/run/docker.sock
#sudo setfacl -m user:${USER}:rw /var/run/docker.sock


echo "Running Hello World Program"

docker run hello-world


if [ $? -eq 0 ]; then
    echo "Docker Installation Successful!"
else
    echo "[ ERROR ] Docker Installation"
fi
