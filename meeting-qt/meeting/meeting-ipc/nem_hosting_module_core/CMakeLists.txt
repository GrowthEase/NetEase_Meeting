project(nem_hosting_module_core)

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface)
include_directories(${CMAKE_CURRENT_LIST_DIR}/config/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/manager/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/protocol/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/service/)

file(GLOB_RECURSE MANAGER_SRC *.cpp *.h)

add_library(${PROJECT_NAME} ${MANAGER_SRC})
