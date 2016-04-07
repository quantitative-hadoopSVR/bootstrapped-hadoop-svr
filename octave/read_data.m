function sample = read_data (filename)

if (! ischar (filename))
  error ("read_data: FILENAME should be a string");
endif

sample = csvread (filename, 1, 0);

endfunction
