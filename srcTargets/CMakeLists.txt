include_guard(GLOBAL)

file(GLOB DIR_LIST LIST_DIRECTORIES true "*")
foreach(DIR ${DIR_LIST})
    if(IS_DIRECTORY ${DIR})
        add_subdirectory(${DIR})
    endif()
endforeach()
