clear all
close all hidden
clc
rand ("seed", 17);

output_file_analyt = "../source_data/analyt/dataAM.csv";
output_file_oper = "../source_data/oper/dataOper.csv";


f = @(x) 1 ./ (0.01*x) + 1;
input_range = 1:120;
output_values = f (input_range);
input_range = input_range (:);
output_values = output_values (:);

output_values_oper = output_values;
output_values_oper(7:17) = output_values(7:17) + rand(11, 1)*5;
result_oper = [output_values_oper, input_range];
dlmwrite (output_file_oper,result_oper);

output_values_analyt = output_values;
output_values_analyt(7:17) = output_values_analyt(7:17) + rand(11, 1)*20;
result_analyt = [output_values_analyt, input_range];
dlmwrite (output_file_analyt,result_analyt);
