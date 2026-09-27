classdef test_level1_statistics < matlab.unittest.TestCase
    %TEST_LEVEL1_STATISTICS Fixed seeds and sampling-aware acceptance rules.
    methods(TestClassSetup)
        function prepare(~)
            root=fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(root,'scripts'));
            checkpoint_setup();
        end
    end
    methods(Test)
        function seedReproducibility(tc)
            a=blackice.draw_scores(1.6,1.59,.01,"R1",1000,42,9001);
            b=blackice.draw_scores(1.6,1.59,.01,"R1",1000,42,9001);
            tc.verifyEqual(a.dry_score_m,b.dry_score_m,'AbsTol',0);
            tc.verifyEqual(a.ice_score_m,b.ice_score_m,'AbsTol',0);
        end
        function globalRNGUnchanged(tc)
            before=rng;
            blackice.draw_scores(1.6,1.59,.01,"R0",1000,42,9001);
            after=rng;
            tc.verifyEqual(before,after);
        end
        function convergencePrefixesIdentical(tc)
            a=blackice.draw_scores(1.6,1.59,.01,"R1",1000,42,9002);
            b=blackice.draw_scores(1.6,1.59,.01,"R1",5000,42,9002);
            tc.verifyEqual(a.dry_score_m,b.dry_score_m(1:1000),'AbsTol',0);
            tc.verifyEqual(a.ice_score_m,b.ice_score_m(1:1000),'AbsTol',0);
        end
        function noiseMeanAndStandardDeviation(tc)
            N=50000; sigma=.01;
            a=blackice.draw_scores(1.6,1.59,sigma,"R0",N,42,9003);
            % Six sampling standard errors; not an arbitrary sensor limit.
            tc.verifyLessThan(abs(mean(a.dry_score_m)),6*sigma/sqrt(N));
            tc.verifyLessThan(abs(std(a.dry_score_m)-sigma),6*sigma/sqrt(2*(N-1)));
        end
        function perfectVsIndependentNoisyReferenceVariance(tc)
            N=50000; sigma=.01;
            a=blackice.draw_scores(1.6,1.59,sigma,"R0",N,42,9004);
            b=blackice.draw_scores(1.6,1.59,sigma,"R1",N,42,9004);
            tc.verifyEqual(var(a.dry_score_m),sigma^2,'AbsTol',6*sigma^2*sqrt(2/(N-1)));
            tc.verifyEqual(var(b.dry_score_m),2*sigma^2,'AbsTol',12*sigma^2*sqrt(2/(N-1)));
        end
        function zeroNoiseIsDeterministic(tc)
            a=blackice.draw_scores(1.6,1.57,0,"R1",100,42,9005);
            tc.verifyEqual(a.dry_score_m,zeros(100,1),'AbsTol',1e-14);
            tc.verifyEqual(a.ice_score_m,.03*ones(100,1),'AbsTol',1e-14);
        end
        function heightIndependenceWithCommonRandomNumbers(tc)
            g1=blackice.geometry(.5,.01,30); g2=blackice.geometry(3,.01,30);
            a=blackice.draw_scores(g1.D_A_m,g1.D_I_m,.01,"R1",1000,42,9006);
            b=blackice.draw_scores(g2.D_A_m,g2.D_I_m,.01,"R1",1000,42,9006);
            tc.verifyEqual(a.ice_score_m,b.ice_score_m,'AbsTol',1e-14);
            tc.verifyEqual(a.dry_score_m,b.dry_score_m,'AbsTol',1e-14);
        end
        function angleMonotonicTheoreticalDetectability(tc)
            g=blackice.geometry(1.6,.01,0:10:70);
            tau=blackice.threshold(.05,.01);
            pd=blackice.normal_tail(tau,g.delta_m,.01);
            tc.verifyGreaterThanOrEqual(min(diff(pd)),0);
        end
        function MCvsTheoryExactIntervals(tc)
            N=50000; delta=.01;
            a=blackice.draw_scores(1.6,1.59,.01,"R1",N,42,9007);
            tau=blackice.threshold(.05,a.sigma_score_m);
            count=[sum(blackice.detect(a.dry_score_m,tau)) sum(blackice.detect(a.ice_score_m,tau))];
            p=[.05 blackice.normal_tail(tau,delta,a.sigma_score_m)];
            [lo,hi]=blackice.binomial_exact_interval(count,N,.001);
            tc.verifyGreaterThanOrEqual(p,lo);
            tc.verifyLessThanOrEqual(p,hi);
        end
        function thresholdDependsOnlyOnDryNull(tc)
            tau=blackice.threshold([.01 .05 .10],.01);
            tc.verifyEqual(blackice.normal_tail(tau,0,.01),[.01 .05 .10],'AbsTol',1e-14);
            tc.verifyEqual(blackice.detect([0 .01 .02],.01),[false false true]);
        end
        function wilsonEndpoints(tc)
            [lo,hi]=blackice.wilson([0 1000],1000,.05);
            tc.verifyEqual(lo(1),0,'AbsTol',1e-15);
            tc.verifyEqual(hi(2),1,'AbsTol',1e-15);
            tc.verifyGreaterThan(hi(1),0);
            tc.verifyLessThan(lo(2),1);
        end
        function exactBinomialEndpoints(tc)
            [lo,hi]=blackice.binomial_exact_interval([0 1000],1000,.05);
            tc.verifyEqual(lo(1),0,'AbsTol',1e-15);
            tc.verifyEqual(hi(2),1,'AbsTol',1e-15);
            tc.verifyEqual(lo(2),(.05/2)^(1/1000),'AbsTol',1e-12);
        end
        function nullThicknessHasEqualClassProbabilities(tc)
            tau=blackice.threshold(.05,.01);
            tc.verifyEqual(blackice.normal_tail(tau,0,.01),.05,'AbsTol',1e-14);
        end
        function ROCIncludesFullRangeAndTies(tc)
            R=blackice.empirical_roc([0;1],[1;2]);
            tc.verifyEqual(R.P_FA_mc([1 end]),[1;0],'AbsTol',0);
            tc.verifyEqual(R.P_D_mc([1 end]),[1;0],'AbsTol',0);
            tc.verifyEqual(R.P_FA_mc(R.threshold_m==1),0,'AbsTol',0);
            tc.verifyEqual(R.P_D_mc(R.threshold_m==1),.5,'AbsTol',0);
        end
    end
end
