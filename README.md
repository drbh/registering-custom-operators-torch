# registering custom operators in torch

This tiny project demonstrates how to create a custom matmul and register it as a torch operator.

This method registers custom code as `ops` ie. `torch.ops.custom_ops.matmul` is the latest recommended way to create [custom operators](https://pytorch.org/tutorials/advanced/cpp_custom_ops.html#cpp-custom-ops-tutorial) in pytorch. 

Previously the recommended method was to directly call the function `custom_ops.matmul(_)` read more about the [deprecated](https://pytorch.org/tutorials/advanced/cpp_extension.html) method on the pytorch website.

## Setup

first lets setup a virtual environment and install torch.

```bash
# install torch and numpy to .venv
uv sync 
```

now build the cpp extensions

```bash
# build the cpp extensions as .so files
make 
```

## Run

finally, run the tests

```bash
# use the custom matmul function (using torch.ops.__LIBRARY_NAME__.matmul)
uv run demo.py 
# Both custom matmul extensions loaded successfully
# Result 1 shape: torch.Size([3, 5])
# Result 2 shape: torch.Size([3, 5])
# Max difference (result1): 4.76837158203125e-07
# Max difference (result2): 4.76837158203125e-07
```

## Notes

we use `torch.ops.load_library` to load the custom library. This is defined in `__init__.py` of the `custom_ops` and `other_custom_ops` directories.

> [!IMPORTANT]
> torch does not handle naming collisions at the `TORCH_LIBRARY(other_custom_ops, m)` level. Attempting to load two libraries with the same name will result in a runtime error. 

Please see the commented code in [other_custom_ops/extensions.cpp](other_custom_ops/extensions.cpp) to see how to avoid/reproduce this error.

For example if you use the same `TORCH_LIBRARY` name in both `custom_matmul` and `other_custom_matmul` you will get the following error:

```bash
uv run demo.py
# libc++abi: terminating due to uncaught exception of type c10::Error: Only a single TORCH_LIBRARY can be used to register the namespace custom_ops; please put all of your definitions in a single TORCH_LIBRARY block.  If you were trying to specify implementations, consider using TORCH_LIBRARY_IMPL (which can be duplicated).  If you really intended to define operators for a single namespace in a distributed way, you can use TORCH_LIBRARY_FRAGMENT to explicitly indicate this.  Previous registration of TORCH_LIBRARY was registered at custom_matmul/extension.cpp:36; latest registration was registered at other_custom_matmul/extension.cpp:49
# Exception raised from registerLibrary at /Users/runner/work/pytorch/pytorch/pytorch/aten/src/ATen/core/dispatch/Dispatcher.cpp:206 (most recent call first):
# frame #0: c10::Error::Error(c10::SourceLocation, std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char>>) + 52 (0x102f22cbc in libc10.dylib)
```

lastly, theres a `make debug` command that can be helpful for debugging the paths and build settings.

```bash
make debug
# Python paths:
#   PYTHON_ROOT: .venv
#   PYTHON_INCLUDE: versions/3.11.1/include/python3.11
# PyTorch paths:
#   TORCH_PATH: .venv/lib/python3.11/site-packages/torch
#   TORCH_INCLUDE: .venv/lib/python3.11/site-packages/torch/include
#   TORCH_LIB: .venv/lib/python3.11/site-packages/torch/lib
# Build settings:
#   MODULES: custom_matmul other_custom_matmul
#   TARGETS: custom_matmul/_C.cpython-311-darwin.so other_custom_matmul/_C.cpython-311-darwin.so
#   EXTENSION_SUFFIX: .cpython-311-darwin.so
```
