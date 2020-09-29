# communication-subspace
Code adapted from  "Cortical areas interact through a communication subspace", Semedo et al. (Neuron, 2019)
My code is the following:

- /data folder includes raw data, preprocessing code, and preprocessed data 
- /figures folder
- /RRR_vs_RidgeR.m
- /example_adapted.m

Semedo code is the following: 

- example_lamdaRRR.m
- LICENSE
- SET_CONSTS.m
- startup.m
- /fa_util folder of functions invoked in factor analysis of source population activity
- /regress_methods folder of functions for each of the available regression methods (Factor R, PC R, Reduced Rank R, Regress, Ridge Regress) 
- /regress_util folder of utility folders invoked in regression / cv routines 


v0.1

This code pack requires the use of MATLAB version 2012b or newer.

1) Change MATLAB workspace directory to root folder

1.5) if you have the data as pulled from M3, move the SDFs and exclusions files into the relevant folders in /data

2) run preprocess.m to generate preprocessed data, or take it as already generated ({animal code}_ {penetration number}_ ori_ {stimulus orientation number as in SDFs file}_ {stimulus type as in SDFs file}_ pp.mat)

3) Run RRR_vs_RidgeR.m or example_adapted.m 
