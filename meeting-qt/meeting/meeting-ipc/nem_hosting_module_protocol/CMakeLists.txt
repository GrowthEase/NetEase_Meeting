project(nem_hosting_module_protocol)

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/config/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/protocol/)

file(GLOB_RECURSE PROTOCOL_SRC *.h *.cpp)

add_library(${PROJECT_NAME} ${PROTOCOL_SRC})
