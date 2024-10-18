if(CMAKE_LIBS_ENABLE_CPM)
    if(NOT CMAKE_LIBS_CPM_VERSION)
        file(
            DOWNLOAD https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.38.3/CPM.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake
            EXPECTED_HASH SHA256=cc155ce02e7945e7b8967ddfaff0b050e958a723ef7aad3766d368940cb15494
        )
    else()
        if(CMAKE_LIBS_CPM_SHA256)
            file(
                DOWNLOAD https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CMAKE_LIBS_CPM_VERSION}/CPM.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake
                EXPECTED_HASH SHA256=${CMAKE_LIBS_CPM_SHA256}
            )
        else()
            message(FATAL_ERROR "You need to specify the sha256sum for cpm if you are changing the version")
        endif()
    endif()
    include(${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake)
endif()
