

checker_V1 = zeros(300,60);
checker_MT = zeros(300,35);

for j = 1:60
    for i = 1:300
        if isequal(V1_concat(j, ((i-1)*10 + 1):i*10), V1_concat(j, 1:10))
            checker_V1(i,j) = 1;
        end 
    end
end

for j = 1:35
    for i = 1:300
        if isequal(MT_concat(j, ((i-1)*10 + 1):i*10), MT_concat(j, 1:10))
            checker_MT(i,j) = 1;
        end 
    end
end



%% 


EX = rand(3,3,3);
eg = mean(EX, [2]);

total = EX - eg;

for j = 1:3
    EX(:,j,:) = EX(:,j,:) - eg;
end

isequal(EX, total)