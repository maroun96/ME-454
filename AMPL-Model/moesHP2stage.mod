/*---------------------------------------------------------------------------------------------------------------------------------------
Set the COP of the Two Stage Heat Pump
---------------------------------------------------------------------------------------------------------------------------------------*/
param COP_HP2stage := 6;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of Electriciy as a function of the COP
---------------------------------------------------------------------------------------------------------------------------------------*/
let Qheatingsupply['HP2stage'] := 2000; #kW

let Flowin['Electricity','HP2stage'] := Qheatingsupply['HP2stage'] / COP_HP2stage;