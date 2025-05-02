% UWB (Gaussian Monocycle) vs Narrowband Pulse Comparison


t = linspace(-2e-9, 2e-9, 2000);  % -2 ns to 2 ns

% --- UWB Pulse (Gaussian Monocycle) ---
fc_uwb = 6.5e9;  % UWB Center frequency 6.5 GHz
tau = 1/(2*pi*fc_uwb);
% tau = 2e-9

gauss_pulse = exp(-(t / tau).^2);
gauss_mono = -2*(t / tau^2) .* gauss_pulse;
gauss_mono = gauss_mono / max(abs(gauss_mono));  % Normalize

% --- Narrowband Pulse ---
fc_nb = 2e9;  % Narrowband center frequency 2 GHz
nb_pulse = sin(2*pi*fc_nb*t) .* (abs(t) < 0.8e-9);  % Gated Sine pulse - short burst


figure;
plot(t*1e9, gauss_mono, 'b-', 'LineWidth', 2); hold on;
plot(t*1e9, nb_pulse, 'r--', 'LineWidth', 2);

xlabel('Time (ns)', 'FontSize', 12);
ylabel('Normalized Amplitude', 'FontSize', 12);
legend('UWB Pulse (Gaussian Monocycle)', 'Narrowband Pulse (Sine Burst)', 'Location', 'northeast');
title('Comparison of UWB and Narrowband Radar Pulses', 'FontSize', 14);
grid on;
xlim([-2 2]);
ylim([-1.5 1.5]);
set(gca, 'FontSize', 12);
