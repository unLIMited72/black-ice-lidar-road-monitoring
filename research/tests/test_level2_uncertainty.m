classdef test_level2_uncertainty < matlab.unittest.TestCase
 methods(TestClassSetup)
  function setup(~)
   addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'scripts')); checkpoint_setup();
  end
 end
 methods(Test)
  function zeroExponentsReduceToLevel1(tc)
   [s,A]=blackice.level2_sigma(.01,[0 30 70],[.5 2 8],0,0,1.6);
   tc.verifyEqual(s,.01*ones(1,3),'AbsTol',1e-14); tc.verifyEqual(A,ones(1,3),'AbsTol',1e-14);
  end
  function normalIncidence(tc)
   [~,A]=blackice.level2_sigma(.01,0,3,2,0,1.6);
   tc.verifyEqual(A,1,'AbsTol',1e-14);
  end
  function referenceRange(tc)
   [~,A]=blackice.level2_sigma(.01,0,1.6,0,2,1.6);
   tc.verifyEqual(A,1,'AbsTol',1e-14);
  end
  function shortRangeClipped(tc)
   [~,A]=blackice.level2_sigma(.01,0,[.5 1 1.5],0,2,1.6);
   tc.verifyEqual(A,ones(1,3),'AbsTol',1e-14);
  end
  function severityIsMonotonic(tc)
   [~,a]=blackice.level2_sigma(.01,[0 30 70],[.5 2 8],.5,.5,1.6);
   [~,b]=blackice.level2_sigma(.01,[0 30 70],[.5 2 8],1,1,1.6);
   [~,d]=blackice.level2_sigma(.01,[0 30 70],[.5 2 8],2,2,1.6);
   tc.verifyGreaterThanOrEqual(b,a); tc.verifyGreaterThanOrEqual(d,b);
  end
  function heightAmplification(tc)
   g=blackice.geometry([.5 1 1.5 2 3],.01,60);
   [~,A]=blackice.level2_sigma(.01,60,g.D_A_m,0,1,1.6);
   tc.verifyGreaterThanOrEqual(diff(A),0); tc.verifyGreaterThan(A(end),A(1));
  end
  function rejectsOutsideGridDomain(tc)
   tc.verifyError(@() blackice.level2_sigma(.01,80,2,1,1,1.6),'MATLAB:notLessEqual');
  end
  function independentClosedForm(tc)
   [s,A]=blackice.level2_sigma(.01,60,4,1,2,1.6);
   tc.verifyEqual(A,12.5,'AbsTol',1e-12); tc.verifyEqual(s,.125,'AbsTol',1e-14);
  end
 end
end
