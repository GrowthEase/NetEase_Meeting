project(nem_hosting_module_core)

set(CMAKE_CXX_STANDARD 14)

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinyNET/include/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinySAK/include/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/config/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/manager/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/protocol/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/service/)

aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/manager MANAGER_SRC)

add_library(nem_hosting_module_core ${MANAGER_SRC})
