set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS true)
if(USE_CPP_20_IMPORTS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmodule-header -stdlib=libc++") # Enable c++20 modules
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD on)
endif()
# Allow for better debug messages using the preprocessor
# Just use the __FILENAME__ macro
# Broken atm
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__FILENAME__='\"$(subst${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"'")
