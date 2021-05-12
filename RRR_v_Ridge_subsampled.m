%%
clear all

addpath regress_methods
addpath regress_util
addpath fa_util
%load('data/sample_data.mat') % for Semedo et al. sample data
repeats = 25; % # of times I resample the source/target subpopulations based on FR-distribution matching

for stim = {'Square'}%,'SineWave','PSsquare'}
    params.StimType = stim{1};
    for j = 1:1 % tracks whether to use lambda-ridge regression (=2) in the reduced rank regression or not (takes a lot longer, but doesn't overfit)
        if j == 1
            strlambda = {'','',false};
        elseif j == 2
            strlambda = {'\lambda{}-', '_lambda',true};
        end


        for i = 0:1 % tracks whether to use trial-shuffled or totally-shuffled data in the analysis. These are good controls, we would expect no predictive performance if our analysis it latching on to real trial-by-trial fluctuations
            if i == 1
                shuffled  =  {'_SHUFFLED', ' Shuffled'};
            elseif i == 2
                shuffled  =  {'_SUPERSHUFFLED', ' SuperShuffled'};
            else 
                shuffled = {'',''};
            end

            for subtract_PTSH = 0:0

                if subtract_PTSH == 1 % tracks whether to use residuals (i.e. subtract a peri-stimulus time histogram) or unprocessed data)
                    params.residuals = ''; 
                else 
                    params.residuals = 'non';
                end 
                    
                for ani =   {'CJ177','CJ179','CJ190','CJ191'} % tracks which animal

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

                        for o = 1:12 % loops through the 12 different directions of stimulus presentation 
                            params.ori = o % tracks direction / orientation of the stimulus (1-12 as in SDFs.mat) for script progress / errors

                            % given above loops, we load in the relevant
                            % preprocessed datafiles
                            datapath = ['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp' shuffled{1} '.mat'];
                            load(datapath);

                            % some datasets have target populations that are
                            % smaller than 10 dimension: can't do 10-D
                            % regression on an 8-neuron space, so define the
                            % max dim for DR analysis to the smaller of 10 or the
                            % target pop size. 

                            if params.target_pop_size < 10
                                num_predict_dim = params.target_pop_size;
                            else 
                                num_predict_dim = 10;
                            end

                            % Create variables to store CV regression performance
                            cvPlots_V1 = zeros(2,num_predict_dim,repeats); % [mean, stderr] x 10 dims x 25 repeats. 
                            ridgePlots_V1 = zeros(2,repeats); % [mean, stderr] x 25 repeats
                            cvPlots_MT = zeros(2,num_predict_dim,repeats); 
                            ridgePlots_MT = zeros(2,repeats);

                            %% Now we define source / target subpopulations for V1 and MT
                            for subsample = 1:repeats % loops through each of the 25 repeats of subpopulation definitions

                                Y_V1 = V1_concat(logical(params.target_pop_index{1,subsample}),:)'; % concatenated matrices need to be transposed to samples x variables (timepoints x neurons)
                                Y_MT = MT_concat(logical(params.target_pop_index{2,subsample}),:)';
                                X = V1_concat(logical(ones(size(V1_concat,1),1) - params.target_pop_index{1,subsample}),:)';

                                clear('V1_data','MT_data');

                                SET_CONSTS

                                %% Cross-validate Reduced Rank Regression

                                % Vector containing the interaction dimensionalities to use when fitting
                                % RRR. 0 predictive dimensions results in using the mean for prediction.

                                numDimsUsedForPrediction = 1:num_predict_dim; % as set above: default is 1:10 unless target pop is smaller

                                % Number of cross validation folds.
                                cvNumFolds = 10;

                                % Initialize default options for cross-validation.
                                cvOptions = statset('crossval');

                                % If the MATLAB parallel toolbox is available, uncomment this line to
                                % enable parallel cross-validation.
                                % cvOptions.UseParall el = true;

                                % Regression method to be used.
                                regressMethod = @ReducedRankRegress;

                                % Auxiliary function to be used within the cross-validation routine (type
                                % 'help crossval' for more information). Briefly, it takes as input the
                                % the train and test sets, fits the model to the train set and uses it to
                                % predict the test set, reporting the model's test performance. Here we
                                % use NSE (Normalized Squared Error) as the performance metric. MSE (Mean
                                % Squared Error) is also available.

                                % 'RidgeInit' tracks whether to use
                                % lamba / Ridge regression in the routine: this
                                % dramatically slows down speed but eliminates
                                % performance decline due to overfitting in
                                % higher dimensions. 

                                % 'Scale' tracks whether to use z-scaling on
                                % data

                                cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
                                    (regressMethod, Ytrain, Xtrain, Ytest, Xtest, ...
                                    numDimsUsedForPrediction, 'LossMeasure', 'NSE',...
                                    'RidgeInit', strlambda{3}, 'Scale', false);

                                %% RRR V1-MT

                                % Cross-validation routine given above
                                % definition of cvFun.
                                cvl = crossval(cvFun, Y_MT, X, ...
                                      'KFold', cvNumFolds, ...
                                    'Options', cvOptions);

                                % Stores cross-validation results: mean loss and standard error of the
                                % mean across folds.

                                cvLoss = [ mean(cvl); std(cvl)/sqrt(cvNumFolds) ];
                                cvPlots_MT(:,:,subsample) = cvLoss;

                                clear('cvl','cvFun');

                                %% RRR V1-V1
                                % repeat the above process for V1-V1 reduced rank regression

                                cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
                                    (regressMethod, Ytrain, Xtrain, Ytest, Xtest, ...
                                    numDimsUsedForPrediction, 'LossMeasure', 'NSE',...
                                    'RidgeInit', strlambda{3}, 'Scale', false);

                                cvl = crossval(cvFun, Y_V1, X, ...
                                      'KFold', cvNumFolds, ...
                                    'Options', cvOptions);

                                % Stores cross-validation results: mean loss and standard error of the
                                % mean across folds.

                                cvLoss = [ mean(cvl); std(cvl)/sqrt(cvNumFolds) ];
                                cvPlots_V1(:,:,subsample) = cvLoss;

                                % To compute the optimal dimensionality for the regression model, call
                                % ModelSelect:

            %                     optDimReducedRankRegress = ModelSelect...
            %                         (cvLoss, numDimsUsedForPrediction);

                                clear('cvl','cvFun');

                                %% Ridge Regression (full model) 

                                regressMethod = @RidgeRegress;
                                dMaxShrink = .5:.01:1;
                                lambda = GetRidgeLambda(dMaxShrink, X);

                                cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
                                    (@RidgeRegress, Ytrain, Xtrain, Ytest, Xtest, lambda, ...
                                    'LossMeasure', 'NSE');

                                %% Ridge Regression V1-MT

                                cvl = crossval(cvFun, Y_MT, X, ...
                                  'KFold', cvNumFolds, ...
                                'Options', cvOptions);

                                cvLoss = [ mean(cvl); std(cvl)/sqrt(cvNumFolds) ];

                                [~,~,optLambdaRidgeRegress] = ModelSelect...
                                    (cvLoss, lambda);

                                ridgePlots_MT(:,subsample) = cvLoss(:,optLambdaRidgeRegress);

                                clear('cvl','cvFun');

                                %% Ridge Regression V1-V1

                                cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
                                    (@RidgeRegress, Ytrain, Xtrain, Ytest, Xtest, lambda, ...
                                    'LossMeasure', 'NSE');       

                                cvl = crossval(cvFun, Y_V1, X, ...
                                  'KFold', cvNumFolds, ...
                                'Options', cvOptions);

                                cvLoss = [ mean(cvl); std(cvl)/sqrt(cvNumFolds) ];

                                [~,~,optLambdaRidgeRegress] = ModelSelect...
                                    (cvLoss, lambda);

                                ridgePlots_V1(:,subsample) = cvLoss(:,optLambdaRidgeRegress);

                                clear('cvl','cvFun');

                            end 

                            clear('V1_concat','MT_concat','X','Y_V1','Y_MT');

                            %% Plotting V1-MT regression

                            y = 1 - mean(cvPlots_MT(1,:,:),3);
                            e = mean(cvPlots_MT(2,:,:),3);
                            x = numDimsUsedForPrediction;
                            errorbar(x, y, e, 'o--', 'Color', COLOR(V2,:), ...
                                    'MarkerFaceColor', COLOR(V2,:), 'MarkerSize', 10)

                            xlabel('Number of predictive dimensions')
                            ylabel('Predictive performance')

                            y2 = 1 - mean(ridgePlots_MT(1,:),2);
                            e2 = mean(ridgePlots_MT(2,:),2); 
                            x2 = 1.5;

                            hold on 
                            errorbar(x2,y2,e2,'d--', 'Color', COLOR(V2,:), ...
                                 'MarkerFaceColor', 'b', 'MarkerSize', 10)
                            hold off

                            legend([strlambda{1} 'Reduced Rank Regression'], ...
                                'Ridge Regression', ...
                                'Location', 'SouthEast')                

                            %% Saving V1-MT regression

                            title(['V1 - MT ' strlambda{1} 'RRR, ' params.animal '/' params.pen ', ' params.StimType ' ori ' num2str(params.ori) ' ' params.residuals 'pp ' shuffled{2}]);
                            savefig(['figures' filesep params.animal filesep params.pen filesep 'V1_MT_' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_regressplot_' params.residuals 'pp' strlambda{2} shuffled{1}]);
                            saveas(gcf,['figures' filesep params.animal filesep params.pen '/V1_MT_' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_regressplot_' params.residuals 'pp' strlambda{2} shuffled{1} '.jpg'])
                            save(['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} '.mat'],...
                                'cvPlots_MT','ridgePlots_MT','params');

                            %% Plotting V1-V1 regression

                            y = 1 - mean(cvPlots_V1(1,:,:),3);
                            e = mean(cvPlots_V1(2,:,:),3);
                            x = numDimsUsedForPrediction;
                            errorbar(x, y, e, 'o--', 'Color', COLOR(V2,:), ...
                                    'MarkerFaceColor', COLOR(V2,:), 'MarkerSize', 10)

                            xlabel('Number of predictive dimensions')
                            ylabel('Predictive performance')

                            y2 = 1 - mean(ridgePlots_V1(1,:),2);
                            e2 = mean(ridgePlots_V1(2,:),2); 
                            x2 = 1.5;

                            hold on 
                            errorbar(x2,y2,e2,'d--', 'Color', COLOR(V2,:), ...
                                 'MarkerFaceColor', 'b', 'MarkerSize', 10)
                            hold off

                            legend([strlambda{1} 'Reduced Rank Regression'], ...
                                'Ridge Regression', ...
                                'Location', 'SouthEast')                

                            %% Saving V1-V1 regression
                            title(['V1 - V1 ' strlambda{1} 'RRR, ' params.animal '/' params.pen ', ' params.StimType ' ori ' num2str(params.ori) ' ' params.residuals 'pp' shuffled{2}]);
                            savefig(['figures' filesep params.animal filesep params.pen filesep 'V1_V1_' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_regressplot_' params.residuals 'pp' strlambda{2} shuffled{1}]);
                            saveas(gcf,['figures' filesep params.animal filesep params.pen filesep 'V1_V1_' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_regressplot_' params.residuals 'pp' strlambda{2} shuffled{1} '.jpg'])
                            save(['data' filesep params.animal filesep params.pen filesep params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_V1_regressVals' strlambda{2} shuffled{1} '.mat'],...
                                'cvPlots_V1','ridgePlots_V1','params');

                            clearvars -except params o intra_areal subtract_PTSH repeats ani p pens shuffled strlambda stim
                        end %all orientations
                    end % all penetrations
                end % all animals
            end % residual or not
        end % shuffle condition
    end % ridge-regression or not
end % stimulus nature 