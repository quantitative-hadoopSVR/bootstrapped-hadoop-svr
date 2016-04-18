function [clean_sample, clean_sample_nCores]  = collectSamples (directory, nSlots, timestep)

if (! ischar (directory))
  error ("read_from_directory: DIRECTORY should be a string");
endif

files = glob ([directory, "/*.csv"]);

sample = [];

for ii = 1:numel (files)
  file = files{ii};
  last_sample = read_data (file);
  last_sample;
  %% here we assume that each operational file has the same 
  %% number or rows ( which basically means that each 
  %% real experiment is performed sampling the same
  %% number of observations.
  window_size = size (last_sample)(1) ./ nSlots;
  %current_sample = last_sample [window_size .* (timestep - 1) : window_size .* (timestep), :]
  %%the first index is what you have taken the iteration be
  %%for the very first iteration you need to take index 1
  current_sample = last_sample ([window_size .* (timestep - 1) + 1 : window_size .* (timestep)], :);
  current_sample;
  sample = [sample; current_sample];
endfor

[clean_sample, indices] = clear_outliers (sample);

clean_sample_nCores = clean_sample;
clean_sample_nCores(:, end) = 1 ./ clean_sample_nCores(:, end);

endfunction