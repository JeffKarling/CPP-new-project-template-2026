cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)

add_executable(${DIR_NAME} ${DIR_NAME}.cpp)

include(${CMAKE_BINARY_DIR}/targetProperties.cmake)
include(${CMAKE_BINARY_DIR}/targetCompileOptions.cmake)

target_link_libraries(${DIR_NAME}
    PRIVATE
        ${PROJECT_NAME}::databaseManager
        PkgConfig::GTEST
)

gtest_discover_tests(${DIR_NAME})
