# Random seeds and streams

The three original files in `research/config/` are the parameter/seed authority. Seed 42 is used for the main and pilot runs; robustness seeds are 42, 31415, 271828. Pilot N is 1000 per class; checkpoint03 N is 5000 per class. The E3 precision-selection candidates and stored selection are supplied.

`draw_scores.m` uses `mrg32k3a` with four substreams `4*(stream_id-1)+1..4` for dry/layer measurement and dry/layer reference. `distribution_scores.m` retains this mapping and delegates Gaussian draws to the original path. E3 stream offset is 100000; checkpoint03 offset is 400000, with task-specific increments in each runner. Generic return draws use `2000000+2*stream_id` and `2000001+2*stream_id`; surface-return draws use `6000000+2*stream_id` and `6000001+2*stream_id`.

Threshold policies, validity profiles and paired surface contrasts reuse designated draws. Repeated rows are not independent samples. Preserve loop ordering and offsets for replay. Configuration identities such as checkpoint03 are internal code version identifiers, not physical experiment names.
