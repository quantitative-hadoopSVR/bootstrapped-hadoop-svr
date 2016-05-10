clear all
close all hidden
clc
rand ("seed", 17);

output_file_analyt = "../source_data/analyt/dataAM.csv";

nMap = 381
nRed = 364
avg_Tmap = 30052.278125
avg_Tred = 2195.046875


%TODO: change functions
f = @(x) ceil(nMap ./ x) .* avg_Tmap + ceil(nRed ./ x) .* avg_Tred
input_range = 1:120;
output_values = f (input_range);
input_range = input_range (:);
output_values = output_values (:);

result_analyt = [output_values, input_range];
dlmwrite (output_file_analyt,result_analyt);
