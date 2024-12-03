import torch
import custom_matmul
import other_custom_matmul

print("Both custom matmul extensions loaded successfully")

# sample matrices
A = torch.randn(3, 4)
B = torch.randn(4, 5)

# run first custom op
result1 = torch.ops.custom_ops.matmul(A, B)

# check if "other_custom_ops" is an attribute of "custom_ops"
if hasattr(torch.ops.custom_ops, "other_custom_ops"):
    # if we namespaced it differently, use that
    result2 = torch.ops.custom_ops.other_custom_ops.matmul(A, B)
else:
    # otherwise try running the second custom op in the same namespace
    result2 = torch.ops.custom_ops.matmul(A, B)


print("Result 1 shape:", result1.shape)
print("Result 2 shape:", result2.shape)

# verify against PyTorch's matmul
torch_result = torch.matmul(A, B)
print("Max difference (result1):", (result1 - torch_result).abs().max().item())
print("Max difference (result2):", (result2 - torch_result).abs().max().item())
