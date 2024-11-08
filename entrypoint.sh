echo "Simulating native model"
echo "======================="
omc sim.mos
mv native/OMBugreport.wrapped_res.csv native.csv
echo "Exporting CS FMU"
echo "================"
omc -d=evaluateAllParameters --fmiFlags=s:cvode --fmuCMakeBuild=true --fmuRuntimeDepends=modelica exportFMU.mos
echo "Simulating CS FMU"
echo "================="
python simFMU.py
