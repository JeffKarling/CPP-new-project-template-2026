list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

configure_file(${CMAKE_CURRENT_LIST_DIR}/Templates/targetProperties.cmake ${CMAKE_BINARY_DIR}/targetProperties.cmake COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/Templates/targetCompileOptions.cmake ${CMAKE_BINARY_DIR}/targetCompileOptions.cmake COPYONLY)

include(iwyu)
include(dependencies.cmake)
include(perf)

#include(heaptrack)
#include(functions)
#include(SystemdRun.cmake)
#include(graphviz)
include(OneApi_Vtune.cmake)
include(OneApi_Advisor.cmake)