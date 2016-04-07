function [training, testing, cv] = split_sample (sample, train, test)

if (train + test > 1)
  error ("split_sample: wrong fractions");
endif

m = size (sample, 1);
m_train = round (m * train);
m_test = round (m * (test + train));
idx_train = 1:m_train;
idx_test = m_train+1:m_test;
idx_cv = m_test+1:m;

training = sample(idx_train, :);
testing = sample(idx_test, :);
cv = sample(idx_cv, :);

endfunction
