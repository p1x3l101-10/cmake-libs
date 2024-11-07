function(BUILD)
    # Set valid arguments
    set(options INSTALL_TARGET)
    set(oneValueArgs STATIC_LIBRARY SHARED_LIBRARY BINARY HEADER_LIBRARY COMPILE_OPTIONS PUBLIC_COMPILE_OPTIONS)
    set(multiValueArgs LIBRARIES PUBLIC_LIBRARIES INTERFACE_LIBRARIES INCLUDE)

    # Add modules for optionals
    if("boost" IN_LIST CMAKE_LIBS_OPTIONALS)
        list(APPEND options LINK_BOOST)
    endif()
    if("swig" IN_LIST CMAKE_LIBS_OPTIONALS)
        list(APPEND options ADD_SWIG)
    endif()
    if(USE_CPP_20_IMPORTS)
        list(APPEND options GENERATE_MODULES)
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
            target_link_libraries(${BUILD_TARGET} PRIVATE Boost::${lib})
        endforeach()
    endif()
    if(BUILD_ADD_SWIG)
        addswig(${BUILD_TARGET})
    endif()

    # Link libraries
    foreach(lib IN LISTS BUILD_LIBRARIES)
        message(VERBOSE "    Linking private library ${lib}")
        target_link_libraries(${BUILD_TARGET} PRIVATE ${lib})
    endforeach()
    foreach(lib IN LISTS BUILD_PUBLIC_LIBRARIES)
        message(VERBOSE "    Linking public library ${lib}")
        target_link_libraries(${BUILD_TARGET} PUBLIC ${lib})
    endforeach()
    foreach(lib IN LISTS BUILD_INTERFACE_LIBRARIES)
        message(VERBOSE "    Linking interface library ${lib}")
        target_link_libraries(${BUILD_TARGET} INTERFACE ${lib})
    endforeach()

    # Extra include directories
    foreach(dir IN LISTS BUILD_INCLUDE)
        message(VERBOSE "    Including directory ${dir}")
        target_include_directories(${BUILD_TARGET} SYSTEM PUBLIC ${include})
    endforeach()

    # Compile options
    if(BUILD_COMPILE_OPTIONS)
        message(VERBOSE "   Adding compilation options: ${BUILD_COMPILE_OPTIONS}")
        target_compile_options(${BUILD_TARGET} PRIVATE ${BUILD_COMPILE_OPTIONS})
    endif()
    if(BUILD_PUBLIC_COMPILE_OPTIONS)
        message(VERBOSE "   Adding public compilation options: ${BUILD_PUBLIC_COMPILE_OPTIONS}")
        target_compile_options(${BUILD_TARGET} PRIVATE ${BUILD_PUBLIC_COMPILE_OPTIONS})
    endif()

    # Modules
    if(BUILD_GENERATE_MODULES)
        file(GLOB_RECURSE MODULES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/modules/*.cppm")
        target_sources(${BUILD_TARGET} PUBLIC FILE_SET CXX_MODULES MODULES)
    endif()

    # Generate config file if project has a template
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/include/config.hpp.in)
        message(VERBOSE "    Generating config.hpp from template")
        include(GNUInstallDirs)
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/include/config.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/.gen/${BUILD_TARGET}/include/config.hpp)
        target_include_directories(${BUILD_TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/.gen/${BUILD_TARGET}/include)
    endif()

    # Add install rule if told to
    if(${BUILD_INSTALL_TARGET})
        message(VERBOSE "    Adding install rule")
        install_target(${BUILD_TARGET})
    endif()
endfunction()