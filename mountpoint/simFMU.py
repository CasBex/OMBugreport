import pyfmi
import pandas as pd

start_time = 0
final_time = 100
interval = 1

fmu = pyfmi.load_fmu("fmu/wrapped.fmu")

options = fmu.simulate_options()
options["ncp"] = int((final_time-start_time)/interval)

res = fmu.simulate(start_time, final_time, options=options)

df = pd.concat(pd.Series(res[v], name=v) for v in res.keys())
df.to_csv("fmu.csv")
