classdef test_level2_validity < matlab.unittest.TestCase
 methods(TestClassSetup)
  function setup(~)
   addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'scripts')); checkpoint_setup();
  end
 end
 methods(Test)
  function allValid(tc)
   c=level2_parameters(); p=blackice.level2_valid_probability([0 70],[.5 9],c.validities(1,:),1.6);
   tc.verifyEqual(p,[1 1],'AbsTol',0);
  end
  function deterministicInclusiveBoundary(tc)
   c=level2_parameters(); p=blackice.level2_valid_probability([60 60 61],[5 5.01 5],c.validities(3,:),1.6);
   tc.verifyEqual(p,[1 0 0],'AbsTol',0);
  end
  function probabilityMonotonicity(tc)
   c=level2_parameters(); p=blackice.level2_valid_probability([0 30 70],[1.6 3 8],c.validities(6,:),1.6);
   tc.verifyLessThanOrEqual(diff(p),0); tc.verifyGreaterThanOrEqual(p,0); tc.verifyLessThanOrEqual(p,1);
  end
  function independentProbabilityFormula(tc)
   c=level2_parameters(); p=blackice.level2_valid_probability(70,3.2,c.validities(6,:),1.6);
   tc.verifyEqual(p,exp(-1),'AbsTol',1e-14);
  end
  function unknownDoesNotBecomeDry(tc)
   d=blackice.level2_decide([.1 .1 NaN -.1],0,[true false true true]);
   tc.verifyEqual(d,int8([1 -1 -1 0]));
  end
  function positiveRangeTheory(tc)
   [v,e]=blackice.level2_theory(1,1,1,"R0",.2);
   tc.verifyEqual(v,.5*erfc(-1/sqrt(2)),'AbsTol',1e-14);
   tc.verifyEqual(e,.5*(erf(-.2/sqrt(2))-erf(-1/sqrt(2))),'AbsTol',1e-14);
  end
  function r1QuadratureIndependentIdentity(tc)
   [v,e]=blackice.level2_theory(1,1,1,"R1",0);
   % Identically distributed independent positive ranges: either ordering equally likely.
   tc.verifyEqual(e,v/2,'AbsTol',1e-10);
  end
 end
end
