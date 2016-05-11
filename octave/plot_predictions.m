function save_plots(query, sszie, model, missing_configuration, iteration, predictions, expected)
%% save plots

filepath = ["../plots/" query "/" sszie "/" model "/missing_" missing_configuration "/prediction_" iteration ".csv"]

%h1=plot(predictions);
%title([query "/" sszie "/" model "/" missing_configuration "/prediction_" iteration]);
%xlabel ("Configuration");
%ylabel ("Predicted value");
%saveas(h1,filepath);

csvwrite(filepath, [predictions expected.']);

endfunction