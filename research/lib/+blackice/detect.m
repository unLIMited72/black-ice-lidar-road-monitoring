function prediction = detect(score_m,threshold_m)
%DETECT Uses observations and a frozen threshold only; no truth/geometry.
arguments
    score_m double {mustBeFinite,mustBeReal}
    threshold_m double {mustBeReal}
end
prediction=score_m>threshold_m;
end
