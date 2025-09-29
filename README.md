

1. **Keeping the number of blocks fixed, how does changing the number of threads per block affect the performance?**

The Plot Showing Number of blocks as fixed and changing the threads per block.

![][image1] : /Users/devmewada/Desktop/CMPE_214/CMPE_214_LAB_2/Screenshot 2025-09-28 at 3.16.07 PM.png 
The x-axis shows the threads vs time in the y-axis, Keeping the block size same we can already see that block sizes which are larger generally yield a good performance initially then plateaus out as we keep on increasing the threads, However at the end spectrum we need to look carefully, converting the x and y axes to a logarithmic scale will help us in investigating by giving us a clear idea.

LOGARITHMIC GRAPH : 

![][image2] : /Users/devmewada/Desktop/CMPE_214/CMPE_214_LAB_2/Screenshot 2025-09-28 at 3.20.21 PM.png

This provides a much better look the performance for the end spectrum, here we can see for larger blocks with more threads (1024) the performance actually decreases and blocks with sizes (16,64,32,256) with more threads (1024) give an optimal performance,  
For the use case of my gpu performance jumps as threads grow from tiny thread values to more warp aligned values, i.e. 32 threads. Extremely large thread values like 1024 often plateaus or dips in performance maybe due to shared memory or scheduling effects reduced concurrency.

2. **Keeping the number of threads per block fixed, how does changing the number of blocks affect the performance?**

The Plot Showing Number of Threads as fixed and changing the number of blocks.

![][image3] : /Users/devmewada/Desktop/CMPE_214/CMPE_214_LAB_2/Screenshot 2025-09-28 at 3.31.18 PM.png

We can observe here that as we increase the number of blocks the performance generally increases, The threads sizes (256-512) generally start the best the plateaus out as we increase the number of blocks, to look more closely at the performance we need to scale the graph into a logarithmic scale. 

LOGARITHMIC GRAPH : 

![][image4] : /Users/devmewada/Desktop/CMPE_214/CMPE_214_LAB_2/Screenshot 2025-09-28 at 3.37.28 PM.png

Here we can observe that the thread size 64 with block size 1024 is giving the best performance along with thread size 256 and 512 with the same block size as 1024\. The reason for the performance increase is generally because the scheduler has more independent blocks to distribute the work, i.e. if a block is already stalling the SM can run warps from another block. But we can see that the performance also plateaus after a certain amount of blocks, the reason for this is because each SM can hold a certain amount of blocks at once which is limited by Threads/SM, Warps/SM, Register/Shared memory the kernel can use. Once every SM fills to its per-SM max for the kernel, adding more blocks makes the queue longer resulting in a plateau.

3. **Keeping the total number of threads fixed, how does the number of blocks and the number of threads per block allocation affect the performance?**

Keeping the total number of threads fixed, the performance is the best when the threads are warp aligned and in the range 128-256-512. Keeping the warp efficiency and enough blocks to feed the SMs, keeping threads very small wastes lanes and keeping threads very large reduces blocks/SM and limit concurrency. 

**Conclusion :** 

On A100 GPU (108 SMs, warp size 32, 2048 threads/SM), the data suggests that the best performance is obtained by using warp aligned, mid-sized threads per block. Tiny thread size will under utilize the memory lanes and for very large threads (1024) it reduces the blocks per SM. Picking threadsPerBlock as a multiple of 32—starting with 256 —and launching blocks ≈ min(ceil(n/T), 4–8×SMs) to keep all SMs busy.
