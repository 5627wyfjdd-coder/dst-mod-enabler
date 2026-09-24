ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = dontstarvetogether

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DSTMods

DSTMods_FILES = Tweak.xm
DSTMods_CFLAGS = -fobjc-arc
DSTMods_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
