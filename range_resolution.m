
% Bandwidth vs Range Resolution Plot to compare among other available
% radars

c = 3e8;  


bandwidths = linspace(0.2e9, 3e9, 300);  % 0.2 GHz to 3 GHz
range_resolution = c ./ (2 .* bandwidths);

% Plot
figure;
plot(bandwidths/1e9, range_resolution*100, 'm-', 'LineWidth', 2);  % cm
hold on;

% Add horizontal markers
yline(60, '--g', 'Narrowband Radar (~60 cm, 250 MHz )', 'LineWidth', 1.5, 'LabelHorizontalAlignment','left', 'FontSize',10);
yline(15, '--p', 'Automotive FMCW Radar (~15 cm, 1 GHz)', 'LineWidth', 1.5, 'LabelHorizontalAlignment','left', 'FontSize',10);
yline(7.5, '--r', 'Your UWB Radar (~7.5 cm, 2GHz)', 'LineWidth', 1.5, 'LabelHorizontalAlignment','left', 'FontSize',10);

% Enhancements
xlabel('Bandwidth (GHz)', 'FontSize', 12);
ylabel('Range Resolution (cm)', 'FontSize', 12);
title('Effect of Bandwidth on Range Resolution', 'FontSize', 14);
grid on;
xlim([0.2 3]);
ylim([0 70]);
set(gca, 'FontSize', 12);

