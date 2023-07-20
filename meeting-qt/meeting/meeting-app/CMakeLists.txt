cmake_minimum_required(VERSION 3.10)

project(NetEaseMeeting LANGUAGES CXX)

cmake_policy(SET CMP0087 NEW)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Widgets Quick QuickControls2 WebEngine Gui Sql REQUIRED)

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}/third_party/neplauncher/include
    ${CMAKE_SOURCE_DIR}/meeting
    ${CMAKE_SOURCE_DIR}/meeting/meeting-app/modules
    ${CMAKE_SOURCE_DIR}/meeting/meeting-ipc/nem_sdk_interface
)

file(GLOB_RECURSE MEETING_SOURCES *.cpp *.h)
file(GLOB_RECURSE MEETING_MAC_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/components/macxhelper.h
    ${CMAKE_CURRENT_LIST_DIR}/components/macxhelper.mm
)

if (APPLE)
    list(APPEND MEETING_SOURCES ${MEETING_MAC_SOURCES})
else ()
    list(REMOVE_ITEM MEETING_SOURCES ${MEETING_MAC_SOURCES})
endif ()

find_program(QT_LUPDATE NAMES lupdate)
find_program(QT_LRELEASE NAMES lrelease)
if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/meeting-app_en_US.qm)
    execute_process(COMMAND ${QT_LUPDATE} ${CMAKE_CURRENT_LIST_DIR} -ts meeting-app_en_US.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
    execute_process(COMMAND ${QT_LRELEASE} meeting-app_en_US.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif ()
if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/meeting-app_en_CN.qm)
    execute_process(COMMAND ${QT_LUPDATE} ${CMAKE_CURRENT_LIST_DIR} -ts meeting-app_en_CN.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
    execute_process(COMMAND ${QT_LRELEASE} meeting-app_en_CN.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif ()
if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/meeting-app_zh_CN.qm)
    execute_process(COMMAND ${QT_LUPDATE} ${CMAKE_CURRENT_LIST_DIR} -ts meeting-app_zh_CN.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
    execute_process(COMMAND ${QT_LRELEASE} meeting-app_zh_CN.ts WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif ()

file(GLOB_RECURSE MEETING_APP_LOCALIZAION_PLIST
    ${CMAKE_SOURCE_DIR}/meeting/bin/localization/en.lproj/*.*
    ${CMAKE_SOURCE_DIR}/meeting/bin/localization/zh-Hans.lproj/*.*
    ${CMAKE_SOURCE_DIR}/meeting/bin/localization/zh-Hant.lproj/*.*
    ${CMAKE_SOURCE_DIR}/meeting/bin/localization/zh-HK.lproj/*.*
)
set(MACOSX_BUNDLE_RESOURCES
    ${CMAKE_CURRENT_LIST_DIR}/meeting-app_en_US.qm
    ${CMAKE_CURRENT_LIST_DIR}/meeting-app_en_CN.qm
    ${CMAKE_CURRENT_LIST_DIR}/meeting-app_zh_CN.qm
    ${CMAKE_SOURCE_DIR}/meeting/bin/feedback.png
    ${CMAKE_SOURCE_DIR}/meeting/bin/feedback_upload.png
    ${CMAKE_SOURCE_DIR}/THIRD_PARTY_COPYRIGHT.txt
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
        ${MEETING_SOURCES}
        ${CMAKE_BINARY_DIR}/version_${PROJECT_NAME}.rc
    )
    file(COPY ${MACOSX_BUNDLE_RESOURCES} DESTINATION ${CMAKE_BINARY_DIR}/bin)
    ne_target_codesign(${PROJECT_NAME} ${CMAKE_BINARY_DIR}/bin)
elseif (APPLE)
    list(APPEND MACOSX_BUNDLE_RESOURCES ${CMAKE_SOURCE_DIR}/meeting/bin/macx.icns)
    if (CMAKE_BUILD_TYPE MATCHES "Release")
        list(APPEND MACOSX_BUNDLE_RESOURCES ${CMAKE_SOURCE_DIR}/meeting/bin/qt.conf)
    endif ()
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE
        ${MEETING_SOURCES}
        ${MACOSX_BUNDLE_RESOURCES}
        ${MEETING_APP_LOCALIZAION_PLIST}
        qml.qrc
    )
    set_source_files_properties(${MACOSX_BUNDLE_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    set_source_files_properties(${MEETING_APP_LOCALIZAION_PLIST} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    if (CMAKE_BUILD_TYPE MATCHES "Release")
        set_source_files_properties(${CMAKE_SOURCE_DIR}/meeting/bin/qt.conf PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    endif ()
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
endif ()

if (APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        "-framework AppKit"
        "-framework CoreVideo"
    )
else ()
    if (CMAKE_BUILD_TYPE MATCHES "Release")
        target_link_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/third_party/neplauncher/libs/x64/Release)
        target_link_libraries(${PROJECT_NAME} PRIVATE NEPLauncher)
    else ()
        target_link_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/third_party/neplauncher/libs/x64/Debug)
        target_link_libraries(${PROJECT_NAME} PRIVATE NEPLauncher)
    endif ()
endif ()

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Gui
    Qt5::Widgets
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Sql
    Qt5::WebEngine
    nem_hosting_module
    ${CONAN_LIBS_ALOG}
)

install(
    TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
    BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
)

if (APPLE)
    install(FILES
        ${CMAKE_SOURCE_DIR}/meeting/bin/NetEaseMeeting.json
        ${CMAKE_SOURCE_DIR}/meeting/bin/macx.icns
        ${CMAKE_SOURCE_DIR}/meeting/bin/macxdmg.png
        DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
    )
else ()
    list(APPEND MACOSX_BUNDLE_RESOURCES
        ${CMAKE_SOURCE_DIR}/meeting/bin/libcrypto-1_1-x64.dll
        ${CMAKE_SOURCE_DIR}/meeting/bin/libssl-1_1-x64.dll
    )
    install(FILES ${MACOSX_BUNDLE_RESOURCES} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
    install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}> DESTINATION pdb OPTIONAL)
endif ()

# qt deploy
if (CMAKE_BUILD_TYPE MATCHES "Release")
    if (APPLE)
        find_program(QT_DEPLOY_QT NAMES macdeployqt)
        set(MEETING_APP ${PROJECT_NAME}.app)
        set(MEETING_CLIENT NetEaseMeetingClient.app)
        set(MEETING_APP_FRAMEWORKS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${MEETING_APP}/Contents/Frameworks)
        set(MEETING_CLIENT_FRAMEWORKS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${MEETING_CLIENT}/Contents/Frameworks)
        set(MEETING_LIBS_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
        set(MEETING_BINARY_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
        add_custom_target(qtdeploy-meeting
            COMMAND ${QT_DEPLOY_QT} ${CMAKE_INSTALL_PREFIX}/bin/${MEETING_CLIENT} -qmldir=${CMAKE_SOURCE_DIR}/meeting/meeting-ui-sdk/qml
            COMMAND mkdir ${MEETING_APP_FRAMEWORKS}
            COMMAND cp -R ${MEETING_LIBS_DIR}/*.dylib ${MEETING_CLIENT_FRAMEWORKS}
            COMMAND cp -R ${MEETING_LIBS_DIR}/nertc*.framework ${MEETING_CLIENT_FRAMEWORKS}
            COMMAND cp -R ${MEETING_LIBS_DIR}/NE*.framework ${MEETING_CLIENT_FRAMEWORKS}
            COMMAND python3 ${CMAKE_SOURCE_DIR}/meeting/build_tool/mac/lipo-remove.py ${MEETING_BINARY_DIR}/${MEETING_CLIENT} ${CMAKE_OSX_ARCHITECTURES}
            COMMAND cp -R ${MEETING_BINARY_DIR}/${MEETING_CLIENT} ${MEETING_APP_FRAMEWORKS}
            COMMAND codesign --entitlements=${CMAKE_SOURCE_DIR}/meeting/bin/NetEaseMeeting.entitlements --timestamp --options=runtime -f -s "06C66D0DDF51A99C6A5C0F65BF9B2ABB5FD409B4" -v ${CMAKE_INSTALL_PREFIX}/bin/${PROJECT_NAME}.app --deep
            COMMENT "Deploying qt dependencies after build..."
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    else ()
        find_program(QT_DEPLOY_QT NAMES windeployqt)
        add_custom_target(qtdeploy-meeting
            COMMAND ${QT_DEPLOY_QT} ${CMAKE_INSTALL_PREFIX}/bin/${PROJECT_NAME}Client.exe -qmldir=${CMAKE_SOURCE_DIR}/meeting/meeting-ui-sdk/qml
            COMMAND ${QT_DEPLOY_QT} ${CMAKE_INSTALL_PREFIX}/bin/${PROJECT_NAME}.exe -qmldir=${CMAKE_SOURCE_DIR}/meeting/meeting-app/qml
            COMMENT "Deploying qt dependencies after build........."
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    endif ()
endif ()
