function [clean_sample, clean_sample_nCores]  = initKB (file)

last_sample = read_data (file);

[clean_sample, indices] = clear_outliers (last_sample);

clean_sample_nCores = clean_sample;
clean_sample_nCores(:, end) = 1 ./ clean_sample_nCores(:, end);

endfunction
