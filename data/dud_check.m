checker = zeros(12,101);
counter = zeros(101);
for j = 1:101
    for i = 1:12
        checker(i,j) = mean(all_sdfs.Square{i,j}, [2,3]);
    end
    counter(j) = mean(checker(:,j));
end