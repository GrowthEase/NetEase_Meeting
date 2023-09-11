cmake_minimum_required(VERSION 3.10)

project(NetEaseMeetingClient LANGUAGES CXX)

cmake_policy(SET CMP0087 NEW)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_SOURCE_DIR}/meeting
    ${CMAKE_SOURCE_DIR}/meeting/meeting-ipc/nem_sdk_interface
    ${CMAKE_SOURCE_DIR}/meeting/meeting-ipc/nem_sdk_interface_ipc_client
    ${CMAKE_SOURCE_DIR}/roomkit/include
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core Quick QuickControls2 Gui Multimedia WebEngineQuick Sql Svg Core5Compat REQUIRED)

file(GLOB_RECURSE MEETING_CLIENT_SOURCES *.cpp *.h)
file(GLOB_RECURSE MEETING_CLIENT_MACOSX_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/components/auth_checker.h
    ${CMAKE_CURRENT_LIST_DIR}/components/auth_checker.mm
    ${CMAKE_CURRENT_LIST_DIR}/components/macx_helpers.h
    ${CMAKE_CURRENT_LIST_DIR}/components/macx_helpers.mm
)
file(GLOB MEETING_CLIENT_WIN32_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/components/windows_helpers.h
    ${CMAKE_CURRENT_LIST_DIR}/components/windows_helpers.cpp
)
file(GLOB MEETING_INVALID_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/service/*.h
    ${CMAKE_CURRENT_LIST_DIR}/service/*.cpp
    ${CMAKE_CURRENT_LIST_DIR}/nemeeting_instance.h
    ${CMAKE_CURRENT_LIST_DIR}/nemeeting_instance.cpp
)

if (APPLE)
    list(APPEND MEETING_CLIENT_SOURCES ${MEETING_CLIENT_MACOSX_SOURCES})
    list(REMOVE_ITEM MEETING_CLIENT_SOURCES ${MEETING_CLIENT_WIN32_SOURCES})
else ()
    list(REMOVE_ITEM MEETING_CLIENT_SOURCES ${MEETING_CLIENT_MACOSX_SOURCES})
endif ()

list(REMOVE_ITEM MEETING_CLIENT_SOURCES ${MEETING_INVALID_SOURCES})

find_program(QT_LUPDATE NAMES lupdate)
find_program(QT_LRELEASE NAMES lrelease)
if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/meeting-ui-sdk_zh_CN.qm)
    execute_process(COMMAND ${QT_LUPDATE} ${CMAKE_CURRENT_LIST_DIR} -ts meeting-ui-sdk_zh_CN.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
    execute_process(COMMAND ${QT_LRELEASE} meeting-ui-sdk_zh_CN.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif ()
if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/meeting-ui-sdk_ja_JP.qm)
    execute_process(COMMAND ${QT_LUPDATE} ${CMAKE_CURRENT_LIST_DIR} -ts meeting-ui-sdk_ja_JP.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
    execute_process(COMMAND ${QT_LRELEASE} meeting-ui-sdk_ja_JP.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif ()

file(GLOB_RECURSE MEETING_CLIENT_ASSETS ${CMAKE_BINARY_DIR}/lib/resource/*.*)
file(GLOB_RECURSE MEETING_CLIENT_CONFIG ${CMAKE_SOURCE_DIR}/meeting/bin/config/*.*)
file(GLOB_RECURSE MEETING_CLIENT_IMAGES ${CMAKE_SOURCE_DIR}/meeting/bin/image/*.*)
file(GLOB MEETING_CLIENT_RESOURCES
    ${CMAKE_CURRENT_LIST_DIR}/meeting-ui-sdk_zh_CN.qm
    ${CMAKE_CURRENT_LIST_DIR}/meeting-ui-sdk_ja_JP.qm
    ${CMAKE_SOURCE_DIR}/meeting/bin/rain.mp3
)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/version.h.in
    ${CMAKE_CURRENT_LIST_DIR}/version.h
)

if (MSVC)
    configure_file(
        ${CMAKE_SOURCE_DIR}/.cmake/version.rc.in
        ${CMAKE_BINARY_DIR}/version_${PROJECT_NAME}.rc
    )
    add_executable(${PROJECT_NAME} WIN32
        qml.qrc
        ${MEETING_CLIENT_SOURCES}
        ${CMAKE_BINARY_DIR}/version_${PROJECT_NAME}.rc
    )
    file(COPY ${CMAKE_BINARY_DIR}/lib/resource/assets DESTINATION ${CMAKE_BINARY_DIR}/bin FILES_MATCHING PATTERN "*")
    file(COPY ${MEETING_CLIENT_CONFIG} DESTINATION ${CMAKE_BINARY_DIR}/bin/config)
    file(COPY ${MEETING_CLIENT_IMAGES} DESTINATION ${CMAKE_BINARY_DIR}/bin/image/vb)
    file(COPY ${MEETING_CLIENT_RESOURCES} DESTINATION ${CMAKE_BINARY_DIR}/bin)
    ne_target_codesign(${PROJECT_NAME} ${CMAKE_BINARY_DIR}/lib)
elseif (APPLE)
    list(APPEND MEETING_CLIENT_SOURCES ${CMAKE_SOURCE_DIR}/meeting/bin/macx.icns)
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE
        ${MEETING_CLIENT_SOURCES}
        ${MEETING_CLIENT_ASSETS}
        ${MEETING_CLIENT_CONFIG}
        ${MEETING_CLIENT_IMAGES}
        ${MEETING_CLIENT_RESOURCES}
        qml.qrc
    )
    # Copy resources
    foreach(RES_FILE ${MEETING_CLIENT_ASSETS})
        file(RELATIVE_PATH RES_PATH "${CMAKE_BINARY_DIR}/lib/resource" ${RES_FILE})
        set_property(SOURCE ${RES_FILE} PROPERTY MACOSX_PACKAGE_LOCATION "Resources/${RES_PATH}")
    endforeach(RES_FILE)
    set_source_files_properties(${MEETING_CLIENT_CONFIG} PROPERTIES MACOSX_PACKAGE_LOCATION Resources/config)
    set_source_files_properties(${MEETING_CLIENT_IMAGES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources/image/vb)
    set_source_files_properties(${MEETING_CLIENT_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endif ()

target_precompile_headers(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/stable.h)

if (APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        INSTALL_RPATH "@executable_path/../Frameworks;@executable_path/../Frameworks/NetEaseMeetingClient.app/Contents/Frameworks"
        # XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "569GNZ5392"
    )
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
else ()
    set_target_properties(${PROJECT_NAME} PROPERTIES
        LINK_FLAGS "/FORCE:MULTIPLE"
    )
endif ()

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        "-framework CoreVideo"
        "-framework AppKit"
        "-framework AVFoundation"
    )
else ()
    target_link_libraries(${PROJECT_NAME} PRIVATE Psapi)
endif ()

target_link_libraries(${PROJECT_NAME} PRIVATE
    ${CONAN_LIBS_ALOG}
    ${CONAN_LIBS_LIBYUV}
    ${CONAN_LIBS_ROOMKIT}
    Qt6::Gui
    Qt6::Quick
    Qt6::Multimedia
    Qt6::QuickControls2
    Qt6::WebEngineQuick
    Qt6::Sql
    Qt6::Svg
    Qt6::Core5Compat
    nem_hosting_module_client
)

install(
    TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
    BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
)

if (WIN32)
    install(DIRECTORY ${CMAKE_BINARY_DIR}/lib/resource/assets DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
    install(FILES ${MEETING_CLIENT_CONFIG} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/config)
    install(FILES ${MEETING_CLIENT_IMAGES} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/image/vb)
    install(FILES ${MEETING_CLIENT_RESOURCES} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
    install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}> DESTINATION pdb OPTIONAL)
endif ()
