ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = DSTMods

DSTMods_FILES = Tweak.xm
DSTMods_CFLAGS = -fobjc-arc
DSTMods_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/library.mk
