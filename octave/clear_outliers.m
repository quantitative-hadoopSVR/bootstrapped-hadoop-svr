function [clean, indices] = clear_outliers (dirty)

avg = mean (dirty);
dev = std (dirty);

cols = size (dirty, 2);
clean = dirty;
indices = 1:size (dirty, 1)';
for (jj = 1:cols)
  if (dev(jj) > 0)
    idx = (abs (clean(:, jj) - avg(jj)) < 3 * dev(jj));
    clean = clean(idx, :);
    indices = indices(idx);
  endif
endfor

endfunction
