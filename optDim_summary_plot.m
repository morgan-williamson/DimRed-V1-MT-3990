
%strlambda = {'','', false};
strlambda = {'\lambda{}-', '_lambda',true};

shuffled  =  {'',''};
% shuffled  =  {'_SHUFFLED', 'Shuffled'};
% shuffled  =  {'_SUPERSHUFFLED', ' SuperShuffled'};

subtract_PTSH = 1;
params.StimType = 'Square';

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
                params.ori = o 
                
                optDimsRRR = zeros(25,2);

                for subsample = 1:25
                    
                    datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_V1_regressVals' strlambda{2} shuffled{1} '.mat'];
                    load(datapath);

                    if params.target_pop_size < 10
                        num_predict_dim = params.target_pop_size;
                    else 
                        num_predict_dim = 10;
                    end
                
                    numDimsUsedForPrediction = 1:num_predict_dim;

                    optDimsRRR(subsample,1) = ModelSelect...
                                 (cvPlots_V1(:,:,subsample), numDimsUsedForPrediction);
                             
                    datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} '.mat'];
                    load(datapath);

                    if params.target_pop_size < 10
                        num_predict_dim = params.target_pop_size;
                    else 
                        num_predict_dim = 10;
                    end         
                    
                    optDimsRRR(subsample,2) = ModelSelect...
                                 (cvPlots_MT(:,:,subsample), numDimsUsedForPrediction);         
                     
                end
                
                allPoints = [allPoints, mean(optDimsRRR,1)'];
            end
            avgPoints = [avgPoints, mean(allPoints(:,size(allPoints,2)-11:size(allPoints,2)),2)];
        end
end

scatter(allPoints(1,:),allPoints(2,:));
ax = gca;
ax.XLim = [0.5 7];
ax.YLim = [0.5 7];

xlabel('optimal predictive V1 dimensionality')
ylabel('optimal predictive MT dimensionality')

hold on 

plot(ax.XLim, ax.YLim, '--');
scatter(avgPoints(1,:),avgPoints(2,:), 'MarkerFaceColor',[0 0 0]);
hold off
                    