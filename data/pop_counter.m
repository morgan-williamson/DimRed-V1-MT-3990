
V1 = []; MT = [];
MT_ss = []; V1_ss = [];
% predicted = '';
predicted = '_Predicted';
for ani = {'CJ177','CJ179','CJ190','CJ191'} % tracks which animal 

        params.animal = ani{1};

        

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
                datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp_V1_regressVals' strlambda{2} shuffled{1} predicted '.mat'];

                load(datapath);
                MT_ss = [MT_ss params.target_pop_size];
                V1_ss = [V1_ss (size(params.target_pop_index{1,1},1)-params.target_pop_size)];
            end
            datapath = ['data/' params.animal '/' params.pen '/exclusions.mat'];
                 load(datapath);
            V1 = [V1 sum(OK.anyVisual{1,1})];
            MT = [MT sum(OK.anyVisual{1,2})];
        end 
end

