%% Preprocessing Shuffler for Semedo DimRed Regression
% Author:                   Morgan Williamson
% Date last edited:         16/12/20
% 
% This is the second script in the preprocessing pipeline: we create 
% concatenated, subsampled data matrices as in preprocess_ani_pen_ori_stim.m
% and then generate null datasets by shuffling the data in two ways. First,
% we shuffled the data across trials while preserving temporal identity
% (e.g. for a given neuron, all the first bins are shuffled; all the second bins are shuffled,
% etc.) - the goal is to break immediate causal connections within a trial.
% Second, we shuffle everything for a given neuron, to even break the
% general Stim-evoked potential trial timecourse. 

% The next script in the pipeline is subpop_creation.m or subpop_homog.m to generate subpopulations on these datasets and the original unshuffled.

clear all;
bin_size = 50; % in ms
params.downsample = 80:bin_size:530;
datapoints_per_trial = size(params.downsample,2); %1000; down to 10 according to current definition of downsample

for sh = 1:2 % tracks the shuffled condition
    params.shuffled = sh;

    if params.shuffled == 1 % this is shuffled accross trials, preserving temporal order of bins (and thus the average timecourse)
        shuffled = '_SHUFFLED';
    elseif params.shuffled == 2 % this is shuffled accross trials and timepoints
        shuffled = '_SUPERSHUFFLED';
    end

    for stim = {'Square','SineWave','PSsquare'} % tracks which stimulus is presented 
        params.StimType = stim{1};

        for subtract_PTSH = 0:1 % tracks whether we're shuffling residual data (1) or not (0)

            for ani =  {'CJ177','CJ179','CJ190','CJ191'} % tracks which animal

                params.animal = ani{1};

                if subtract_PTSH == 1
                    params.residuals = '';
                else 
                    params.residuals = 'non';
                end 

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

                    for o = 1:12 % loops through the 12 different directions of stimulus presentation 
                        params.ori = o % this is printed for the purposes of tracking script progress and errors

                        % define savepath given the above loops                       
                        datapath = ['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp' shuffled '.mat'];
                      
                        % load in data 
                        load(['data/' params.animal '/' params.pen '/SDFs.mat']);
                        load(['data/' params.animal '/' params.pen '/exclusions.mat']);
                        V1_data = all_sdfs.(params.StimType){1,params.ori}(logical(OK.anyVisual{1,1}),:,params.downsample); % pulling the relevant spike counts from the SDFs file
                        MT_data = all_sdfs.(params.StimType){2,params.ori}(logical(OK.anyVisual{1,2}),:,params.downsample); % these arrays should be N neurons x 300 trials x 10 bins
                        clear('all_sdfs','OK');

                        % convert to firing rate for 50ms bins
                        V1_data = V1_data * 1000 / bin_size; 
                        MT_data = MT_data * 1000 / bin_size;

                        % convert to residuals: subtract the PTSH         
                        if subtract_PTSH == 1
                            V1_data = V1_data - mean(V1_data, [2]); % (V1_data is neurons x trials x time, so e.g. 54 x 300 x 10)
                            MT_data = MT_data - mean(MT_data, [2]);
                        end 

                        % begin shuffling data
                        if params.shuffled == 1
                            for N = 1: size(V1_data,1)
                                for time = 1:size(V1_data,3)
                                    V1_data(N,:,time) = V1_data(N,randperm(size(V1_data,2)),time);  % trial-shuffling data. Fix neuron and time point, shuffle across trials.  
                                end
                            end

                            for N = 1: size(MT_data,1)
                                for time = 1:size(MT_data,3)
                                    MT_data(N,:,time) = MT_data(N,randperm(size(MT_data,2)),time);   % neurons x trials x time points 
                                end
                            end
                        elseif params.shuffled == 2
                            for N = 1: size(V1_data,1)                                                % Fix Neuron
                                for trial = 1:size(V1_data,2)
                                    V1_data(N,trial,:) = V1_data(N,trial,randperm(size(V1_data,3)));  % shuffle bins for each trial  
                                end
                                for time = 1:size(V1_data,3)
                                    V1_data(N,:,time) = V1_data(N,randperm(size(V1_data,2)),time);    % shuffle trials for each bin 
                                end 
                            end
                            for N = 1: size(MT_data,1)                                                % Fix Neuron
                                for trial = 1:size(MT_data,2)
                                    MT_data(N,trial,:) = MT_data(N,trial,randperm(size(MT_data,3)));  % shuffle bins for each trial  
                                end
                                for time = 1:size(MT_data,3)
                                    MT_data(N,:,time) = MT_data(N,randperm(size(MT_data,2)),time);    % shuffle trials for each bin 
                                end 
                            end
                        end 
                        
                        % concatenate data for regression purposes
                        for trials = 1:300
                            V1_concat(:,((datapoints_per_trial)*(trials-1)+1):(datapoints_per_trial)*trials) = squeeze(V1_data(:,trials,:));
                            MT_concat(:,((datapoints_per_trial)*(trials-1)+1):(datapoints_per_trial)*trials) = squeeze(MT_data(:,trials,:));
                        end

                        save(datapath,'V1_concat', 'MT_concat','params');
                        clear('V1_concat', 'MT_concat','V1_data','MT_data');
                    end 
                end 
            end
        end 
    end
end
                
                
           