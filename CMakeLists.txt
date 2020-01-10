cmake_minimum_required(VERSION 3.1)

project(barcode LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "-g -pthread ${CMAKE_CXX_FLAGS}")

find_package(Qt5 COMPONENTS Core Quick SerialPort REQUIRED)

include_directories(
    /opt/jz/jrosmm/include
    /opt/ros/kinetic/include
    )

link_directories(
    /opt/ros/kinetic/lib
    )

add_executable(${PROJECT_NAME}
    barcode.h
    barcode.cc
    main.cc
    qml.qrc
    )

set_target_properties(${PROJECT_NAME}
    PROPERTIES
    LINK_FLAGS "-Wl,-rpath=/home/jz/oyoung/lib:${catkin_LIBRARY_DIRS}"
)
target_compile_definitions(${PROJECT_NAME} PRIVATE
    $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
    )
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Core
    Qt5::Quick
    Qt5::SerialPort

    roscpp
    roscpp_serialization
    rosconsole
    )
