clc; clear all; close all;

% load sensor data
load('sensor_data.mat')

% 1) Histograms
figure('Name', 'Histograms');
sensors     = {acc_data, gyr_data, mag_data};
names       = {'Accelerometer (m/s²)', 'Gyroscope (rad/s)', 'Magnetometer (µT)'};
axes_labels = {'X', 'Y', 'Z'};

for s = 1:3
    for ax = 1:3
        subplot(3, 3, (s-1)*3 + ax);
        histogram(sensors{s}(:, ax), 50);
        xlabel(axes_labels{ax});
        title(sprintf('%s — %s', names{s}, axes_labels{ax}));
        hold on;
        % Overlay normal distribution fit in red
        mu        = mean(sensors{s}(:, ax));
        sig       = std(sensors{s}(:, ax));
        x_fit     = linspace(mu - 4*sig, mu + 4*sig, 100);
        n         = numel(sensors{s}(:, ax));
        bin_width = range(sensors{s}(:, ax)) / 50;
        plot(x_fit, n * bin_width * normpdf(x_fit, mu, sig), 'r-', 'LineWidth', 2);
        hold off;
    end
end

% 2) Signals over time
figure('Name', 'Signals Over Time');
subplot(3,1,1);
plot(acc_T, acc_data);
legend('X','Y','Z'); xlabel('Time (s)'); ylabel('m/s²');
title('Accelerometer over time');
grid on;

subplot(3,1,2);
plot(gyr_T, gyr_data);
legend('X','Y','Z'); xlabel('Time (s)'); ylabel('rad/s');
title('Gyroscope over time');
grid on;

subplot(3,1,3);
plot(mag_T, mag_data);
legend('X','Y','Z'); xlabel('Time (s)'); ylabel('µT');
title('Magnetometer over time');
grid on;

% 3) Mean and Covariance
mean_acc = mean(acc_data);
mean_gyr = mean(gyr_data);
mean_mag = mean(mag_data);

cov_acc  = cov(acc_data);
cov_gyr  = cov(gyr_data);
cov_mag  = cov(mag_data);

fprintf('=== Accelerometer ===\n');
fprintf('Mean:  X=%.4f  Y=%.4f  Z=%.4f m/s²\n', mean_acc);
fprintf('Covariance:\n'); disp(cov_acc);

fprintf('=== Gyroscope ===\n');
fprintf('Mean:  X=%.4f  Y=%.4f  Z=%.4f rad/s\n', mean_gyr);
fprintf('Covariance:\n'); disp(cov_gyr);

fprintf('=== Magnetometer ===\n');
fprintf('Mean:  X=%.4f  Y=%.4f  Z=%.4f µT\n', mean_mag);
fprintf('Covariance:\n'); disp(cov_mag);

fprintf('=== Magnetometer field magnitude ===\n');
mag_magnitude = sqrt(sum(mag_data.^2, 2));
fprintf('Mean magnitude: %.4f µT\n', mean(mag_magnitude));
fprintf('Std magnitude:  %.4f µT\n', std(mag_magnitude));