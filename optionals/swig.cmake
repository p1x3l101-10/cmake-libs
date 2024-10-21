find_package(SWIG REQUIRED)
include(${SWIG_USE_FILE})
macro(ADDSWIG target source_files)
    # Swig python module
    find_package(PythonLibs)
    if(PythonLibs_FOUND)
        include_directories(${PYTHON_INCLUDE_PATH})
        set_source_files_properties(SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/${target}/swig/python.i PROPERTIES CPLUSPLUS ON)
        set_property(SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/${target}/swig/python.i PROPERTY SWIG_MODULE_NAME ${target})
        swig_add_library(${target}_swig LANGUAGE python SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${target}/swig/python.i)
    endif()
    # TODO: add more swig modules
endmacro()
