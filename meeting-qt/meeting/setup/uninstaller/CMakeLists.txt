cmake_minimum_required(VERSION 3.10)

project(uninstall DESCRIPTION "NetEase meeting uninstaller")

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/setup.rc.in
    ${CMAKE_CURRENT_LIST_DIR}/setup.rc
)

file(GLOB_RECURSE UNINSTALLER_SOURCES *.cpp *.h ${CMAKE_CURRENT_LIST_DIR}/setup.rc)

add_executable(${PROJECT_NAME} ${UNINSTALLER_SOURCES})

set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_custom_target(zip_uninstall_res ALL
	COMMAND ${CMAKE_COMMAND} -E tar "cf"  ${CMAKE_CURRENT_LIST_DIR}/res.zip --format=zip -- res
	WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin
    VERBATIM
    USES_TERMINAL
    COMMENT "Packing resources files to ${CMAKE_CURRENT_LIST_DIR}"
)

add_dependencies(${PROJECT_NAME} zip_uninstall_res)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
	COMMAND ${CMAKE_BINARY_DIR}/ssigncode.exe -c -t sha256 -f $<TARGET_FILE:${PROJECT_NAME}>
	COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${PROJECT_NAME}> ${CMAKE_INSTALL_PREFIX}/bin
	WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin
	DEPENDS codesign_${PROJECT_NAME}
	COMMENT "Copying ${PROJECT_NAME} to ${CMAKE_INSTALL_PREFIX}/bin"
)

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
