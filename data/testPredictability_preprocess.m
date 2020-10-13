clear all 


params.StimType = 'Square';     % stimulus type {'Square', 'SineWave, 'PSSquare'?, 'Dots'}
params.downsample = 80:50:530;  % these are the timepoints at which I've decided to downsample, expecting it to be 50ms bins centred every 50ms from +80 to +530 ms post stimulus

for subtract_PTSH = 1:1

    for ani =  {'CJ177','CJ179','CJ190','CJ191'} % tracks which animal 

        params.animal = ani{1};

        if subtract_PTSH == 1         % tracks whether to use residuals (i.e. subtract a peri-stimulus time histogram) or unprocessed data
            params.residuals = '';   
        else 
            params.residuals = 'non';
        end 
        
        if strcmp(ani{1}, 'CJ177')
            pens = {'008'}; %{'007','008'};
        elseif strcmp(ani{1}, 'CJ179')
            pens = {'012','013','016'};
        elseif strcmp(ani{1},'CJ190')
            pens = {'001','003'};
        elseif strcmp(ani{1},'CJ191')
            pens = {'002'};
        end

        for p = pens
            params.pen = p{1};
            
            load(['data' filesep params.animal filesep params.pen filesep 'regressV1MT.mat']);
            
            % VAF_shuffle is a structure containing the VAFs measured for a number of
            % shuffle versions of the recorded data (MT trials are in random order, so
            % should be unpredictable from V1).

            % VAFs is a matrix of the VAF measured for the unshuffled data. 
            [nDir, nNeu] = size(VAF_shuffle);
            CI_upper = zeros(nDir, nNeu); 

            percentileCut = 95; % what percentile of the null distribution should we call "significant"?

            % calculate the confidence intervals for the specified percentile from
            % each of the shuffles.
            pFun = @(x) prctile(x, percentileCut);
            for iDir = 1:nDir
                for iCh = 1:nNeu
                    CI = bootci(1000, {pFun, VAF_shuffle{iDir, iCh}});
                    CI_upper(iDir, iCh) = CI(2); %to be conservative, use the upper bound on the confidence interval.
                end
            end

            canPredict = VAFs > CI_upper; % logical matrix, 1 means we can likely predict that neuron better than chance.
            clear('pFun','nNeu','nDir','iCh','CI_upper','CI', 'VAFs', 'VAF_shuffle','iDir','percentileCut');

            for o = 1:12 % loops through the 12 different directions of stimulus presentation 
                params.ori = o 

                % tracks direction / orientation of the stimulus (1-12 as in SDFs.mat)


                datapath = ['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'Predict_pp.mat'];


                load(['data/' params.animal '/' params.pen '/SDFs.mat']);
                load(['data/' params.animal '/' params.pen '/exclusions.mat']);
                V1_data = all_sdfs.(params.StimType){1,params.ori}(logical(OK.anyVisual{1,1}),:,params.downsample); % pulling the relevant spike counts from the SDFs file
                MT_data = all_sdfs.(params.StimType){2,params.ori}(logical(OK.anyVisual{1,2}),:,params.downsample); % these arrays should be N neurons x 300 trials x 10 bins
                MT_data = MT_data(canPredict(params.ori,:),:,:);                                                                                  % only including predictable MT neurons in the target MT population
                clear('all_sdfs','OK','param');

                %% preprocess

                V1_data = V1_data / 0.05; % conversion to firing rate for 50ms bins (doesn't change anything right? just scaling)
                MT_data = MT_data / 0.05;

                if subtract_PTSH == 1
                    V1_data = V1_data - mean(V1_data, [2]); % converting to residuals: subtracting the PTSH (V1_data is neurons x trials x time, so e.g. 54 x 300 x 10)
                    MT_data = MT_data - mean(MT_data, [2]);
                end 

                V1_concat = zeros(size(V1_data,1), size(V1_data,2)*size(V1_data,3)); % this concatentates the datapoints of the trials into a single timecourse
                MT_concat = zeros(size(MT_data,1), size(MT_data,2)*size(MT_data,3)); % K neurons x N (= 10 bins x 300 trials) datapoints
                
                datapoints_per_trial = size(params.downsample,2); %1000; down to 10 according to current definition of downsample

                for trials = 1:300
                    V1_concat(:,((datapoints_per_trial)*(trials-1)+1):(datapoints_per_trial)*trials) = squeeze(V1_data(:,trials,:));
                    MT_concat(:,((datapoints_per_trial)*(trials-1)+1):(datapoints_per_trial)*trials) = squeeze(MT_data(:,trials,:));
                end

                save(datapath,'V1_concat', 'MT_concat','params','canPredict');
                clear('V1_concat', 'MT_concat','V1_data','MT_data','datapoints_per_trial','trials');
            end
        end 
    end
end

clearvars -except 'datapath';