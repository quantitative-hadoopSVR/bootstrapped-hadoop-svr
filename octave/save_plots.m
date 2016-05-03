function save_plots(model, model_linear, RMSEs, RMSEs_linear, MSE, MSE_linear,iterations)
%% save plots

path = "../plots/";

h1=plot(MSE_linear);
title("Mean Square Error for each iteration, Linear Model");
xlabel ("Iterations");
ylabel ("MSE");
saveas(h1,[path,"MSE_linear_",num2str(iterations),"_iterations.jpg"]);

h2=plot(MSE);
title("Mean Square Error for each iteration, Kernel Model");
xlabel ("Iterations");
ylabel ("MSE");
saveas(h2,[path,"MSE_Kernel_",num2str(iterations),"_iterations.jpg"]);

h3=plot(RMSEs_linear);
title("Root Mean Square Error for each iteration, Linear Model");
xlabel ("Iterations");
ylabel ("RMSE");
saveas(h3,[path,"RMSEs_linear_",num2str(iterations),"_iterations.jpg"]);

h4=plot(RMSEs);
title("Root Mean Square Error for each iteration, Kernel Model");
xlabel ("Iterations");
ylabel ("RMSE");
saveas(h4,[path,"RMSEs_Kernel_",num2str(iterations),"_iterations.jpg"]);



%saveas(plot(model.SVs),[path,"SupportVectors_Kernel.jpg"]);
%saveas(plot(model_linear.SVs),[path,"SupportVectors_Linear.jpg"]);

endfunction
