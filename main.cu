#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "kernel.cu"
#include <chrono>
#include <fstream>

int main (int argc, char *argv[]){

    float *A_h, *B_h, *C_h;
    float *A_d, *B_d, *C_d;
    unsigned VecSize;

    if (argc == 1) {
        VecSize = 256;
    } else if (argc == 2) {
      VecSize = atoi(argv[1]);
    } else {
        printf("Usage: ./vecAdd <Size>");
        exit(0);
    }

    A_h = (float*) malloc( sizeof(float) * VecSize );
    B_h = (float*) malloc( sizeof(float) * VecSize );
    C_h = (float*) malloc( sizeof(float) * VecSize );

      for (unsigned int i=0; i < VecSize; i++) {
      A_h[i] = i;
      B_h[i] = i;
    }

    cudaDeviceSynchronize();

    int size = VecSize * sizeof(float); float *d_A, *d_B, *d_C;
    cudaMalloc((void **) &d_A, size);
    cudaMalloc((void **) &d_B, size);
    cudaMalloc((void **) &d_C, size);
    cudaMemcpy(d_A, A_h, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B_h, size, cudaMemcpyHostToDevice);

    cudaDeviceSynchronize();

    // int threadsPerBlock = 256;
    int n = (int)VecSize;
    // int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;
    // VecAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n);

    // cudaMemcpy(C_h, d_C, size, cudaMemcpyDeviceToHost);


    // cudaDeviceSynchronize();

    // for (int i = 0; i < 8 && i < n; ++i) {
    //     printf("C[%d] = %f\n", i, C_h[i]);
    // }

    int threadsPerBlock[] = {1,2,4,8,16,32,64,128,256,512,1024};
    int Blocks[]      = {1,2,4,8,16,32,64,128,256,512,1024};
    int THREAD_SIZE = sizeof(threadsPerBlock)/sizeof(threadsPerBlock[0]);
    int BLOCK_SIZE  = sizeof(Blocks)/sizeof(Blocks[0]);




  cudaDeviceProp prop{};
  cudaGetDeviceProperties(&prop, 0);

  std::ofstream csv("timings.csv");
  csv << "blocks,threads,n,time_ms\n";

  for (int bi = 0; bi < BLOCK_SIZE; ++bi) {
      int B = Blocks[bi];


      for (int ti = 0; ti < THREAD_SIZE; ++ti) {
          int T = threadsPerBlock[ti];



          printf("B=%d, T=%d :\n", B, T);
          auto t0 = std::chrono::high_resolution_clock::now();
          VecAdd<<<B, T>>>(d_A, d_B, d_C, n);


          cudaError_t err = cudaGetLastError();
          if (err != cudaSuccess) {
              fprintf(stderr, "Launch failed (B=%d,T=%d): %s\n",
                      B, T, cudaGetErrorString(err));
              continue;
          }

          cudaDeviceSynchronize();
          auto t1 = std::chrono::high_resolution_clock::now();
          double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();

          cudaMemcpy(C_h, d_C, size, cudaMemcpyDeviceToHost);

          csv << B << ',' << T << ',' << n << ',' << ms << '\n';

          printf("B=%4d T=%4d | C[0]=%.1f C[1]=%.1f C[%d]=%.1f\n",
                B, T, C_h[0], C_h[1], n-1, C_h[n-1]);
      }
  }

  csv.close();



    free(A_h);
    free(B_h);
    free(C_h);

    //INSERT Memory CODE HERE
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}