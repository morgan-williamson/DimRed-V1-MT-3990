
%strlambda = {'','', false};
strlambda = {'\lambda{}-', '_lambda',true};
predicted = '';
% predicted = '_Predicted';
shuffled  =  {'',''};
% shuffled  =  {'_SHUFFLED', 'Shuffled'};
% shuffled  =  {'_SUPERSHUFFLED', ' SuperShuffled'};

subtract_PTSH = 0;
params.StimType = 'Square';
%params.StimType = 'SineWave';
%params.StimType = 'PSsquare';
cvNumFolds = 10;
num_datasets = 0;
allPoints = [] ; % n x 2 matrix, each column contains pair [V1 optimal dimensionality, MT optimal dimensionality] where n is numnber of datasets
avgPoints = [];
incl_datasets = ones(1,96);
for ani = {'CJ177','CJ179','CJ190','CJ191'} % tracks which animal 

        params.animal = ani{1};

        if subtract_PTSH == 1         % tracks whether to use residuals (i.e. subtract a peri-stimulus time histogram) or unprocessed data
            params.residuals = '';   
        else 
            params.residuals = 'non';
        end 

        if strcmp(ani{1}, 'CJ177')
            pens = {'007','008'};
        elseif strcmp(ani{1}, 'CJ179')
            pens = {'012','013','016'};
        elseif strcmp(ani{1},'CJ190')
            pens = {'001','003'};
        elseif strcmp(ani{1},'CJ191')
            pens = {'002'};
        end

        for p = pens
            params.pen = p{1};
            
            
            for o = 1:12 % loops through the 12 different directions of stimulus presentation 
                params.ori = o 
                
                optDimsRRR = zeros(25,2);
                full_models = zeros(2,2,25);
                
                shuffled  =  {'',''};

                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} predicted '.mat'];
                load(datapath);
                full_models(1,:,:) = ridgePlots_MT; %  unshuffled full models
                
                shuffled  =  {'_SHUFFLED', 'Shuffled'};
                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} predicted '.mat'];
                load(datapath);
                full_models(2,:,:) = ridgePlots_MT; % shuffled full models
                shuffled  =  {'',''};

                num_datasets = num_datasets + 1;
                
                s = (size(full_models,3) - 1) * mean(full_models(1,2,:),3);
                s = s + (size(full_models,3) - 1) * mean(full_models(2,2,:),3);
                s = s / (2*size(full_models,3) - 2); % pooled standard deviation
                s = s * sqrt(10);
                
                
                if abs((mean(full_models(1,1,:)) - mean(full_models(2,1,:))) / s) < 3
                    incl_datasets(1,num_datasets) = 0;
                    
                end
                
                if params.target_pop_size < 3
                    incl_datasets(1,num_datasets) = 0;
                end
                
                if isequal(full_models, zeros(size(full_models)))
                    incl_datasets(1,num_datasets) = 0;
                     
                end
                
                 
                
                for subsample = 1:25
                    datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_V1_regressVals' strlambda{2} shuffled{1} predicted '.mat'];
                    load(datapath);

                    if isempty(cvPlots_MT)
                        optDimsRRR(subsample,1) = NaN;
                        optDimsRRR(subsample,2) = NaN;
                        continue
                    end

                    
                    
                    
                    if params.target_pop_size < 10
                        num_predict_dim = params.target_pop_size;
                    else 
                        num_predict_dim = 10;
                    end

                    numDimsUsedForPrediction = 1:num_predict_dim;

                    optDimsRRR(subsample,1) = ModelSelect...
                                 (cvPlots_V1(:,:,subsample), numDimsUsedForPrediction);
                    params.optDim = optDimsRRR(subsample,1); 
                    
                    save(datapath, 'params','cvPlots_V1','ridgePlots_V1','canPredict');
                    %save(datapath, 'params','cvPlots_V1','ridgePlots_V1','canPredict');
                    
                    datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} predicted '.mat'];
                    load(datapath);

                    if params.target_pop_size < 10
                        num_predict_dim = params.target_pop_size;
                    else 
                        num_predict_dim = 10;
                    end         
                    
                    optDimsRRR(subsample,2) = ModelSelect...
                                 (cvPlots_MT(:,:,subsample), numDimsUsedForPrediction);
                    params.optDim = optDimsRRR(subsample,2);
                             
                             
                    save(datapath, 'params','cvPlots_MT','ridgePlots_MT','canPredict');
                    %save(datapath, 'params','cvPlots_MT','ridgePlots_MT','canPredict');

                             
                end
                
                allPoints = [allPoints, mean(optDimsRRR,1,'omitNaN')'];
            end
            lastPoints = allPoints(:,size(allPoints,2) - 11 : size(allPoints,2)); 
            avgPoints = [avgPoints, mean(lastPoints(:,logical(incl_datasets(1,size(allPoints,2)-11:size(allPoints,2)))),2,'omitNaN')];
        end
end

s1 = scatter(allPoints(1,logical(incl_datasets)),allPoints(2,logical(incl_datasets)),'MarkerEdgeColor',[0,0,0]);
ax = gca;
ax.XLim = [0.5 9];
ax.YLim = [0.5 9];

% Create ylabel
ylabel('Optimal Predictive MT Dimensionality','FontWeight','bold',...
    'Color',[0.219607843137255 0.462745098039216 0.113725490196078]);

% Create xlabel
xlabel('Optimal Predictive V1 Dimensionality','FontWeight','bold',...
    'Color',[0 0.447058823529412 0.741176470588235]);

% Create title
title('Comparison of Predictive Dimensionality by Target Area');
hold on 

s2 = plot(ax.XLim, ax.YLim, '--');
s3 = scatter(avgPoints(1,:),avgPoints(2,:), 'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0,0,0]);

s4 = scatter(mean(allPoints(1,logical(incl_datasets)),'omitNaN'),mean(allPoints(2,logical(incl_datasets)),'omitNaN'),'d','MarkerFaceColor','#D95319');
legend([s1 s3 s4], 'dataset','mean by penetration','total mean');
hold off
                    