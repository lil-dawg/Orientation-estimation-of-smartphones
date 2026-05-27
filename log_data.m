clc; clear all;

m = mobiledev;
m.AccelerationSensorEnabled    = 1;
m.AngularVelocitySensorEnabled = 1;
m.MagneticSensorEnabled        = 1;
m.SampleRate = 'High';
m.Logging = 1;

fprintf('Collecting data for 10 seconds');
pause(10);
m.Logging = 0;

[acc_data, acc_T] = accellog(m);
[gyr_data, gyr_T] = angvellog(m);
[mag_data, mag_T] = magfieldlog(m);
clear m;

filename = 'sensor_data.mat';
save(filename, 'acc_data', 'acc_T', 'gyr_data', 'gyr_T', 'mag_data', 'mag_T');
fprintf('Saved to %s\n', filename);