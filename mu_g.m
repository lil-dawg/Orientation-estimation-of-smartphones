function [x, P] = mu_g(x, P, yacc, Ra, g0)
    q = x;

    [Q0, Q1, Q2, Q3] = dQqdq(q);

    % Jacobian H
    H = [Q0' * g0, Q1' * g0, Q2' * g0, Q3' * g0]';
    
    % Q  is sensor to world
    % Q' is world to sensor
    Q = Qq(q);

    % Predicted measurement
    y_hat = Q' * g0;
    
    % Innovation
    y_tilde = yacc - y_hat;

    % Innovation covariance
    S = H * P * H' + Ra;
    
    % Kalman gain
    K = P * H' / S;
    
    % State and covariance update
    x = x + K * y_tilde;
    P = (eye(4) - K * H) * P;
    
    % Normalize
    [x, P] = mu_normalizeQ(x, P);
    
end