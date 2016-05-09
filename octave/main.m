clear all
close all hidden
clc
warning("off")


%% Input data parameters: path to folder containing 
%% the analytical data and to folder containing 
%% the operational data.
query = "R1";
configuration_to_predict = 2
avg_time_query_vector = [24 234 234 2345];

configurations = [60 80 100 120]

%% 60 = 1 ; 80 = 2; 100 = 3; 120 = 4
query_analytical_data = ["analyt/dataAM_" query ".csv"]
query_operational_data_60 = ["oper/dataOper_" query "_60.csv"]
query_operational_data_80 = ["oper/dataOper_" query "_80.csv"]
query_operational_data_100 = ["oper/dataOper_" query "_100.csv"]
query_operational_data_120 = ["oper/dataOper_" query "_120.csv"]

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

%% Number of iterations for the re-training after the bootstrapping
iterations = 100;

%% Initializing the Knowledge Base sampling the analytical data
[analytical_sample, analytical_sample_linear] = initKB ([base_dir, query_analytical_data]);


%% Scaling and permutating the analytical dataset
rand ("seed", 17);
permutation = randperm (size (analytical_sample, 1));

[analytical_scaled, mu, sigma] = zscore (analytical_sample);
analytical_shuffled = analytical_scaled(permutation, :);

mu_y = mu(1);
sigma_ = sigma(1);
mu_X = mu(2:end);
sigma_X = sigma(2:end);

[analytical_scaled_linear, mu, sigma] = zscore (analytical_sample_linear);
analytical_shuffled_linear = analytical_scaled_linear(permutation, :);

mu_X_linear = mu(2:end);
sigma_X_linear = sigma(2:end);

%% Separating prediction variables from target variable in the analytical dataset get first column in y and second in X. 
y = analytical_shuffled(:, 1);
X= analytical_shuffled(:, 2:end);

y_linear = analytical_shuffled_linear(:, 1);
X_linear = analytical_shuffled_linear(:, 2:end);

%% Assign weights 1 for the first iteration
weight=ones(size(analytical_shuffled,1),1) * analyt_weight_value;
weight_linear=ones(size(analytical_shuffled_linear,1),1) * analyt_weight_value;

%% Splitting the analytical datasets
[ytr, ytst, ~] = split_sample (y, train_frac, test_frac);
[Xtr, Xtst, ~] = split_sample (X, train_frac, test_frac);
[Wtr, Wtst, ~] = split_sample (weight, train_frac, test_frac);
[ytr_linear, ytst_linear, ~] = split_sample (y_linear, train_frac, test_frac);
[Xtr_linear, Xtst_linear, ~] = split_sample (X_linear, train_frac, test_frac);
[Wtr_linear, Wtst_linear, ~] = split_sample (weight_linear, train_frac, test_frac);

ycv = avg_time_query_vector(configuration_to_predict);
Xcv = configurations(configuration_to_predict);
ycv_linear = avg_time_query_vector(configuration_to_predict);
Xcv_linear = 1 / Xcv
%% TODO: train the machine learner with the obtainted
%% knowlege base. Built using linear kernel for "_linear" dataset
%% and using RBF kernel for full featured datasets 
%% ( even if right now we don't have this distinction, let's
%% keep it for possible future use and for applying both
%% the techniques in any case (it still makes sense to compare 
%% linear and RBF kernels, if possible (single attribute) ).
%% Anyway according to the LIBSVM guide, since in our case 
%% the number of instances is much higher than the number of
%% features, we should expect to get better accuracy using the RBF kernel.
%% No need to try the polynomial kernel, according to the LIBSVM guide.

%% Linear kernel model
sprintf("Training the SVR from on analytical model (linear).")
[C, eps] = modelSelection (Wtr_linear, ytr_linear, Xtr_linear, ytst_linear, Xtst_linear, "-s 3 -t 0 -q -h 0", C_range, E_range);
options = ["-s 3 -t 0 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
model_linear = svmtrain (Wtr_linear, ytr_linear, Xtr_linear, options);
[predictions_linear{1}, accuracy_linear, ~] = svmpredict (ycv_linear, Xcv_linear, model_linear);
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
[predictions{1}, accuracy, ~] = svmpredict (ycv, Xcv, model);
Cs(1) = C;
Es(1) = eps;
RMSEs(1) = sqrt (accuracy(2));
MSE(1)=accuracy(2);
coefficients{1} = model.sv_coef;
SVs{1} = model.SVs;
b{1} = - model.rho;

current_KB = analytical_shuffled;
current_KB_linear = analytical_shuffled_linear;

%% TODO: .....
operational_data = [];

operational_data_60 = read_data(query_operational_data_60)
operational_data_80 = read_data(query_operational_data_80)
operational_data_100 = read_data(query_operational_data_100)
operational_data_120 = read_data(query_operational_data_120)


if configuration_to_predict ~= 1
  [operational_data_60_cleaned, ~] = clear_outliers (operational_data_60);
  operational_data = [query_operational_data ; operational_data_60_cleaned]
endif

if configuration_to_predict ~= 2
  [operational_data_80_cleaned, ~] = clear_outliers (operational_data_80);
  operational_data = [query_operational_data ; operational_data_80_cleaned]
endif

if configuration_to_predict ~= 3
  [operational_data_100_cleaned, ~] = clear_outliers (operational_data_100);
  operational_data = [query_operational_data ; operational_data_100_cleaned]
endif

if configuration_to_predict ~= 4
  [operational_data_120_cleaned, ~] = clear_outliers (operational_data_120);
  operational_data = [query_operational_data ; operational_data_120_cleaned]
endif

operational_data_chunks = collectSamples (operational_data, iterations);

%%
for ii = 1: length(operational_data_chunks)
  current_chunk = operational_data_chunks{ii};
  current_chunk_linear = current_chunk;
  current_chunk_linear(:, end) = 1 ./ current_chunk_linear(:, end);


  %% updating the knowledge base [current_KB] 
  %% and [current_KB_linear] with the operational sample
  %% for the current iteration
  %% Use here the preferred update function among the available ones (merge or RNN).
  [current_KB, current_weight] = updateKB_RNN(current_KB, current_chunk, weight, oper_weight_value);
  [current_KB_linear, current_weight_linear] = updateKB_RNN (current_KB_linear, current_chunk_linear, weight_linear, oper_weight_value);

  %% re-train the machine learner with the updated
  %% knowlege base. 
  %% At the end, improvement for different runs

  %% Separating prediction variables from target variable in the analytical dataset
  y = current_KB(:, 1);
  X = current_KB(:, 2:end);
  weight = current_weight;

  
  y_linear = current_KB_linear(:, 1);
  X_linear = current_KB_linear(:, 2:end);
  weight_linear = current_weight_linear;
  
  %% Splitting the analytical datasets and weights accordingly
  [ytr, ytst, ~] = split_sample (y, train_frac, test_frac);
  [Xtr, Xtst, ~] = split_sample (X, train_frac, test_frac);
  [Wtr, Wtst, ~] = split_sample (weight, train_frac, test_frac);
  [ytr_linear, ytst_linear, ~] = split_sample (y_linear, train_frac, test_frac);
  [Xtr_linear, Xtst_linear, ~] = split_sample (X_linear, train_frac, test_frac);
  [Wtr_linear, Wtst_linear, ~] = split_sample (weight_linear, train_frac, test_frac);

  %% White box model, linear^(-1)
  sprintf("Re-training (%d) the SVR from on analytical model (linear).", ii)
  [C, eps] = modelSelection (Wtr_linear, ytr_linear, Xtr_linear, ytst_linear, Xtst_linear, "-s 3 -t 0 -q -h 0", C_range, E_range);
  options = ["-s 3 -t 0 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
  model_linear = svmtrain (Wtr_linear, ytr_linear, Xtr_linear, options);
  [predictions_linear{ii+1}, accuracy_linear, ~] = svmpredict (ycv_linear, Xcv_linear, model_linear);
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
  [predictions{ii+1}, accuracy, ~] = svmpredict (ycv, Xcv, model);
  Cs(ii+1) = C;
  Es(ii+1) = eps;
  MSE(ii+1)=accuracy(2);
  RMSEs(ii+1) = sqrt (accuracy(2));
  coefficients{ii+1} = model.sv_coef;
  SVs{ii+1} = model.SVs;
  b{ii+1} = - model.rho;

  
endfor

%% Call save plots when model is done from the command line using the command below
%%save_plots(model, model_linear, RMSEs, RMSEs_linear, MSE, MSE_linear,iterations)


