function [C, epsilon] = modelSelection (ytrain, Xtrain, ytest, Xtest, options, C_range, epsilon_range)

raw_options = options;
C_range = C_range(:)';
epsilon_range = epsilon_range(:)';

C = Inf;
epsilon = Inf;
MSE = Inf;
for (cc = C_range)
  for (ee = epsilon_range)
    options = [raw_options, " -p ", num2str(ee), " -c ", num2str(cc)];
    model = svmtrain (ytrain, Xtrain, options);
    [~, accuracy, ~] = svmpredict (ytest, Xtest, model, "-q");
    mse = accuracy(2);
    if (mse < MSE)
      C = cc;
      epsilon = ee;
      MSE = mse;
    endif
  endfor
endfor

endfunction