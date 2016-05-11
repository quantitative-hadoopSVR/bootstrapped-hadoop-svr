function save_plots(query, sszie, model, missing_configuration, iteration, predictions, expected,added_sample)
%% save plots

x = [60, 80, 100, 120];
if (added_sample==0)
  filepath = ["../plots/" query "/" sszie "/" model "/missing_" missing_configuration "/PredictionExpectedValues_" iteration ".jpg"]
  h1 = plot(x,predictions,x,expected);
  title([query "/" sszie "/" model "/missing " missing_configuration "/Prediction and Expected Values " iteration]);
  legend ("Predicted Value","Expected Value");
else
  filepath = ["../plots/" query "/" sszie "/" model "/missing_" missing_configuration "/PredictionExpectedAddedValues_" iteration ".jpg"]
  h1 = plot(x, predictions, '-', x, expected, '-', added_sample(:,2), added_sample(:,1), 'x');
  title([query "/" sszie "/" model "/missing " missing_configuration "/Prediction Expected and Added Values " iteration]);
  legend ("Predicted Value","Expected Value","Added Value");
endif

h1=figure(1);
xlabel ("Configuration of Cores");
ylabel ("Response Time");
set(gca, 'XTick', x); % Change x-axis ticks
print(1,filepath);

%%Uncomment here if you want to produce the csv files
%csvwrite(filepath, [predictions expected.']);
endfunction