# Separating Geometry, Measurement Uncertainty, and Return Observability in LiDAR-Based Black-Ice Road Monitoring: A Simulation Study

Prepared local release package; not yet publicly released. Package version: `v1.0-submission`. Author-controlled software/model is licensed under MIT; author-controlled data, original documentation and assets under CC BY 4.0 with the boundaries in [LICENSE](LICENSE) and [license scope](docs/LICENSE_SCOPE.md). Repository location prepared for release: https://github.com/unLIMited72/black-ice-lidar-road-monitoring (currently PRIVATE; public release pending).

## Overview

This simulation sensitivity study separates layer geometry, measurement/reference uncertainty and valid-return availability in roadside winter monitoring. It does not establish physical black-ice detection performance, material identification, an optimal angle, minimum detectable thickness, safety benefit or deployment readiness.

## Contents

- `research/config`, `research/lib`, `research/scripts`, `research/models`, `research/tests`: project source, settings, model and historical tests.
- `research/results`: unchanged author simulation outputs and selected table extracts.
- `reference_outputs/figures`: ten project figure assets; Figure 3 is not bundled.
- `supplementary/electronic_tables`: S2, S3, S4 and S9 with units and source notes.
- `reproduction/final_tables`: final author-written table fragments; no publisher template.
- `docs` and `environment`: model limits, maps, recorded requirements and citations.

## Requirements and workflow

MATLAB R2024a Update 9 / Simulink 24.1 are the historically recorded proprietary runtime; they are not distributed or licensed by this package. Python plotting requires NumPy and Matplotlib; extraction also requires pandas. See [environment](environment/README.md) and [reproduction](reproduction/README.md).

From this repository root, `python3 reproduction/verify_package.py` checks shipped bytes, paths and source syntax without simulation or output regeneration. E1 is OPTIONAL / USER-SUPPLIED INPUT: obtain the original published table independently and follow [E1 instructions](reproduction/E1_USER_INPUT.md). Missing E1 input skips that comparison without preventing the other plotting/extraction stages. Full-grid table extraction still requires the separate Zenodo CSV overlay.

## Outputs and limits

[Figure map](docs/FIGURE_REPRODUCTION_MAP.csv) and [table map](docs/TABLE_REPRODUCTION_MAP.csv) distinguish shipped assets, optional inputs and generated outputs. Figure 2 is a project-created coordinate schematic; its original generator is supplied, but exact final editorial export provenance is incomplete. Final renderer byte identity is not promised. Two optional historical tests need an unshipped MAT file from an intentional future E3 run; see [boundaries](docs/REPRODUCIBILITY_BOUNDARY.md).

## Seeds

Master seed 42; robustness seeds 42, 31415 and 271828; mrg32k3a streams. See [stream definitions](docs/RANDOM_STREAMS.md). Reused draws are not independent samples.

## Citation and availability

[CITATION.cff](CITATION.cff) identifies Seoungjun Lim and Wonhyuk Choi and the unpublished related manuscript. Version is `v1.0-submission`; the actual public release date remains pending. Reserved Zenodo version DOI: `10.5281/zenodo.22994272`. This DOI has been reserved for the `v1.0-submission` archival record and will become registered when the Zenodo record is published. The record is currently unpublished; the concept DOI is not yet available. The full processed E3 CSV (280107771 bytes) is in the separate Zenodo staging overlay. No publication is asserted.

## Third-party material

[References](docs/THIRD_PARTY_REFERENCES.md) provide source citations and links. Publisher PDFs, manuals, published numerical tables and their Figure 3/S1 derivatives are not bundled. S4 combines author calculations with attributed manufacturer specification magnitudes; S9 contains bibliographic metadata and author synthesis. Underlying source rights are not licensed by this package. No private interaction records or development history are included.

## Contact

Wonhyuk Choi, Department of Avionics Engineering, Hanseo University: choiwh@hanseo.ac.kr.

## Licensing

See [NOTICE](NOTICE) for attribution and [license scope](docs/LICENSE_SCOPE.md) for path coverage. CC BY 4.0 applies to the authors’ original compilation, analysis and documentation to the extent controlled by the authors; cited third-party source material remains subject to its original terms. Later publication snapshot: `v1.0.0`, distinct from this submission snapshot. Future archival citation uses the exact version DOI; a concept DOI is for discovery only.
