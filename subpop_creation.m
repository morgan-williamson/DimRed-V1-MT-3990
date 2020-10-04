clear all 

params.StimType = 'Square';
repeats = 25; % # of times I resample the source/target subpopulations based on FR-distribution matching
edges = 0:3:60;
subtract_PTSH = 0;

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
        
    % params.animal = 'CJ191';
    % params.pen = '002';
    % intra_areal = 0;



        for o = 1:12
            params.ori = o 
            params.residuals = 'non'; 

            datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp.mat'];
            load(datapath)
        
            %% Now we define source / target subpopulations for V1 and MT
            params.target_population_choices = cell(2,repeats);

            for subsamp = 1:repeats
            
                subpop = getRateMatchedSubpops({V1_concat,MT_concat},edges,size(MT_concat,1));
                params.target_population_choices{1,subsamp} = subpop{1};
                params.target_population_choices{2,subsamp} = subpop{2};
                %[length(subpop{1}), length(subpop{2})]
            end 
            params.target_pop_size = length(params.target_population_choices{1,1});
            params.target_pop_index = cell(2,repeats);
            
            for ss = 1:repeats
                index_V1 = zeros(size(V1_concat,1),1);
                index_MT = zeros(size(MT_concat,1),1);

                for k = 1:params.target_pop_size
                    index_V1(params.target_population_choices{1,ss}(k)) = 1;
                    index_MT(params.target_population_choices{2,ss}(k)) = 1;
                end 
                params.target_pop_index{1,ss} = index_V1;
                params.target_pop_index{2,ss} = index_MT;
            end
            
            save(datapath,'V1_concat', 'MT_concat','params');
            
            s1 = params.target_pop_size;
            s2 = params.target_population_choices;
            s3 = params.target_pop_index;
            
            params.residuals = '';
    
            datapath = ['data/' params.animal '/' params.pen '/' params.animal '_' params.pen '_ori_' num2str(params.ori) '_' params.StimType '_' params.residuals 'pp.mat'];
            load(datapath)
            params.target_pop_size = s1;
            params.target_population_choices= s2;
            params.target_pop_index = s3;
            save(datapath,'V1_concat', 'MT_concat','params');
          
            
        end
    end 
end 

     
