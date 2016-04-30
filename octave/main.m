clear all
close all hidden
clc
warning("off")

%% Input data parameters: path to folder containing 
%% the analytical data and to folder containing 
%% the operational data.
query_analytical_data = "analyt/dataAM.csv";
query_operational_data = "oper/dataOper.csv";
base_dir = "../source_data/";

%% Splitting parameters
train_frac = 0.6;
test_frac = 0.2;


%% Ranges to be used to the identification
%% of the optimal "C" and "epsilon" parameter of the SVR
%% when using epsilon-SVR ( the SVR type used by Eugenio.
%% we could investigate if it makes sense to try nu-SVR too ).
C_range = linspace (0.1, 5, 20);
E_range = linspace (0.1, 5, 20);

%% Number of iterations for the re-training after the bootstrapping
iterations = 10;

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
weight=ones(size(analytical_shuffled,1),1) * 1;
weight_linear=ones(size(analytical_shuffled_linear,1),1) * 1;

%% Splitting the analytical datasets
[ytr, ytst, ycv] = split_sample (y, train_frac, test_frac);
[Xtr, Xtst, Xcv] = split_sample (X, train_frac, test_frac);
[Wtr, Wtst, Wcv] = split_sample (weight, train_frac, test_frac);
[ytr_linear, ytst_linear, ycv_linear] = split_sample (y_linear, train_frac, test_frac);
[Xtr_linear, Xtst_linear, Xcv_linear] = split_sample (X_linear, train_frac, test_frac);
[Wtr_linear, Wtst_linear, Wcv_linear] = split_sample (weight_linear, train_frac, test_frac);

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
model = svmtrain (Wtr_linear, ytr_linear, Xtr_linear, options);
[predictions_linear{1}, accuracy, ~] = svmpredict (ycv_linear, Xcv_linear, model);
Cs_linear(1) = C;
Es_linear(1) = eps;
RMSEs_linear(1) = sqrt (accuracy(2));
MSE_linear(1)=accuracy(2);
coefficients_linear{1} = model.sv_coef;
SVs_linear{1} = model.SVs;
b_linear{1} = - model.rho;


%% RBF kernel model
sprintf("Training the SVR from on analytical model.")
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


#{
%% RBF kernel model, where you choose best parameters first and then train the model
sprintf("Training the SVR from on analytical model.Black box model, RBF with best parameters")
[bestcv,bestc,bestg]=parameter_selection (ytr,Xtr);
options = ["-s 3 -t 2 -h 0 -g ", num2str(bestg), " -c ", num2str(bestc), " -v ", num2str(bestcv)];
model_CV = svmtrain ([],ytr, Xtr, options);
[predictions_CV{1}, accuracy_CV, ~] = svmpredict (ycv, Xcv, model);
Cs_CV(1) = bestc;
Es_CV(1) = model.epsilon;
RMSE_CVs(1) = sqrt (accuracy_CV(2));
MSE_CV(1)=accuracy_CV(2);
coefficients_CV{1} = model.sv_coef;
SVs_CV{1} = model.SVs;
b_CV{1} = - model.rho;
#}


current_KB = analytical_shuffled
current_KB_linear = analytical_shuffled_linear

operational_data_chunks = collectSamples ([base_dir, query_operational_data], iterations);

%%
for ii = 1: length(operational_data_chunks)
  current_chunk = operational_data_chunks{ii};
  current_chunk_linear = current_chunk;
  current_chunk_linear(:, end) = 1 ./ current_chunk_linear(:, end);

  %% Scaling and permutating the operational dataset 
  %% for the current iteration
  rand ("seed", 17);
  permutation = randperm (size (current_chunk, 1));

  [current_chunk_scaled, mu, sigma] = zscore (current_chunk);
  current_chunk_shuffled = current_chunk_scaled(permutation, :);

  mu_y = mu(1);
  sigma_ = sigma(1);
  mu_X = mu(2:end);
  sigma_X = sigma(2:end);

  [current_chunk_linear_scaled, mu, sigma] = zscore (current_chunk_linear);
  current_chunk_linear_shuffled = current_chunk_linear_scaled(permutation, :);
  
  %% TODO: updating the knowledge base [current_KB] 
  %% and [current_KB_linear] with the operational sample
  %% for the current iteration
  %% Use here the preferred update function among the available ones (merge or RNN).
  [current_KB, current_weight] = updateKB_RNN(current_KB, current_chunk_shuffled, weight);
  [current_KB_linear, current_weight_linear] = updateKB_RNN (current_KB_linear, current_chunk_linear_shuffled, weight_linear);

  current_KB
  current_KB_linear
  %% TODO: re-train the machine learner with the updated
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
  [ytr, ytst, ycv] = split_sample (y, train_frac, test_frac);
  [Xtr, Xtst, Xcv] = split_sample (X, train_frac, test_frac);
  [Wtr, Wtst, Wcv] = split_sample (weight, train_frac, test_frac);
  [ytr_linear, ytst_linear, ycv_linear] = split_sample (y_linear, train_frac, test_frac);
  [Xtr_linear, Xtst_linear, Xcv_linear] = split_sample (X_linear, train_frac, test_frac);
  [Wtr_linear, Wtst_linear, Wcv_linear] = split_sample (weight_linear, train_frac, test_frac);

  %% White box model, linear^(-1)
  sprintf("Re-training (%d) the SVR from on analytical model (linear).", ii)
  [C, eps] = modelSelection (Wtr_linear, ytr_linear, Xtr_linear, ytst_linear, Xtst_linear, "-s 3 -t 0 -q -h 0", C_range, E_range);
  options = ["-s 3 -t 0 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
  model = svmtrain (Wtr_linear, ytr_linear, Xtr_linear, options);
  [predictions_linear{ii+1}, accuracy, ~] = svmpredict (ycv_linear, Xcv_linear, model);
  Cs_linear(ii+1) = C;
  Es_linear(ii+1) = eps;
  MSE_linear(ii+1)=accuracy(2);
  RMSEs_linear(ii+1) = sqrt (accuracy(2));
  coefficients_linear{ii+1} = model.sv_coef;
  SVs_linear{ii+1} = model.SVs;
  b_linear{ii+1} = - model.rho;



  %% Black box model, RBF
  sprintf("Re-training (%d) the SVR from on analytical model.", ii)
  [C, eps] = modelSelection (Wtr, ytr, Xtr, ytst, Xtst, "-s 3 -t 2 -q -h 0", C_range, E_range);
  options = ["-s 3 -t 2 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
  model = svmtrain (Wtr, ytr, Xtr, options);
  [predictions{ii+1}, accuracy, ~] = svmpredict (ycv, Xcv, model);
  [predictions{ii+1}, accuracy, ~] = svmpredict (ycv, Xcv, model);
  Cs(ii+1) = C;
  Es(ii+1) = eps;
  MSE(ii+1)=accuracy(2);
  RMSEs(ii+1) = sqrt (accuracy(2));
  coefficients{ii+1} = model.sv_coef;
  SVs{ii+1} = model.SVs;
  b{ii+1} = - model.rho;

  
endfor
%check output meaning
  model.totalSV;
  model.nSV;
  %plot(model.SVs);
  %plot(model.SVs_linear);
  %plot(model.SVR);

