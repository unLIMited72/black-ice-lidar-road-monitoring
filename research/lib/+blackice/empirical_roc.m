function R = empirical_roc(dry,ice)
%EMPIRICAL_ROC All distinct observed score thresholds with strict X>tau.
N=numel(dry);
[score,order]=sort([dry(:);ice(:)]);
labels=[false(N,1);true(N,1)]; labels=labels(order);
cumI=cumsum(labels); cumD=cumsum(~labels);
[tau,last]=unique(score,'last');
R=table([-Inf;tau;Inf],[1;(N-cumD(last))/N;0], ...
    [1;(N-cumI(last))/N;0], ...
    'VariableNames',{'threshold_m','P_FA_mc','P_D_mc'});
end
