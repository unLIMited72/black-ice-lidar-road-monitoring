classdef test_device_spec_analysis < matlab.unittest.TestCase
 methods(TestClassSetup)
  function setup(~)
   addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'scripts')); checkpoint_setup();
  end
 end
 methods(Test)
  function ratiosAreNotNoise(tc)
   c=checkpoint03_parameters(); q=blackice.device_spec_envelope(1.5,.010,0,c);
   tc.verifyEqual(q.R_resolution,1,'AbsTol',1e-12);
   tc.verifyEqual(q.R_accuracy,.4,'AbsTol',1e-12);
   tc.verifyEqual(c.sigmas_mm,[2.5 5 10 20],'AbsTol',0);
  end
  function fiveMeterBoundary(tc)
   c=checkpoint03_parameters(); q=blackice.device_spec_envelope([4.999;5],.01,0,c);
   tc.verifyEqual(q.typical_accuracy_scale_mm,[25;100],'AbsTol',0);
   tc.verifyEqual(q.accuracy_band_crossing,[false;true]);
  end
  function shortRangeWarning(tc)
   c=checkpoint03_parameters(); q=blackice.device_spec_envelope([.5;1.5],.002,0,c);
   tc.verifyEqual(q.short_range_nonlinearity_warning,[true;false]);
  end
 end
end
