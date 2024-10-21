function(module type name)
    if ( ${type} STREQUAL "sharedLib" )
        file(GLOB_RECURSE source_files "${CMAKE_CURRENT_SOURCE_DIR}/${name}/src/*.cpp" )
        add_library( ${PROJECT_NAMESPACE}::${name} ALIAS ${name} SHARED ${source_files} )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/public )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/interface )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include )
    elseif ( ${type} STREQUAL "bin" )
        file(GLOB_RECURSE source_files "${CMAKE_CURRENT_SOURCE_DIR}/${name}/src/*.cpp")
        add_executable( ${PROJECT_NAMESPACE}::${name} ALIAS ${name} ${source_files} )
        target_include_directories( ${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include )
    elseif ( ${type} STREQUAL "header" )
        add_library( ${PROJECT_NAMESPACE}::${name} ALIAS ${name} STATIC )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/public )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/interface )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include )
    elseif ( ${type} STREQUAL "staticLib" )
        file(GLOB_RECURSE source_files "${CMAKE_CURRENT_SOURCE_DIR}/${name}/src/*.cpp" )
        add_library( ${PROJECT_NAMESPACE}::${name} ALIAS ${name} STATIC ${source_files} )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/public )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/interface )
        target_include_directories( ${PROJECT_NAMESPACE}::${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include )
    endif()
    # TODO: Parse the simple texts files to add target_link_libraries accordingly
endfunction()

macro (install_target target)
    include(GNUInstallDirs)
    install(
        TARGETS     ${target}
        INCLUDES    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        ARCHIVE     DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY     DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME     DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endmacro()

function(BUILD)
    # Set valid arguments
    set(options INSTALL_TARGET)
    set(oneValueArgs STATIC_LIBRARY SHARED_LIBRARY BINARY HEADER_LIBRARY)
    set(multiValueArgs LIBRARIES PUBLIC_LIBRARIES INTERFACE_LIBRARIES INCLUDE)

    # Add modules for optionals
    if("boost" IN_LIST CMAKE_LIBS_OPTIONALS)
        list(APPEND options LINK_BOOST)
    endif()
    if("swig" IN_LIST CMAKE_LIBS_OPTIONALS)
        list(APPEND options ADD_SWIG)
    endif()

    # Parse args
    cmake_parse_arguments(BUILD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    # Add basic build rules and export the build target in one variable
    if(BUILD_STATIC_LIBRARY)
        message(VERBOSE "Creating ruleset for static library: ${BUILD_STATIC_LIBRARY}...")
        module(staticLib ${BUILD_STATIC_LIBRARY})
        set(BUILD_TARGET ${BUILD_STATIC_LIBRARY})
    elseif(BUILD_SHARED_LIBRARY)
        message(VERBOSE "Creating ruleset for shared library: ${BUILD_SHARED_LIBRARY}...")
        module(staticLib ${BUILD_SHARED_LIBRARY})
        set(BUILD_TARGET ${BUILD_SHARED_LIBRARY})
    elseif(BUILD_BINARY)
        message(VERBOSE "Creating ruleset for binary: ${BUILD_BINARY}...")
        module(bin ${BUILD_BINARY})
        set(BUILD_TARGET ${BUILD_BINARY})
    elseif(BUILD_HEADER_LIBRARY)
        message(VERBOSE "Creating ruleset for header library: ${BUILD_HEADER_LIBRARY}...")
        module(header ${BUILD_HEADER_LIBRARY})
        set(BUILD_TARGET ${BUILD_HEADER_LIBRARY})
    elseif()
        message(FATAL_ERROR "You need to specify a build type/target")
    endif()

    # Add optionals
    if(BUILD_LINK_BOOST)
        foreach(lib IN LISTS CMAKE_LIBS_OPTIONALS_BOOST_COMPONENTS)
            message(VERBOSE "   Linking Boost library: ${lib}")
            target_link_libraries(${PROJECT_NAMESPACE}::${BUILD_TARGET} PRIVATE Boost::${lib})
        endforeach()
    endif()
    if(BUILD_ADD_SWIG)
        addswig(${PROJECT_NAMESPACE}::${BUILD_TARGET})
    endif()

    # Link libraries
    foreach(lib IN LISTS BUILD_LIBRARIES)
        message(VERBOSE "    Linking private library ${lib}")
        target_link_libraries(${PROJECT_NAMESPACE}::${BUILD_TARGET} PRIVATE ${lib})
    endforeach()
    foreach(lib IN LISTS BUILD_PUBLIC_LIBRARIES)
        message(VERBOSE "    Linking public library ${lib}")
        target_link_libraries(${PROJECT_NAMESPACE}::${BUILD_TARGET} PUBLIC ${lib})
    endforeach()
    foreach(lib IN LISTS BUILD_INTERFACE_LIBRARIES)
        message(VERBOSE "    Linking interface library ${lib}")
        target_link_libraries(${PROJECT_NAMESPACE}::${BUILD_TARGET} INTERFACE ${lib})
    endforeach()

    # Extra include directories
    foreach(dir IN LISTS BUILD_INCLUDE)
        message(VERBOSE "    Including directory ${dir}")
        target_include_directories(${PROJECT_NAMESPACE}::${BUILD_TARGET} PRIVATE ${include})
    endforeach()

    # Generate config file if project has a template
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/include/config.hpp.in)
        message(VERBOSE "    Generating config.hpp from template")
        include(GNUInstallDirs)
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/include/config.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TARGET}/include/config.hpp)
        target_include_directories(${PROJECT_NAMESPACE}::${BUILD_TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TARGET}/include)
    endif()

    # Add install rule if told to
    if(${BUILD_INSTALL_TARGET})
        message(VERBOSE "    Adding install rule")
        install_target(${PROJECT_NAMESPACE}::${BUILD_TARGET})
    endif()
endfunction()

function(ADD_PACKAGE NAME)
    # find_package wrapper that tells user what is going on
    message(VERBOSE "Adding dependancy ${NAME} to environment")
    find_package(${ARGV})
endfunction()

# Ensure that this project has a namespace
if(NOT PROJECT_NAMESPACE)
    set(PROJECT_NAMESPACE "${PROJECT_NAME}")
endif()
