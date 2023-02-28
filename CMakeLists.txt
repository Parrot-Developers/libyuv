# CMakeLists for libyuv
# Originally created for "roxlu build system" to compile libyuv on windows
# Run with -DTEST=ON to build unit tests

cmake_minimum_required(VERSION 3.15)
project(libyuv 
          VERSION 1.0 
          LANGUAGES C CXX 
)	# "C" is required even for C++ projects


OPTION( TEST "Built unit tests" OFF )
OPTION( USE_JPEG "Build with libjpeg" OFF)
OPTION( YUV_SHARED "Build shared library" ON)
OPTION( YUV_STATIC "Build static library" ON)
OPTION( BUILD_EXECUTABLE "Build yuvconvert executable" OFF)

SET ( ly_base_dir	${PROJECT_SOURCE_DIR} )
SET ( ly_src_dir	${ly_base_dir}/source )
SET ( ly_inc_dir	${ly_base_dir}/include )
SET ( ly_tst_dir	${ly_base_dir}/unit_test )

SET ( ly_lib_name	yuv )
SET ( ly_lib_static	${ly_lib_name} )
SET ( ly_lib_shared	${ly_lib_name}_shared )

FILE ( GLOB_RECURSE	ly_source_files ${ly_src_dir}/*.cc )
LIST ( SORT			ly_source_files )

FILE ( GLOB_RECURSE	ly_unittest_sources ${ly_tst_dir}/*.cc )
LIST ( SORT			ly_unittest_sources )

# this creates the static library (.a)
if (YUV_STATIC)
  ADD_LIBRARY				( ${ly_lib_static} STATIC ${ly_source_files} )
  TARGET_INCLUDE_DIRECTORIES(${ly_lib_static} PUBLIC ${ly_inc_dir})
  SET_TARGET_PROPERTIES(${ly_lib_static} PROPERTIES
                         POSITION_INDEPENDENT_CODE ${BUILD_SHARED_LIBS})
endif()

# this creates the shared library (.so)
if (YUV_SHARED)
  ADD_LIBRARY( ${ly_lib_shared} SHARED ${ly_source_files} )
  SET_TARGET_PROPERTIES	( ${ly_lib_shared} PROPERTIES OUTPUT_NAME "${ly_lib_name}" )
  SET_TARGET_PROPERTIES	( ${ly_lib_shared} PROPERTIES PREFIX "lib" )
  TARGET_INCLUDE_DIRECTORIES(${ly_lib_shared} PUBLIC ${ly_inc_dir})

# state that libpomp need PIC when the default is shared libraries
  SET_TARGET_PROPERTIES( ${ly_lib_shared} PROPERTIES
                         POSITION_INDEPENDENT_CODE ${BUILD_SHARED_LIBS}
    )
endif()

# this creates the conversion tool
if (BUILD_EXECUTABLE)
  ADD_EXECUTABLE			( yuvconvert ${ly_base_dir}/util/yuvconvert.cc )
  TARGET_LINK_LIBRARIES	( yuvconvert ${ly_lib_static} )
endif()

if (USE_JPEG)
  INCLUDE ( FindJPEG )
  if (JPEG_FOUND)
    include_directories( ${JPEG_INCLUDE_DIR} )
    if (BUILD_EXECUTABLE)
      target_link_libraries( yuvconvert ${JPEG_LIBRARY} )
    endif()
    add_definitions( -DHAVE_JPEG )
  endif()
endif()

if(TEST)
  find_library(GTEST_LIBRARY gtest)
  if(GTEST_LIBRARY STREQUAL "GTEST_LIBRARY-NOTFOUND")
    set(GTEST_SRC_DIR /usr/src/gtest CACHE STRING "Location of gtest sources")
    if(EXISTS ${GTEST_SRC_DIR}/src/gtest-all.cc)
      message(STATUS "building gtest from sources in ${GTEST_SRC_DIR}")
      set(gtest_sources ${GTEST_SRC_DIR}/src/gtest-all.cc)
      add_library(gtest STATIC ${gtest_sources})
      include_directories(${GTEST_SRC_DIR})
      include_directories(${GTEST_SRC_DIR}/include)
      set(GTEST_LIBRARY gtest)
    else()
      message(FATAL_ERROR "TEST is set but unable to find gtest library")
    endif()
  endif()

  add_executable(libyuv_unittest ${ly_unittest_sources})
  target_link_libraries(libyuv_unittest ${ly_lib_name} ${GTEST_LIBRARY})
  find_library(PTHREAD_LIBRARY pthread)
  if(NOT PTHREAD_LIBRARY STREQUAL "PTHREAD_LIBRARY-NOTFOUND")
    target_link_libraries(libyuv_unittest pthread)
  endif()
  if (JPEG_FOUND)
    target_link_libraries(libyuv_unittest ${JPEG_LIBRARY})
  endif()

  if(NACL AND NACL_LIBC STREQUAL "newlib")
    target_link_libraries(libyuv_unittest glibc-compat)
  endif()
endif()

# install the conversion tool, .so, .a, and all the header files
if (BUILD_EXECUTABLE)
  INSTALL ( PROGRAMS ${CMAKE_BINARY_DIR}/yuvconvert			DESTINATION bin )
endif()
if (YUV_STATIC)
  INSTALL ( TARGETS ${ly_lib_static}						DESTINATION lib )
endif()
if (YUV_SHARED)
  INSTALL ( TARGETS ${ly_lib_shared} LIBRARY				DESTINATION lib RUNTIME DESTINATION bin )
endif()
INSTALL ( DIRECTORY ${PROJECT_SOURCE_DIR}/include/		DESTINATION include )

# create the .deb and .rpm packages using cpack
INCLUDE ( CM_linux_packages.cmake )

