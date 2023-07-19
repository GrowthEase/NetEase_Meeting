cmake_minimum_required(VERSION 3.10)

project(duilib)

file(GLOB_RECURSE DUILIB_SRC *.cpp *.h)

add_definitions(-DUILIB_EXPORTS)

add_library(${PROJECT_NAME} STATIC ${DUILIB_SRC})
