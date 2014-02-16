/* Copyright 2012.  Los Alamos National Security, LLC. This material was produced
 * under U.S. Government contract DE-AC52-06NA25396 for Los Alamos National 
 * Laboratory (LANL), which is operated by Los Alamos National Security, LLC
 * for the U.S. Department of Energy. The U.S. Government has rights to use,
 * reproduce, and distribute this software.  NEITHER THE GOVERNMENT NOR LOS
 * ALAMOS NATIONAL SECURITY, LLC MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR
 * ASSUMES ANY LIABILITY FOR THE USE OF THIS SOFTWARE.  If software is modified
 * to produce derivative works, such modified software should be clearly marked,
 * so as not to confuse it with the version available from LANL.   
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at 
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.”
 *
 * Under this license, it is required to include a reference to this work. We
 * request that each derivative work contain a reference to LANL Copyright 
 * Disclosure C13002/LA-CC-12-022 so that this work’s impact can be roughly
 * measured. In addition, it is requested that a modifier is included as in
 * the following example:
 *
 * //<Uses | improves on | modified from> LANL Copyright Disclosure C13002/LA-CC-12-022
 *
 * This is LANL Copyright Disclosure C13002/LA-CC-12-022
 */

/*
 *  Authors: Bob Robey       XCP-2   brobey@lanl.gov
 *           David Nicholaeff        dnic@lanl.gov, mtrxknight@aol.com
 *           Rachel Robey            rnrobey@gmail.com
 */

/* neigh_kern.cl */

#ifdef HAVE_CL_DOUBLE
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
typedef double  real;
#else
typedef float   real;
#endif

struct neighbor {
   uint left;
   uint right;
};

__kernel void init_kern(
        const uint size,
	__global int *temp) {

	const uint idx = get_global_id(0);

        if (idx >= size) return;

	temp[idx] = -1;
}

__kernel void hash_kern(
	const real min_val,
	const real min_diff,
        const uint length,
	__global const real *arr,
	__global int *temp) {
	
	const uint idx = get_global_id(0);
	
        if(idx >= length) return;

        temp[(uint)((arr[idx]-min_val)/min_diff)] = idx;
}

__kernel void get_neighbor_kern(
	const real min_val,
	const real min_diff,
        const uint length,
	__global const real *arr,
	__global const int *temp,
        const uint temp_size,
        __global struct neighbor *neighbor_buffer) {
	
	const uint idx = get_global_id(0);
	
        if(idx >= length) return;

        int idx_new = (int)((arr[idx]-min_val)/min_diff);

        int left = idx;
        int right = idx;

        for (int i = idx_new+1; i < temp_size; i++) {
           if (temp[i] != -1) {
              right = temp[i];
              break;
           }
        }

        for (int i = idx_new-1; i >= 0; i--) {
           if (temp[i] != -1) {
              left = temp[i];
              break;
           }
        }

        neighbor_buffer[idx].left  = left;
        neighbor_buffer[idx].right = right;
}
