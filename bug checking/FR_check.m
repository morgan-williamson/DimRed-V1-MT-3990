FR_checker_V1 = [];
FR_checker_MT = [];
all_neurons = [];
params.StimType = 'Square';
params.residuals = 'non';

for ani = {'CJ177','CJ179','CJ191'}
    
    params.animal = ani{1};
           
    if strcmp(ani{1}, 'CJ177')
        pens = {'007','008'};
    elseif strcmp(ani{1}, 'CJ179')
        pens = {'012'};
    else
        pens = {'002'};
    end
    
    for p = pens
            params.pen = p{1};
        FR_checker_V1 = [];
        FR_checker_MT = [];
        for o = 1:12 % tracks direction / orientation of the stimulus (1-12 as in SDFs.mat)
            params.ori = o;

            datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp.mat'];

            load(datapath);

            FR_checker_V1 = [FR_checker_V1 V1_concat];
            FR_checker_MT = [FR_checker_MT MT_concat];
        end 

        FR_V1 = mean(FR_checker_V1,2);
        FR_MT = mean(FR_checker_MT,2);
        all_neurons = [all_neurons;FR_V1;FR_MT];
    end
end 
