#!/bin/bash
# Written by www.continualintegration.com

flinkversion=1.14.3

distro=$(cat /etc/*-release | grep NAME)

debflag=$(echo $distro | grep -i "ubuntu")
if [ -z "$debflag" ]
then   # If it is not Ubuntu, test if it is Debian.
  debflag=$(echo $distro | grep -i "debian")
  echo "determining Linux distribution..."
else
   echo "You have Ubuntu Linux!"
fi

rhflag=$(echo $distro | grep -i "red*hat")
if [ -z "$rhflag" ]
then   #If it is not RedHat, see if it is CentOS or Fedora.
  rhflag=$(echo $distro | grep -i "centos")
  if [ -z "$rhflag" ]
    then    #If it is neither RedHat nor CentOS, see if it is Fedora.
    echo "It does not appear to be CentOS or RHEL..."
    rhflag=$(echo $distro | grep -i "fedora")
    fi
fi

if [ -z "$rhflag" ]
  then
  echo "...still determining Linux distribution..."
else
  echo "You have a RedHat distribution (e.g., CentOS, RHEL, or Fedora)"
  yum -y install java-1.8.0-openjdk* nc   # install nc for initial testing only.
  JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
  echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' >> ~/.bashrc
  source ~/.bashrc
  source /etc/environment
  echo "In our experience Red Hat family of servers need more than 1 GB of memory.  The other distros of Linux don't have this need."
  echo "Your server may or may not have ample memory (either in pure RAM or with swap space).  This message is just an FYI."
  echo "For a script to create virtual memory, try this link: "
  echo "https://www.continualintegration.com/miscellaneous-articles/how-do-you-write-a-bash-script-to-create-virtual-memory-in-the-size-of-2-gb-on-a-linux-server/"
  echo " "
fi

if [ -z "$debflag" ]
then
  echo "...still determining Linux distribution..."
else
   echo "You are using either Ubuntu Linux or Debian Linux."
   apt-get -y update # This is necessary on new AWS Ubuntu servers.
   apt -y install openjdk-11-jre-headless unzip
fi

suseflag=$(echo $distro | grep -i "suse")
if [ -z "$suseflag" ]
then
  if [ -z "$debflag" ]
  then
    if [ -z "$rhflag" ]
      then
      echo "*******************************************"
      echo "Could not determine the Linux distribution!"
      echo "Installation aborted. Nothing was done."
      echo "******************************************"
      exit
    fi
  fi
else
   zypper -n install java-1_8_0-openjdk
fi

#curl -Ls https://dlcdn.apache.org/flink/flink-1.14.3/flink-1.14.3-bin-scala_2.12.tgz > /tmp/flink-$flinkversion-bin-scala_2.12.tgz

curl -Ls https://archive.apache.org/dist/flink/flink-1.14.3/flink-1.14.3-bin-scala_2.11.tgz > /tmp/flink-$flinkversion-bin-scala_2.12.tgz
cd /tmp/
tar -xzvf flink-$flinkversion-bin-scala_2.12.tgz
mv flink-$flinkversion /opt/flink
#./bin/start-cluster.sh    # This is commented out in case you want to customize it before you start it.
ip=$(curl icanhazip.com)
complete=$ip:8081
echo "To start Apache Flink, do the following:"
echo "cd /opt/flink"
echo "Then run: sudo ./bin/start-cluster.sh"
echo "-----------------------------------------"
echo 'Next, after you have started the solo-server Flink "cluster"...'
echo "Open a web browser and go to http://"$complete" to test the installation of Flink on this server"
echo "(This assumes that port 8081 is open)"
