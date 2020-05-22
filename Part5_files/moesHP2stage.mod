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

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the COP of the Two Stage Heat Pump
---------------------------------------------------------------------------------------------------------------------------------------*/
param T_source_HP=293.15; #Assumption
	
param COP_LP{t in Time} := carnot_LP[t]*(Theating['LowT']+273.15)/(Theating['LowT']+273.15-T_lake[t]);
param COP_HP{t in Time} := carnot_HP[t]*(Theating['MediumT']+273.15)/(Theating['MediumT']+273.15-T_source_HP);
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of Electriciy as a function of the COP
---------------------------------------------------------------------------------------------------------------------------------------*/
#The max heating supply at HP is 6000
#The max heating supply at LP is 5350; 
#For simplification, we take Qheatingsupply['HP2stage_LP'] = Qheatingsupply['HP2stage_HP'] = Qheatingsupply['HP2stage'] 

let Qheatingsupply['HP2stage'] := 12000; 

param Wcompressor_HP2stage_LP{t in Time}:= 0.5*Qheatingsupply['HP2stage']/COP_LP[t];		#Power of LP compressor of the two stage HP
param Wcompressor_HP2stage_HP{t in Time}:= 0.5*Qheatingsupply['HP2stage']/COP_HP[t];		#Power of HP compressor of the two stage HP
 
for {t in Time}{
  	let Flowin_HP2stage["Electricity","HP2stage",t] := Wcompressor_HP2stage_LP[t] + Wcompressor_HP2stage_HP[t]  ;
 }
 
 

 