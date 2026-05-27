function [x, P] = tu_qw(x, P, omega, T, Rw)
    F = eye(4) + T * Somega(omega) / 2;
    G = T * Sq(x) / 2;

    x = F * x;

    P = F * P * F' + G * Rw * G';

    [x, P] = mu_normalizeQ(x, P);
end
