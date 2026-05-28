function [xhat, meas] = filter_tu(calAcc, calGyr, calMag)
% FILTERTEMPLATE  Filter template
%
% This is a template function for how to collect and filter data
% sent from a smartphone live.  Calibration data for the
% accelerometer, gyroscope and magnetometer assumed available as
% structs with fields m (mean) and R (variance).
%
% The function returns xhat as an array of structs comprising t
% (timestamp), x (state), and P (state covariance) for each
% timestamp, and meas an array of structs comprising t (timestamp),
% acc (accelerometer measurements), gyr (gyroscope measurements),
% mag (magnetometer measurements), and orint (orientation quaternions
% from the phone).  Measurements not availabe are marked with NaNs.
%
% As you implement your own orientation estimate, it will be
% visualized in a simple illustration.  If the orientation estimate
% is checked in the Sensor Fusion app, it will be displayed in a
% separate view.
%
% Note that it is not necessary to provide inputs (calAcc, calGyr, calMag).

  %% Filter settings
  t0 = [];  % Initial time (initialize on first data received)
  nx = 4;   % Assuming that you use q as state variable.

  % Filter settings
  Rw =  1.0e-6 * [0.1907  0.0065 -0.0124;
                   0.0065  0.1607  0.0084;
                  -0.0124  0.0084  0.1485];


  % Current filter state.
  x = [1; 0; 0 ;0];
  P = eye(nx, nx);

  % Saved filter states.
  xhat = struct('t', zeros(1, 0),...
                'x', zeros(nx, 0),...
                'P', zeros(nx, nx, 0));

  meas = struct('t', zeros(1, 0),...
                'acc', zeros(3, 0),...
                'gyr', zeros(3, 0),...
                'mag', zeros(3, 0),...
                'orient', zeros(4, 0));
 % try
    %% Create data link
    m = mobiledev;
    
    m.AccelerationSensorEnabled   = 1;
    m.AngularVelocitySensorEnabled = 1;
    m.MagneticSensorEnabled       = 1;
    m.OrientationSensorEnabled = 1;
    m.SampleRate = 'High';

    m.Logging = 1;  % Start data reception.

    % Used for visualization.
    figure(1);
    subplot(1, 2, 1);
    ownView = OrientationView('Own filter', gca);  % Used for visualization.
    googleView = [];
    counter = 0;  % Used to throttle the displayed frame rate.
    t_prev = [];

    %% Filter loop
    while m.Connected  % Repeat while data is available
      % Get the next measurement set, assume all measurements
      % within the next 5 ms are concurrent (suitable for sampling
      % in 100Hz).
      pause(0.01)
      
      % Get data
      % data = datanow(m);

      % if isempty(data)  % No new data received
      %   continue;        % Skips the rest of the look
      % end

      % t   = data.Time;
      % acc = data.Acceleration';   % [3x1]
      % gyr = data.AngularVelocity'; % [3x1]
      % mag = data.MagneticField';   % [3x1]
      % orientation = data.Orientation';

      % Get latest acceleration
        [acc_data, acc_t] = accellog(m);
        acc = acc_data(end, :)';  % take latest sample
        
        % Get latest gyroscope
        [gyr_data, gyr_t] = angvellog(m);
        gyr = gyr_data(end, :)';
        
        % Get latest magnetometer
        [mag_data, mag_t] = magfieldlog(m);
        mag = mag_data(end, :)';
        
        % Get latest orientation
        [ori_data, ori_t] = orientlog(m);
        orientation = ori_data(end, :)';
        
        % Use gyro timestamp as current time
        t = gyr_t(end);

      if isempty(t0)  % Initialize t0
        t0 = t;
        t_prev = t;
      end

      T = t - t_prev;  % Time since last measurement
      t_prev = t;

      if ~any(isnan(acc))  % Acc measurements are available.
        g0 = [-0.0497, 0.0228, 9.8325]'; % Mean of acceleration during rest
        Ra = 1.0e-03 * [ 0.1014, -0.0167, -0.0062   % Covariance acc during rest
                        -0.0167,  0.1210,  0.0016
                        -0.0062,  0.0016,  0.0646];
        [x, P] = mu_g(x, P, acc, Ra, g0);
      end

      if ~any(isnan(gyr))  % Gyro measurements are available.
        [x, P] = tu_qw(x, P, gyr, T, Rw);
      else
        [x, P] = tu_noAngRate(x, P, T, Rw);
      end

      if ~any(isnan(mag))  % Mag measurements are available.
        % Task 9
      end

      if ~any(isnan(orientation))
        az = deg2rad(orientation(1));
        pitch = deg2rad(orientation(2));
        roll  = deg2rad(orientation(3));
        orientation_q = eul2quat([az, pitch, roll], 'ZYX')';
      else
        orientation_q = nan(4,1);
      end

      % Visualize result
      if rem(counter, 10) == 0
        setOrientation(ownView, x(1:4));
        title(ownView, 'OWN', 'FontSize', 16);
        if ~any(isnan(orientation_q))
          if isempty(googleView)
            subplot(1, 2, 2);
            % Used for visualization.
            googleView = OrientationView('Google filter', gca);
          end
          setOrientation(googleView, orientation_q);
          title(googleView, 'GOOGLE', 'FontSize', 16);
        end
      end
      counter = counter + 1;

      % Save estimates
      xhat.x(:, end+1) = x;
      xhat.P(:, :, end+1) = P;
      xhat.t(end+1) = t - t0;

      meas.t(end+1) = t - t0;
      meas.acc(:, end+1) = acc;
      meas.gyr(:, end+1) = gyr;
      meas.mag(:, end+1) = mag;
      meas.orient(:, end+1) = orientation_q;
    end
  %catch e
    fprintf(['Unsuccessful connecting to client!\n' ...
      'Make sure to start streaming from the phone *after*'...
             'running this function!']);
 % end
end
