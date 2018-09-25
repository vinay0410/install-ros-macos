brew update
brew install cmake

brew tap ros/deps
brew tap osrf/simulation   # Gazebo, sdformat, and ogre
brew tap homebrew/core # VTK5
brew tap homebrew/science  # others

mkdir -p ~/Library/Python/2.7/lib/python/site-packages
echo "$(brew --prefix)/lib/python2.7/site-packages" >> ~/Library/Python/2.7/lib/python/site-packages/homebrew.pth

#pip install --upgrade pip

sudo -H python2 -m pip install wxPython empy

sudo -H python2 -m pip install -U wstool rosdep rosinstall rosinstall_generator rospkg catkin-pkg sphinx

brew install boost boost-python eigen
brew install console_bridge poco tinyxml
brew install pyqt5 --with-python


sudo -H rosdep init
rosdep update

mkdir ~/ros_catkin_ws
cd ~/ros_catkin_ws

rosinstall_generator desktop --rosdistro lunar --deps --wet-only --tar > lunar-desktop-wet.rosinstall

wstool init -j8 src lunar-desktop-wet.rosinstall

rosdep install --skip-keys google-mock --from-paths src --ignore-src --rosdistro lunar -y

./src/catkin/bin/catkin_make_isolated --install -DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_BUILD_TYPE=Release

source ~/ros_catkin_ws/install_isolated/setup.bash
