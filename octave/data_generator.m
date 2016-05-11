clear all
close all hidden
clc
rand ("seed", 17);

% available values are R1, R3, R5
query = "R1"

% available values are 250, 500, 750
ssize = "750"


nRed = 455
nMap = 434
avg_Tmap = 29826.2375
avg_Tred= 1917.3



input_range = 1:10:120;


f = @(x) ceil(nMap ./ x) .* avg_Tmap + ceil(nRed ./ x) .* avg_Tred;

output_file_analyt = ["../source_data/analyt/" query "/" ssize "/dataAM.csv"];

output_values = f (input_range);
input_range = input_range (:);
output_values = output_values (:);

result_analyt = [output_values, input_range];
dlmwrite (output_file_analyt,result_analyt);

