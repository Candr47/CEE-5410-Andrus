$ontext
CEE 5410 - Water Resource Systems Analysis
Homework 6 Chapter 7 Problem 1 Irrigation Optimization




$offText

* Step 1: Define the sets
sets source possible irrigation sources /HiDam, LoDam, Pump/
    season six month irrigation seasons /s1, s2/;

* Step 2: Define the Parameters
Parameters
    CapCost(source) the capital cost to build a source ($)
        /HiDam 10000,
        LoDam 6000,
        Pump 8000/
    OpCost(source) the operating cost ($ per acft)
        /HiDam 0,
        LoDam 0,
        Pump 20/
    Capacity(source) the capacity (acft)
        /HiDam 700,
        LoDam 300,
        Pump 396/
    Inflow(season) the inflow to the river each season (acft)
        /s1 600,
        s2 200/
    Demand(season) the irrigation demand for each season (acft per acre)
        /s1 1,
        s2 3/
*integer parameters  
    IntUpBnd(source) upper bound on integer variables (#)
        /HiDam 1,
        LoDam 1,
        Pump 1/
    IntLoBnd(source) lower bound on integer variables (#)
        /HiDam 0,
        LoDam 0,
        Pump 0/;

* Step 3: Define the variables
VARIABLES I(source) binary decision to build or do prject from source src (1=yes 0=no)
          X(source,season) volume of water provided by source src (ac-ft per year)
          TCost  total capital and operating costs of supply actions ($)
          Storage(source,season) the unused inflow from each season (acft)
          Acres the total acres irrigate (acre);

BINARY VARIABLES I;
* Non-negativity constraints
POSITIVE VARIABLES X,Storage, Acres;

* Step 4: Define Equations
Equations  
    Cost         Total Cost ($) and objective function value
    MaxCap(source,season)     Maximum capacity of source when built (ac-ft per year)
    MeetDemand(season)     Meet demand for each season
    IntUpBound(source) Upper bound on interger variables (number)
    IntLowBound(source) Lower bound on integer variables (number)
    OneDam only one dam can be built
    ResBalance1(source,season) the reservoir balance the first season
    ResBalance2(source,season) the reservoir balance for the second season
    ResCapacity(source,season) the capacity of the reservoir based on the source
    WaterAvailable(season) the water available from the inflow each season;    
    
Cost..      TCost =E= sum(source, CapCost(source)*I(source) + OpCost(source)*sum(season, X(source, season))) - 300*Acres;
MaxCap(source,season)..        X(source,season) =L= Capacity(source)*I(source);
MeetDemand(season)..    sum(source, X(source,season)) =G= Demand(season)*Acres;
IntUpBound(source) ..       I(source) =L= IntUpBnd(source);
IntLowBound(source) ..      I(source) =G= IntLoBnd(source);
OneDam..                    I('HiDam') + I('LoDam') =L= 1;
ResBalance1(source,'s1')$(ord(source) <= 2)..    Storage(source,'s1') =E= Inflow('s1')*I(source) - X(source,'s1');
ResBalance2(source,'s2')$(ord(source) <= 2)..    Storage(source,'s2') =E= Storage(source,'s1') + Inflow('s2')*I(source) - X(source,'s2');
ResCapacity(source,season)$(ord(source) <= 2)..     Storage(source,season) =L= Capacity(source)*I(source);
WaterAvailable(season)..    sum(source, X(source,season)) =L= sum(source$(ord(source)<=2), Inflow(season)*I(source)) + Capacity('Pump')*I('Pump');

* Step 5. DEFINE the Model
MODEL IrrigationSource /ALL/;

* 6. Solve the Model as an LP (relaxed IP)
SOLVE IrrigationSource USING MIP MAXIMIZING TCost;

DISPLAY X.L, I.L, Acres.L, Storage.L, TCost.L;
