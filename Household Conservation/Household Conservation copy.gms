$onText

The purpose of this model is to optimize household water usage based on different conservation actions.

Conservation efforts are focused on different end uses, and what short-term and long-term actions can be taken to
save water with each end use.

The end uses are: shower, toilet, faucet, laundry, dishwasher, and outdoor use.
Faucet includes handwashing, culinary, and handwashing dishes.

The objective function is to minimize the cost of water used in a year. Assume $6.64 per 1000 gal of water.

Dimensions: End uses, long-term actions, short-term actions.

Decision Variables:
    EndUse: volume of water for each end use
    ShortTerm: Action for each long-term end use
    LongTerm: Action for each short-term end use


$offText
*********************************************************
** Monte Carlo Simulation
*********************************************************

* Step 1. Define the Sets
Set Sim "Simulation runs" /s1*s250/;

sets EndUse end uses /Shower, Toilet, Faucets, Laundry, Dishwasher, Outdoor/
    ShortTerm short term actions /ShortShowers, LessShowers, LessFaucet, LessLaundry, LessDishLoads/
    LongTerm long term actions /LowFlowShower, LowFLowToilet, AeratorFaucet, HELaundry, HEDishwasher/
*    Data input data columns /RateStd, RateEff, Duration, Frequency, InvestCost/

* 1a. Define subsets for to assign short term actions to the data they change
    ShortTermDuration(ShortTerm) actions that reduce duration /ShortShowers/
    ShortTermFrequency(ShortTerm) actions that reduce frequency /LessShowers, LessFaucet, LessLaundry, LessDishLoads/;

* 1b. Define subset for time-based end uses (variable duration)
Set TimeBased(EndUse) /Shower/;

* 1c. Map actions to end uses
Set MapShortTermEndUse(ShortTerm, EndUse)
        /ShortShowers . Shower,
        LessShowers .Shower,
        LessFaucet .Faucets,
        LessLaundry .Laundry,
        LessDishLoads .Dishwasher/;
Set MapLongTermEndUse(LongTerm, EndUse)
        /LowFlowShower .Shower
        LowFlowToilet .Toilet
        AeratorFaucet .Faucets
        HELaundry .Laundry
        HEDishwasher .Dishwasher/;

* Step 2. Define Parameters
Parameters  Duration(EndUse)         The duration for each end use
            Frequency(EndUse)        The frequency of use for each end use     
            MaxReduction(EndUse)     The max duration and frequency can be reduced by short term actions
            WillingShortTerm(ShortTerm)    Willing to do short term actions (0-1)
            WillingLongTerm(LongTerm)      Willing to do long term actions (0-1)
            TimePeriod                The time period in years (1-10)
            OutdoorBase              Random starting volume for outdoor (gallons)
            OutdoorTarget            Target volume for outdoor (gallons)
            OutdoorWillingness       Willingness to close the gap between the base and target outdoor water use;
            
Parameter RateEff(EndUse) The standard flow rate (gallons per minute or gallons per load)
    /Shower      1.5,
    Toilet      1.6,
    Faucets     1.5,
    Laundry     13,  
    Dishwasher  4, 
    Outdoor     5  /;

Parameter RateStd(EndUse) The efficient flow rate for new appliances (GPM or GPL)
    /Shower      2.1,
    Toilet      2.6,
    Faucets     2.2,
    Laundry     31,  
    Dishwasher  6.1, 
    Outdoor     5  /;

Parameter InvestCost(EndUse) The investment cost for buying a new appliance ($)
    /Shower      60,
    Toilet      100,
    Faucets     50,
    Laundry     400,  
    Dishwasher  300, 
    Outdoor     100/;
    
Parameters MCResults(Sim, *)        Summary Results per Run
    MCWaterBefore(Sim, EndUse)      Water use per end use BEFORE actions
    MCWaterAfter(Sim, EndUse)       Water use per end use AFTER actions
    MCActionShort(Sim, ShortTerm)   Short term actions taken (amount of reduction)
    MCActionLong(Sim, LongTerm)     Long term actions taken (1=Yes 0=No)
    MCWillingShort(Sim, ShortTerm)  Was the household willing to do short term? (1=Yes)
    MCWillingLong(Sim, LongTerm)    Was the household willing to do long term? (1=Yes)
    MCOutdoorBase(Sim)              Outdoor base random value
    MCOutdoorTarget(Sim)            Outdoor target random value
    MCOutdoorWilling(Sim)           How willing is the household to reduce outdoor? (0-100%)
    MCWaterSavings(Sim, EndUse)     Volume of water SAVED (Before - After)
    MCBillSavings(Sim)              Total $ saved on water bill
    MCOutdoorReductionVol(Sim)      Volume of outdoor water reduced;
            
Scalars WaterPrice Cost per gallon of water ($) /0.00664/;
        
* Step 3. Define the Variables
Variables   CurrentWaterVol(EndUse)      Volume of water currently used before actions in the time period per end use (gallons)
            TotalCurrentWaterVol         The total water used before actions (gallons)
            WaterEndUseVol(EndUse)       Total water used per end use after conservation actions (gallons)
            TotalWater                   Total water used in the time period (gallons)
            TotalInvestCost              Total cost of implementing long term actions ($)            
            TotalCost                    Objective function value ($)
            DoLongTerm(LongTerm)         Binary variable to represent if a long term action is taken 1:do 0:don't
            DoShortTerm(ShortTerm)       Variable to represent if a short term action is taken
            OutdoorReduction             Amount of outdoor water reduced (gallons);
            
Binary Variable DoLongTerm(LongTerm);

Positive Variables DoShortTerm(ShortTerm),WaterEndUse(EndUse), OutdoorReduction;

WaterEndUseVol.lo(EndUse) = 0;

* Step 4. Define the equations using the variables
Equations   CurrentWaterUse(EndUse) The current water use before actions have been taken in the time period (gallons)
            TotalCurrentWaterUseEQN The equation to find total current water use before actions (gallons)
            WaterUsed(EndUse)       The water used for each end use after conservation actions are taken
            TotalWaterUsed          The total water used in the time period after conservation actions (gallons)
            TotalInvest             The total cost of long term actions ($)
            LimitDuration(EndUse)   Constraint to make sure the duration doesn't exceed the max reduction
            LimitFrequency(EndUse)  Constraint to make sure the frequency doesn't exceed the max reduction
            LimitOutdoor            Constraint to make sure the outdoor reduction doesn't exceed the reasonable range
            TotalCostEQN            Objective function ($);
            
CurrentWaterUse(EndUse).. CurrentWaterVol(EndUse) =e= (RateStd(EndUse) * Duration(EndUse) * Frequency(EndUse) * 52 * TimePeriod)$(not sameas(EndUse,'Outdoor'))
                                                    + (OutdoorBase * 52 * TimePeriod)$(sameas(EndUse,'Outdoor'));
    
TotalCurrentWaterUseEQN.. TotalCurrentWaterVol =e= sum(EndUse, CurrentWaterVol(EndUse));

WaterUsed(EndUse).. WaterEndUseVol(EndUse) =e= (52 * TimePeriod *
    (RateStd(EndUse) * (1 - sum(LongTerm$MapLongTermEndUse(LongTerm,EndUse), DoLongTerm(LongTerm))) + RateEff(EndUse) * sum(LongTerm$MapLongTermEndUse(LongTerm,EndUse), DoLongTerm(LongTerm))) *
    max(0, (Duration(EndUse) - sum(ShortTerm$(MapShortTermEndUse(ShortTerm,EndUse) and ShortTermDuration(ShortTerm)), DoShortTerm(ShortTerm)))) *
    max(0, (Frequency(EndUse) - sum(ShortTerm$(MapShortTermEndUse(ShortTerm,EndUse) and ShortTermFrequency(ShortTerm)), DoShortTerm(ShortTerm)))))$(not sameas(EndUse,'Outdoor')) +
    ( max(0, (OutdoorBase * 52 * TimePeriod) - OutdoorReduction) )$(sameas(EndUse,'Outdoor'));

TotalWaterUsed.. TotalWater =e= sum(EndUse,WaterEndUseVol(EndUse));
TotalInvest..   TotalInvestCost =e= sum((LongTerm,EndUse)$MapLongTermEndUse(LongTerm,EndUse), InvestCost(EndUse) * DoLongTerm(LongTerm));

LimitDuration(EndUse)..  sum(ShortTerm$(MapShortTermEndUse(ShortTerm,EndUse) and ShortTermDuration(ShortTerm)), DoShortTerm(ShortTerm)) =L= MaxReduction(EndUse);
LimitFrequency(EndUse)..  sum(ShortTerm$(MapShortTermEndUse(ShortTerm,EndUse) and ShortTermFrequency(ShortTerm)), DoShortTerm(ShortTerm)) =L= MaxReduction(EndUse);
LimitOutdoor.. OutdoorReduction =L= (OutdoorBase - OutdoorTarget) * 52 * TimePeriod * OutdoorWillingness;
TotalCostEQN.. TotalCost =e= TotalInvestCost + (TotalWater * WaterPrice);

* Step 5. Define the Model
Model WaterConservationMC /all/;

* Step 6. Define the Monte Carlo loop
Loop(Sim,
    
* --- A. GENERATE RANDOM DATA ---
* Generate base data roughly based on realistic ranges
    TimePeriod                  = 10;
    WillingShortTerm(ShortTerm) = UniformInt(0, 1);
    WillingLongTerm(LongTerm)   = UniformInt(0, 1);
    OutdoorWillingness          = UniformInt(0, 1);
    OutdoorBase                 = Uniform(400, 2000);
    
* 1. Initialize all Durations to 1 
    Duration(EndUse) = 1;

* 2. Set specific random Durations for Time-Based uses
    Duration('Shower') = UniformInt(5, 40);

* 3. Set specific random Frequencies (Weekly Uses)
    Frequency('Shower') = UniformInt(5, 35);
    Frequency('Toilet') = UniformInt(30, 100);
    Frequency('Faucets') = UniformInt(40, 120);
    Frequency('Laundry') = UniformInt(1, 9);
    Frequency('Dishwasher') = UniformInt(1, 10);
* Outdoor frequency is handled by the Base Volume logic below, but set to 1 to be safe
    Frequency('Outdoor') = 1;

* Calculate MaxReduction (Here defined as 40% of the base Duration/Frequency)
    MaxReduction(EndUse) = 0; 

* If an end use has duration actions, max reduction is 40% of Duration
    MaxReduction(EndUse)$(sum(ShortTerm$(MapShortTermEndUse(ShortTerm,EndUse) and ShortTermDuration(ShortTerm)),1)) = Duration(EndUse) * 0.40;

* If an end use has frequency actions, max reduction is 40% of Frequency
    MaxReduction(EndUse)$(sum(ShortTerm$(MapShortTermEndUse(ShortTerm,EndUse) and ShortTermFrequency(ShortTerm)),1)) = Frequency(EndUse) * 0.40;
    
* If Willing is 0, the upper bound is 0 (cannot do action)
    DoShortTerm.up(ShortTerm)$ShortTermDuration(ShortTerm) = sum(EndUse$MapShortTermEndUse(ShortTerm,EndUse), Duration(EndUse)) * 0.40 * WillingShortTerm(ShortTerm);
    DoShortTerm.up(ShortTerm)$ShortTermFrequency(ShortTerm) = sum(EndUse$MapShortTermEndUse(ShortTerm,EndUse), Frequency(EndUse)) * 0.40 * WillingShortTerm(ShortTerm);
        
* If Willing=0, .up becomes 0. The solver cannot choose to invest.
* If Willing=1, .up becomes 1. The solver CAN choose to invest, but will only do so if it saves money.
    DoLongTerm.up(LongTerm) = WillingLongTerm(LongTerm);
    
* Target Volume: Randomly 30% to 85% of the Base Volume
    OutdoorTarget = OutdoorBase * Uniform(0.30, 0.85);
    
* --- B. SOLVE ---
    Solve WaterConservationMC using MINLP minimizing TotalCost;

* --- C. STORE RESULTS ---
* Summary Stats
    MCResults(Sim, 'ObjValue')     = TotalCost.l;
    MCResults(Sim, 'TotalWater_Current') = TotalCurrentWaterVol.l;
    MCResults(Sim, 'TotalWater_After')   = TotalWater.l;
    MCResults(Sim, 'InvestCost')   = TotalInvestCost.l;
    
    WillingShortTerm(ShortTerm)$(WillingShortTerm(ShortTerm)=0) = EPS;
    WillingLongTerm(LongTerm)$(WillingLongTerm(LongTerm)=0)     = EPS;
    OutdoorWillingness$(OutdoorWillingness=0)                   = EPS;

* Detailed Breakdowns
    MCWaterBefore(Sim, EndUse)     = CurrentWaterVol.l(EndUse);
    MCWaterAfter(Sim, EndUse)      = WaterEndUseVol.l(EndUse);
    MCActionLong(Sim, LongTerm)   = DoLongTerm.l(LongTerm);
    MCActionShort(Sim, ShortTerm) = DoShortTerm.l(ShortTerm);
    MCWillingShort(Sim, ShortTerm) = WillingShortTerm(ShortTerm);
    MCWillingLong(Sim, LongTerm)  = WillingLongTerm(LongTerm);
    MCOutdoorBase(Sim)            = OutdoorBase;
    MCOutdoorTarget(Sim)          = OutdoorTarget;
    MCOutdoorWilling(Sim)         = OutdoorWillingness;
    

* 1. Water Savings per End Use
    MCWaterSavings(Sim, EndUse) = CurrentWaterVol.l(EndUse) - WaterEndUseVol.l(EndUse);

* 2. Financial Bill Savings
    MCBillSavings(Sim) = (TotalCurrentWaterVol.l - TotalWater.l) * WaterPrice;

* 3. Explicit Outdoor Reduction
    MCOutdoorReductionVol(Sim) = OutdoorReduction.l;
);

* Step 7. Display the results
Option decimals=2;
Display MCResults, MCWaterBefore, MCWaterAfter, MCActionLong, MCWillingLong, MCActionShort,
        MCWillingShort, MCOutdoorBase, MCOutdoorTarget, MCOutdoorWilling,
        MCWaterSavings, MCBillSavings, MCOutdoorReductionVol;

* Step 8. Export Results to Excel
* 1. Dump parameters to GDX
Execute_Unload 'HouseholdConservationData.gdx', 
    MCResults, 
    MCWaterBefore, 
    MCWaterAfter, 
    MCWaterSavings,
    MCBillSavings,
    MCOutdoorReductionVol,
    MCActionLong, 
    MCActionShort, 
    MCWillingLong, 
    MCWillingShort,
    MCOutdoorBase, 
    MCOutdoorTarget, 
    MCOutdoorWilling;

* 2. Write to Excel
Execute 'gdxxrw.exe HouseholdConservationData.gdx O=ConservationResults.xlsx ZeroOut=1 par=MCResults rng=MCResults!A1 par=MCWaterBefore rng=MCWaterBefore!A1 par=MCWaterAfter rng=MCWaterAfter!A1 par=MCActionShort rng=MCActionShort!A1 par=MCActionLong rng=MCActionLong!A1 par=MCWillingShort rng=MCWillingShort!A1 par=MCWillingLong rng=MCWillingLong!A1 par=MCOutdoorBase rng=MCOutdoorBase!A1 par=MCOutdoorTarget rng=MCOutdoorTarget!A1 par=MCOutdoorWilling rng=MCOutdoorWilling!A1 par=MCWaterSavings rng=MCWaterSavings!A1 par=MCBillSavings rng=MCBillSavings!A1 par=MCOutdoorReductionVol rng=MCOutdoorReductionVol!A1';