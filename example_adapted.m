%%
addpath regress_methods
addpath regress_util
addpath fa_util

SET_CONSTS

%load('data/sample_data.mat') % for Semedo et al. sample data 
params.animal = 'CJ191';
params.pen = '002';
params.StimType = 'Square';
intra_areal = 0;

for subtract_PTSH = 0:1
    for o = 1:12
        params.ori = o; 
        
        if subtract_PTSH == 1
            params.residuals = '';
        else 
            params.residuals = 'non';
        end 
        
        datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp.mat'];
        load(datapath)



        if intra_areal == 1
            Y_reg = 'V1';
            source_choice = randi([0,1], 1,size(V1_concat,1)) < 0.5;
            X = V1_concat(logical(source_choice),:)';
            Y_MT = V1_concat(logical(ones(1,size(V1_concat,1)) - source_choice),:)';
        else
            Y_reg = 'MT';
            X = V1_concat';
            Y_MT = MT_concat';
        end

        clear('V1_data','MT_data','V1_concat','MT_concat', 'source_choice');

        SET_CONSTS

        %%
        % ========================================================================
        % 1) Identifying dimensions in the source activity space
        % ========================================================================

        % The process of identifying dimensions in the source activity space
        % depends on the method used. Here, we provide a few examples.

        % Sample data used here corresponds to V1 and V2 residuals (i.e., PSTHs
        % have been subtracted from the full responses), in response to a drifting
        % grating. sample_data.mat contains two variables, X and Y_V2. X contains
        % the activity in the source population. It's a N-by-p matrix, where N is
        % the number of datapoints and p is the number of source neurons. Y
        % contains the activity in the target population. It's a N-by-K matrix,
        % where K is the number of target neurons. For the sample data, N = 4000,
        % p = 79 and K = 31. The N datapoints can come from different time points
        % or different trials. As an example, the 4000 datapoints used here come
        % from 400 trials that contained 10 time points each.



        %% Reduced Rank Regression

     %    [~, B_] = ReducedRankRegress(Y_MT, X);
        % The columns of B_ contain the predictive dimensions of source activity
        % X. Predictive dimensions are ordered by target variance explained. As a
        % result, the top d predictive dimension are given by B_(:,1:d). The
        % columns of B_ are not orthonormal, i.e., they do not form an orthonormal
        % basis for a subspace of the source activity X. They are, however,
        % guaranteed to be independent. A suitable basis for the predictive
        % subspace can be found via QR decomposition: [Q,R] = qr( B_(:,1:q) ). In
        % this instance, Q provides an orthonormal basis for a q-dimensional
        % predictive subspace. The correct dimensionality for the Reduced Rank
        % Regression model (i.e., the optimal number of predictive dimensions) is
        % found via cross-validation (see section 2), below).

        %% Factor Analysis

    %     q = 30;
    % 
    %     [Z, U, Q] = ExtractFaLatents(X, q);
        % The columns of U contain the dominant dimensions of the source activity
        % X. Dominant dimensions are ordered by shared variance explained. As a
        % result, the top d dominant dimensions are given by U(:,1:d). Note that
        % the latent variables Z under the Factor Analysis model are not obtained
        % by projecting the data onto the dominant dimensions. This is due to
        % Factor Analysis' noise model. Rather, Z = (X - M)*Q, where Q is the
        % Factor Analysis "decoding" matrix, and M is the sample mean. The
        % reconstructed data is given by Z*U' + M. The correct dimensionality for
        % the Factor Analysis model (i.e., the optimal number of dominant
        % dimensions) is found via cross-validation (see section 2), below).

        %%
        % ========================================================================
        % 2) Cross-validation
        % ========================================================================

        % - Cross-validating any of the included regression methods follows the
        % same general from. First, define the auxiliary cross-validation function
        % based on the chosen regression method:
        % 
        % cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
        %	(regressMethod, Ytrain, Xtrain, Ytest, Xtest, cvParameter, ...
        %	'LossMeasure', lossMeasure, ...
        %	'RegressMethodExtraArg1', regressMethodExtraArg1, ...);
        % 
        % When using Ridge regression, for example, we have:
        % 
        % regressMethod = @RidgeRegress;
        % cvParameter = lambda;
        % lossMeasure = 'NSE'; % NSE stands for Normalized Squared Error
        % 
        % Ridge Regression has no extra arguments, so the auxiliary
        % cross-validation function becomes:
        % 
        % cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
        %	(@RidgeRegress, Ytrain, Xtrain, Ytest, Xtest, lambda, ...
        %	'LossMeasure', 'NSE');
        % 
        % Whenever the regression function has extra (potentially optional)
        % arguments, they are passed to the auxiliary cross-validation function as
        % name argument pairs.
        % 
        % For Ridge regression, the correct range for lambda can be determined
        % using:
        % 
        % dMaxShrink = .5:.01:1;
        % lambda = GetRidgeLambda(dMaxShrink, X);
        % 
        % (See Elements of Statistical Learning, by Hastie, Tibshirani and
        % Friedman for more information.)



        %% Regression cross-validation examples +++++++++++++++++++++++++++++++++++
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        %% Cross-validate Reduced Rank Regression

        % Vector containing the interaction dimensionalities to use when fitting
        % RRR. 0 predictive dimensions results in using the mean for prediction.
        numDimsUsedForPrediction = 1:10;

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
        
        cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
            (regressMethod, Ytrain, Xtrain, Ytest, Xtest, ...
            numDimsUsedForPrediction, 'LossMeasure', 'NSE');

        % Cross-validation routine.
        cvl = crossval(cvFun, Y_MT, X, ...
              'KFold', cvNumFolds, ...
            'Options', cvOptions);

        % Stores cross-validation results: mean loss and standard error of the
        % mean across folds.
        cvLoss = [ mean(cvl); std(cvl)/sqrt(cvNumFolds) ];

        % To compute the optimal dimensionality for the regression model, call
        % ModelSelect:
        optDimReducedRankRegress = ModelSelect...
            (cvLoss, numDimsUsedForPrediction);

        % Plot Reduced Rank Regression cross-validation results
        x = numDimsUsedForPrediction;
        y = 1-cvLoss(1,:);
        e = cvLoss(2,:);

        errorbar(x, y, e, 'o--', 'Color', COLOR(V2,:), ...
            'MarkerFaceColor', COLOR(V2,:), 'MarkerSize', 10)

        xlabel('Number of predictive dimensions')
        ylabel('Predictive performance')

        %% Ridge Regression (full model) 

        regressMethod = @RidgeRegress;
        dMaxShrink = .5:.01:1;
        lambda = GetRidgeLambda(dMaxShrink, X);

        cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
            (@RidgeRegress, Ytrain, Xtrain, Ytest, Xtest, lambda, ...
            'LossMeasure', 'NSE');


        cvl = crossval(cvFun, Y_MT, X, ...
          'KFold', cvNumFolds, ...
        'Options', cvOptions);

        cvLoss = [ mean(cvl); std(cvl)/sqrt(cvNumFolds) ];

        y = mean(1-cvLoss(1,:));
        e = mean(cvLoss(2,:));
        x = [1.5];

        hold on 
        errorbar(x,y,e,'d--', 'Color', COLOR(V2,:), ...
             'MarkerFaceColor', 'b', 'MarkerSize', 10)
        hold off


         %% Cross-validate Factor Regression
    % 
    %     numDimsUsedForPrediction = 1:10;
    % 
    %     cvNumFolds = 10;
    % 
    %     cvOptions = statset('crossval');
    %     % cvOptions.UseParallel = true;
    % 
    %     regressMethod = @FactorRegress;
    % 
    %     % In order to apply Factor Regression, we must first determine the optimal
    %     % dimensionality for the Factor Analysis Model
    %     p = size(X, 2);
    %     q = 0:30;
    %     qOpt = FactorAnalysisModelSelect( ...
    %         CrossValFa(X, q, cvNumFolds, cvOptions), ...
    %         q);
    % 
    %     cvFun = @(Ytrain, Xtrain, Ytest, Xtest) RegressFitAndPredict...
    %         (regressMethod, Ytrain, Xtrain, Ytest, Xtest, ...
    %         numDimsUsedForPrediction, ...
    %         'LossMeasure', 'NSE', 'qOpt', qOpt);
    %     % qOpt is an extra argument for FactorRegress. Extra arguments for the
    %     % regression function are passed as name/value pairs after the
    %     % cross-validation parameter (in this case numDimsUsedForPrediction).
    %     % qOpt, the optimal factor analysis dimensionality for the source activity
    %     % X, must be provided when cross-validating Factor Regression. When
    %     % absent, Factor Regression will automatically determine qOpt via 
    %     % cross-validation (which will generate an error if Factor Regression is
    %     % itself used within a cross-validation procedure).
    % 
    %     cvl = crossval(cvFun, Y_MT, X, ...
    %           'KFold', cvNumFolds, ...
    %         'Options', cvOptions);
    % 
    %     cvLoss = ...
    %         [ mean(cvl); std(cvl)/sqrt(cvNumFolds) ];
    % 
    %     optDimFactorRegress = ModelSelect...
    %         (cvLoss, numDimsUsedForPrediction);
    % 
    %     % Plot Reduced Rank Regression cross-validation results
    %     x = numDimsUsedForPrediction;
    %     x(x > qOpt) = [];
    %     y = 1-cvLoss(1,:);
    %     e = cvLoss(2,:);
    % 
    %     hold on
    %     errorbar(x, y, e, 'o--', 'Color', COLOR(V2,:), ...
    %         'MarkerFaceColor', 'w', 'MarkerSize', 10)
    %     hold off



         %%
    %     legend('Reduced Rank Regression', ...
    %         'Factor Regression', ...
    %         'Location', 'SouthEast')

    legend('Reduced Rank Regression', ...
            'Ridge Regression', ...
            'Location', 'SouthEast')

        %% Factor analysis cross-validation example +++++++++++++++++++++++++++++++
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        %%
    %     q = 0:30;
    % 
    %     cvNumFolds = 10;
    % 
    %     cvOptions = statset('crossval');
    %     % cvOptions.UseParallel = true;
    % 
    %     cvLoss= CrossValFa(X, q, cvNumFolds, cvOptions);
    % 
    % 
    %     % CrossValFa returns the cumulative shared variance explained. To compute
    %     % the optimal Factor Analysis dimensionality, call
    %     % FactorAnalysisModelSelect:
    %     qOpt = FactorAnalysisModelSelect(cvLoss, q);

        %% Saving figures
        title(['V1 - ' Y_reg ' RRR, ' params.animal '/' params.pen ', ' params.StimType ' ori ' num2str(params.ori) ' ' params.residuals 'pp']);
        savefig(['figures/' params.animal '/' params.pen '/V1_' Y_reg '_' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_regressplot_' params.residuals 'pp']);

        clearvars -except params o intra_areal subtract_PTSH
    end
end