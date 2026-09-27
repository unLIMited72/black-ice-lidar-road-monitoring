classdef test_noise_distribution_robustness < matlab.unittest.TestCase
 properties(TestParameter)
  family={"Gaussian","Uniform","Laplace"};
  reference={"R0","R1"};
 end
 methods(TestClassSetup)
  function setup(~)
   addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'scripts')); checkpoint_setup();
  end
 end
 methods(Test)
  function equalVariance(tc,family)
   e=blackice.sample_noise_distribution(family,.01,100000,42,800001);
   tc.verifyLessThan(abs(mean(e)),6*.01/sqrt(100000));
   % Laplace has largest fourth moment: conservative six-SE variance tolerance.
   tc.verifyLessThan(abs(var(e)-.01^2),6*.01^2*sqrt(5/100000));
  end
  function reproducibleAndLocalRNG(tc,family)
   before=rng;
   a=blackice.sample_noise_distribution(family,.01,1000,42,800002);
   b=blackice.sample_noise_distribution(family,.01,1000,42,800002);
   tc.verifyEqual(a,b,'AbsTol',0); tc.verifyEqual(rng,before);
  end
  function matchedThresholdIdentity(tc,family,reference)
   tau=blackice.distribution_threshold([.01 .05 .1],.01,family,reference,"matched");
   p=blackice.score_noise_tail(tau,.01,family,reference);
   tc.verifyEqual(p,[.01 .05 .1],'AbsTol',1e-12);
  end
  function distributionTheoryAgainstSamples(tc,family,reference)
   s=blackice.distribution_scores(1.5,1.49,.01,reference,50000,42,450001,family);
   tau=blackice.distribution_threshold(.05,.01,family,reference,"matched");
   k=[sum(s.dry_score_m>tau) sum(s.ice_score_m>tau)];
   theory=[.05 blackice.score_noise_tail(tau-.01,.01,family,reference)];
   [lo,hi]=blackice.binomial_exact_interval(k,50000,.001);
   tc.verifyGreaterThanOrEqual(theory,lo); tc.verifyLessThanOrEqual(theory,hi);
  end
  function gaussianLegacyIdentical(tc)
   a=blackice.draw_scores(1.5,1.49,.01,"R1",1000,42,450002);
   b=blackice.distribution_scores(1.5,1.49,.01,"R1",1000,42,450002,"Gaussian");
   tc.verifyEqual(a,b);
  end
  function uniformDifferenceKnownTail(tc)
   a=sqrt(3)*.01;
   tc.verifyEqual(blackice.score_noise_tail([0 a 2*a],.01,"Uniform","R1"),[.5 .125 0],'AbsTol',1e-14);
  end
 end
end
