# Bugreport
CS FMUs generate errors after switching phenomena.
This repository demonstrates the issue.

To run:
```bash
$ docker build . -t ombug --no-cache # no-cache to use the most recent OM nightly
$ docker run -v ./mountpoint:/home/ombug -it ombug
```

## The model
The Modelica model in `mountpoint/OMBugreport` represents a simple building heating system. A constant supply temperature is imposed on the heating fluid (water) and a floor heating model is coupled to a fixed temperature boundary condition. The valve opens and closes periodically every 5s.

## The omc simulation
Openmodelica is perfectly capable of simulating the model. After running the container, the result can be found in `mountpoint/native.csv`.
Simulation settings are to use `cvode` since this is also the solver used in the FMU.
This is mainly to get a good comparison, other solvers also work.

## The FMU simulation
The exported FMU fails simulation at second 6, one second after the first valve switch, due to an excessively large negative pressure.

I hypothesise that the discontinuity in pressure due to the valve switch is used to calculate the gradient of the FMU which results in this very large pressure change.

## Expected result
Both simulations work and produce the same result.
