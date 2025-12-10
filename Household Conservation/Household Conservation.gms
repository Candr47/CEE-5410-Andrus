$onText

The purpose of this model is to optimize household water usage based on different conservation actions.

Conservation efforts are focused on different end uses, and what short-term and long-term actions can be taken to
save water with each end use.

The end uses are: shower, toilet, faucet, laundry, dishwasher, and outdoor use.
Faucet includes handwashing, culinary, and handwashing dishes.

The objective function is to minimize the cost of water used in a year. Assume $6.64 per 1000 gal of water.

Dimensions: End uses, long-term actions, short-term actions.

Decision Variables:
    X: volume of water for each end use
    Y: Action for each long-term end use
    Z: Action for each short-term end use

State Variables:
    TotalX: Total volume of water from all end uses
    Cost: cost of water used

Constraints:
    Water Volume per end use >= Minimum Volume
    For each end use (i)
        X >= Current Volume - (water saved)*Y - (water saved)*Z
        Y <= (willingness to do action i) [0,1]
        Z <= (willingness to do action i) [???] how to represent preference without doing every action to minimize cost???

A Monte Carlo simulation will be used but for now I'm starting with a single model with made up input survey values.

$offText

** Just the linear program

* Step 1. Define the Sets
sets X end uses /Shower, Toilet, Faucets, Laundry, Dishwasher, Outdoor/
    Y short term actions /ShortShowers, LessShowers, LessToilet, LessFaucet, LessLaundry, LessDishLoads, ShortIrrigation, LessIrrigation/
    Z long term actions /LowFlowShower, LowFLowToilet, AeratorFaucet, HELaundry, HEDishwasher, ReduceYard/
    Data input data columns /RateStd, RateEff, Duration, Frequency, InvestCost/
* 1a. Define subsets for to assign short term actions to the data they change
    YDuration(Y) actions that reduce duration /ShortShowers, ShortIrrigation/
    YFrequency(Y) actions that reduce frequency /LessShowers, LessToilet, LessFaucet, LessLaundry, LessDishLoads, LessIrrigation/;

* 1b. Map actions to end uses
Set MapYX(Y, X)
        /ShortShowers . Shower,
        LessShowers .Shower,
        LessToilet .Toilet,
        LessFaucet .Faucets,
        LessLaundry .Laundry,
        LessDishLoads .Dishwasher,
        ShortIrrigation .Outdoor,
        LessIrrigation .Outdoor/;
Set MapZX(Z, X)
        /LowFlowShower .Shower
        LowFlowToilet .Toilet
        AeratorFaucet .Faucets
        HELaundry .Laundry
        HEDishwasher .Dishwasher
        ReduceYard .Outdoor/;

* Step 2. Define the input data
* 2a. Define the parameter to match the excel data
Parameter InputData(X,Data) the input data from excel (and the survey)
          MaxReduction(Y) the max duration and frequency can be reduced by short term actions
          PrefScoreY(Y) User preference for short term actions (1-10)
          PrefScoreZ(Z) User Preference for long term actions (1-10);

* 2b. Load the input data for current water used
$call gdxxrw.exe Household_Input_Data.xlsx par=InputData rng=Sheet2!A3:G6 rDim=1 cDim=1 out=Household_Input_Data.gdx
$gdxIn Household_Input_Data.gdx
$load InputData
$gdxIn

$call gdxxrw.exe Household_Input_Data.xlsx par=MaxReduction rng=Sheet2!I3:N9 rDim=1 cDim=1 out=Household_Input_Data.gdx
$gdxIn Household_Input_Data.gdx
$load MaxReduction
$load PrefScoreY
$load PrefScoreZ
$gdxIn

* 2c. Put the input data into parameters
Parameters RateStd(X)       The standard flow rate (gallons per minute or gallons per load)
            RateEff(X)      The efficient flow rate for new appliances (GPM or GPL)
            Duration(X)     The duration for each end use X
            Frequency(X)    The frequency of use for each end use X
            InvestCost(X)   The investment cost for buying a new appliance ($);
            
 RateStd(X)     =InputData(X, 'RateStd');
 RateEff(x)     =InputData(X, 'RateEff');
 Duration(X)    =InputData(X, 'Duration');
 Frequency(X)   =InputData(X, 'Frequency');
 InvestCost(X)  =InputData(X, 'InvestCost');
 
* 2d. Define the rest of the parameters using the input data 
Parameters CurrentUse(X)    The volume of current water used by the household
*Equation for current use: GPM * minutes *uses per week = Weekly Gallons used
CurrentUse(X)   = RateStd(X) * Duration(X) * Frequency(X);

Scalars WaterPrice Cost per gallon of water ($) /0.00664/
        PenaltyWeight Cost penalty per discomfort point ($) /10/
        MaxScore Maximum preference score /10/;
        
* Step 3. Define the Variables
Variables   TotaCost            Objective function value ($)
            DoZAction(Z)        Binary variable to represent if a long term action is taken 1:do 0:don't
            DoYAction(Y)        Variable to represent if a short term action is taken
            TotalInvestCost     Total cost of implementing long term actions ($)
            TotalWaterYear      Total water used per year (gallons)
            WaterEndUse(X)      Total water used per end use (gallons);

Binary Variable DoZAction(Z);

Positive Variables DoYAction(Y), WaterEndUse(X);

* Step 4. Define the equations using the variables
Equations   TotalBenefit        Objective function ($)
            TotalInvest         The total cost of long term actions ($)
            TotalWaterUsed      The total water used in a year after conservation actions (gallons)
            WaterUsed(X)        The water used for each end use after actions are taken
            DiscomfortCostY(Y)  The virtual cost for each short term action ($)
            DiscomfortCostZ(Z)  The virtual cost for each long term action ($);

WaterUsed(X).. WaterEndUse(X) =e= (RateStd(X) * (1-DoZAction(Z) +(RateEff(X) * doZAction(Z)) * (Duration(X) - YDuration(Y)) * (Frequency(X) - YFrequency(Y));
TotalInvest..    =e= sum(Z, InvestCost(X) * DoZAction(Z));
TotalWaterUsed.. =e= sum(X,WaterUsed(X)) * 52;

DiscomfortCostY(Y).. = (MaxScore - PrefScore_Y(Y)) * PenaltyWeight;            
DiscomfortCostZ(Z).. = (MaxScore - PrefScore_Z(Z)) * PenaltyWeight;

TotalBenefit.. =e= TotalInvest + (TotalWaterUsed * WaterPrice) +sum(Y, DiscomfortCostY(Y) * DoYAction(Y)) +sum(Z, DiscomfortCostZ(Z) * DoZAction(Z));



* Step 5. Define the model
Model WaterConservation /all/;
Solve WaterConservation using MINLP minimizing TotalBenefit;

