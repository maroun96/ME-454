/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of the boiler
http://2050-calculator-tool-wiki.decc.gov.uk/costs/573

---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_el_Boiler default 0.2;
param eff_th_Boiler default 0.94;

let Qheatingsupply['Boiler'] := 1000; #Reference size of the boiler unit
param Elec_Boiler:=Qheatingsupply['Boiler']/eff_th_Boiler*eff_el_Boiler;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of natural gas as a function of efficiency
---------------------------------------------------------------------------------------------------------------------------------------*/
let Flowin['Natgas','Boiler'] := Qheatingsupply['Boiler'] / eff_th_Boiler; 
let Flowout['Electricity','Boiler'] := Flowin['Natgas','Boiler'] * eff_el_Boiler; 

