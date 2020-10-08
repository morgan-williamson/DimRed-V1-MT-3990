%% Shuffler 


clear all 

addpath regress_methods
addpath regress_util
addpath fa_util
params.StimType = 'Square';
params.downsample = 80:50:530;
params.shuffled = 2;

if params.shuffled == 1
    shuffled = '_SHUFFLED';
elseif params.shuffled == 2
    shuffled = '_SUPERSHUFFLED';
end 

for subtract_PTSH = 0:1

    for ani = {'CJ177','CJ179','CJ191'} % tracks which animal 

        params.animal = ani{1};

        if subtract_PTSH == 1         % tracks whether to use residuals (i.e. subtract a peri-stimulus time histogram) or unprocessed data
            params.residuals = '';   
        else 
            params.residuals = 'non';
        end 

        if strcmp(ani{1}, 'CJ177')    % assigns the appropriate list of penetrations to loop through for a given animal 
            pens = {'007','008'};
        elseif strcmp(ani{1}, 'CJ179')
            pens = {'012'};
        else
            pens = {'002'};
        end

        for p = pens
            params.pen = p{1};



            for o = 1:12 % loops through the 12 different directions of stimulus presentation 
                params.ori = o 
                
                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp' shuffled '.mat'];
                
                datapoints_per_trial = size(params.downsample,2); %1000; down to 10 according to current definition of downsample

                load(['data/' params.animal '/' params.pen '/SDFs.mat']);
                load(['data/' params.animal '/' params.pen '/exclusions.mat']);
                V1_data = all_sdfs.(params.StimType){1,params.ori}(logical(OK.anyVisual{1,1}),:,params.downsample); % pulling the relevant spike counts from the SDFs file
                MT_data = all_sdfs.(params.StimType){2,params.ori}(logical(OK.anyVisual{1,2}),:,params.downsample); % these arrays should be N neurons x 300 trials x 10 bins
                clear('all_sdfs','OK');
                
                V1_data = V1_data / 0.05; % conversion to firing rate for 50ms bins (doesn't change anything right? just scaling)
                MT_data = MT_data / 0.05;

                if subtract_PTSH == 1
                    V1_data = V1_data - mean(V1_data, [2]); % converting to residuals: subtracting the PTSH (V1_data is neurons x trials x time, so e.g. 54 x 300 x 10)
                    MT_data = MT_data - mean(MT_data, [2]);
                end 
                
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
                
                
           