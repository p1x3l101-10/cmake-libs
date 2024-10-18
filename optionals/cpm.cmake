if(NOT CMAKE_LIBS_OPTIONALS_CPM_VERSION)
    set(CMAKE_LIBS_OPTIONALS_CPM_VERSION "0.40.2")
endif()
if(NOT CMAKE_LIBS_OPTIONALS_CPM_SHA256SUM)
    set(CMAKE_LIBS_OPTIONALS_CPM_SHA256SUM "c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d")
endif()

message(VERBOSE "Adding CPM version: ${CMAKE_LIBS_OPTIONALS_CPM_VERSION}")

file(
    DOWNLOAD https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CMAKE_LIBS_OPTIONALS_CPM_VERSION}/CPM.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake
    EXPECTED_HASH SHA256=${CMAKE_LIBS_OPTIONALS_CPM_SHA256SUM}
)
include(${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake)
