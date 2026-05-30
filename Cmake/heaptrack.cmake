include_guard(GLOBAL)

find_program(HEAPTRACK "heaptrack")

#if (HEAPTRACK_OPT AND HEAPTRACK)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/heaptrack)
add_custom_target(Heaptrack
        COMMENT "Runs app with heaptrack, collects profiling data in: ${CMAKE_CURRENT_BINARY_DIR}/heaptrack"
        #DEPENDS ${MY_BUILD_PATH_NAME}
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/heaptrack"
        COMMAND "${HEAPTRACK}" $<TARGET_FILE:exeMain>
)


#endif ()