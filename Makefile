# Python and PyTorch paths
PYTHON := .venv/bin/python
PYTHON_CONFIG := $(PYTHON)-config
PYTHON_ROOT := $(shell $(PYTHON) -c "import sys; print(sys.prefix)")
PYTHON_INCLUDE := $(shell $(PYTHON) -c "from sysconfig import get_paths; print(get_paths()['include'])")

# PyTorch paths
TORCH_PATH := $(shell $(PYTHON) -c "import os, torch; print(os.path.dirname(torch.__file__))")
TORCH_INCLUDE := $(TORCH_PATH)/include
TORCH_LIB := $(TORCH_PATH)/lib

# System-specific settings
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    EXTENSION_SUFFIX := $(shell $(PYTHON) -c 'import sysconfig; print(sysconfig.get_config_var("EXT_SUFFIX"))')
    SHARED_FLAG := -bundle -undefined dynamic_lookup
else
    EXTENSION_SUFFIX := .so
    SHARED_FLAG := -shared
endif

# Compiler settings
CXX := clang
CXXFLAGS := -O3 -fPIC -std=c++17 -Wall -Wextra -Wunused-parameter
INCLUDES := -I$(PYTHON_INCLUDE) \
           -I$(TORCH_INCLUDE) \
           -I$(TORCH_INCLUDE)/torch/csrc/api/include
LDFLAGS := -L$(TORCH_LIB) -ltorch -ltorch_cpu -lc10 $(SHARED_FLAG)

# Module definitions
MODULES := custom_matmul other_custom_matmul
TARGETS := $(foreach mod,$(MODULES),$(mod)/_C$(EXTENSION_SUFFIX))

# Build targets
.PHONY: all clean debug $(MODULES)

all: $(TARGETS)

# Generic rule for building modules
%/_C$(EXTENSION_SUFFIX): %/extension.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -DTORCH_EXTENSION_NAME=_C $^ $(LDFLAGS) -o $@

# Individual module targets
$(MODULES): %: %/_C$(EXTENSION_SUFFIX)

clean:
	rm -rf build dist *.egg-info
	rm -f $(TARGETS)
	find . -type d -name "__pycache__" -exec rm -rf {} +

debug:
	@echo "Python paths:"
	@echo "  PYTHON_ROOT: $(PYTHON_ROOT)"
	@echo "  PYTHON_INCLUDE: $(PYTHON_INCLUDE)"
	@echo "PyTorch paths:"
	@echo "  TORCH_PATH: $(TORCH_PATH)"
	@echo "  TORCH_INCLUDE: $(TORCH_INCLUDE)"
	@echo "  TORCH_LIB: $(TORCH_LIB)"
	@echo "Build settings:"
	@echo "  MODULES: $(MODULES)"
	@echo "  TARGETS: $(TARGETS)"
	@echo "  EXTENSION_SUFFIX: $(EXTENSION_SUFFIX)"