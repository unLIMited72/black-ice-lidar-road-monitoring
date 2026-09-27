function [valid_probability,event_probability,method] = level2_theory(DA,Dt,sigma,mode,tau)
%LEVEL2_THEORY Probability of positive ranges and a detection event.
% Stress dropout is independent and is applied by the caller.
% R1 joint probability integrates over positive measured range; tau >= 0.
validateattributes(tau,{'numeric'},{'real','nonnegative'});
if sigma==0
    valid_probability=double(DA>0 && Dt>0);
    event_probability=valid_probability*double(DA-Dt>tau);
    method="zero-noise deterministic limit";
    return
end
pm=blackice.normal_tail(0,Dt,sigma);
if mode=="R0"
    pr=1; sx=sigma;
else
    pr=blackice.normal_tail(0,DA,sigma); sx=sqrt(2)*sigma;
end
valid_probability=pm*pr;
gaussian=blackice.normal_tail(tau,DA-Dt,sx);
method="Gaussian (discarded tail <= 1e-12)";
if 1-valid_probability<=1e-12
    event_probability=gaussian;
elseif mode=="R0"
    event_probability=max(0,gaussian-(1-pm));
    event_probability(tau>=DA)=0;
    method="positive-range exact R0";
else
    event_probability=zeros(size(tau));
    for j=1:numel(tau)
        f=@(z) exp(-z.^2/2)/sqrt(2*pi).*blackice.normal_tail(Dt+sigma*z+tau(j),DA,sigma);
        event_probability(j)=integral(f,-Dt/sigma,Inf,'AbsTol',1e-12,'RelTol',1e-10);
    end
    method="positive-range quadrature R1";
end
end
