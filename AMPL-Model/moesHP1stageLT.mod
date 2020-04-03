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
for{t in Time}{
	ler Flowin_hp["Electricity", "HP1stgeLT", t] := Qheating["HP1stageLT"] / COP_HP1stageLT[t];
