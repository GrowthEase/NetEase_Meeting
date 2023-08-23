cmake_minimum_required(VERSION 3.10)

project(MeetingSample LANGUAGES CXX)

cmake_policy(SET CMP0087 NEW)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core Widgets Quick QuickControls2 WebEngineQuick Gui Sql Core5Compat REQUIRED)

include_directories(
    ${CMAKE_SOURCE_DIR}/meeting
    ${CMAKE_SOURCE_DIR}/meeting/meeting-ipc/nem_sdk_interface
)

file(GLOB_RECURSE MEETING_SAMPLE_SOURCES *.cpp *.h)

if (MSVC)
    add_executable(${PROJECT_NAME} WIN32
        qml.qrc
        ${MEETING_SAMPLE_SOURCES}
    )
    ne_target_codesign(${PROJECT_NAME} ${CMAKE_BINARY_DIR}/bin)
elseif (APPLE)
    list(APPEND MACOSX_BUNDLE_RESOURCES ${CMAKE_SOURCE_DIR}/meeting/bin/macx.icns)
    if (CMAKE_BUILD_TYPE MATCHES "Release")
        list(APPEND MACOSX_BUNDLE_RESOURCES ${CMAKE_SOURCE_DIR}/meeting/bin/qt.conf)
    endif ()
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE
        ${MEETING_SAMPLE_SOURCES}
        ${MACOSX_BUNDLE_RESOURCES}
        macx_helper.mm
        qml.qrc
    )
    set_source_files_properties(${MACOSX_BUNDLE_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endif ()

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
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Gui
        Qt6::Widgets
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Sql
        Qt6::WebEngineQuick
    )
endif ()

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Gui
    Qt6::Widgets
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
    Qt6::WebEngineQuick
    Qt6::Core5Compat
    nem_hosting_module
)

if (APPLE)
    install(
        TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
        BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    )
else ()
    install(
        TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/sample
        BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    )
endif ()

if (WIN32)
    install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}> DESTINATION pdb OPTIONAL)
endif ()

# qt deploy
if (CMAKE_BUILD_TYPE MATCHES "Release")
    if (APPLE)
        find_program(QT_DEPLOY_QT NAMES macdeployqt)
        set(MEETING_SAMPLE ${PROJECT_NAME}.app)
        set(MEETING_SAMPLE_FRAMEWORKS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${MEETING_SAMPLE}/Contents/Frameworks)
        set(MEETING_CLIENT NetEaseMeetingClient.app)
        set(MEETING_LIBS_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
        set(MEETING_BINARY_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
        add_custom_target(qtdeploy-sample
            COMMAND mkdir ${MEETING_SAMPLE_FRAMEWORKS}
            COMMAND cp -R ${MEETING_LIBS_DIR}/libnem_hosting_module.dylib ${MEETING_SAMPLE_FRAMEWORKS}
            COMMAND cp -R ${MEETING_BINARY_DIR}/${MEETING_CLIENT} ${MEETING_SAMPLE_FRAMEWORKS}
            COMMAND codesign --entitlements=${CMAKE_SOURCE_DIR}/meeting/bin/NetEaseMeeting.entitlements --timestamp --options=runtime -f -s "06C66D0DDF51A99C6A5C0F65BF9B2ABB5FD409B4" -v ${CMAKE_INSTALL_PREFIX}/bin/${PROJECT_NAME}.app --deep
            COMMENT "Deploying qt dependencies after build for meeting sample..."
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    endif ()
endif ()
