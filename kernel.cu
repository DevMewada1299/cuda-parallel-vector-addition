#include <stdio.h>
#include <cuda_runtime.h>

__global__ void VecAdd(const float* A, const float* B, float* C, int N) {
    for (int i = blockIdx.x * blockDim.x + threadIdx.x;
         i < N;
         i += blockDim.x * gridDim.x) {
        C[i] = A[i] + B[i];
         }
}
