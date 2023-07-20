project(nipc)

if (WIN32)
    add_definitions(-DTINYSAK_IMPORTS_IGNORE -DTINYNET_IMPORTS_IGNORE)
endif ()

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/base/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/config/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/ipc/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/proxy_config/)

aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/base BASE_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/ipc IPC_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/ipc/package IPC_PACKAGE_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/proxy_config PROXY_CONFIG_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/socket SOCKET_SRC)

add_library(${PROJECT_NAME}
    ${BASE_SRC}
    ${IPC_SRC}
    ${IPC_PACKAGE_SRC}
    ${PROXY_CONFIG_SRC}
    ${SOCKET_SRC}
)
