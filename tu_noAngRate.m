function [x, P] = tu_noAngRate(x, P, T, Rw)
    F = eye(4);
    G = T * Sq(x) / 2;

    x = F * x;

    P = F * P * F' + G * Rw * G';

    [x, P] = mu_normalizeQ(x, P);
end
