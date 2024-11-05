set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS true)
if(USE_CPP_20_IMPORTS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmodules-ts -fmodule-header") # Enable c++20 modules
endif()
# Allow for better debug messages using the preprocessor
# Just use the __FILENAME__ macro
# Broken atm
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__FILENAME__='\"$(subst${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"'")
