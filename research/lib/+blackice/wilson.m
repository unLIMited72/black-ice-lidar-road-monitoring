function [lo,hi] = wilson(k,n,alpha)
%WILSON Two-sided binomial score interval, handles k=0 and k=n.
arguments
    k double {mustBeNonnegative,mustBeInteger}
    n double {mustBePositive,mustBeInteger}
    alpha (1,1) double {mustBeGreaterThan(alpha,0),mustBeLessThan(alpha,1)} = 0.05
end
assert(all(k<=n,'all'),'blackice:InvalidCount','k must be <= n.');
z=sqrt(2)*erfcinv(alpha);
p=k./n; den=1+z^2./n;
center=(p+z^2./(2*n))./den;
half=z./den.*sqrt(p.*(1-p)./n+z^2./(4*n.^2));
lo=max(0,center-half); hi=min(1,center+half);
end
