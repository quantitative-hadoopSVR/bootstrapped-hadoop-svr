clear all
close all hidden
clc
warning("off")


%% Input data parameters: path to folder containing 
%% the analytical data and to folder containing 
%% the operational data.
query = "R5";
ssize = "250";
configuration_to_predict = 2;
%R1-250
%avg_time_query_vector = [79316.55 63576.45 49026.8 42215.55];

%R3-250
%avg_time_query_vector = [275684.25 197388.3 168209.25 143650.1];

%R5-250
avg_time_query_vector = [25924.65 25830.7 25316.1 26072.3];


configurations = [60 80 100 120];

%% 60 = 1 ; 80 = 2; 100 = 3; 120 = 4
query_analytical_data = ["analyt/" query "/" ssize "/dataAM.csv"];
query_operational_data_60 = ["oper/" query "/" ssize "/dataOper_" num2str(configurations(1)) ".csv"];
query_operational_data_80 = ["oper/" query "/" ssize "/dataOper_" num2str(configurations(2)) ".csv"];
query_operational_data_100 = ["oper/" query "/" ssize "/dataOper_" num2str(configurations(3)) ".csv"];
query_operational_data_120 = ["oper/" query "/" ssize "/dataOper_" num2str(configurations(4)) ".csv"];


base_dir = "../source_data/";

%% Splitting parameters
train_frac = 0.7;
test_frac = 0.3;

oper_weight_value = 10;
analyt_weight_value = 1;

%% Ranges to be used to the identification
%% of the optimal "C" and "epsilon" parameter of the SVR
%% when using epsilon-SVR ( the SVR type used by Eugenio.
%% we could investigate if it makes sense to try nu-SVR too ).
C_range = linspace (0.1, 5, 20);
E_range = linspace (0.1, 5, 20);

%% Initializing the Knowledge Base sampling the analytical data
[analytical_sample, ~] = initKB ([base_dir, query_analytical_data]);
weight=ones(size(analytical_sample,1),1) * analyt_weight_value;

rand ("seed", 17);

permutation = randperm (size (analytical_sample, 1));

analytical_shuffled = analytical_sample(permutation, :);
weight_shuffled = weight(permutation);

%% Separating prediction variables from target variable in the analytical dataset get first column in y and second in X. 
y = analytical_shuffled(:, 1);
X= analytical_shuffled(:, 2);

%% Splitting the analytical datasets
[ytr, ytst, ~] = split_sample (y, train_frac, test_frac);
[Xtr, Xtst, ~] = split_sample (X, train_frac, test_frac);
[Wtr, Wtst, ~] = split_sample (weight_shuffled, train_frac, test_frac);

%% Linear kernel model
sprintf("Training the SVR from on analytical model (linear).")
[C, eps] = modelSelection (Wtr, ytr, Xtr, ytst, Xtst, "-s 3 -t 0 -q -h 0", C_range, E_range);
options = ["-s 3 -t 0 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
model_linear = svmtrain (Wtr, ytr, Xtr, options);
[predictions_linear{1}, accuracy_linear, ~] = svmpredict (avg_time_query_vector.', configurations.', model_linear);
plot_predictions(query, ssize, "linear", num2str(configurations(configuration_to_predict)), "analyt", predictions_linear{1}, avg_time_query_vector,0)
Cs_linear(1) = C;
Es_linear(1) = eps;
RMSEs_linear(1) = sqrt (accuracy_linear(2));
MSE_linear(1)=accuracy_linear(2);
coefficients_linear{1} = model_linear.sv_coef;
SVs_linear{1} = model_linear.SVs;
b_linear{1} = - model_linear.rho;


%% RBF kernel model
sprintf("Training the SVR from on analytical model.(kernel)")
[C, eps] = modelSelection (Wtr, ytr, Xtr, ytst, Xtst, "-s 3 -t 2 -q -h 0", C_range, E_range);
options = ["-s 3 -t 2 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
model = svmtrain (Wtr,ytr, Xtr, options);
[predictions{1}, accuracy, ~] = svmpredict (avg_time_query_vector.', configurations.', model);
plot_predictions(query, ssize, "gaussian", num2str(configurations(configuration_to_predict)), "analyt", predictions{1}, avg_time_query_vector,0)
Cs(1) = C;
Es(1) = eps;
RMSEs(1) = sqrt (accuracy(2));
MSE(1)=accuracy(2);
coefficients{1} = model.sv_coef;
SVs{1} = model.SVs;
b{1} = - model.rho;

current_KB = analytical_sample;
current_weight = weight

operational_data_60 = read_data([base_dir query_operational_data_60])
operational_data_80 = read_data([base_dir query_operational_data_80])
operational_data_100 = read_data([base_dir query_operational_data_100])
operational_data_120 = read_data([base_dir query_operational_data_120])

[operational_data_60_cleaned, ~] = clear_outliers (operational_data_60);
[operational_data_80_cleaned, ~] = clear_outliers (operational_data_80);
[operational_data_100_cleaned, ~] = clear_outliers (operational_data_100);
[operational_data_120_cleaned, ~] = clear_outliers (operational_data_120);

for ii = 1: min([length(operational_data_60_cleaned) length(operational_data_80_cleaned) length(operational_data_100_cleaned) length(operational_data_120_cleaned)])

  if ( configuration_to_predict == 1 )
    current_chunk = [operational_data_80_cleaned(ii, :) ; operational_data_100_cleaned(ii, :) ; operational_data_120_cleaned(ii, :)];
  endif

  if ( configuration_to_predict == 2 )
    current_chunk = [operational_data_60_cleaned(ii, :) ; operational_data_100_cleaned(ii, :) ; operational_data_120_cleaned(ii, :)];
  endif

  if ( configuration_to_predict == 3 )
    current_chunk = [operational_data_60_cleaned(ii, :) ; operational_data_80_cleaned(ii, :) ; operational_data_120_cleaned(ii, :)];
  endif

  if ( configuration_to_predict == 4 )
    current_chunk = [operational_data_60_cleaned(ii, :) ; operational_data_80_cleaned(ii, :) ; operational_data_100_cleaned(ii, :)];
  endif

  [current_KB, current_weight] = updateKB_RNN(current_KB, current_chunk, current_weight, oper_weight_value);

  permutation = randperm (size (current_KB, 1));

  current_KB_shuffled = current_KB(permutation, :);
  current_weight_shuffled = current_weight(permutation);

  y = current_KB_shuffled(:, 1);
  X = current_KB_shuffled(:, 2);

  [ytr, ytst, ~] = split_sample (y, train_frac, test_frac);
  [Xtr, Xtst, ~] = split_sample (X, train_frac, test_frac);
  [Wtr, Wtst, ~] = split_sample (current_weight_shuffled, train_frac, test_frac);

  %% White box model, linear^(-1)
  sprintf("Re-training (%d) the SVR from on analytical model (linear).", ii)
  [C, eps] = modelSelection (Wtr, ytr, Xtr, ytst, Xtst, "-s 3 -t 0 -q -h 0", C_range, E_range);
  options = ["-s 3 -t 0 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
  model_linear = svmtrain (Wtr, ytr, Xtr, options);
  [predictions_linear{ii+1}, accuracy_linear, ~] = svmpredict (avg_time_query_vector.', configurations.', model_linear);
  plot_predictions(query, ssize, "linear", num2str(configurations(configuration_to_predict)), num2str(ii), predictions_linear{ii+1}, avg_time_query_vector,current_chunk)
  Cs_linear(ii+1) = C;
  Es_linear(ii+1) = eps;
  MSE_linear(ii+1)=accuracy_linear(2);
  RMSEs_linear(ii+1) = sqrt (accuracy_linear(2));
  coefficients_linear{ii+1} = model_linear.sv_coef;
  SVs_linear{ii+1} = model_linear.SVs;
  b_linear{ii+1} = - model_linear.rho;

  %% Black box model, RBF
  sprintf("Re-training (%d) the SVR from on analytical model.(kernel)", ii)
  [C, eps] = modelSelection (Wtr, ytr, Xtr, ytst, Xtst, "-s 3 -t 2 -q -h 0", C_range, E_range);
  options = ["-s 3 -t 2 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
  model = svmtrain (Wtr, ytr, Xtr, options);
  [predictions{ii+1}, accuracy, ~] = svmpredict (avg_time_query_vector.', configurations.', model);
  plot_predictions(query, ssize, "gaussian", num2str(configurations(configuration_to_predict)), num2str(ii), predictions{ii+1}, avg_time_query_vector,current_chunk)
  Cs(ii+1) = C;
  Es(ii+1) = eps;
  MSE(ii+1)=accuracy(2);
  RMSEs(ii+1) = sqrt (accuracy(2));
  coefficients{ii+1} = model.sv_coef;
  SVs{ii+1} = model.SVs;
  b{ii+1} = - model.rho;
 
endfor
