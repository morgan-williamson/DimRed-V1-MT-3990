%%      Preprocessing for Semedo DR regression
% 
% inputs: 
%         - SDFs.mat file containing rolling window (1ms steps, 50ms window) sums of spike counts for neurons identified by Liz and Kilosort. 
%           In neurons x trials x timepoints format.
%
%         - exclusions.mat differentiates  neurons that do /don't react to
%         visual input. (CURRENTLY USING ANYVISUAL - LIZ?)
% outputs:
% for each stimulus orientation of a chosen animal / penetration / stimulus
% type:
%         - V1_concat, a p x N matrix containing concatenated N datapoints
%         of p neurons. N = 10 timepoints (listed in downsample) from the
%         stimulus phase x 300 trials. 
%         - MT_concat, a k x N matrix with k neurons
%         - params contains the details of the dataset. What animal,
%         penetration, stimulus orientation and type. downsample is
%         included too.
%         - savepath is passed so example_adapted.m can be run immediately
%         after to run regression & dimensionality reduction code from Semedo
%         et al. 2019.
%

% NOTE:   run from /DimRed-V1-MT-3990 to get save pathing right

clear all;



%% params

params.animal = 'CJ191';        % pick your pokemon  {'CJ177','CJ179','CJ191'}
params.pen = '002';             % penetration number e.g. 007/008 for CJ177
params.StimType = 'Square';     % stimulus type {'Square', 'SineWave, 'PSSquare'?, 'Dots'}
params.downsample = 80:50:530;  % these are the timepoints at which I've decided to downsample, expecting it to be 50ms bins centred every 50ms from +80 to +530 ms post stimulus

for subtract_PTSH = 0:1  % tracks whether I'm subtracting the peristimulus time histogram from each timeseries per trial per neuron (default yes, but I want to try run the code on evoked data? then again it's no longer stationary)
    for o = 1:12 % tracks direction / orientation of the stimulus (1-12 as in SDFs.mat)

        params.ori = o; 
        
        if subtract_PTSH == 1
            params.residuals = ''; %changes the save name of the file depending on whether I'm preprocess / subtracting PTSH or not.
        else 
            params.residuals = 'non';
        end 
        
        datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp.mat'];

        datapoints_per_trial = size(params.downsample,2); %1000; down to 10 according to current definition of downsample

        load(['data/' params.animal '/' params.pen '/SDFs.mat']);
        load(['data/' params.animal '/' params.pen '/exclusions.mat']);
        V1_data = all_sdfs.(params.StimType){1,params.ori}(logical(OK.anyVisual{1,1}),:,params.downsample); % pulling the relevant spike counts from the SDFs file
        MT_data = all_sdfs.(params.StimType){2,params.ori}(logical(OK.anyVisual{1,2}),:,params.downsample); % these arrays should be N neurons x 300 trials x 10 bins
        clear('all_sdfs','OK');

        %% preprocess


        V1_data = V1_data / 0.05; % conversion to firing rate for 50ms bins (doesn't change anything right? just scaling)
        MT_data = MT_data / 0.05;

        if subtract_PTSH == 1
            V1_data = V1_data - mean(V1_data, [2]); % converting to residuals: subtracting the PTSH (V1_data is neurons x trials x time, so e.g. 54 x 300 x 10)
            MT_data = MT_data - mean(MT_data, [2]);
        end 

        % this was an old method of PTSH subtraction, problematic as it
        % recalculated the PTSH after each subtraction 

        % for trials = 1:300
        %     
        %     for i = 1:size(V1_data, 1) % # i tracks neurons, we substract the trial-average PTSH from the timecourse of each trial, per neuron
        %         V1_data(i,trials,:) = V1_data(i,trials,:) - mean(V1_data(i,:,:),[2]);
        %     end 
        % 
        %     for i = 1:size(MT_data, 1) % same for MT
        %         MT_data(i,trials,:) = MT_data(i,trials,:) - mean(MT_data(i,:,:),[2]);
        %     end 
        %     
        % end 
        %%

        V1_concat = zeros(size(V1_data,1), size(V1_data,2)*size(V1_data,3)); % this concatentates the datapoints of the trials into a single timecourse
        MT_concat = zeros(size(MT_data,1), size(MT_data,2)*size(MT_data,3)); % K neurons x N (= 10 bins x 300 trials) datapoints

        for trials = 1:300
            V1_concat(:,((datapoints_per_trial)*(trials-1)+1):(datapoints_per_trial)*trials) = squeeze(V1_data(:,trials,:));
            MT_concat(:,((datapoints_per_trial)*(trials-1)+1):(datapoints_per_trial)*trials) = squeeze(MT_data(:,trials,:));
        end

        % isequal(reshape(V1_data, size(V1_data,1),size(V1_data,2)*size(V1_data,3)), V1_concat)

        % V1_data = reshape(V1_data, size(V1_data,1),size(V1_data,2)*size(V1_data,3));
        % MT_data = reshape(MT_data, size(MT_data,1),size(MT_data,2)*size(MT_data,3));

        save(datapath,'V1_concat', 'MT_concat','params');
        clear('V1_concat', 'MT_concat','V1_data','MT_data');
    end
end 

clearvars -except 'datapath';