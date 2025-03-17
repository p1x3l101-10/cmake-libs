function(module type name fileExt codeGen)
    if(NOT (codeGen STREQUAL ""))
        message(VERBOSE "    Running code generator...")
        execute_process(
            COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/${name}/${codeGen}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${name}
            OUTPUT_QUIET
        )
    endif()
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

include(ExternalProject)

macro(append_cmake_prefix_path)
    list(APPEND CMAKE_PREFIX_PATH ${ARGN})
    string(REPLACE ";" "|" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
endmacro()

function(BuildExternalProject)
    set(options MESON_PROJECT)
    set(oneValueArgs NAME GIT_REPO GIT_REV)
    set(multiValueArgs)

    cmake_parse_arguments(BEP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    set(BEP_INSTALL_PATH "${PROJECT_SOURCE_DIR}/bep/${BEP_NAME}")
    set(BEP_INSTALL_PATH_LIB "${BEP_INSTALL_PATH}/lib")
    set(BEP_INSTALL_PATH_INCLUDE "${BEP_INSTALL_PATH}/include")

    if(BEP_MESON_PROJECT)
        find_program(MESON_BIN NAMES meson)
    endif()

    if(BEP_MESON_PROJECT)
        ExternalProject_Add(
            ${BEP_NAME}_external
            CONFIGURE_COMMAND ${MESON_BIN} setup --prefix <INSTALL_DIR> <BINARY_DIR> <SOURCE_DIR>
            BUILD_COMMAND ${MESON_BIN} compile -C <BINARY_DIR> --verbose
            INSTALL_COMMAND ${MESON_BIN} install -C <BINARY_DIR>
            GIT_REPOSITORY ${BEP_GIT_REPO}
            GIT_TAG ${BEP_GIT_REV}
            GIT_SHALLOW true
            GIT_PROGRESS true
        )
    endif()
    
    file(MAKE_DIRECTORY "${BEP_INSTALL_PATH_INCLUDE}")
    add_library(BEP::${BEP_NAME} INTERFACE IMPORTED GLOBAL ${BEP_NAME}_external)
    target_include_directories(BEP::${BEP_NAME} INTERFACE ${INSTALL_PATH_INCLUDE})
    target_link_libraries(BEP::${BEP_NAME} INTERFACE ${INSTALL_PATH_LIB}/*.*)
    add_dependencies(BEP::${BEP_NAME} ${BEP_NAME}_external)
endfunction()
