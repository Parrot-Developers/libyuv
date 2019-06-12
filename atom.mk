LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libyuv
LOCAL_CATEGORY_PATH := libs
LOCAL_DESCRIPTION := YUV scaling and conversion library
LOCAL_EXPORT_LDLIBS := -lyuv
include $(BUILD_CMAKE)
