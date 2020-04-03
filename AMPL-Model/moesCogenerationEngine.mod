/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficienc of the boiler
---------------------------------------------------------------------------------------------------------------------------------------*/
#https://ec.europa.eu/energy/sites/ener/files/documents/Article%2014_1EEDGermanyEN.pdf
#page 27 for 2000 kWe
param eff_el_CogEng default 0.42;
param eff_th_CogEng default 0.48;
#param eff_fumes_CogEng default 0.2432;

let Qheatingsupply['Cogen'] := 2000; #Reference size of the cogeneration unit
param Elec_Cogen:=Qheatingsupply['Cogen']/eff_th_CogEng*eff_el_CogEng;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of natural gas as a function of efficiency
---------------------------------------------------------------------------------------------------------------------------------------*/
let Flowin['Natgas','Cogen'] := Qheatingsupply['Cogen'] / eff_th_CogEng; #+ Qheatingsupply['Cogen']/eff_fumes_CogEng;
let Flowout['Electricity','Cogen']:=Flowin['Natgas','Cogen']*eff_el_CogEng;
	