FROM osrf/ros:galactic-desktop-focal

# Tell the container to use the C.UTF-8 locale for its language settings
ENV LANG C.UTF-8

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install required packages
RUN set -x \
    && apt-get update \
    && apt-get --with-new-pkgs upgrade -y \
    && apt-get install -y git \
    && apt-get install ros-galactic-joint-state-publisher -y \
    && apt-get install ros-galactic-robot-state-publisher -y \
    && apt-get install ros-galactic-cartographer -y \
    && apt-get install ros-galactic-cartographer-ros -y \ 
    && apt-get install ros-galactic-gazebo-plugins -y \
    && apt-get install ros-galactic-teleop-twist-keyboard -y \  
    && apt-get install ros-galactic-teleop-twist-joy -y \
    && apt-get install ros-galactic-xacro ros-galactic-nav2* -y \ 
    && apt-get install ros-galactic-urdf ros-galactic-v4l2-camera -y \
    && apt-get install git -y \
    && rm -rf /var/lib/apt/lists/*

# Link python3 to python otherwise ROS scripts fail when using the OSRF contianer
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set up the simulation workspace
WORKDIR /
RUN mkdir -p simulation_ws/src
WORKDIR /simulation_ws/src

# Git clone tortoisebot_waypoits package with tests 
RUN /bin/bash -c "git clone https://github.com/Romu10/GTest-Framework-for-ROS2.git"

# build
WORKDIR /simulation_ws
RUN /bin/bash -c "source /opt/ros/galactic/setup.bash && colcon build --packages-select waypoints_interfaces"
RUN /bin/bash -c "source install/setup.bash && colcon build"

# replace setup.bash in ros_entrypoint.sh
RUN sed -i 's|source "/opt/ros/\$ROS_DISTRO/setup.bash"|source "/simulation_ws/install/setup.bash"|g' /ros_entrypoint.sh

# Set up the Network Configuration
# Example with the ROS_MASTER_URI value set as the one running on the Host System
# ENV ROS_MASTER_URI http://1_simulation:11311

# Cleanup
RUN rm -rf /root/.cache

# Start a bash shell when the container starts
CMD ["bash"]
