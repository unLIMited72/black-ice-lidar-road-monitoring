function [lo,hi] = binomial_exact_interval(k,n,alpha)
%BINOMIAL_EXACT_INTERVAL Clopper-Pearson interval for verification at tails.
% Unlike the score/Wilson approximation, maintains coverage near p=0 or 1.
arguments
    k double {mustBeNonnegative,mustBeInteger}
    n double {mustBePositive,mustBeInteger}
    alpha (1,1) double {mustBeGreaterThan(alpha,0),mustBeLessThan(alpha,1)}
end
n=n+zeros(size(k));
assert(all(k<=n,'all'));
lo=zeros(size(k)); hi=ones(size(k));
nonzero=k>0; nonfull=k<n;
lo(nonzero)=betaincinv(alpha/2,k(nonzero),n(nonzero)-k(nonzero)+1);
hi(nonfull)=betaincinv(1-alpha/2,k(nonfull)+1,n(nonfull)-k(nonfull));
end
