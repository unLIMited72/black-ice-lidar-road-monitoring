function decision = level2_decide(score_m,threshold_m,valid)
%LEVEL2_DECIDE -1 Unknown, 0 Dry, 1 Ice. No truth inputs.
decision=-ones(size(score_m),'int8');
usable=logical(valid)&isfinite(score_m);
decision(usable)=int8(blackice.detect(score_m(usable),threshold_m));
end
