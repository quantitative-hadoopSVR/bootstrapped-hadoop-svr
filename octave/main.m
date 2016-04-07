clear all
close all hidden
clc

%% Input data parameters: path to folder containing 
%% the analytical data and to folder containing 
%% the operational data.
query_analytical_data = "analyt";
query_operational_data = "oper";
base_dir = "/Users/michele/MATLAB/bootstrapped-hadoop-svr/source_data/";

% Splitting parameters
train_frac = 0.6;
test_frac = 0.2;

%% Number of iterations for the re-training after the bootstrapping
iterations = 1;

%% Initializing the Knowledge Base sampling the analytical data
[analytical_sample, analytical_sample_nCore] = initKB ([base_dir, query_analytical_data]);

%% Scaling and permutating the analytical dataset
rand ("seed", 17);
permutation = randperm (size (analytical_sample, 1));

[analytical_scaled, mu, sigma] = zscore (analytical_sample);
analytical_shuffled = analytical_scaled(permutation, :);

mu_y = mu(1);
sigma_ = sigma(1);
mu_X = mu(2:end);
sigma_X = sigma(2:end);

[analytical_scaled_nCores, mu, sigma] = zscore (analytical_sample_nCore);
analytical_shuffled_nCores = analytical_scaled_nCores(permutation, :);

mu_X_nCores = mu(2:end);
sigma_X_nCores = sigma(2:end);

%% Separating prediction variables from target variable in the analytical dataser
y = analytical_shuffled(:, 1);
X= analytical_shuffled(:, 2:end);

y_nCores = analytical_shuffled_nCores(:, 1);
X_nCores = analytical_shuffled_nCores(:, 2:end);

%% Splitting the analytical datasets
[ytr, ytst, ycv] = split_sample (y, train_frac, test_frac);
[Xtr, Xtst, Xcv] = split_sample (X, train_frac, test_frac);
[ytr_nCores, ytst_nCores, ycv_nCores] = split_sample (y_nCores, train_frac, test_frac);
[Xtr_nCores, Xtst_nCores, Xcv_nCores] = split_sample (X_nCores, train_frac, test_frac);

%% TODO: train the machine learner with the obtainted
%% knowlege base.

%%
for ii = 1: iterations
  
  %% sampling the operational data for the current iteration.
  [operational_sample, operational_sample_nCore] = collectSamples ([base_dir, query_operational_data], iterations, ii)
  
  %% Scaling and permutating the operational dataset 
  %% for the current iteration
  rand ("seed", 17);
  permutation = randperm (size (operational_sample, 1));

  [operational_scaled, mu, sigma] = zscore (operational_sample);
  operational_shuffled = operational_scaled(permutation, :);

  mu_y = mu(1);
  sigma_ = sigma(1);
  mu_X = mu(2:end);
  sigma_X = sigma(2:end);

  [operational_scaled_nCores, mu, sigma] = zscore (operational_sample_nCore);
  operational_shuffled_nCores = operational_scaled_nCores(permutation, :);
  
  %% TODO: updating the knowledge base [analytical_shuffled] 
  %% and [analytical_shuffled_nCore] with the operational sample
  %% for the current iteration
  
  %% TODO: re-train the machine learner with the updated
  %% knowlege base. 
  
  %% TODO: evaluate ( generate also some plots ) the current accuracy 
  %% of the machine learner
endfor

