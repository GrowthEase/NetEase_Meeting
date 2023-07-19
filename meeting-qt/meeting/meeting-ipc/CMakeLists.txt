cmake_minimum_required(VERSION 3.10)

IF (UNIX)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum OS X deployment version")
ENDIF ()

project(nem_ipc_module)

set(CMAKE_DEBUG_POSTFIX d)
IF (WIN32)
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF")
ENDIF ()

add_definitions(-DUNICODE -D_UNICODE -DTINYNET_EXPORTS -DNEM_SDK_INTERFACE_COMPONENT_BUILD -DNEM_SDK_INTERFACE_IMPLEMENTATION)

add_subdirectory(nipclib)
add_subdirectory(nem_hosting_module_core)
add_subdirectory(nem_hosting_module_protocol)
add_subdirectory(nem_hosting_module)
add_subdirectory(nem_hosting_module_client)
