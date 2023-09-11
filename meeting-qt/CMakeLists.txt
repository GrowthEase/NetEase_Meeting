cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD 14)
set(CONAN_DISABLE_CHECK_COMPILER ON CACHE BOOL "Disable compiler check of conan." FORCE)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/.cmake/")

option(BUILD_IPC_INTERFACE_ONLY "Building IPC interface only" OFF)

project(xkit-desktop)

include(CTest)
include(GetGitRevisionDescription)
include(GNUInstallDirs)
include(PlatformSettings)
include(Win32Codesign)

# IPC
add_subdirectory(meeting/meeting-ipc/nipclib)
add_subdirectory(meeting/meeting-ipc/nem_hosting_module_core)
add_subdirectory(meeting/meeting-ipc/nem_hosting_module_protocol)
add_subdirectory(meeting/meeting-ipc/nem_hosting_module)
if (NOT BUILD_IPC_INTERFACE_ONLY)
    add_subdirectory(meeting/meeting-ipc/nem_hosting_module_client)
    # Meeting
    add_subdirectory(meeting/meeting-ui-sdk)
    add_subdirectory(meeting/meeting-app)
    add_subdirectory(meeting/meeting-sample)
    # Testing
    if (BUILD_TESTING)
        add_subdirectory(testing/integration-testing)
        add_subdirectory(testing/unit-testing)
        add_subdirectory(testing/hawk-e2e-testing)
    endif ()
endif ()

if (NOT BUILD_IPC_INTERFACE_ONLY)
    add_custom_target(conan-install ALL
        COMMAND conan imports ${CMAKE_CURRENT_LIST_DIR}/conanfile.py -imf ${CMAKE_INSTALL_PREFIX}
        COMMENT "Import Conan dependencies......."
    )
endif ()
