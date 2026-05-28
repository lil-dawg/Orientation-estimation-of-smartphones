function [x, P] = mu_g(x, P, yacc, Ra, g0)
    q = x;

    Q = Qq(q);

    [Q0, Q1, Q2, Q3] = dQqdq(q);

end