# Model scope

A simulation sensitivity study for interpretation of roadside winter-monitoring LiDAR evidence. Geometry supplies the range shift of an assumed planar layer. Incidence angle is measured from the road normal; sensor height is perpendicular to the road. Dry and layer ranges share the geometry. Measurement uncertainty and independent-reference uncertainty affect the score; R0 uses the ideal reference and R1 an independent noisy reference. Assumed stress laws and return proxies are sensitivity scenarios, not physically fitted optical parameters.

Return availability controls whether an attempt supplies a usable decision. Conditional detection is read on valid ice returns; coverage is the valid-return fraction. Overall opportunity is coverage multiplied by conditional detection and must be interpreted per attempted ice-class measurement. No-valid cases remain undefined for conditional quantities rather than being assigned zero detection probability. False-alarm probability is reported with its conditioning convention.

Paired same-geometry controls isolate the added return proxy within this model. They do not identify material. Published 2023/2025 rows share a numerical pattern and are not two independent physical validation datasets.

Not established: physical black-ice detection performance, material identification, optimal installation angle, minimum detectable thickness, safety benefit or deployment readiness. Wet pavement and other optical confounders are not calibrated classes here. Device- and wavelength-specific measurements of thin ice, wet pavement and controlled incidence conditions remain necessary for material-specific operational thresholds.

Implementations: `research/lib/+blackice/geometry.m`, `uncertainty_sigma.m`, `level2_sigma.m`, `draw_scores.m`, `surface_observability.m`, `observability_cell.m`, and the three configuration files. No model parameters were changed for release preparation.
