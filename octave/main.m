clear all
close all hidden
clc

%% Input data parameters
query = "analyt";
base_dir = "/Users/michele/MATLAB/bootstrapped-hadoop-svr/source_data/";

% Splitting parameters
train_frac = 0.6;
test_frac = 0.2;

% Number of iterations for the re-training after the bootstrapping
iterations = 10;

%% Initializing the Knowledge Base
[sample, sample_nCore] = initKB ([base_dir, query]);

% Scaling and permutating the dataset
rand ("seed", 17);
permutation = randperm (size (sample, 1));

[scaled, mu, sigma] = zscore (sample);
shuffled = scaled(permutation, :);

mu_y = mu(1);
sigma_ = sigma(1);
mu_X = mu(2:end);
sigma_X = sigma(2:end);

[scaled_nCores, mu, sigma] = zscore (sample_nCore);
shuffled_nCores = scaled_nCores(permutation, :);

mu_X_nCores = mu(2:end);
sigma_X_nCores = sigma(2:end);

% Separating prediction variables from target variable
y = shuffled(:, 1);
X= shuffled(:, 2:end);

y_nCores = shuffled_nCores(:, 1);
X_nCores = shuffled_nCores(:, 2:end);

% Splitting the datasets
[ytr, ytst, ycv] = split_sample (y, train_frac, test_frac);
[Xtr, Xtst, Xcv] = split_sample (X, train_frac, test_frac);
[ytr_nCores, ytst_nCores, ycv_nCores] = split_sample (y_nCores, train_frac, test_frac);
[Xtr_nCores, Xtst_nCores, Xcv_nCores] = split_sample (X_nCores, train_frac, test_frac);


