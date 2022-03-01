cmake_minimum_required(VERSION 3.10)

set(TARGET_NAME nem_hosting_module)
file(GLOB_RECURSE NEM_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface/*.h)
list(REMOVE_ITEM NEM_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface/sdk_introduction.h)

project(${TARGET_NAME})

set(CMAKE_CXX_STANDARD 14)

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinyNET/include/)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinySAK/include/)

aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/base/ BASE_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/global/ GLOBAL_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/service/ SERVICE_SRC)

IF (WIN32)
	link_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/jsoncpp/prebuild/windows/x86/)
	link_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/openssl/prebuild/windows/x86/)
	link_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinyNET/prebuild/windows/x86/)
	link_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinySAK/prebuild/windows/x86/)
ELSE ()
	link_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/jsoncpp/prebuild/Mac/)
	link_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinyNET/prebuild/Mac/)
	link_directories(${CMAKE_CURRENT_LIST_DIR}/../third_party/doubanguo/tinySAK/prebuild/Mac/)
ENDIF ()

IF (WIN32)
	add_library(${TARGET_NAME} SHARED ${GLOBAL_SRC} ${SERVICE_SRC} ${NEM_PUBLIC_HEADERS})
ELSE ()
	add_library(${TARGET_NAME} SHARED ${BASE_SRC} ${GLOBAL_SRC} ${SERVICE_SRC} ${NEM_PUBLIC_HEADERS})
ENDIF ()

IF (UNIX)
	set_target_properties(${TARGET_NAME} PROPERTIES 
	  FRAMEWORK TRUE 
	  FRAMEWORK_VERSION C 
	  VERSION 1.0.0
	  SOVERSION 1.0.0
	  PUBLIC_HEADER "${NEM_PUBLIC_HEADERS}"
	)
ENDIF ()

IF (WIN32)
	target_link_libraries(${TARGET_NAME} 
		debug jsoncpp_d optimized jsoncpp 
		debug tinyNETd optimized tinyNET 
		debug tinySAKd optimized tinySAK 
		debug libcryptod optimized libcrypto 
		debug libssld optimized libssl 
  )
  target_link_libraries(${TARGET_NAME} Iphlpapi)
  target_link_libraries(${TARGET_NAME} Winmm)
  target_link_libraries(${TARGET_NAME} Crypt32)
  target_link_libraries(${TARGET_NAME} Ws2_32)
ELSE ()
	target_link_libraries(${TARGET_NAME} jsoncpp)
	target_link_libraries(${TARGET_NAME} tinyNet)
	target_link_libraries(${TARGET_NAME} tinySAK)
ENDIF ()

target_link_libraries(${TARGET_NAME} nipc)
target_link_libraries(${TARGET_NAME} nem_hosting_module_core)
target_link_libraries(${TARGET_NAME} nem_hosting_module_protocol)
