LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libyuv
LOCAL_CATEGORY_PATH := libs
LOCAL_DESCRIPTION := YUV scaling and conversion library
LOCAL_EXPORT_LDLIBS := -lyuv

ifeq ("$(TARGET_FORCE_STATIC)","1")
	LOCAL_CMAKE_CONFIGURE_ARGS := -DYUV_SHARED=OFF
endif

include $(BUILD_CMAKE)
