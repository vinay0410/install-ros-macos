
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

brew install boost boost-python eigen
brew install console_bridge poco tinyxml tinyxml2 qt
brew install pyqt5 --with-python
brew install opencv
brew install gtest assimp qhull lz4
brew install urdfdom urdfdom_headers ogre1.9


export PATH="/usr/local/opt/qt/bin:$PATH"

export CMAKE_PREFIX_PATH=$(brew --prefix qt5)

# Install Yaml CPP from Sourcebrew installation conflicts with gtests
# and while building from source we can expicitly diable building tests
wget https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.zip
mkdir yaml
unzip yaml-cpp-0.6.2.zip -d yaml

pushd yaml/*/
  mkdir build && cd build
  cmake -DYAML_CPP_BUILD_TESTS=OFF ..
  make -j2
  sudo make install
popd

# Source : https://answers.ros.org/question/266864/continued-installing-on-mac-sierra-qt_gui_cpp_sip-errors/

  pushd /usr/local/share/sip
  if [ ! -e PyQt5 ]; then
    ln -s Qt5 PyQt5
  fi
  popd

# Certificate Error on some machines

ruby -ropenssl -e "p OpenSSL::X509::DEFAULT_CERT_FILE"
export SSL_CERT_FILE=/usr/local/etc/openssl/cert.pem

sudo -H rosdep init

# if rosdep init fails, do it manually

if [ $? -ne 0 ]; then
  wget https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/sources.list.d/20-default.list
  sudo mkdir -p /etc/ros/rosdep/sources.list.d/
  sudo mv -f 20-default.list /etc/ros/rosdep/sources.list.d/
fi

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
