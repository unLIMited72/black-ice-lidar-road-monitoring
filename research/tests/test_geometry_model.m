classdef test_geometry_model < matlab.unittest.TestCase
    %TEST_GEOMETRY_MODEL Public geometry contracts and actual Simulink path.
    properties
        cfg
    end
    methods(TestClassSetup)
        function prepare(tc)
            root=fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(root,'scripts'));
            tc.cfg=checkpoint_setup();
            if ~isfile(tc.cfg.model_file), build_geometry_simulink_model(); end
        end
    end
    methods(Test)
        function G1_zeroThickness(tc)
            g=blackice.geometry(1.6,0,0:10:70);
            tc.verifyEqual(g.D_A_m,g.D_I_m,'AbsTol',1e-12);
            tc.verifyEqual(g.delta_m,zeros(1,8),'AbsTol',1e-12);
        end
        function G2_normalIncidence(tc)
            t=[0 .002 .005 .010 .020 .030];
            g=blackice.geometry(1.6,t,0);
            tc.verifyEqual(g.delta_m,t,'AbsTol',1e-12);
        end
        function G3_thirtyMillimeters(tc)
            g=blackice.geometry(1.6,0.030,0);
            tc.verifyEqual(g.delta_m,.030,'AbsTol',1e-12);
        end
        function G4_fortyFiveDegrees(tc)
            g=blackice.geometry(1.6,.030,45);
            tc.verifyEqual(g.delta_m,.030/cosd(45),'AbsTol',1e-12);
        end
        function G5_heightIndependence(tc)
            g=blackice.geometry(tc.cfg.heights_m,.030,45);
            tc.verifyEqual(g.delta_m,repmat(.030/cosd(45),1,5),'AbsTol',1e-12);
        end
        function G6_invalidAngles(tc)
            g=blackice.geometry(1.6,.030,[90 91 180 -1]);
            tc.verifyFalse(any(g.geometry_valid));
            tc.verifyTrue(all(isnan(g.delta_m)));
        end
        function G7_invalidHeight(tc)
            g=blackice.geometry([.03 .02 0],.030,0);
            tc.verifyFalse(any(g.geometry_valid));
        end
        function G8_negativeThickness(tc)
            g=blackice.geometry(1.6,-.001,30);
            tc.verifyFalse(g.geometry_valid);
            tc.verifyTrue(isnan(g.D_I_m));
        end
        function nonfiniteInputs(tc)
            g=blackice.geometry([Inf NaN 1.6],[.03 .03 Inf],[0 0 NaN]);
            tc.verifyFalse(any(g.geometry_valid));
        end
        function analyticalVsSimulinkAll240(tc)
            [H,t,a]=ndgrid(tc.cfg.heights_m,tc.cfg.thicknesses_mm/1000,tc.cfg.angles_deg);
            ref=blackice.geometry(H(:),t(:),a(:));
            actual=blackice.simulate_geometry(H(:),t(:),a(:),tc.cfg);
            tc.verifyEqual(actual.D_A_m,ref.D_A_m,'AbsTol',tc.cfg.geometry_atol_m);
            tc.verifyEqual(actual.D_I_m,ref.D_I_m,'AbsTol',tc.cfg.geometry_atol_m);
            tc.verifyEqual(actual.delta_m,ref.delta_m,'AbsTol',tc.cfg.geometry_atol_m);
            tc.verifyTrue(all(actual.geometry_valid));
        end
        function simulinkRejectsInvalidGeometry(tc)
            H=[1.6;1.6;.03;.02;1.6;Inf;NaN;1.6];
            t=[.03;.03;.03;.03;-.01;.03;.03;.03];
            a=[90;100;0;0;0;0;0;-1];
            actual=blackice.simulate_geometry(H,t,a,tc.cfg);
            tc.verifyFalse(any(actual.geometry_valid));
            tc.verifyTrue(all(isnan(actual.D_A_m)));
            tc.verifyTrue(all(isnan(actual.D_I_m)));
            tc.verifyTrue(all(isnan(actual.delta_m)));
        end
    end
end
