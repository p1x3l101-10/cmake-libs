if(NOT CMAKE_LIBS_OPTIONALS_BOOST_COMPONENTS)
    message(FATAL_ERROR "Boost components need to be specified")
endif()
if(NOT CMAKE_LIBS_OPTIONALS_BOOST_VERSION)
    message(FATAL_ERROR "Boost version needs to be specified")
endif()

message(VERBOSE "Adding boost with components: ${CMAKE_LIBS_OPTIONALS_BOOST_COMPONENTS}")

find_package(
    Boost ${CMAKE_LIBS_OPTIONALS_BOOST_VERSION}
    COMPONENTS ${CMAKE_LIBS_OPTIONALS_BOOST_COMPONENTS}
    QUIET # Dont warn if the lib is not found, we are going to download it instead
)

message(VERBOSE "   Local boost not found, downloading via CPM.cmake")

if(NOT Boost_FOUND)
    # Use cpm if a local version can't be used
    # Ensure that CPM is available
    if(NOT "cpm" IN_LIST CMAKE_LIBS_OPTIONALS)
        list(APPEND CMAKE_LIBS_OPTIONALS "cpm")
        include(${CMAKE_CURRENT_LIST_DIR}/cpm.cmake)
    endif()
    # Download the lib
    CPMAddPackage(
        NAME Boost
        VERSION ${CMAKE_LIBS_OPTIONALS_BOOST_VERSION}
        URL "https://github.com/boostorg/boost/releases/download/boost-${CMAKE_LIBS_OPTIONALS_BOOST_VERSION}/boost-${CMAKE_LIBS_OPTIONALS_BOOST_VERSION}-b2-nodocs.tar.xz"
        OPTIONS
            "BOOST_ENABLE_CMAKE ON"
            "BOOST_INCLUDE_LIBRARIES ${CMAKE_LIBS_OPTIONALS_BOOST_COMPONENTS}"
    )
endif()
