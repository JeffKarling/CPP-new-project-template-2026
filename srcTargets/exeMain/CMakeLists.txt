cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)

set(MAIN_TARGET ${PROJECT_NAME})

# Temporarily override DIR_NAME to MAIN_TARGET so that targetProperties and targetCompileOptions
# configure the dynamically-named project target (template2026) rather than the directory name (exeMain).
set(ORIGINAL_DIR_NAME ${DIR_NAME})
set(DIR_NAME ${MAIN_TARGET})

add_executable(${MAIN_TARGET})

include(${CMAKE_BINARY_DIR}/targetProperties.cmake)
include(${CMAKE_BINARY_DIR}/targetCompileOptions.cmake)

# Restore DIR_NAME to the original directory name for file sets and header tracking
set(DIR_NAME ${ORIGINAL_DIR_NAME})

target_sources(${MAIN_TARGET}
        PRIVATE
        ${DIR_NAME}.cpp

        PUBLIC
        FILE_SET ${DIR_NAME}
        TYPE HEADERS
        FILES
        ${DIR_NAME}/${DIR_NAME}.hpp
)

target_link_libraries(${MAIN_TARGET}
        PRIVATE
        ${PROJECT_NAME}::tbbAlgos
        ${PROJECT_NAME}::databaseManager
        ${PROJECT_NAME}::dbExport
)

