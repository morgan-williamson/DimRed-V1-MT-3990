
%strlambda = {'','', false};
strlambda = {'\lambda{}-', '_lambda',true};
predicted = '';
%  predicted = '_Predicted'
 shuffled  =  {'',''};
% shuffled  =  {'_SHUFFLED', 'Shuffled'};
% shuffled  =  {'_SUPERSHUFFLED', ' SuperShuffled'};

subtract_PTSH = 1;
params.StimType = 'Square';
%params.StimType = 'SineWave';
%params.StimType = 'PSsquare';
cvNumFolds = 10;

allPoints = [] ; % n x 2 matrix, each column contains pair [V1 optimal dimensionality, MT optimal dimensionality] where n is numnber of datasets
avgPoints = [];
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
                params.ori = o; 
                
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
                
                
%                 if abs((mean(full_models(1,1,:)) - mean(full_models(2,1,:))) / s) < 3
%                     continue
%                 end
% %                 
                if isequal(full_models, zeros(size(full_models)))
                    continue 
                end
%                 
                for subsample = 1:25
                    datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_V1_regressVals' strlambda{2} shuffled{1} predicted '.mat'];

                    load(datapath);

                    
                    
                    
                    
                    if params.target_pop_size < 10
                        num_predict_dim = params.target_pop_size;
                    else 
                        num_predict_dim = 10;
                    end

                    numDimsUsedForPrediction = 1:num_predict_dim;

                    optDimsRRR(subsample,1) = ridgePlots_V1(1,subsample);
%                     params.optDim = optDimsRRR(subsample,1); 
                    
%                     save(datapath, 'params','cvPlots_V1','ridgePlots_V1','canPredict');
%                     %save(datapath, 'params','cvPlots_V1','ridgePlots_V1','canPredict');
                    datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} predicted '.mat'];
                    
                    
                    load(datapath);

                    if params.target_pop_size < 10
                        num_predict_dim = params.target_pop_size;
                    else 
                        num_predict_dim = 10;
                    end         
                    if num_predict_dim > 0
                        
                        optDimsRRR(subsample,2) = ridgePlots_MT(1,subsample);
                    else
                        optDimsRRR(subsample,1) = NaN;
                        
                        optDimsRRR(subsample,2) = NaN;
                    end
                    
                    
                    

%                     params.optDim = optDimsRRR(subsample,2);
%                     if ridgePlots_MT(1,subsample) <= 0.01
%                         params
%                     end
                             
%                     save(datapath, 'params','cvPlots_MT','ridgePlots_MT','canPredict');
                    %save(datapath, 'params','cvPlots_MT','ridgePlots_MT','canPredict');

                             
                end
                
                allPoints = [allPoints, mean(optDimsRRR,1)'];
            end
%              avgPoints = [avgPoints, mean(allPoints(:,size(allPoints,2)-11:size(allPoints,2)),2)];
        end
end
% 
% scatter(allPoints(1,:),allPoints(2,:));
% ax = gca;
% ax.XLim = [0.5 7];
% ax.YLim = [0.5 7];
% 
% xlabel('optimal predictive V1 dimensionality')
% ylabel('optimal predictive MT dimensionality')

% hold on 
% 
% plot(ax.XLim, ax.YLim, '--');
% % scatter(avgPoints(1,:),avgPoints(2,:), 'MarkerFaceColor',[0 0 0]);
% hold off
            

h1 = histogram(1-allPoints(1,:));
h1.BinWidth = 0.01;
hold on
h2 = histogram(1-allPoints(2,:));
h2.BinWidth = 0.01;
h2.FaceColor = '#38761d';

m1 = errorbar(mean(1-allPoints(1,:),'omitNaN'),55,0,'v', 'Color', '#0072BD', ...
                     'MarkerFaceColor', '#0072BD','CapSize',0);
m2 = errorbar(mean(1-allPoints(2,:),'omitNaN'),55,0,'v','Color', '#38761d', ...
                     'MarkerFaceColor', '#38761d','CapSize', 0);  	
title('Distribution of predictive performance by target population')
legend([h1 h2 m1 m2], 'Predicting V1','Predicting MT', 'mean V1', 'mean MT');
hold off