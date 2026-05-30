cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)

add_library(${DIR_NAME} STATIC)
add_library(${PROJECT_NAME}::${DIR_NAME} ALIAS ${DIR_NAME})

add_subdirectory(${DIR_NAME}Interface)

include(${CMAKE_BINARY_DIR}/targetProperties.cmake)
include(${CMAKE_BINARY_DIR}/targetCompileOptions.cmake)

target_sources(${DIR_NAME}
        PRIVATE
        ${DIR_NAME}.cpp

        PUBLIC
        FILE_SET ${DIR_NAME}
        TYPE HEADERS
        FILES
        ${DIR_NAME}/${DIR_NAME}.hpp
)

target_link_libraries(${DIR_NAME} PUBLIC
        ${PROJECT_NAME}::${DIR_NAME}Interface
)

add_dependencies(${DIR_NAME} ${PROJECT_NAME}::${DIR_NAME}Interface)

# Enclose unit test subdirectories within standard BUILD_TESTING checks
if(BUILD_TESTING)
    add_subdirectory(${DIR_NAME}TEST)
endif()
