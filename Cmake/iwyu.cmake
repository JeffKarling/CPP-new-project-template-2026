include_guard(GLOBAL)

find_program(IWYU_PATH NAMES include-what-you-use iwyu)
if(NOT IWYU_PATH)
    message(FATAL_ERROR "Could not find the program include-what-you-use")
endif()