# communication-subspace-Williamson-3990
Code adapted from  "Cortical areas interact through a communication subspace", Semedo et al. (Neuron, 2019)
My code is the following:

- /data folder includes raw data, preprocessing code, and preprocessed data 
- /figures folder
- /RRR_vs_RidgeR.m
- /example_adapted.m
- /subpop_creation.m  generates FR-distribution matched subpopulations (x25) of my data, to feed into RRR_v_Ridge_subsampled.m
- /RRR_v_Ridge_subsampled.m , main script performing (Ridge and/or Reduced Rank) regression (cv 10-fold) on matched subpopulations of V1/MT 

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

2) run preprocess_ani_pen_ori_stim.m to generate preprocessed data, or take it as already generated ({animal code}_ {penetration number}_ ori_ {stimulus orientation number as in SDFs file}_ {stimulus type as in SDFs file}_ pp.mat)

3) run subpop_creation.m to generate distribution matched subpopulations for subsequent analysis

4) Run RRR_v_Ridge_subsampled.m for regression analysis / figure generation (will take a while) 
