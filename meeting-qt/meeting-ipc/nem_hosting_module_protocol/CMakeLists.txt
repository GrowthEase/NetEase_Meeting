project(nem_hosting_module_protocol)

set(CMAKE_CXX_STANDARD 14)

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/config/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/protocol/)

aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/protocol PROTOCOL_SRC)

add_library(nem_hosting_module_protocol ${PROTOCOL_SRC})
