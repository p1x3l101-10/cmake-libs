function(module type name fileExt)
    if(${type} STREQUAL "sharedLib")
        file(GLOB_RECURSE source_files CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${name}/src/*.${fileExt}")
        add_library(${name} SHARED ${source_files})
        target_include_directories( ${name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/public )
        target_include_directories( ${name} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/interface )
        target_include_directories( ${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include )
    elseif(${type} STREQUAL "bin")
        file(GLOB_RECURSE source_files CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${name}/src/*.${fileExt}")
        add_executable(${name} ${source_files})
        target_include_directories(${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include)
    elseif(${type} STREQUAL "header")
        add_library(${name} INTERFACE)
        target_include_directories(${name} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include)
    elseif (${type} STREQUAL "staticLib")
        file(GLOB_RECURSE source_files CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${name}/src/*.${fileExt}")
        add_library(${name} STATIC ${source_files} )
        target_include_directories(${name} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/public)
        target_include_directories(${name} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include/interface)
        target_include_directories(${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${name}/include)
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

function(ADD_PACKAGE NAME)
    # find_package wrapper that tells user what is going on
    message(VERBOSE "Adding dependancy ${NAME} to environment")
    find_package(${ARGV})
endfunction()
