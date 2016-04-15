clear all
close all hidden
clc

%% Input data parameters: path to folder containing 
%% the analytical data and to folder containing 
%% the operational data.
query_analytical_data = "analyt";
query_operational_data = "oper";
base_dir = "/home/irma/quantitative/bootstrapped-hadoop-svr/source_data/";

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
%% knowlege base. Built using linear kernel for "_nCores" dataset
%% and using RBF kernel for full featured datasets 
%% ( even if right now we don't have this distinction, let's
%% keep it for possible future use and for applying both
%% the techniques in any case (it still makes sense to compare 
%% linear and RBF kernels, if possible (single attribute) ).
%% Anyway according to the LIBSVM guide, since in our case 
%% the number of instances is much higher than the number of
%% features, we should expect to get better accuracy using the RBF kernel.
%% No need to try the polynomial kernel, according to the LIBSVM guide.

%% White box model, nCores^(-1)
[C, eps] = modelSelection (ytr_nCores, Xtr_nCores, ytst_nCores, Xtst_nCores, "-s 3 -t 0 -q -h 0", C_range, E_range);
options = ["-s 3 -t 0 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
model = svmtrain (ytr_nCores, Xtr_nCores, options);
[predictions(:, 2), accuracy, ~] = svmpredict (ycv_nCores, Xcv_nCores, model);
Cs(2) = C;
Es(2) = eps;
RMSEs(2) = sqrt (accuracy(2));
coefficients{2} = model.sv_coef;
SVs{2} = model.SVs;
b{2} = - model.rho;

%% Black box model, RBF
[C, eps] = modelSelection (ytr, Xtr, ytst, Xtst, "-s 3 -t 2 -q -h 0", C_range, E_range);
options = ["-s 3 -t 2 -h 0 -p ", num2str(eps), " -c ", num2str(C)];
model = svmtrain (ytr, Xtr, options);
[predictions(:, 4), accuracy, ~] = svmpredict (ycv, Xcv, model);
Cs(4) = C;
Es(4) = eps;
RMSEs(4) = sqrt (accuracy(2));
coefficients{4} = model.sv_coef;
SVs{4} = model.SVs;
b{4} = - model.rho;

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
  %% At the end, improvement for different runs
  
endfor
