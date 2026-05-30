cmake_minimum_required(VERSION 3.31)

cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)
set(DIR_NAME template2026)

#set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
#set(CMAKE_CXX_MODULE_STD 1)

project(${DIR_NAME}
        VERSION 1.0.0
        DESCRIPTION "${PROJECT_NAME} is a awsome project."
        HOMEPAGE_URL "fightingbugs.home.local"
        LANGUAGES CXX
)

option(ENABLE_WARNING_AS_ERROR "Enable warning as errors for Debug builds" OFF)
option(ENABLE_IPO "Enable Interprocedural Optimization (LTO) for Release builds" ON)
option(ENABLE_IWYU "Enable Include-What-You-Use analysis" OFF)
option(ENABLE_CPPCHECK "Enable Cppcheck static analysis" OFF)

set(ENABLE_TESTS ON)

if(CMAKE_BUILD_TYPE MATCHES ".*San.*" OR CMAKE_BUILD_TYPE MATCHES ".*Tidy.*")
    set(ENABLE_TESTS OFF)
endif()

add_subdirectory(Cmake)

if(ENABLE_TESTS)
    enable_testing()
    include(GoogleTest)
endif()

add_subdirectory(srcTargets)
