
# This Makefile provides the built-in "run" functionality for Replit.

export PLATFORM = PLATFORM_WEB
export PROJECT_NAME = raylib_game
export PROJECT_BUILD_PATH = $(REPL_HOME)/build
export PROJECT_SOURCE_PATH = $(REPL_HOME)/src
export PROJECT_SOURCE_FILES = $(wildcard $(PROJECT_SOURCE_PATH)/*.c)
export BUILD_WEB_RESOURCES = TRUE
export BUILD_WEB_SHELL = $(PROJECT_SOURCE_PATH)/minshell.html
export PROJECT_CUSTOM_FLAGS = -Wno-unused-function
export CUSTOM_CFLAGS = -Wno-unused-but-set-variable
export RAYLIB_PATH = $(HOME)/raylib
export RAYLIB_SRC_PATH = $(RAYLIB_PATH)/src
export EMSDK_PATH = $(HOME)/emsdk
export EMSDK_QUIET = 1

SHELL = /bin/bash
MAKEFLAGS += --no-print-directory

.PHONY: all run raylib emsdk

# Build the target web files
all: $(PROJECT_BUILD_PATH)/$(PROJECT_NAME).html

# Run the target web files
run: $(PROJECT_BUILD_PATH)/$(PROJECT_NAME).html
	@python3 -m http.server

# Download and build raylib
raylib: $(RAYLIB_SRC_PATH)/libraylib.a

# Build raylib
$(RAYLIB_SRC_PATH)/libraylib.a: $(RAYLIB_SRC_PATH)/Makefile | emsdk
	source "$(EMSDK_PATH)/emsdk_env.sh" && $(MAKE) -C $(RAYLIB_SRC_PATH) raylib

# Download raylib
$(RAYLIB_SRC_PATH)/Makefile:
	git clone --depth=1 https://github.com/raysan5/raylib.git $(RAYLIB_PATH)

# Download and install Emscripten
emsdk: $(EMSDK_PATH)/.emscripten

# Activate Emscripten
$(EMSDK_PATH)/.emscripten: | $(EMSDK_PATH)/upstream/emscripten
	cd $(EMSDK_PATH) && ./emsdk activate latest

# Install Emscripten
$(EMSDK_PATH)/upstream/emscripten: | $(EMSDK_PATH)/emsdk
	cd $(EMSDK_PATH) && ./emsdk install latest

# Download Emscripten
$(EMSDK_PATH)/emsdk:
	git clone --depth=1 https://github.com/emscripten-core/emsdk.git $(EMSDK_PATH)

# Build the target web files
$(PROJECT_BUILD_PATH)/$(PROJECT_NAME).html: $(PROJECT_SOURCE_FILES) $(BUILD_WEB_SHELL) | raylib emsdk
	source "$(EMSDK_PATH)/emsdk_env.sh" && $(MAKE) -C $(PROJECT_SOURCE_PATH) $(PROJECT_NAME)
