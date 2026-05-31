cmake_minimum_required(VERSION 3.31)

cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)
set(DIR_NAME template2026)

#set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
#set(CMAKE_CXX_MODULE_STD 1)

project(${DIR_NAME}
        VERSION 1.1.2
        DESCRIPTION "${PROJECT_NAME} is a opinionated personal C+++ project template"
        HOMEPAGE_URL "https://github.com/JeffKarling/CPP-new-project-template-2026"
        LANGUAGES CXX
)

option(ENABLE_WARNING_AS_ERROR "Enable warning as errors for Debug builds" OFF)
option(ENABLE_IPO "Enable Interprocedural Optimization (LTO) for Release builds" ON)
option(ENABLE_IWYU "Enable Include-What-You-Use analysis" OFF)
option(ENABLE_CPPCHECK "Enable Cppcheck static analysis" OFF)

# Standard CTest integration.
# Define the standard BUILD_TESTING option manually (default ON) to avoid CDash target clutter.
option(BUILD_TESTING "Build the testing tree." ON)

# Disable testing for sanitizers and static analysis (Tidy) to optimize build times.
if(CMAKE_BUILD_TYPE MATCHES ".*San.*" OR CMAKE_BUILD_TYPE MATCHES ".*Tidy.*")
    set(BUILD_TESTING OFF CACHE BOOL "Build the testing tree." FORCE)
endif()

# Enable testing directly at the directory level if BUILD_TESTING is enabled.
if(BUILD_TESTING)
    enable_testing()
endif()

add_subdirectory(Cmake)

if(BUILD_TESTING)
    include(GoogleTest)
endif()

add_subdirectory(srcTargets)
