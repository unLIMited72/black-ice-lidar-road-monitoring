classdef test_return_observability < matlab.unittest.TestCase
 methods(TestClassSetup)
  function setup(~)
   addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'scripts')); checkpoint_setup();
  end
 end
 methods(Test)
  function normalAngleNormalization(tc)
   [q,p]=blackice.return_proxy(0,1.6,1,1,1.5,1.6);
   tc.verifyEqual(q,1,'AbsTol',1e-14); tc.verifyEqual(p,1,'AbsTol',1e-14);
  end
  function rangeDoesNotIncreaseReturn(tc)
   q=blackice.return_proxy(30,[.5 1 2 3],1,1,.5,1.6);
   tc.verifyLessThan(diff(q),zeros(1,3));
  end
  function strongerSpecularityReducesReturn(tc)
   weak=blackice.return_proxy([0 30 70],2,1,1,.1,1.6);
   strong=blackice.return_proxy([0 30 70],2,1,1,1.5,1.6);
   tc.verifyLessThanOrEqual(strong,weak);
   tc.verifyLessThan(strong(2:end),weak(2:end));
  end
  function independentFormula(tc)
   q=blackice.return_proxy(45,3.2,.5,1,.5,1.6);
   tc.verifyEqual(q,.5/sqrt(2)*exp(-.5)/4,'AbsTol',1e-14);
  end
  function probabilityLinks(tc)
   a=blackice.surface_observability([0 .2 100],.2,"rational");
   b=blackice.surface_observability([0 .2 100],.2,"exponential");
   tc.verifyEqual(a(1:2),[0 .5],'AbsTol',1e-14);
   tc.verifyEqual(b(1:2),[0 1-exp(-1)],'AbsTol',1e-14);
   tc.verifyGreaterThanOrEqual([a b],0); tc.verifyLessThanOrEqual([a b],1);
  end
  function dryVersusAssignedIce(tc)
   dry=blackice.return_proxy(50,2,1,1,0,1.6);
   ice=blackice.return_proxy(50,2,1,1,.5,1.6);
   tc.verifyGreaterThan(dry,ice);
  end
 end
end
