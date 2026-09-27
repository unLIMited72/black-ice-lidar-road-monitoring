"""Read frozen CSV results; write manuscript-only extracts and numerical claim ledger.
No random sampling, simulation, or writes to checkpoint outputs.
"""
from pathlib import Path
import json
import pandas as pd
import numpy as np

B = Path(__file__).resolve().parents[1]
P = B/'results/processed'
O = B/'results/paper_tables'
M = B/'results/reproduction_metadata'
M.mkdir(parents=True, exist_ok=True)
O.mkdir(exist_ok=True)
claims=[]
cache={}
def read(name):
    if name not in cache: cache[name]=pd.read_csv(B/name)
    return cache[name]
def select(name,filters):
    d=read(name); mask=np.ones(len(d),dtype=bool)
    for k,v in filters.items(): mask &= (np.isclose(d[k],v,rtol=0,atol=1e-12) if isinstance(v,(float,int)) else d[k].eq(v)).to_numpy() if not isinstance(v,(float,int)) else np.isclose(d[k],v,rtol=0,atol=1e-12)
    return d.loc[mask]
def claim(label,name,filters,col,operation='single',scale=1,expected=None):
    q=select(name,filters)
    if operation=='single':
        assert len(q)==1,(label,len(q)); value=float(q.iloc[0][col])*scale
    elif operation=='count': value=len(q)
    elif operation=='max': value=float(q[col].max())*scale
    elif operation=='mean': value=float(q[col].mean())*scale
    elif operation=='sum': value=float(q[col].sum())*scale
    elif operation=='max_abs_target_difference': value=float((q[col]-q['pfa_target']).abs().max())*scale
    if expected is not None: assert abs(value-expected)<1e-10,(label,value,expected)
    claims.append(dict(claim_id=f'N{len(claims)+7:03}',label=label,source=name,filter_json=json.dumps(filters),column=col,operation=operation,scale=scale,expected=value,tolerance=1e-10))
    return value
def save(d,name): d.to_csv(O/name,index=False,float_format='%.15g')
# E1 is optional and contributes no bundled source-specific expected values.
if (B/'data/paper/paper_temperature_table.csv').is_file():
    t=read('data/paper/paper_temperature_table.csv')
    save(t,'supp_table_s1_published_data.csv')
else:
    print('E1 skipped: optional user-supplied input absent; see reproduction/E1_USER_INPUT.md')
src='results/processed/level2_full_e3_results.csv'; d=read(src)
base=dict(H_m=1.5,thickness_mm=10,sigma0_mm=10,pfa_target=.05,validity_mode='V0',reference_mode='R0')
rows=[]
for fam in ['L1','L2-A','L2-B','L2-C']:
    for angle in [0,30,70]:
        f=base|dict(stress_family=fam,stress_severity='baseline' if fam=='L1' else 'moderate',angle_deg=angle)
        q=select(src,f); rows.append(q)
        for col in ['P_D','P_D_CI_low','P_D_CI_high','P_FA','P_D_theory']: claim(f'{fam} angle {angle} {col}',src,f,col)
rep=pd.concat(rows)
cols=['scenario_id','stress_family','stress_severity','reference_mode','validity_mode','H_m','thickness_mm','angle_deg','sigma0_mm','pfa_target','P_D','P_D_CI_low','P_D_CI_high','P_FA','coverage_ice','P_D_all']
save(rep[cols],'table5_representative_results.csv')
for h in [.5,1,1.5,2,3]:
    f=base|dict(stress_family='L2-C',stress_severity='moderate',angle_deg=30,H_m=h)
    claim(f'Height {h} PD',src,f,'P_D')
for fam in ['L1','L2-C']:
    for ref in ['R0','R1']:
        f=base|dict(stress_family=fam,stress_severity='baseline' if fam=='L1' else 'moderate',angle_deg=30,reference_mode=ref)
        claim(f'{fam} {ref} PD',src,f,'P_D')
for angle in [30,70]:
    f=base|dict(stress_family='L2-C',stress_severity='moderate',angle_deg=angle,validity_mode='V2',validity_severity='moderate')
    for col in ['P_D','coverage_ice','P_D_all','N_valid_ice']: claim(f'V2 {angle} {col}',src,f,col)
save(d[(d.thickness_mm==10)&(d.sigma0_mm==10)&(d.pfa_target==.05)&(d.validity_mode=='V0')&((d.stress_severity=='moderate')|(d.stress_family=='L1'))], 'figure_level2_extract.csv')
src='results/processed/checkpoint03_ablation.csv'; d=read(src)
ab=d[(d.thickness_mm==10)&(d.pfa_target==.05)&(d.kappa==.5)&d.angle_deg.isin([0,30,70])]
save(ab[['stage','angle_deg','reference_mode','validity_mode','P_D','P_D_CI_low','P_D_CI_high','coverage_ice','P_D_all','N_valid_ice','P_FA']],'table6_ablation.csv')
for _,row in ab.iterrows():
    f=dict(thickness_mm=10,pfa_target=.05,kappa=.5,angle_deg=int(row.angle_deg),stage=row.stage)
    for col in ['P_D','coverage_ice','P_D_all','N_valid_ice']: claim(f'Ablation {row.stage} {row.angle_deg} {col}',src,f,col)
src='results/processed/checkpoint03_specificity_control.csv'
for angle in [0,30,70]:
    f=dict(H_m=1.5,thickness_mm=10,sigma0_mm=10,reference_mode='R1',pfa_target=.05,kappa=.5,angle_deg=angle)
    for col in ['C0_coverage_ice','coverage_ice','C0_PD_all','P_D_all']: claim(f'C0/C1 {angle} {col}',src,f,col)
src='results/processed/checkpoint03_thin_layer_results.csv'; d=read(src); thin=d[d.angle_deg==30]; save(thin,'supp_table_s2_thin_layer.csv')
for th in [0,1,2,3,5,10]:
    for col in ['P_D','coverage_ice','P_D_all','P_D_CI_low','P_D_CI_high']: claim(f'Thin {th} {col}',src,{'angle_deg':30,'thickness_mm':th},col)
src='results/processed/checkpoint03_distribution_summary.csv'; d=read(src)
f=dict(thickness_mm=10,angle_deg=30,sigma0_mm=10,reference_mode='R1',stress_family='L2-C',surface_enabled=0,pfa_target=.05)
rob=select(src,f); save(rob,'supp_table_s3_noise_summary.csv')
for _,row in rob.iterrows():
    for col in ['PD_seed_mean','PFA_seed_mean','PD_theory','PFA_theory']:
        if col in row: claim(f'Noise {row.noise_family} {row.threshold_policy} {col}',src,f|dict(noise_family=row.noise_family,threshold_policy=row.threshold_policy),col)
claim('Maximum distribution theory spread','results/processed/checkpoint03_distribution_spread.csv',{},'cross_distribution_spread','max')
claim('Maximum Gaussian-fixed theoretical PFA deviation','results/processed/checkpoint03_noise_robustness.csv',{'threshold_policy':'Gaussian_fixed'},'P_FA_theory','max_abs_target_difference')
src='results/processed/checkpoint03_device_spec.csv'; d=read(src)
print('SPEC_COLUMNS',list(d.columns))
for th in [2,5,10,30]:
    for angle in [0,70]:
        for col in ['delta_mm','R_resolution','R_accuracy']:
            claim(f'Device {th} {angle} {col}',src,dict(H_m=1.5,thickness_mm=th,angle_deg=angle),col)
save(d,'supp_table_s4_device_scale.csv')
src='results/processed/simulink_geometry_validation.csv'
for col in ['error_DA_m','error_DI_m','error_DeltaD_m']: claim('Geometry max '+col,src,{},col,'max')
claim('Archived tests passed','results/processed/checkpoint03_test_results.csv',{},'Passed','sum',expected=84)
claim('Archived tests failed','results/processed/checkpoint03_test_results.csv',{},'Failed','sum',expected=0)
save(pd.DataFrame(claims),'manuscript_numerical_claims.csv')
(M/'numerical_claim_ledger.json').write_text(json.dumps(claims,indent=2),encoding='utf8')
# Bind the principal prose/abstract statements to the same source ledger.
# Failure to find the source-derived rounded number in its specified paragraph
# makes the MATLAB manuscript audit fail (not merely a ledger self-check).
bindings=[]
def bind(label,anchor,fmt='%.4f'):
    c=next(c for c in claims if c['label']==label)
    bindings.append(dict(claim_id=c['claim_id'],anchor=anchor,format=fmt))
for fam in ['L1','L2-C']:
    for angle in [0,70]:
        bind(f'{fam} angle {angle} P_D','Black-ice road monitoring requires')
        bind(f'{fam} angle {angle} P_D','For constant measurement uncertainty' if fam=='L1' else 'The angle trend changes')
for h in [.5,1.5,3]: bind(f'Height {h} PD','Height becomes influential')
for fam in ['L1','L2-C']:
    for ref in ['R0','R1']: bind(f'{fam} {ref} PD','An independent noisy reference')
for col in ['P_D','coverage_ice','P_D_all']: bind(f'V2 70 {col}','Does conditional performance')
bind('V2 70 N_valid_ice','Does conditional performance','%.0f')
for th in [2,5,10]:
    bind(f'Device {th} 0 R_accuracy','At normal incidence and a dry range','%.2f')
bind('Device 10 70 delta_mm','At normal incidence and a dry range')
bind('Device 10 70 R_accuracy','At normal incidence and a dry range')
for st in ['A0','A1','A2','A3','A4','A5']: bind(f'Ablation {st} 30 P_D_all','Which additions account')
bind('Ablation A5 70 N_valid_ice','At 70°, A5-S2','word_six')
for col in ['C0_coverage_ice','coverage_ice','C0_PD_all','P_D_all']: bind(f'C0/C1 70 {col}','E8 holds geometry')
for col in ['C0_coverage_ice','coverage_ice']: bind(f'C0/C1 70 {col}','Black-ice road monitoring requires')
for fam in ['Gaussian','Uniform','Laplace']: bind(f'Noise {fam} matched PD_seed_mean','Equal-variance distributions preserve')
bind('Maximum distribution theory spread','Across the matched/no-return comparison')
bind('Maximum Gaussian-fixed theoretical PFA deviation','Across the matched/no-return comparison')
for th in [1,3,5,10]:
    for col in ['P_D','P_D_all']: bind(f'Thin {th} {col}','In the E5 main scenario')
bind('Thin 0 P_D','In the E5 main scenario')
(M/'manuscript_numeric_bindings.json').write_text(json.dumps(bindings,ensure_ascii=False,indent=2),encoding='utf8')
print('CLAIMS',len(claims)); print(rob.to_string(index=False)); print(thin[['thickness_mm','P_D','coverage_ice','P_D_all']].to_string(index=False))
