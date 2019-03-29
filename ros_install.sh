#!/bin/bash
# The BSD License
# Copyright (c) 2014 OROCA and ROS Korea Users Group

set -x

function usage {
    # Print out usage of this script.
    echo >&2 "usage: $0 [catkin workspace name (default:catkin_ws)] [ROS distro (default: kinetic)] [ROS configurations (default: desktop-full, available: desktop-full, desktop, base)]"
    echo >&2 "          [-h|--help] Print help message."
    exit 0
}
# Parse command line. If the number of argument differs from what is expected, call `usage` function.
OPT=`getopt -o h -l help -- $*`
if [ $# != 3 ]; then
    usage
fi
eval set -- $OPT
while [ -n "$1" ] ; do
    case $1 in
        -h|--help) usage ;;
        --) shift; break;;
        *) echo "Unknown option($1)"; usage;;
    esac
done

name_catkinws=$1
name_catkinws=${name_catkinws:="catkin_ws"}
name_ros_distro=$2
name_ros_distro=${name_ros_distro:="kinetic"}
name_ros_config=$3
name_ros_config=${name_ros_config:="desktop-full"}

version=`lsb_release -sc`

echo "[Checking the ubuntu version]"
case $version in
  "saucy" | "trusty" | "vivid" | "wily" | "xenial")
  ;;
  *)
    echo "ERROR: This script will only work on Ubuntu Saucy(13.10) / Trusty(14.04) / Vivid / Wily / Xenial. Exit."
    exit 0
esac

echo "[Update & upgrade the package]"
sudo apt-get update
sudo apt-get upgrade

echo "[Check the 14.04.2 TLS issue]"
relesenum=`grep DISTRIB_DESCRIPTION /etc/*-release | awk -F 'Ubuntu ' '{print $2}' | awk -F ' LTS' '{print $1}'`
if [ "$relesenum" = "14.04.2" ]
then
  echo "Your ubuntu version is $relesenum"
  echo "Intstall the libgl1-mesa-dev-lts-utopic package to solve the dependency issues for the ROS installation specifically on $relesenum"
  sudo apt-get install -y libgl1-mesa-dev-lts-utopic
else
  echo "Your ubuntu version is $relesenum"
fi

echo "[Installing chrony and setting the ntp:=date]"
sudo apt-get install -y chrony
sudo ntpdate ntp.ubuntu.com

echo "[Add the ROS repository]"
if [ ! -e /etc/apt/sources.list.d/ros-latest.list ]; then
  sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"
fi

echo "[Download the ROS keys]"
roskey=`apt-key list | grep "ROS builder"`
if [ -z "$roskey" ]; then
  wget --quiet https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -
fi

echo "[Update & upgrade the package]"
sudo apt-get update
sudo apt-get upgrade

echo "[Installing ROS version: $name_ros_distro, config: $name_ros_config]"
sudo apt-get install -y ros-$name_ros_distro-$name_ros_config ros-$name_ros_distro-rqt-*

echo "[rosdep init and python-rosinstall]"
sudo sh -c "rosdep init"
rosdep update
. /opt/ros/$name_ros_distro/setup.sh
sudo apt-get install -y python-rosdep python-catkin-tools python-rosinstall-generator python-wstool python-rosinstall build-essential 

echo "[enable python3 support]"
sudo apt-get install -y python3-dev python3-pip python3-yaml python3-setuptools python3-catkin-tools
sudo pip3 install -y rospkg catkin_pkg

echo "[Making the catkin workspace and testing the catkin_make]"
mkdir -p ~/$name_catkinws/src
cd ~/$name_catkinws
catkin init
cd ~/$name_catkinws/
catkin build

echo "[Setting the ROS evironment]"
sh -c "echo \"source /opt/ros/$name_ros_distro/setup.bash\" >> ~/.bashrc"
sh -c "echo \"source ~/$name_catkinws/devel/setup.bash\" >> ~/.bashrc"
sh -c "echo \"export ROS_MASTER_URI=http://localhost:11311\" >> ~/.bashrc"
sh -c "echo \"export ROS_HOSTNAME=localhost\" >> ~/.bashrc"

echo "[Complete!!!]"

exec bash

exit 0
