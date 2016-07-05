% This function clears the dirty input from outliers
%
% It removes all the points whose distances from the average value of the input 
% are more than two times of the standard deviation of the input

function [clean, indices] = clear_outliers (dirty)

avg = mean (dirty);
dev = std (dirty);

cols = size (dirty, 2);
clean = dirty;
indices = 1:size (dirty, 1)';
for (jj = 1:cols)
  if (dev(jj) > 0)
    idx = (abs (clean(:, jj) - avg(jj)) < 2 * dev(jj));
    clean = clean(idx, :);
    indices = indices(idx);
  endif
endfor

endfunction
