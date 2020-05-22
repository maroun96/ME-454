/*---------------------------------------------------------------------------------------------------------------------------------------
Set the Carnot factor of the Two Stage Heat Pump
---------------------------------------------------------------------------------------------------------------------------------------*/


#Refrigerant 21
#Low Pressure 
param a_LP=9.84064e-05;
param b_LP=0.0141694;
param c_LP=0.329747;
#High Pressure
param a_HP=0.000385189;
param b_HP=0.00800024;
param c_HP=0.588206;

#Carnot factor calculation
param carnot_LP{t in Time} := a_LP*Text[t]^2+b_LP*Text[t]+c_LP;
param carnot_HP{t in Time} := a_HP*Text[t]^2-b_HP*Text[t]+c_HP;

/*var carnot_LP{Time} >=0.001;
var carnot_HP{Time} >=0.001;

subject to carnot_Low {t in Time}:
	carnot_LP[t]=a_LP*Text[t]^2+b_LP*Text[t]+c_LP;
	
subject to carnot_Hig {t in Time}:
	carnot_HP[t]=a_HP*Text[t]^2-b_HP*Text[t]+c_HP;*/
	
/*---------------------------------------------------------------------------------------------------------------------------------------
Set the COP of the Two Stage Heat Pump
---------------------------------------------------------------------------------------------------------------------------------------*/
param T_source_HP=293.15; #Assumption

/*var COP_LP{Time} >=0.001;
var COP_HP{Time} >=0.001;
subject to cop_lp {t in Time}:
	(Theating['LowT']+273.15-T_lake[t])*COP_LP[t]=carnot_LP[t]*(Theating['LowT']+273.15);
	
subject to cop_hp {t in Time}:
	(Theating['MediumT']+273.15-T_source_HP)*COP_HP[t]=carnot_HP[t]*(Theating['MediumT']+273.15);
*/
	
param COP_LP{t in Time} := carnot_LP[t]*(Theating['LowT']+273.15)/(Theating['LowT']+273.15-T_lake[t]);
param COP_HP{t in Time} := carnot_HP[t]*(Theating['MediumT']+273.15)/(Theating['MediumT']+273.15-T_source_HP);
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of Electriciy as a function of the COP
---------------------------------------------------------------------------------------------------------------------------------------*/
let Qheatingsupply['HP2stage'] := 3000; 
#var Wcompressor_HP2stage{Time} >= 0;

param Wcompressor_HP2stage{t in Time}:= Qheatingsupply['HP2stage']/COP_LP[t]+Qheatingsupply['HP2stage']/COP_HP[t];		#Power of one compressor of the two stage HP
	 
for {t in Time}{
  	let Flowin_HP2stage["Electricity","HP2stage",t] := Wcompressor_HP2stage[t];
 }
 

 