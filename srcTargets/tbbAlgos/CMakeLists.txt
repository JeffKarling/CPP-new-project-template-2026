cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)

add_library(${DIR_NAME} STATIC)
add_library(${PROJECT_NAME}::${DIR_NAME} ALIAS ${DIR_NAME})

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

target_link_libraries(${DIR_NAME}
        PUBLIC 
        PkgConfig::tbb 
)

# Link Intel ITT API for JIT profiling if found
if(ittnotify_FOUND)
    target_link_libraries(${DIR_NAME} PRIVATE PkgConfig::ittnotify)
    target_compile_definitions(${DIR_NAME} PRIVATE USE_ITT=1)
endif()

if(ENABLE_TESTS)
    add_subdirectory(${DIR_NAME}TEST)
endif()

