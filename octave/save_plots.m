function save_plots(model, model_linear, RMSEs, RMSEs_linear, MSE, MSE_linear)
%% save plots

path = "../plots/";
saveas(plot(RMSEs),[path,"RMSEs_Kernel.jpg"]);
saveas(plot(MSE),[path,"MSE_Kernel.jpg"]);
saveas(plot(model.SVs),[path,"SupportVectors_Kernel.jpg"]);
saveas(plot(RMSEs_linear),[path,"RMSEs_linear.jpg"]);
saveas(plot(MSE_linear),[path,"MSE_linear.jpg"]);
saveas(plot(model_linear.SVs),[path,"SupportVectors_Linear.jpg"]);

endfunction
