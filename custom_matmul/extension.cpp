#include <torch/extension.h>

torch::Tensor matmul(const torch::Tensor &A, const torch::Tensor &B)
{
    TORCH_CHECK(A.dim() == 2 && B.dim() == 2, "Both tensors must be 2D");
    TORCH_CHECK(A.size(1) == B.size(0), "Inner dimensions must match");
    TORCH_CHECK(A.is_contiguous() && B.is_contiguous(), "Matrices must be contiguous");

    const int M = A.size(0);
    const int K = A.size(1);
    const int N = B.size(1);

    auto C = torch::zeros({M, N}, A.options());

    auto A_data = A.data_ptr<float>();
    auto B_data = B.data_ptr<float>();
    auto C_data = C.data_ptr<float>();

    for (int i = 0; i < M; i++)
    {
        for (int j = 0; j < N; j++)
        {
            float sum = 0.0f;
            for (int k = 0; k < K; k++)
            {
                sum += A_data[i * K + k] * B_data[k * N + j];
            }
            C_data[i * N + j] = sum;
        }
    }

    return C;
}

// Define the custom operator
TORCH_LIBRARY(custom_ops, m)
{
    m.def("matmul(Tensor A, Tensor B) -> Tensor");
}

// Register the CPU implementation
TORCH_LIBRARY_IMPL(custom_ops, CPU, m)
{
    m.impl("matmul", &matmul);
}