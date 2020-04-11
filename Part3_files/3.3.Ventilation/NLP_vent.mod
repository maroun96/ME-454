################################
# DTmin optimisation
################################
# Sets & Parameters
reset;
set Time default {};        				#your time set from the MILP 
set Buildings default {};					# set of buildings
set MediumTempBuildings default {};			# set of buildings heated by medium temperature loop
set LowTempBuildings default {};			# set of buildings heated by low temperature loop


param Text{t in Time};  #external temperature - Part 1
param top{Time}; 		#your operating time from the MILP part
param Areabuilding		>=0.001; #defined .dat file.

param Tint 				:= 21+273.15; # internal set point temperature [C]
param mair 				:= 2.5; # m3/m2/h
param Cpair 			:= 1.152; # kJ/m3K
param Uvent 			:= 0.025; # air-air HEX


param EPFLMediumT 		:= 65+273.15; #[degC]
param EPFLMediumOut 	:= 30+273.15; #[degC]

param CarnotEff 		:= 0.55; #assumption: carnot efficiency of heating heat pumps
param Cel 				:= 0.20; #[CHF/kWh] operating cost for buying electricity from the grid

param THPhighin 		:= 7+273.15; #[deg C] temperature of water coming from lake into the evaporator of the HP
param THPhighout 		:= 3+273.15; #[deg C] temperature of water coming from lake into the evaporator of the HP
param Cpwater			:= 4.18; #[kJ/kgC]

param i 				:= 0.06 ; #interest rate
param n 				:= 20; #[y] life-time
param FBMHE 			:= 4.74; #bare module factor of the heat exchanger
param INew 				:= 605.7; #chemical engineering plant cost index (2015)
param IRef 				:= 394.1; #chemical engineering plant cost index (2000)
param aHE 				:= 1200; #HE cost parameter
param bHE 				:= 0.6; #HE cost parameter

################################
# Variables

var Text_new{t in Time} 	>= Text[t]; #[degC]
var Trelease{Time}	>= 0+273.15; #[degC]
var Qheating{Time} 	>= 0; #your heat demand from the MILP part, is now a variable.

var E{Time} 		>= 0; # [kW] electricity consumed by the heat pump (using pre-heated lake water)
var TLMCond 	 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var TLMEvap 		>= 0.001; # K] logarithmic mean temperature in the evaporator of the heating HP (using pre-heated lake water)
var Qevap{Time} 	>= 0; #[kW] heat extracted in the evaporator of the heating HP (using pre-heated lake water)
var Qcond{Time} 	>= 0; #[kW] heat delivered in the condensor of the heating HP (using pre-heated lake water)
var COP{Time} 		>= 0.001; #coefficient of performance of the heating HP (using pre-heated lake water)

var OPEX 			>= 0.001; #[CHF/year] operating cost
var CAPEX 			>= 0.001; #[CHF/year] annualized investment cost
var TC 				>= 0.001; #[CHF/year] total cost

var TLMEvapHP 		>= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP (not using pre-heated lake water

var TEvap 			>= 0.001+273.15; #[degC]
var Heat_Vent{Time} >= 0; #[kW]
var DTLNVent{Time} 	>= 0.001; #[degC]
var Area_Vent 		>= 0.001; #[m2]
var DTminVent 		>= 2; #[degC]

var Flow{Time} 		>= 0; #lake water entering free coling HEX
var MassEPFL{Time} 	>= 0; # MCp of EPFL heating system [KJ/(s degC)]

var Uenv{Buildings} >= 0; # overall heat transfer coefficient of the building envelope 

#### Building dependent parameters

param irradiation{Time};# solar irradiation [kW/m2] at each time step									
param specElec{Buildings,Time} default 0;
param FloorArea{Buildings} default 0; #area [m2]
param k_th{Buildings} default 0; # thermal losses and ventilation coefficient in (kW/m2/K)
param k_sun{Buildings} default 0;# solar radiation coefficient [−]
param share_q_e default 0.8; # share of internal gains from electricity [-]
param specQ_people{Buildings} default 0;# specific average internal gains from people [kW/m2]

################################
# Constraints
################################

## VENTILATION

subject to Uenvbuilding{b in MediumTempBuildings}: # Uenv calculation for each building based on k_th and mass of air used
		Uenv[b] = k_th[b]-mair/3600*Cpair;
	
subject to VariableHeatdemand {t in Time}: #Heat demand calculated as the sum of all buildings -> medium temperature
		# if Text[t] < 16  then
			Qheating[t] = sum{b in MediumTempBuildings} max(FloorArea[b]*(k_th[b]*(Tint-Text[t]) - k_sun[b]*irradiation[t]-specQ_people[b] - share_q_e*specElec[b,t]),0)
;	

subject to Heat_Vent1 {t in Time}: #HEX heat load from one side;
		Heat_Vent[t] = mair*Cpair/3600*(Text_new[t]-Text[t])	;
		
subject to Heat_Vent2 {t in Time}: #HEX heat load from the other side;
		Heat_Vent[t]=mair*Cpair/3600*(Tint-Trelease[t]);	

subject to DTLNVent1 {t in Time}: #DTLN ventilation -> pay attention to this value: why is it special?
		DTLNVent[t] = ((Text_new[t]-Tint)-(Text[t]-Trelease[t]))/(log(Text_new[t]-Tint)-log(Text[t]-Trelease[t]));

subject to Area_Vent1 {t in Time}: #Area of ventilation HEX
		Area_Vent >= Heat_Vent[t]/(DTLNVent[t]*Uvent);	

subject to DTminVent1 {t in Time}: #DTmin needed on one side of HEX
		DTminVent <= Tint - Text_new[t];

subject to DTminVent2 {t in Time}: #DTmin needed on the other side of HEX 
		DTminVent <= Trelease[t] - Text[t];

## MASS BALANCE

subject to Flows{t in Time}: #MCp of EPFL heating fluid calculation.
		MassEPFL[t] = Qheating[t]/(EPFLMediumT - EPFLMediumOut);		

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEvaporator{t in Time}: #water side of evaporator that takes flow from lake (Reference case)
		Qevap[t] = Flow[t]*Cpwater*(THPhighin-THPhighout);	

subject to QCondensator{t in Time}: #EPFL side of condenser delivering heat to EFPL (Reference case)
		Qcond[t] = MassEPFL[t]*(EPFLMediumT-EPFLMediumOut);		

subject to Electricity1{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the heat extracted (Reference case)
		E[t] = Qcond[t]-Qevap[t];

subject to Electricity{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the COP (Reference case)
		E[t] = Qcond[t]/COP[t];	

subject to COPerformance{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator (Reference case)
		COP[t] = CarnotEff*TLMCond/(TLMCond-TLMEvap);	

subject to dTLMCondensor{t in Time}: #the logarithmic mean temperature on the condenser, using inlet and outlet temperatures. Note: should be in K (Reference case)
		TLMCond= (EPFLMediumT-EPFLMediumOut)/log(EPFLMediumT/EPFLMediumOut);	

subject to dTLMEvaporatorHP{t in Time}: #the logarithmic mean temperature can be computed using the inlet and outlet temperatures, Note: should be in K (Reference case)
		TLMEvap = (THPhighin-THPhighout)/log(THPhighin/THPhighout);	

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEPFLausanne{t in Time}: #the heat demand of EPFL should be supplied by the the HP.
		Qcond[t] = Qheating[t];	

subject to OPEXcost: #the operating cost can be computed using the electricity consumed in the HP.
		OPEX = sum{t in Time}  Cel*E[t];

subject to CAPEXcost: #the investment cost can be computed using the area of the ventilation heat exchanegr
		CAPEX = (aHE*Area_Vent^bHE)*INew/IRef*FBMHE*i*(1+i)^n/((1+i)^n-1);	

subject to TCost: #the total cost can be computed using the operating and investment cost
		TC = OPEX + CAPEX;

################################
minimize obj : TC;