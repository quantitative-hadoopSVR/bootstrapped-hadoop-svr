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

%% Separating prediction variables from target variable in the analytical dataset get first column in y and second in X. 
y = analytical_shuffled(:, 1);
X= analytical_shuffled(:, 2:end);

%% Assign weights 1 for the first iteration
weight=ones(size(analytical_shuffled,1),1) * 1;

%% Splitting the analytical datasets
[ytr, ytst, ycv] = split_sample (y, train_frac, test_frac);
[Xtr, Xtst, Xcv] = split_sample (X, train_frac, test_frac);
[Wtr, Wtst, Wcv] = split_sample (weight, train_frac, test_frac);


%% RBF kernel model, where you choose best parameters first and then train the model
sprintf("Training the SVR from on analytical model.Black box model, RBF with best parameters with crossvalidation")
[bestcv,bestc,bestg]=parameter_selection (ytr,Xtr,Wtr);
options = ["-s 3 -t 2 -h 0 -g ", num2str(bestg), " -c ", num2str(bestc)];
model_CV = svmtrain (Wtr,ytr, Xtr, options);
[predictions_CV{1}, accuracy_CV, ~] = svmpredict (ycv, Xcv, model_CV);
Cs_CV(1) = bestc;
RMSE_CVs(1) = sqrt (accuracy_CV(2));
MSE_CV(1)=accuracy_CV(2);
coefficients_CV{1} = model_CV.sv_coef;
SVs_CV{1} = model_CV.SVs;

% calculate w and b
w_CV{1} = model_CV.SVs' * model_CV.sv_coef;
b_CV{1} = -model_CV.rho;

current_KB = analytical_shuffled;
operational_data_chunks = collectSamples ([base_dir, query_operational_data], iterations);

%%
for ii = 1: length(operational_data_chunks)
  current_chunk = operational_data_chunks{ii};

  mu_y = mu(1);
  sigma_ = sigma(1);
  mu_X = mu(2:end);
  sigma_X = sigma(2:end);
 
  %% TODO: updating the knowledge base [current_KB] 
  %% and [current_KB_linear] with the operational sample
  %% for the current iteration
  %% Use here the preferred update function among the available ones (merge or RNN).
  [current_KB, current_weight] = updateKB_RNN(current_KB, current_chunk, weight);
 
  %% TODO: re-train the machine learner with the updated
  %% knowlege base. 
  %% At the end, improvement for different runs
 

  %% Separating prediction variables from target variable in the analytical dataset
  y = current_KB(:, 1);
  X = current_KB(:, 2:end);
  weight = current_weight;

  
  %% Splitting the analytical datasets and weights accordingly
  [ytr, ytst, ycv] = split_sample (y, train_frac, test_frac);
  [Xtr, Xtst, Xcv] = split_sample (X, train_frac, test_frac);
  [Wtr, Wtst, Wcv] = split_sample (weight, train_frac, test_frac);


  %% RBF kernel model, where you choose best parameters first and then train the model
sprintf("Re-Training the SVR from on analytical model.Black box model, RBF with best parameters with crossvalidation",ii)
[bestcv,bestc,bestg]=parameter_selection (ytr,Xtr,Wtr);
options = ["-s 3 -t 2 -h 0 -g ", num2str(bestg), " -c ", num2str(bestc)];
model_CV = svmtrain (Wtr,ytr, Xtr, options);
[predictions_CV{1}, accuracy_CV, ~] = svmpredict (ycv, Xcv, model_CV);
Cs_CV(ii+1) = bestc;
RMSE_CVs(ii+1) = sqrt (accuracy_CV(2));
MSE_CV(ii+1)=accuracy_CV(2);
coefficients_CV{ii+1} = model_CV.sv_coef;
SVs_CV{ii+1} = model_CV.SVs;
% calculate w and b
w_CV{ii+1} = model_CV.SVs' * model_CV.sv_coef;
b_CV{ii+1} = -model_CV.rho;
  
endfor

%%save the plots. run the below function for that

%%save_plots_CV(model_CV, RMSE_CVs, MSE_CV, iterations);
