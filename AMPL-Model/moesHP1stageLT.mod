/*---------------------------------------------------------------------------------------------------------------------------------------
Set the sink temperature of the HP
---------------------------------------------------------------------------------------------------------------------------------------*/
param T_sinkLT := 50+273+5;
/*---------------------------------------------------------------------------------------------------------------------------------------
Set real COP of HP
---------------------------------------------------------------------------------------------------------------------------------------*/
param COP_HP1stageLT{t in Time}:= (eff_Carnot*T_sinkLT/(T_sinkLT - T_source[t]));
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of electricity as a function of HP
---------------------------------------------------------------------------------------------------------------------------------------*/
subject to HPLT_elec{t in Time}:
	Flowin['Electricity','HP1stageLT'] * mult_t['HP1stageLT',t] = Qheatingsupply['HP1stageLT'] * mult_t['HP1stageLT',t] / COP_HP1stageLT[t];