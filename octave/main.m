clear all
close all hidden
clc

%% Parameters
query = "";
base_dir = "/Users/michele/MATLAB/bootstrapped-hadoop-svr/source_data/";

train_frac = 0.6;
test_frac = 0.2;

%% Read and clean stuff
sample = read_from_directory ([base_dir, query]);

[clean_sample, indices] = clear_outliers (sample);

clean_sample_nCores = clean_sample;
clean_sample_nCores(:, end) = 1 ./ clean_sample_nCores(:, end);

rand ("seed", 17);
permutation = randperm (size (clean_sample, 1));

[scaled, mu, sigma] = zscore (clean_sample);
shuffled = scaled(permutation, :);

y = shuffled(:, 1);
X= shuffled(:, 2:end);

mu_y = mu(1);
sigma_ = sigma(1);
mu_X = mu(2:end);
sigma_X = sigma(2:end);

[scaled_nCores, mu, sigma] = zscore (clean_sample_nCores);
shuffled_nCores = scaled_nCores(permutation, :);

y_nCores = shuffled_nCores(:, 1);
X_nCores = shuffled_nCores(:, 2:end);

mu_X_nCores = mu(2:end);
sigma_X_nCores = sigma(2:end);

[ytr, ytst, ycv] = split_sample (y, train_frac, test_frac);
[Xtr, Xtst, Xcv] = split_sample (X, train_frac, test_frac);
[ytr_nCores, ytst_nCores, ycv_nCores] = split_sample (y_nCores, train_frac, test_frac);
[Xtr_nCores, Xtst_nCores, Xcv_nCores] = split_sample (X_nCores, train_frac, test_frac);


