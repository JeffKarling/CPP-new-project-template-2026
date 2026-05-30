cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)

add_library(${DIR_NAME})
add_library(${PROJECT_NAME}::${DIR_NAME} ALIAS ${DIR_NAME})

include(${CMAKE_BINARY_DIR}/targetProperties.cmake)
include(${CMAKE_BINARY_DIR}/targetCompileOptions.cmake)

add_custom_command(
        DEPENDS ${DIR_NAME}/itemDatabase.proto
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${DIR_NAME}
        OUTPUT 
            ${CMAKE_CURRENT_BINARY_DIR}/${DIR_NAME}/itemDatabase.pb.cc
            ${CMAKE_CURRENT_BINARY_DIR}/${DIR_NAME}/itemDatabase.pb.h
        COMMENT "Generating itemDatabase header and object from proto file"
        COMMAND protoc
        ARGS --proto_path=${CMAKE_CURRENT_SOURCE_DIR}/${DIR_NAME} itemDatabase.proto --cpp_out=${CMAKE_CURRENT_BINARY_DIR}/${DIR_NAME}
)

target_sources(${DIR_NAME}
        PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/${DIR_NAME}/itemDatabase.pb.cc

        PUBLIC
        FILE_SET ${DIR_NAME}
        TYPE HEADERS
        BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${DIR_NAME}/itemDatabase.pb.h
)

target_link_libraries(${DIR_NAME} protobuf::libprotobuf)
