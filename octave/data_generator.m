% generate data according to a specific function and a range of inputs

clear all
close all hidden
clc
rand ("seed", 17)

output_file_analyt = "/home/irma/quantitative/bootstrapped-hadoop-svr/source_data/analyt/dataAM.csv";
output_file_oper_1 = "/home/irma/quantitative/bootstrapped-hadoop-svr/source_data/oper/dataOper1.csv";
output_file_oper_2 = "/home/irma/quantitative/bootstrapped-hadoop-svr/source_data/oper/dataOper2.csv";
output_file_oper_3 = "/home/irma/quantitative/bootstrapped-hadoop-svr/source_data/oper/dataOper3.csv";


f = @(x) exp(-x ./ 2) .* 10000;
input_range = 1:120;
output_values = f (input_range);
input_range = input_range (:);
output_values = output_values (:);

output_values_oper1 = output_values;
output_values_oper1(18:36) = output_values(18:36) + rand(19, 1)*500;
result = [output_values_oper1, input_range];
dlmwrite (output_file_oper_1,result);

output_values_oper2 = output_values;
output_values_oper2(18:36) = output_values(18:36) + rand(19, 1)*350;
result = [output_values_oper2, input_range];
dlmwrite (output_file_oper_2,result);

output_values_oper3 = output_values;
output_values_oper3(18:36) = output_values(18:36) + rand(19, 1)*650;
result = [output_values_oper3, input_range];
dlmwrite (output_file_oper_3,result);

output_values_analyt = output_values;
output_values_analyt(18:36) = output_values_analyt(18:36) + rand(19, 1)*1200;
result_analyt = [output_values_analyt, input_range];
dlmwrite (output_file_analyt,result_analyt);
