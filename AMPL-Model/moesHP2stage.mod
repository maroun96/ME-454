/*---------------------------------------------------------------------------------------------------------------------------------------
Set the COP of the Two Stage Heat Pump
---------------------------------------------------------------------------------------------------------------------------------------*/
param T_heatingmax_HP2stage := 65+273; #Maximum heating temperature is at 65C

#We exchange at a maximum temperature of 65C, Delta
param T_sink_HP2stage := T_heatingmax_HP2stage + dTmin;

#COP
param COP_HP2stage=6;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of Electriciy as a function of the COP
---------------------------------------------------------------------------------------------------------------------------------------*/
let Flowin['Electricity','HP2stage'] := Qheatingsupply['HP2stage'] / COP_HP2stage;