%% Homogeneous Subpopulation creation for Semedo DimRed Regression
% Author:                   Morgan Williamson
% Date last edited:         21/12/20
% 
% This is the final script in the preprocessing pipeline: we take
% preprocessed, binned FR-timeseries from preprocess.m files, then define 
% "source" and "target" populations of V1 & MT data such that V1/MT target populations
% are matched by FR-distribution. In a previous version of this script
% (subpop_creation.m) these subpopulations were defined independently per
% stimulus condition (e.g. Square Orientation 1 vs SineWave Ori 4).
% In this script we define the same populations across stimuli per
% penetration. This allows comparison of the subspaces defined on these
% populations in subsequent DR analysis! 

% The next scripts in the pipeline are preprocess_shuffler.m to generate
% trial-shuffled data from these concat datasets, and then
% subpop_creation.m to generate subpopulations on these datasets.

%% Inputs: 
%         - V1_concat and MT_concat matrices from preprocess.m files 
%           In neurons x timepoints format.
%
%         - this is for each animal, penetration, stimulus 

%% Outputs:
% the same datafiles but with the addition of defined source/target
% populations in params struct
%         - params.target_population_index is an array of logical indices that pick out the 25 repeats of subpopulations defined on the original neurons 
%         - params.target_population_choices is an array of the numbering
%         of neurons chosen in the above 
%         - params.target_population_size is a count of the number of
%         neurons in the target populations after this FR-distribution
%         matching procedure (e.g. how large is the common distribution of
%         neurons by mean FR)
%
% NOTE:   run from /DimRed-V1-MT-3990 to get save pathing right

clear all;

repeats = 25;               % # of times I resample the source/target subpopulations based on FR-distribution matching
edges = 0:3:60;

for sh = 0:2
    params.shuffled = sh;

    if params.shuffled == 1
        shuffled = '_SHUFFLED';
    elseif params.shuffled == 2
        shuffled = '_SUPERSHUFFLED';
    else 
        shuffled = '';
    end 
    for ani = {'CJ177','CJ179','CJ190','CJ191'} % tracks which animal 
        params.animal = ani{1};

        if strcmp(ani{1}, 'CJ177') % defines the available MT penetrations to loop through given the animal
            pens = {'007','008'};
        elseif strcmp(ani{1}, 'CJ179')
            pens = {'012','013','016'};
        elseif strcmp(ani{1},'CJ190')
            pens = {'001','003'};
        elseif strcmp(ani{1},'CJ191')
            pens = {'002'};
        end
        for p = pens % loops through the different MT penetrations for each animal
            params.pen = p{1};
            
            % Now we collect all the spike counts for the populations
            % across all stimuli (stimulus type / orientation) 
            
            total_V1 = [];
            total_MT = [];
            
            for stim = {'Square','SineWave','PSsquare'}
                params.StimType = stim{1};
                for o = 1:12
                    params.ori = o 
                    params.residuals = 'non'; % we load in non-residual data as we match neurons by their FR-properties, not their PTSH-subtracted properties!

                    datapath = ['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp' shuffled '.mat'];
                    load(datapath)

                    total_V1 = [total_V1, V1_concat];
                    total_MT = [total_MT, MT_concat];
                    
                end 
            end 
            
            % with the total spike count series, we now use distribution
            % matching to randomly define 25 subpopulations of V1/MT to
            % define source/target populations for further analysis 
            
            params.target_population_choices = cell(2,repeats);

            for subsamp = 1:repeats % set to 25
                subpop = getRateMatchedSubpops({total_V1,total_MT},edges,size(total_MT,1));
                params.target_population_choices{1,subsamp} = subpop{1};
                params.target_population_choices{2,subsamp} = subpop{2};
            end 
            
            % given the choices of neurons are by neuronal number in the
            % matrices provided, we convert to logical indices for each
            % population, and describe the size of the target subpops
            params.target_pop_size = length(params.target_population_choices{1,1});
            params.target_pop_index = cell(2,repeats);

            for ss = 1:repeats
                index_V1 = zeros(size(V1_concat,1),1);
                index_MT = zeros(size(MT_concat,1),1);
                for k = 1:params.target_pop_size
                    index_V1(params.target_population_choices{1,ss}(k)) = 1;
                    index_MT(params.target_population_choices{2,ss}(k)) = 1;
                end 
                params.target_pop_index{1,ss} = index_V1;
                params.target_pop_index{2,ss} = index_MT;
            end
            
            % these parameters are to be applied uniformly accross
            % datasets, so we keep them here
            
            s1 = params.target_pop_size;
            s2 = params.target_population_choices;
            s3 = params.target_pop_index;

            % now to go back through the datasets and add the subpop params
            for stim = {'Square','SineWave','PSsquare'}
                params.StimType = stim{1};
                for o = 1:12
                    params.ori = o 
                    
                    % for non-residual data
                    params.residuals = 'non';
                    datapath = ['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp' shuffled '.mat'];
                    load(datapath)
                    params.target_pop_size = s1;
                    params.target_population_choices= s2;
                    params.target_pop_index = s3;
                    save(datapath,'V1_concat', 'MT_concat','params');
                    
                    % now for residual data
                    params.residuals = '';
                    datapath = ['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp' shuffled '.mat'];
                    load(datapath)
                    params.target_pop_size = s1;
                    params.target_population_choices= s2;
                    params.target_pop_index = s3;
                    save(datapath,'V1_concat', 'MT_concat','params');
                end
            end 
        end        
    end
end
     
