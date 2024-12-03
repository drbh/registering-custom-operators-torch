import torch
import os
from importlib import machinery

cur_dir = os.path.dirname(__file__)
kern_path = "_C" + machinery.EXTENSION_SUFFIXES[0]

torch.ops.load_library(
    os.path.join(
        cur_dir,
        kern_path,
    )
)
