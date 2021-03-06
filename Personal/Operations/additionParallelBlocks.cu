#include <stdio.h>
#define N 512


void random_ints(int* a, int n)
{
   int i;
   for (i = 0; i < n; ++i) {
       a[i] = rand() %5000;
   }
}

// each parallel invocation of add() is referred to as a block : the set of blocks is referred to as a grid
__global__ void add(int *a, int *b, int *c)
{
    // each block handles a different element of the array
    // on the device, each block can execute in parallel
    // use blockIdx.x to access block index
    c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x];
}

int main(void)
{
    // host copies of a, b, c
    int *a, *b, *c; 
    // device copies of a, b, c
    int *d_a, *d_b, *d_c; 
    int size = N * sizeof(int);

    // we need to allocate memory on the GPU
    // allocate space for device copies of a, b, c
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    // allocate space for host copies of a, b, c and setup input values
    a = (int *)malloc(size); 
    random_ints(a, N);
    b = (int *)malloc(size); 
    random_ints(b, N);
    c = (int *)malloc(size);

    // copy inputs to device
    cudaMemcpy(d_a, &a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, &b, size, cudaMemcpyHostToDevice);

    // launch add() kernel on the GPU with N blocks
    add<<<N,1>>>(d_a, d_b, d_c);

    // copy result back to host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

    // don't forget to free the memory
    free(a);
    free(b);
    free(c);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // check error 
    printf("CUDA error: %s\n", cudaGetErrorString(cudaGetLastError()));

    return 0;
}