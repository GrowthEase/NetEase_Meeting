cmake_minimum_required(VERSION 3.10)

project(meeting-setup)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../.cmake/")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Gm- /Zi /MT")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF")
add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

include_directories(${CMAKE_CURRENT_BINARY_DIR})

include(GetGitRevisionDescription)
include(GNUInstallDirs)
include(Win32Codesign)

add_definitions(
    -DUNICODE
    -D_UNICODE
    -DPSAPI_VERSION=1
    -DWIN32_LEAN_AND_MEAN
)

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}
)

add_subdirectory(base)
add_subdirectory(duilib)
add_subdirectory(uninstaller)
add_subdirectory(installer)
add_dependencies(zip_binaries uninstall)
