function [clean_sample, clean_sample_nCores]  = initKB (directory)

if (! ischar (directory))
  error ("read_from_directory: DIRECTORY should be a string");
endif

files = glob ([directory, "/*.csv"]);

sample = [];

for ii = 1:numel (files)
  file = files{ii};
  last_sample = read_data (file);
  sample = [sample; last_sample];
endfor

[clean_sample, indices] = clear_outliers (sample);

clean_sample_nCores = clean_sample;
clean_sample_nCores(:, end) = 1 ./ clean_sample_nCores(:, end);

endfunction
