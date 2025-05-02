% Constants
c = 3e8;                        % Speed of light [m/s]
fc = 6.5e9;                     % Center frequency [Hz]
BW = 2e9;                       % Bandwidth [Hz]
Fs = 40e9;                      % Sampling frequency [Hz]
Ts = 1/Fs;

% Target range
R_target = 5;                  % meters
tau = 2*R_target / c;          % round-trip delay
N_delay = round(tau / Ts);

% Time axis
N_total = 2000;
t = (0:N_total-1)*Ts;

% Gaussian Monocycle (no modulation)
Tp = 2e-9;                      % Pulse duration
sigma = Tp/2.5;
tp = (-100:100)*Ts;
g = -((tp)/sigma.^2).*exp(-(tp).^2/(2*sigma.^2));
g = g / max(abs(g));

% Create received signal with delay + noise
rx_signal = zeros(1, N_total);
rx_signal(N_delay+1:N_delay+length(g)) = g;
rx_signal = rx_signal + 0.2*randn(1, N_total);  % AWGN

% Apply Bandpass Filter (realistic UWB front-end effect)
bpFilt = designfilt('bandpassfir', ...
    'FilterOrder', 200, ...
    'CutoffFrequency1', 5.75e9, ...
    'CutoffFrequency2', 7.0e9, ...
    'SampleRate', Fs);
rx_signal_filtered = filter(bpFilt, rx_signal);

% Matched Filter
mf = fliplr(g);
matched_output = conv(rx_signal, mf, 'same');
matched_output2 = conv(rx_signal_filtered, mf, 'same');

% Estimate delay and range
[~, peak_idx] = max(matched_output);
tau_est = (peak_idx - 1) * Ts;
R_est = tau_est * c / 2;

% Plot
figure;

plot(tp*1e9, g);
title('Transmitted Gaussian Monocycle');
xlabel('Time [ns]'); ylabel('Amplitude');



figure;
plot(t*1e9, rx_signal);
title('Received Signal Before Bandpass Filtering');
xlabel('Time [ns]'); ylabel('Amplitude');

figure;
plot(t*1e9, matched_output);
hold on;
plot(t(peak_idx)*1e9, matched_output(peak_idx), 'ro');
title(['Matched Filter Output — Estimated Range: ' num2str(R_est, '%.2f') ' m']);
xlabel('Time [ns]'); ylabel('Amplitude');


