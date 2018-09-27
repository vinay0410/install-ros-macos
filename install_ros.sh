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

sudo -H python2 -m pip install -U wstool rosdep rosinstall rosinstall_generator rospkg catkin-pkg sphinx nose

brew install boost boost-python eigen yaml-cpp
brew install console_bridge poco tinyxml tinyxml2 qt
brew install pyqt5 --with-python
brew install opencv
brew install gtest assimp qhull lz4
brew install urdfdom urdfdom_headers ogre1.9


export PATH="/usr/local/opt/qt/bin:$PATH"

export CMAKE_PREFIX_PATH=$(brew --prefix qt5)

# Source : https://answers.ros.org/question/266864/continued-installing-on-mac-sierra-qt_gui_cpp_sip-errors/

  pushd /usr/local/share/sip
  if [ ! -e PyQt5 ]; then
    ln -s Qt5 PyQt5
  fi
  popd

sudo -H rosdep init
rosdep update

mkdir ~/ros_catkin_ws
cd ~/ros_catkin_ws

rosinstall_generator desktop --rosdistro lunar --deps --wet-only --tar > lunar-desktop-wet.rosinstall

wstool init src

pushd src
    # Avoid downloading opencv3; we already installed it from homebrew.
    wstool merge file://$(pwd)/../lunar-desktop-wet.rosinstall
    wstool remove opencv3
    wstool update -j8

    rosdep install --skip-keys google-mock --skip-keys python-wxtools --from-paths . --ignore-src --rosdistro lunar -y

popd

if [ -e src/geometry2/tf2/src/buffer_core.cpp ]; then

sed -i '' 's/ logWarn/ CONSOLE_BRIDGE_logWarn/g' src/geometry2/tf2/src/buffer_core.cpp
sed -i '' 's/ logError/ CONSOLE_BRIDGE_logError/g' src/geometry2/tf2/src/buffer_core.cpp

fi

if [ -e src/vision_opencv/cv_bridge/CMakeLists.txt ]; then
  sed -i '' 's/Boost REQUIRED python\b/Boost REQUIRED python27/g' src/vision_opencv/cv_bridge/CMakeLists.txt
  sed -i '' 's/Boost REQUIRED python)/Boost REQUIRED python27)/g' src/vision_opencv/cv_bridge/CMakeLists.txt
fi


./src/catkin/bin/catkin_make_isolated --install -DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_BUILD_TYPE=Release

#source ~/ros_catkin_ws/install_isolated/setup.bash
