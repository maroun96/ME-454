/*---------------------------------------------------------------------------------------------------------------------------------------
Set the COP of the Two Stage Heat Pump
---------------------------------------------------------------------------------------------------------------------------------------*/
param T_heatingmax_HP2stage := 65+273; #Maximum heating temperature is at 65C

#We exchange at a maximum temperature of 65C, Delta
param T_sink_HP2stage := T_heatingmax_HP2stage + dTmin;

#COP
param COP_HP2stage{t in Time}:= (eff_Carnot*T_sink_HP2stage/(T_sink_HP2stage - T_source[t]));
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of Electriciy as a function of the COP
---------------------------------------------------------------------------------------------------------------------------------------*/
subject to HP2stage_elec{t in Time}:
	Flowin['Electricity','HP2stage']  * mult_t['HP2stage',t] = Qheatingsupply['HP2stage'] * mult_t['HP2stage',t] / COP_HP2stage[t];
