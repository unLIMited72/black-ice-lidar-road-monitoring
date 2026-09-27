function p = normal_tail(x,mu,sigma)
%NORMAL_TAIL Gaussian P(X>x), stable in the upper tail; no stats dependency.
arguments
    x double {mustBeReal}
    mu double {mustBeFinite,mustBeReal}
    sigma double {mustBeFinite,mustBePositive,mustBeReal}
end
p=0.5*erfc((x-mu)./(sqrt(2)*sigma));
end
