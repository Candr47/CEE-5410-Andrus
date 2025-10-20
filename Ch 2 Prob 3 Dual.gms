$ontext
CEE 5410 - Water Resource Systems Analysis
Homework 6 Chapter 2 Problem 3 Irrigation Optimization

THE PROBLEM:

An aqueduct can supply water for irrigation.

Decision Variables: Acre of hay (Xhay, acre) , acre of grain (Xgrain, acre)

Objective Function: maximize profit = Z = 100Xhay + 120Xgrain

Constraints: Xhay + XGrain <= 10000 acres land
             2Xhay + XGrain <= 14000 acres in June
             Xhay + 2XGrain <= 18000 acres in July
             Xhay           <= 6000 acres in August

Solution: Use GAMS to solve this linear program

Caitlyn Andrus
a02312721@usu.edu
October 14, 2025
$offText

*Define the sets
Sets crops planted /Hay, Grain/
     quantity quantity needed in acre of acft /Land, June, July, August/;

*Define input data
Parameters
    c(crops) Objective function coefficients ($ per crop)
            /hay 100,
            Grain 110/
    b(quantity) Right hand constraint values (per acre of acft)
            /Land 10000,
            June 14000,
            July 18000,
            August 6000/;

Table A(crops,quantity) Left hand side of the constraint coefficients
            Land   June    July   August
    Hay      1       2      1        1
    Grain     1       1      2        0;

*Define the variables
Variables X(crops) crops planted (number)
        VProfit total profit ($)
        Y(quantity) value of the quantities used (units)
        VCost the total reduced cost ($);

*non-negativity constraints
Positive Variables X,Y;

*Combine variables and data in Equations
Equations
    ProfitPrimal Total profit ($) and objective function value
    QConsPrimal(quantity) Quantity constraints Primal
    CostDual The reduced cost dual ($)
    QConsDual(crops) Profit levels ($);

*Primal Equations
ProfitPrimal..                    VProfit =E= Sum(crops, c(crops)*X(crops));
QConsPrimal(quantity)..      SUM(crops, A(crops,quantity)*X(crops)) =L= b(quantity);

*Dual Equations
CostDual..      VCost =E= sum(quantity,b(quantity)*Y(quantity));
QConsDual(crops)..  sum(quantity,A(crops,quantity)*Y(quantity)) =G= c(crops);


*define the models from the equations
*Primal model
Model PlantingPrimal /ProfitPrimal, QConsPrimal/;
PlantingPrimal.optfile = 1;

*Dual Model
Model PlantingDual /CostDual, QConsDual/;


*solve the Primal Model to moximize Vprofit
Solve PlantingPrimal using LP maximizing VProfit;

Solve PlantingDual using LP minimizing VCost;
