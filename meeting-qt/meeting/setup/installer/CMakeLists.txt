cmake_minimum_required(VERSION 3.10)

project(installer DESCRIPTION "NetEase meeting installer")

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/setup.rc.in
    ${CMAKE_CURRENT_LIST_DIR}/setup.rc
)

file(GLOB_RECURSE INSTALLER_SOURCES *.cpp *.h ${CMAKE_CURRENT_LIST_DIR}/setup.rc)

add_executable(${PROJECT_NAME} ${INSTALLER_SOURCES})

set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

ne_target_codesign(${PROJECT_NAME} ${CMAKE_BINARY_DIR}/bin)

execute_process(COMMAND curl -L -o ${CMAKE_INSTALL_PREFIX}/bin/vc_redist.x64.exe https://aka.ms/vs/17/release/vc_redist.x64.exe)

add_custom_target(zip_binaries
    COMMAND ${CMAKE_COMMAND} -E tar "cf" ${CMAKE_CURRENT_LIST_DIR}/release.7z --format=7zip -- ${CMAKE_INSTALL_PREFIX}/bin
    WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}
    VERBATIM
    USES_TERMINAL
    COMMENT "Packing release 7z files......."
)

add_custom_target(zip_install_res ALL
	COMMAND ${CMAKE_COMMAND} -E tar "cf"  ${CMAKE_CURRENT_LIST_DIR}/res.zip --format=zip -- res
	WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin
    VERBATIM
    USES_TERMINAL
    COMMENT "Packing resources files to ${CMAKE_CURRENT_LIST_DIR}"
)

add_dependencies(${PROJECT_NAME} zip_binaries zip_install_res)

set_target_properties(${PROJECT_NAME} PROPERTIES
    LINK_FLAGS "/MANIFESTUAC:\"level='requireAdministrator' uiAccess='false'\" /SUBSYSTEM:WINDOWS"
)

target_link_libraries(${PROJECT_NAME}
	base
	duilib
	GDIPlus
	Comctl32
	Msimg32
)

install(
    TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}
)
