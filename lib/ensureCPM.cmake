macro(ensureCPM)
    if(NOT "cpm" IN_LIST CMAKE_LIBS_OPTIONALS)
        list(APPEND CMAKE_LIBS_OPTIONALS "cpm")
        include(${CMAKE_CURRENT_LIST_DIR}/../optionals/cpm.cmake)
    endif()
endmacro()
