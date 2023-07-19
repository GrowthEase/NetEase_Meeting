cmake_minimum_required(VERSION 3.10)

project(base)

add_definitions(-DNOMINMAX)

file(GLOB_RECURSE BASE_SRC *.h *.cpp *.c)
file(GLOB_RECURSE BASE_UNITTEST_SRC *_unittest.h *_unittest.cpp)

list(REMOVE_ITEM BASE_SRC
    ${BASE_UNITTEST_SRC}
    ${CMAKE_CURRENT_LIST_DIR}/framework/libuv_message_pump.cpp
    ${CMAKE_CURRENT_LIST_DIR}/network/http.h
    ${CMAKE_CURRENT_LIST_DIR}/network/http.cpp
)

add_library(${PROJECT_NAME} STATIC ${BASE_SRC})
