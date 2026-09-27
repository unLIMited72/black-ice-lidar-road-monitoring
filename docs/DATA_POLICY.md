# Data policy

MINIMUM REPRODUCIBLE DATA: seven shipped plotting CSV inputs, selected Table 5/6 extracts, final author table fragments, S2/S3/S4/S9. E1 observations are not supplied; use reproduction/E1_USER_INPUT.md.

EXTENDED PROCESSED DATA: unchanged project convergence, sensitivity, robustness and model-return outputs. Stored precision, seeds and no-valid cells are preserved.

LARGE ARCHIVAL DATA: the full processed E3 grid (280107771 bytes) is Zenodo-only. Copy `large_data/research/results/processed/level2_full_e3_results.csv` from the archive to the matching repository path for table extraction. This is aggregated simulated data, not per-attempt raw observations.

S4 is MIXED: original deterministic analysis plus cited manufacturer specification facts (G_p2 denotes Garmin manual page 2). S9 is MIXED: bibliographic/source facts plus author categorical synthesis and access limitations. No source table image, caption, abstract or manual passage is included in either CSV. These original CSVs are retained unchanged for technical staging; no license over underlying sources is asserted. CC BY 4.0 applies to author-controlled compilation, analysis and documentation only; original source terms remain applicable.

Raw/environment-bearing MAT files are not shipped. Two optional historical tests need a MAT file produced by deliberate replay, as documented in REPRODUCIBILITY_BOUNDARY.md. No simulation/recalculation took place during staging.
