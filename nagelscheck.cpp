/*==========================================================
 * nagelscheck.c - example in MATLAB External Interfaces
 *
 * Multiplies an input scalar (multiplier) 
 * times a 1xN matrix (inMatrix)
 * and outputs a 1xN matrix (outMatrix)
 *
 * The calling syntax is:
 *
 *		outMatrix = nagelscheck(multiplier, inMatrix)
 *
 * This is a MEX-file for MATLAB.
 * Copyright 2007-2012 The MathWorks, Inc.
 *
 *========================================================*/

#include "mex.h"
#include <iostream>

int *road_next;
int *velocities_next;
int iter = 0;
double accum = 0;
double carsOnRoad = 0; // # cars ever on the road
int updateVelocities(int *road, int *velocities, double *params, double *out, mwSize n, mwSize n2) {
    int road_length = (int)(params[0] + 0.5);
    int vmax = (int)(params[1] + 0.5);
    double p = params[2];
    for (int j=0; j < road_length; j++) {
       if (road[j] == 1) {
           int distance = 0;
           bool bf = false;
           for (int k=1; k <= vmax; k++) {
               distance = k;
               int index = j + k;
              
               if (j+k < road_length) {
                   index = j+k;
               }
               else {
                   index = j+k-road_length;
               }
               
               if (road[index] == 1)
                   bf = 1;
               
               if (bf)
                   break;
           }
           if (velocities[j] < vmax)
               velocities[j] = velocities[j] + 1;
           if ((velocities[j] > distance - 1) && bf)
               velocities[j] = distance - 1;
           double x = ((double)rand()) / ((double)(RAND_MAX));
           if (x < p && velocities[j] > 0) {
               velocities[j] = velocities[j] - 1;
           }
           accum += velocities[j];
           carsOnRoad++;
       }
    }
    return 0;
}

int count = 0;
int safecount = 0;
void updatePositions(int *road, int *velocities, double *params, int *pops, int *sources, int *times, double *out, mwSize n, mwSize n2) {
    int road_length = (int)(params[0] + 0.5);
    int vmax = (int)(params[1] + 0.5);
    int safe = (int)(params[4] + 0.5);
    double p = params[2];
    for (int i=0; i < n2; i++) {
        if (iter >= times[i] && pops[i] && road[sources[i]] == 0) {
            road[sources[i]] = 1;
            pops[i] = pops[i] - 1;
        }
    }
    for (int j=0; j < road_length; j++) {
        if (road[j] == 1) {
            int index = j+velocities[j];
            if (j+velocities[j] < road_length) {
                index = j+velocities[j];
                road_next[index] = 1;
                velocities_next[index] = velocities[j];
                if (j < safe && index >= safe) {
                    safecount++;
                }
            }
            else {
                if (j < safe)
                    safecount++;
                
                count = count + 1;
                index = j+velocities[j] - road_length;
            }
        }
    }
    
    for (int i = 0; i < n; i++) {
        road[i] = road_next[i];
        road_next[i] = 0;
        velocities[i] = velocities_next[i];
        velocities_next[i] = 0;
    }
}

/* The computational routine */
void nagelscheck(double *r, double *v, double *params, double *p, double *s, double *t, double *out, mwSize n, mwSize n2) {
    int totalCars = 0;
    safecount = 0;
    count = 0;
    accum = 0;
    carsOnRoad = 0;
    int *road = new int[n];
    int *velocities = new int[n];
    int *populations = new int[n2];
    int *sources = new int[n2];
    int *times = new int[n2];
    road_next = new int[n]();
    velocities_next = new int[n]();
    int simulation_steps = (int)(params[3] + 0.5);
    int safe = (int)(params[4] + 0.5);
    for (int i = 0; i < n; i++) {
        road[i] = (int)(r[i] + 0.5);
        if (road[i]) {
            totalCars++;
            if (i >= safe)
                safecount++;
        }
        velocities[i] = (int)(v[i] + 0.5);
    }
    for (int i = 0; i < n2; i++) {
        populations[i] = (int)(p[i] + 0.5);
        sources[i] = (int)(s[i] + 0.5);
        times[i] = (int)(t[i] + 0.5);
        if (sources[i] < safe){
            totalCars += populations[i];
        }
    }
    
    std::cout << "unsafe " << totalCars - safecount << std::endl;

    for (iter = 0; iter < simulation_steps; iter++) {
        int res = updateVelocities(road,velocities,params,out,n,n2);
        updatePositions(road,velocities,params,populations,sources,times,out,n,n2);
        if (safecount >= totalCars) {
            std::cout << "Finished in " << iter << " steps." << std::endl;
            std::cout << "Avg velocity " << accum/(double)(carsOnRoad) << std::endl;
            return;
        }
    }
    std::cout << "Avg velocity " << accum/(double)(carsOnRoad) << std::endl;
    std::cout << "Safe cars " << safecount << std::endl;
    std::cout << "Done cars " << count << std::endl;
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double multiplier;              /* input scalar */
    double *inRoad;               /* 1xN input matrix */
    double *inVel;               /* 1xN input matrix */
    double *inParams;               /* 1xN input matrix */
    double *inPop;               /* 1xN input matrix */
    double *inSource;
    double *inTime;
    size_t ncols1;                   /* size of matrix */
    size_t ncols2;                   /* size of matrix */
    size_t ncols3, ncols4, ncols5, ncols6;                   /* size of matrix */
    double *outMatrix;              /* output matrix */

    /* check for proper number of arguments */
    if(nrhs!=6) {
        mexErrMsgIdAndTxt("MyToolbox:nagelscheck:nrhs","5 inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:nagelscheck:nlhs","One output required.");
    }
    /* make sure the first input argument is scalar */
    if( !mxIsDouble(prhs[0])) {
        mexErrMsgIdAndTxt("MyToolbox:nagelscheck:notScalar","Input multiplier must be a vec.");
    }
    
    /* make sure the second input argument is type int */
    if( !mxIsDouble(prhs[1])) {
        mexErrMsgIdAndTxt("MyToolbox:nagelscheck:notDouble","Input matrix must be type double.");
    }
    
    /* make sure the second input argument is type double */
    if( !mxIsDouble(prhs[2]) || 
         mxIsComplex(prhs[2])) {
        mexErrMsgIdAndTxt("MyToolbox:nagelscheck:notDouble","Input matrix must be type double.");
    }
    
    /* check that number of rows in second input argument is 1 */
    if(mxGetM(prhs[1])!=1) {
        mexErrMsgIdAndTxt("MyToolbox:nagelscheck:notRowVector","Input must be a row vector.");
    }
    
    /* check that number of rows in third input argument is 1 */
    if(mxGetM(prhs[2])!=1) {
        mexErrMsgIdAndTxt("MyToolbox:nagelscheck:notRowVector","Input must be a row vector.");
    }
        
    /* create a pointer to the real data in the input matrix  */
    inRoad = mxGetPr(prhs[0]);

    /* get dimensions of the road matrix */
    ncols1 = mxGetN(prhs[0]);

    /* create a pointer to the real data in the input matrix  */
    inVel = mxGetPr(prhs[1]);

    /* get dimensions of the velocity matrix */
    ncols2 = mxGetN(prhs[1]);

    inParams = mxGetPr(prhs[2]);
    ncols3 = mxGetN(prhs[2]);
    
    inPop = mxGetPr(prhs[3]);
    ncols4 = mxGetN(prhs[3]);
    
    inSource = mxGetPr(prhs[4]);
    ncols5 = mxGetN(prhs[4]);
    
    inTime = mxGetPr(prhs[5]);
    ncols6 = mxGetN(prhs[5]);
        
    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)ncols1,mxREAL);

    /* get a pointer to the real data in the output matrix */
    outMatrix = mxGetPr(plhs[0]);
    
    /* call the computational routine */
    nagelscheck(inRoad,inVel,inParams,inPop,inSource,inTime,outMatrix,(mwSize)ncols1,(mwSize)ncols4);
}
