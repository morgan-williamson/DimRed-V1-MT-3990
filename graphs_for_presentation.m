%% Concurrent graphs V1-MT

% set colours for graphs

orig = 1;
lam = 2;
shuff = 3;
sshuff = 4;

axesColorOrder = get(0, 'DefaultAxesColorOrder');
COLOR(orig,:) = axesColorOrder(1,:);
COLOR(lam,:) = axesColorOrder(5,:);
COLOR(shuff,:) = axesColorOrder(7,:);
COLOR(sshuff,:) = axesColorOrder(4,:);
clear axesColorOrder





params.StimType = 'Square';
%params.StimType = 'SineWave';
%params.StimType = 'PSsquare';

repeats = 25; % # of times I resample the source/target subpopulations based on FR-distribution matching
%shuffled = ''; 
%shuffled  =  '_SHUFFLED';
shuffled  =  {'_SUPERSHUFFLED', ' SuperShuffled'};
%strlambda = {'lambda-', '_lambda'}; % currently also got RidgeInit set to 1
strlambda = {'',''};

for subtract_PTSH = 1:1

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
                
                
                strlambda = {'lambda-', '_lambda'};
                shuffled  =  {'',''};
                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_V1_regressVals' strlambda{2} shuffled{1} '.mat'];

                load(datapath);
                
                if params.target_pop_size < 10
                    num_predict_dim = params.target_pop_size;
                else 
                    num_predict_dim = 10;
                end
                
                numDimsUsedForPrediction = 1:num_predict_dim;                
        
                %% Plotting V1 regression
                
                y = 1 - mean(cvPlots_V1(1,:,:),3);
                e = mean(cvPlots_V1(2,:,:),3);
                x = numDimsUsedForPrediction;
                p1 = errorbar(x, y, e, 'o-', 'Color', COLOR(orig,:), ...
                        'MarkerFaceColor', COLOR(orig,:), 'MarkerSize', 7,'CapSize',0,'LineWidth',2)

                xlabel('Number of predictive dimensions')
                ylabel('Predictive performance')
               
                y2 = 1 - mean(ridgePlots_V1(1,:),2);
                e2 = mean(ridgePlots_V1(2,:),2); 
                x2 = 0.5;
                
                hold on 
                p2 = errorbar(x2,y2,e2,'^--', 'Color', COLOR(orig,:), ...
                     'MarkerFaceColor', COLOR(orig,:), 'MarkerSize', 7,'CapSize',0,'LineWidth',2)
                 
                shuffled = {'_SHUFFLED', ' Shuffled'};
                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_V1_regressVals' strlambda{2} shuffled{1} '.mat'];

                load(datapath);
                
                y7 = 1 - mean(cvPlots_V1(1,:,:),3);
                e7 = mean(cvPlots_V1(2,:,:),3);
                x7 = numDimsUsedForPrediction;
                
                hold on
                p7 =  errorbar(x7, y7, e7, 'o-', 'Color', COLOR(orig,:), ...
                        'MarkerFaceColor', 'w', 'MarkerSize', 7, 'CapSize',0,'LineWidth',2)
                hold off
                
                y8 = 1 - mean(ridgePlots_V1(1,:),2);
                e8 = mean(ridgePlots_V1(2,:),2); 
                x8 = 0.5;
                
                hold on 
                p8 = errorbar(x8,y8,e8,'^--', 'Color', COLOR(orig,:), ...
                     'MarkerFaceColor', 'w', 'MarkerSize', 7,'CapSize',0,'LineWidth',2)
                hold off 
                
                               
                %% Plotting lambda regression
                shuffled  =  {'',''};
                strlambda = {'lambda-', '_lambda'};
                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} '.mat'];

                load(datapath);
                
                if params.target_pop_size < 10
                    num_predict_dim = params.target_pop_size;
                else 
                    num_predict_dim = 10;
                end
                
                numDimsUsedForPrediction = 1:num_predict_dim;
                                
                y3 = 1 - mean(cvPlots_MT(1,:,:),3);
                e3 = mean(cvPlots_MT(2,:,:),3);
                x3 = numDimsUsedForPrediction;
                
                hold on
                p3 = errorbar(x3, y3, e3, 'o-', 'Color', '#38761d', ...
                        'MarkerFaceColor', '#38761d', 'MarkerSize', 7,'CapSize',0,'LineWidth',2)
                hold off
                
                xlabel('Number of predictive dimensions')
                ylabel('Predictive performance')
               
                y4 = 1 - mean(ridgePlots_MT(1,:),2);
                e4 = mean(ridgePlots_MT(2,:),2); 
                x4 = 0.5;
                
                hold on 
                p4 = errorbar(x4,y4,e4,'^--', 'Color', '#38761d', ...
                     'MarkerFaceColor', '#38761d', 'MarkerSize', 7, 'CapSize',0,'LineWidth',2)
                hold off
                 %% Plotting shuffled regression
                
%                 strlambda = {'', ''};
                shuffled = {'_SHUFFLED', ' Shuffled'};
                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} '.mat'];

                load(datapath);
                
                y5 = 1 - mean(cvPlots_MT(1,:,:),3);
                e5 = mean(cvPlots_MT(2,:,:),3);
                x5 = numDimsUsedForPrediction;
                
                hold on
                p5 =  errorbar(x5, y5, e5, 'o-', 'Color', '#38761d', ...
                        'MarkerFaceColor', 'w', 'MarkerSize', 7,'CapSize',0,'LineWidth',2)
                hold off
                
                y6 = 1 - mean(ridgePlots_MT(1,:),2);
                e6 = mean(ridgePlots_MT(2,:),2); 
                x6 = 0.5;
                
                hold on 
                p6 = errorbar(x6,y6,e6,'^--', 'Color', '#38761d', ...
                     'MarkerFaceColor', 'w', 'MarkerSize', 7,'CapSize',0,'LineWidth',2)
                hold off 
                
                
%                 %% Plotting SuperShuffled regression
%                 
%                 %strlambda = {'', ''};
%                 shuffled = {'_SUPERSHUFFLED', ' SuperShuffled'};
%                 datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_MT_regressVals' strlambda{2} shuffled{1} '_Predicted.mat'];
% 
%                 load(datapath);
%                 
%                 y7 = 1 - mean(cvPlots_MT(1,:,:),3);
%                 e7 = mean(cvPlots_MT(2,:,:),3);
%                 x7 = numDimsUsedForPrediction;
%                 
%                 hold on                
%                 p7 = errorbar(x7, y7, e7, 'o--', 'Color', COLOR(sshuff,:), ...
%                         'MarkerFaceColor', COLOR(sshuff,:), 'MarkerSize', 7)
%                 hold off
%                
%                 y8 = 1 - mean(ridgePlots_MT(1,:),2);
%                 e8 = mean(ridgePlots_MT(2,:),2); 
%                 x8 = 1.5;
%                 
%                 hold on 
%                 p8 = errorbar(x8,y8,e8,'d--', 'Color', COLOR(sshuff,:), ...
%                      'MarkerFaceColor', 'w', 'MarkerSize', 7)
%                 hold off
                
                legend([p1,p7,p3,p5], 'V1', ...
                    'V1 Shuffled', ...
                    'MT',...
                    'MT Shuffled', 'Location','East' ); %'Location', 'SouthEast'
                
                title(['Interareal regression, ' params.animal '/' params.pen ', ' params.StimType ' ori ' num2str(params.ori)]);
                savefig(['figures/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_regressplot_' params.residuals 'pp_lambda_compShuff']);
                saveas(gcf,['figures/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_regressplot_' params.residuals 'pp_lambda_compShuff.jpg'])
                
                clearvars -except params o intra_areal subtract_PTSH repeats ani p pens shuffled strlambda COLOR orig lam sshuff shuff
            end %all orientations
        end % all penetrations
    end % all animals
end % residual or not
                
                