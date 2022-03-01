project(nipc)

set(CMAKE_CXX_STANDARD 14)

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinyNET/include/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinySAK/include/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/base/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/config/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/ipc/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/proxy_config/)

aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/base BASE_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/ipc IPC_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/ipc/package IPC_PACKAGE_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/proxy_config PROXY_CONFIG_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/socket SOCKET_SRC)

add_library(nipc
	${BASE_SRC} 
	${IPC_SRC} 
	${IPC_PACKAGE_SRC} 
	${PROXY_CONFIG_SRC} 
	${SOCKET_SRC} 
)
