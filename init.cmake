if(APPLE)
  set(CMAKE_INSTALL_RPATH "@loader_path/../lib;@loader_path")
elseif(UNIX)
  set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib:$ORIGIN/")
endif()
