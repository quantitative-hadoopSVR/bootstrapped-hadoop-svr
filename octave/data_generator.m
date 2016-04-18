% generate data according to a specific function and a range of inputs

output_file_analyt = "/Users/michele/Desktop/corsi_phd/Quantitative/progetto/bootstrapped-hadoop-svr/source_data/analyt/dataAM.csv";
output_file_oper = "/Users/michele/Desktop/corsi_phd/Quantitative/progetto/bootstrapped-hadoop-svr/source_data/oper/dataOper.csv";

f = @(x) exp(-x ./ 2) .* 10000;
input_range = 1:20;
output_values = f (input_range);
input_range = input_range (:);
output_values = output_values (:);
result = [output_values, input_range];
dlmwrite (output_file_oper,result);

output_values_analyt = output_values;
output_values_analyt(3:6) = output_values_analyt(3:6) + rand(4, 1)*1000;
result_analyt = [output_values_analyt, input_range];
dlmwrite (output_file_analyt,result_analyt);
