# E1 — optional user-supplied published input

E1 is independent of the simulated geometry, uncertainty and return-availability results. No published observations, filled CSV, Figure 3 reference PDF or electronic S1 is included. Source values must be obtained independently; no automatic download or scraping is provided.

1. Consult Kim et al. (2023), DOI [10.12673/jant.2023.27.6.865](https://doi.org/10.12673/jant.2023.27.6.865), journal page 868 (PDF page 4), Korean Table 2 / English caption Table 1; and Hong and Choi (2025), DOI [10.14419/bg3mw803](https://doi.org/10.14419/bg3mw803), journal page 103 (PDF page 3), Table 2. Follow the source terms for your use. Matching observations in these papers are not independent validation datasets.
2. In your disposable working copy, prepare `research/data/paper/paper_temperature_transcription.csv` with exactly these required numeric columns (Celsius and metres):
   ```csv
   temperature_C,asphalt_m,black_ice_m,reported_difference_m
   ```
   The header-only template in that directory contains no source observations. Fill rows from the original table, retaining its reported values. Do not commit the filled input or generated E1 outputs. No source-specific expected distances or mismatch counts are hardcoded.
3. For intentional local reassessment, in MATLAB from the repository root:
   ```matlab
   addpath('research/scripts');
   summary = reproduce_paper_table();
   ```
   The function validates numeric columns, subtracts asphalt minus ice, preserves the reported column and writes local comparison/mismatch files. If the optional CSV is absent it reports a skip and returns. An empty/malformed supplied CSV is an input error, not silently accepted.
4. The resulting `research/data/paper/paper_temperature_table.csv` enables the E1 block of either plotting exporter and optional S1 extraction. The extract is written under `research/results/paper_tables/`, not automatically inserted into the supplied electronic tables. All such local E1 files remain excluded from sharing by default.

Without the optional input, Python plotting renders the other nine exports. Full-grid table extraction uses the independent Zenodo overlay and skips S1. Numbering of the original manuscript figures and tables remains unchanged. The two mixed original published-data claim ledgers are not shipped; simulation extraction retains the original N007-onward claim identifiers.
