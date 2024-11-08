package OMBugreport
model MWE "Debug FMU situation"
  parameter Real m_flow_nominal = 0.095;
  parameter Real dp_nominal = 6000;
  replaceable package Medium = Buildings.Media.Water;
  IDEAS.Fluid.HeatExchangers.RadiantSlab.EmbeddedPipe embeddedPipe(redeclare
      package Medium =                                                                      Medium,
      m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal,
    A_floor=1)                                                                                               annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={30,30})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=293.15)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={80,30})));
  IDEAS.Fluid.Sensors.EnthalpyFlowRate senEntFlo1(redeclare package Medium=Medium,
      m_flow_nominal=m_flow_nominal)                                               annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={14,0})));
  IDEAS.Fluid.HeatExchangers.Heater_T hea(m_flow_nominal=m_flow_nominal, redeclare
      package Medium =                                                                            Medium,
    dp_nominal=10)                        annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-52,26})));
  Modelica.Blocks.Sources.Constant const(k=35)
    annotation (Placement(transformation(extent={{-98,-10},{-78,10}})));
  IDEAS.Fluid.Movers.FlowControlled_dp fan(redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal)
    annotation (Placement(transformation(extent={{-46,50},{-26,70}})));
  IDEAS.Fluid.Actuators.Valves.TwoWayLinear val(redeclare package Medium=Medium,
    allowFlowReversal=false,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=10,
    use_inputFilter=false)
    annotation (Placement(transformation(extent={{4,50},{24,70}})));
  IDEAS.Fluid.Sensors.EnthalpyFlowRate senEntFlo(redeclare package Medium=Medium,
      m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{-20,50},{0,70}})));
  Modelica.Blocks.Sources.Constant const1(k=dp_nominal)
    annotation (Placement(transformation(extent={{-86,72},{-66,92}})));
  Modelica.Blocks.Sources.Pulse pulse(width=50, period=10) annotation (
      Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={78,80})));

  Buildings.Fluid.Sources.Boundary_pT bou(nPorts=1, redeclare package Medium=Medium)
    annotation (Placement(transformation(extent={{-42,76},{-22,96}})));
  Buildings.Utilities.IO.SignalExchange.Overwrite oveValve(y(unit="1"), u(unit="1"), description="Override the valve control signal")
    annotation (Placement(transformation(extent={{48,70},{28,90}})));
  Buildings.Utilities.IO.SignalExchange.Read reaQFloHea(y(unit="W"), description="Floor heating heat exchanged")
    "Floor heating heat exchanged"
    annotation (Placement(transformation(extent={{52,-26},{72,-6}})));
equation
  connect(embeddedPipe.heatPortEmb[1], fixedTemperature.port)
    annotation (Line(points={{40,30},{70,30}}, color={191,0,0}));
  connect(senEntFlo1.port_a, embeddedPipe.port_b) annotation (Line(points={{24,-1.72085e-15},
          {30,-1.72085e-15},{30,20}}, color={0,127,255}));
  connect(senEntFlo1.port_b, hea.port_a) annotation (Line(points={{4,7.21645e-16},
          {-52,7.21645e-16},{-52,16}}, color={0,127,255}));
  connect(const.y, hea.TSet)
    annotation (Line(points={{-77,0},{-60,0},{-60,14}}, color={0,0,127}));
  connect(hea.port_b, fan.port_a)
    annotation (Line(points={{-52,36},{-52,60},{-46,60}}, color={0,127,255}));
  connect(val.port_b, embeddedPipe.port_a)
    annotation (Line(points={{24,60},{30,60},{30,40}}, color={0,127,255}));
  connect(fan.port_b, senEntFlo.port_a)
    annotation (Line(points={{-26,60},{-20,60}}, color={0,127,255}));
  connect(senEntFlo.port_b, val.port_a)
    annotation (Line(points={{0,60},{4,60}}, color={0,127,255}));
  connect(const1.y, fan.dp_in)
    annotation (Line(points={{-65,82},{-36,82},{-36,72}}, color={0,0,127}));
  connect(senEntFlo.port_a, bou.ports[1]) annotation (Line(points={{-20,60},{-20,
          58},{-22,58},{-22,74},{-14,74},{-14,86},{-22,86}}, color={0,127,255}));
  connect(pulse.y, oveValve.u)
    annotation (Line(points={{67,80},{50,80}}, color={0,0,127}));
  connect(oveValve.y, val.y)
    annotation (Line(points={{27,80},{14,80},{14,72}}, color={0,0,127}));
  connect(embeddedPipe.QTot, reaQFloHea.u)
    annotation (Line(points={{36,19},{36,-16},{50,-16}}, color={0,0,127}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=1000,
      Tolerance=1e-06, StartTime = 0, Interval = 2));
end MWE;

model wrapped "Wrapped model"
	// Input overwrite
	Modelica.Blocks.Interfaces.RealInput oveValve_u(unit="1", min=-1.7976931348623157e+308, max=1.7976931348623157e+308) "Override the valve control signal";
	Modelica.Blocks.Interfaces.BooleanInput oveValve_activate "Activation for Override the valve control signal";
	// Out read
	Modelica.Blocks.Interfaces.RealOutput reaQFloHea_y(unit="W") = mod.reaQFloHea.y "Floor heating heat exchanged";
	Modelica.Blocks.Interfaces.RealOutput oveValve_y(unit="1") = mod.oveValve.y "Override the valve control signal";
	// Original model
	MWE mod(
		oveValve(uExt(y=oveValve_u),activate(y=oveValve_activate))) "Original model with overwrites";
end wrapped;
end OMBugreport;