function save_plots_CV(model_CV, RMSEs_CVs, MSE_CV, iterations)
%% save plots

path = "../plots/";

h1=plot(MSE_CV);
title("Mean Square Error for each iteration, Kernel Model with parameters selected with crossvalidation");
xlabel ("Iterations");
ylabel ("MSE");
saveas(h1,[path,"MSE_Kernel_CV_",num2str(iterations),"_iterations.jpg"]);

h2=plot(RMSEs_CVs);
title("Root Mean Square Error for each iteration, Kernel Model with parameters selected with crossvalidation");
xlabel ("Iterations");
ylabel ("RMSE");
saveas(h2,[path,"RMSEs_kernel_CV_",num2str(iterations),"_iterations.jpg"]);



%saveas(plot(model.SVs),[path,"SupportVectors_Kernel.jpg"]);
%saveas(plot(model_linear.SVs),[path,"SupportVectors_Linear.jpg"]);

endfunction
