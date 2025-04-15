function(BUILD)
    # Set valid arguments
    set(options INSTALL_TARGET USE_GENERATOR)
    set(oneValueArgs STATIC_LIBRARY SHARED_LIBRARY BINARY HEADER_LIBRARY PRIVATE_COMPILE_OPTIONS PUBLIC_COMPILE_OPTIONS INTERFACE_COMPILE_OPTIONS PRIVATE_LINK_OPTIONS PUBLIC_LINK_OPTIONS INTERFACE_LINK_OPTIONS FILE_EXTENSION GENERATOR_EXTENSION GENERATOR_BINARY)
    set(multiValueArgs LIBRARIES PUBLIC_LIBRARIES INTERFACE_LIBRARIES INCLUDE)

    # Add modules for optionals
    if(USE_CPP_20_IMPORTS)
        list(APPEND oneValueArgs MODULE_EXTENSION)
        list(APPEND options GENERATE_MODULES)
    endif()

    # Parse args
    cmake_parse_arguments(BUILD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    # Set default filetype
    if(NOT BUILD_FILE_EXTENSION)
        set(BUILD_FILE_EXTENSION "cpp")
    endif()

    # Run any code generators if needed
    if(BUILD_USE_GENERATOR)
        if(NOT BUILD_GENERATOR_EXTENSION)
            set(BUILD_GENERATOR_EXTENSION "bash")
        endif()
        if(NOT BUILD_GENERATOR_BINARY)
            set(BUILD_GENERATOR_BINARY "") # Blank value if unused
        endif()
        set(CODE_GENERATOR "generator.${BUILD_GENERATOR_EXTENSION}")
    elseif()
        # Blank value if unused
        set(CODE_GENERATOR "")
        set(BUILD_GENERATOR_BINARY "")
    endif()

    # Add basic build rules and export the build target in one variable
    if(BUILD_STATIC_LIBRARY)
        message(VERBOSE "Creating ruleset for static library: ${BUILD_STATIC_LIBRARY}...")
        module(staticLib ${BUILD_STATIC_LIBRARY} ${BUILD_FILE_EXTENSION} "${CODE_GENERATOR}" "${BUILD_GENERATOR_BINARY}")
        set(BUILD_TARGET ${BUILD_STATIC_LIBRARY})
    elseif(BUILD_SHARED_LIBRARY)
        message(VERBOSE "Creating ruleset for shared library: ${BUILD_SHARED_LIBRARY}...")
        module(staticLib ${BUILD_SHARED_LIBRARY} ${BUILD_FILE_EXTENSION} "${CODE_GENERATOR}" "${BUILD_GENERATOR_BINARY}")
        set(BUILD_TARGET ${BUILD_SHARED_LIBRARY})
    elseif(BUILD_BINARY)
        message(VERBOSE "Creating ruleset for binary: ${BUILD_BINARY}...")
        module(bin ${BUILD_BINARY} ${BUILD_FILE_EXTENSION} "${CODE_GENERATOR}" "${BUILD_GENERATOR_BINARY}")
        set(BUILD_TARGET ${BUILD_BINARY})
    elseif(BUILD_HEADER_LIBRARY)
        message(VERBOSE "Creating ruleset for header library: ${BUILD_HEADER_LIBRARY}...")
        module(header ${BUILD_HEADER_LIBRARY} ${BUILD_FILE_EXTENSION} "${CODE_GENERATOR}" "${BUILD_GENERATOR_BINARY}")
        set(BUILD_TARGET ${BUILD_HEADER_LIBRARY})
    elseif()
        message(FATAL_ERROR "You need to specify a build type/target")
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
    if(BUILD_PRIVATE_COMPILE_OPTIONS)
        message(VERBOSE "    Adding compilation options: ${BUILD_PRIVATE_COMPILE_OPTIONS}")
        target_compile_options(${BUILD_TARGET} PRIVATE ${BUILD_PRIVATE_COMPILE_OPTIONS})
    endif()
    if(BUILD_PUBLIC_COMPILE_OPTIONS)
        message(VERBOSE "    Adding public compilation options: ${BUILD_PUBLIC_COMPILE_OPTIONS}")
        target_compile_options(${BUILD_TARGET} PUBLIC ${BUILD_PUBLIC_COMPILE_OPTIONS})
    endif()
    if(BUILD_INTERFACE_COMPILE_OPTIONS)
        message(VERBOSE "    Adding interface linking options: ${BUILD_INTERFACE_COMPILE_OPTIONS}")
        target_link_options(${BUILD_TARGET} PUBLIC ${BUILD_INTERFACE_COMPILE_OPTIONS})
    endif()
    # Link options
    if(BUILD_PRIVATE_LINK_OPTIONS)
        message(VERBOSE "    Adding linking options: ${BUILD_PRIVATE_LINK_OPTIONS}")
        target_link_options(${BUILD_TARGET} PRIVATE ${BUILD_PRIVATE_LINK_OPTIONS})
    endif()
    if(BUILD_PUBLIC_LINK_OPTIONS)
        message(VERBOSE "    Adding public linking options: ${BUILD_PUBLIC_LINK_OPTIONS}")
        target_link_options(${BUILD_TARGET} PUBLIC ${BUILD_PUBLIC_LINK_OPTIONS})
    endif()
    if(BUILD_INTERFACE_LINK_OPTIONS)
        message(VERBOSE "    Adding interface linking options: ${BUILD_INTERFACE_LINK_OPTIONS}")
        target_link_options(${BUILD_TARGET} PUBLIC ${BUILD_INTERFACE_LINK_OPTIONS})
    endif()

    # Modules
    if(BUILD_GENERATE_MODULES)
        if(NOT BUILD_MODULE_EXTENSION)
            set(BUILD_MODULE_EXTENSION "ixx")
        endif()
        message(VERBOSE "    Using c++ modules")
        file(GLOB_RECURSE modules CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/modules/*.${BUILD_MODULE_EXTENSION}")
        set_target_properties(${BUILD_TARGET} PROPERTIES CXX_SCAN_FOR_MODULES ON)
        target_sources(${BUILD_TARGET} PUBLIC FILE_SET CXX_MODULES FILES ${modules})
    endif()

    # Generate config file if project has a template
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/include/config.hpp.in)
        message(VERBOSE "    Generating config.hpp from template")
        include(GNUInstallDirs)
        if(BUILD_HEADER_LIBRARY)
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/include/config.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/.gen/${BUILD_TARGET}/include/${BUILD_HEADER_LIBRARY}.config.hpp)
            target_include_directories(${BUILD_TARGET} INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/.gen/${BUILD_TARGET}/include)
        else()
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}/include/config.hpp.in ${CMAKE_CURRENT_BINARY_DIR}/.gen/${BUILD_TARGET}/include/config.hpp)
            target_include_directories(${BUILD_TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/.gen/${BUILD_TARGET}/include)
        endif()
    endif()

    # Add install rule if told to
    if(${BUILD_INSTALL_TARGET})
        message(VERBOSE "    Adding install rule")
        install_target(${BUILD_TARGET})
    endif()
endfunction()