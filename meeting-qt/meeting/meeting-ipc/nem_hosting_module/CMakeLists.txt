cmake_minimum_required(VERSION 3.10)

project(nem_hosting_module)

add_definitions(-DNEM_SDK_INTERFACE_COMPONENT_BUILD -DNEM_SDK_INTERFACE_IMPLEMENTATION)

file(GLOB_RECURSE NEM_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface/*.h)
list(REMOVE_ITEM NEM_PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface/sdk_introduction.h)

include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${CMAKE_CURRENT_LIST_DIR}/../)
include_directories(${CMAKE_CURRENT_LIST_DIR}/../nem_sdk_interface)

aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/base/ BASE_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/global/ GLOBAL_SRC)
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/service/ SERVICE_SRC)

if (WIN32)
    add_library(${PROJECT_NAME} SHARED ${GLOBAL_SRC} ${SERVICE_SRC} ${NEM_PUBLIC_HEADERS})
    ne_target_codesign(${PROJECT_NAME} ${CMAKE_BINARY_DIR}/lib)
else ()
    add_library(${PROJECT_NAME} SHARED ${BASE_SRC} ${GLOBAL_SRC} ${SERVICE_SRC} ${NEM_PUBLIC_HEADERS})
endif ()

set_target_properties(${PROJECT_NAME} PROPERTIES PUBLIC_HEADER "${NEM_PUBLIC_HEADERS}")

if (UNIX)
    if (CMAKE_BUILD_TYPE MATCHES "Release")
        set_target_properties(${PROJECT_NAME} PROPERTIES
            XCODE_ATTRIBUTE_DEPLOYMENT_POSTPROCESSING YES
            XCODE_ATTRIBUTE_STRIP_STYLE "non-global"
            XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS YES
            XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
            XCODE_ATTRIBUTE_GCC_INLINES_ARE_PRIVATE_EXTERN YES
            XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN YES
        )
    endif ()
endif ()

if (WIN32)
    target_link_libraries(${PROJECT_NAME}
        Iphlpapi
        Winmm
        Crypt32
        Ws2_32
    )
else ()
    target_link_libraries(${PROJECT_NAME}
        "-framework CFNetwork"
        "-framework Foundation"
    )
endif ()

target_link_libraries(${PROJECT_NAME}
    nipc
    nem_hosting_module_core
    nem_hosting_module_protocol
    # 3rd
    ${CONAN_LIBS_JSONCPP}
    ${CONAN_LIBS_TINYNET}
    ${CONAN_LIBS_TINYSAK}
    ${CONAN_LIBS_OPENSSL}
)

install(
    TARGETS ${PROJECT_NAME}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
    BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    FRAMEWORK DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}
)

if (WIN32)
    install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}> DESTINATION pdb OPTIONAL)
endif ()
