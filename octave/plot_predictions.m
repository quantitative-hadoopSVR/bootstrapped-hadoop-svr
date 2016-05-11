function save_plots(query, sszie, model, missing_configuration, iteration, predictions, expected)
%% save plots

filepath = ["../plots/" query "/" sszie "/" model "/missing_" missing_configuration "/prediction_accuracy_" iteration ".jpg"]

x = [1:4];
h1=plot(x,predictions,x,expected);
h1=figure(1);
title([query "/" sszie "/" model "/" missing_configuration "/prediction_" iteration]);
xlabel ("Configuration");
ylabel ("Predicted value");
print(1,filepath, "-landscape");

%csvwrite(filepath, [predictions expected.']);

endfunction