

M = csvread('build/input/spy_options.csv', 1);
M([6, 18],:) = [];
L = M(:,1);
r = M(:,2) * 100;

scatter(L, r, 'MarkerFaceColor', 'blue');
set(gcf, 'Color', 'w')
xlabel("$L = \frac{assets}{equity}$",...
    'interpreter', 'latex', 'FontWeight', 'bold', 'fontsize', 14)
ylabel("$r$", 'interpreter', 'latex', 'FontWeight', 'bold', 'fontsize', 14)
saveas(gcf, 'docs/spy_option_rates.eps', 'epsc')