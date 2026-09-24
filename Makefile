ARCHS = arm64
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = dontstarve
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DSTModLoader

DSTModLoader_FILES = Tweak.x
DSTModLoader_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/DSTModLoader.bundle/Ice\ Backpack$(ECHO_END)
	$(ECHO_NOTHING)cp -R payload/* $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/DSTModLoader.bundle/Ice\ Backpack/$(ECHO_END)

