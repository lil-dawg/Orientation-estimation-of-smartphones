function [x, P] = mu_m(x, P, mag, m0, Rm)
    q = x;

    [Q0, Q1, Q2, Q3] = dQqdq(q);

    % Jacobian H
    H = [Q0' * m0, Q1' * m0, Q2' * m0, Q3' * m0];
    
    % Q  is sensor to world
    % Q' is world to sensor
    Q = Qq(q);

    % Predicted measurement
    y_hat = Q' * m0;
    
    % Innovation
    y_tilde = mag - y_hat;

    % Innovation covariance
    S = H * P * H' + Rm;
    
    % Kalman gain
    K = P * H' / S;
    
    % State and covariance update
    x = x + K * y_tilde;
    P = (eye(4) - K * H) * P;
    
    % Normalize
    [x, P] = mu_normalizeQ(x, P);
end