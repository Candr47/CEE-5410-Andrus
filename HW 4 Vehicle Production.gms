$ontext
CEE 5410 - Water Resource Systems Analysis
Homework 3 Vehicle Production Problem

THE PROBLEM:

A motor vehicle company is planning production for the upcoming year to maximize profits.

Decision Variables: Number of trucks (Xtruck, #) , number of sedans (Xsedan , #)

Objective Function: maximize profit = Z = 100Xtruck + 110Xsedan

Constraints: Xtruck + Xsedan <= 10000 vehicles/units
             2Xtruxk + Xsedan <= 14000 fuel tanks
             Xtruck + 2Xsedan <= 18000 rows of seats
             Xtruck           <= 6000 four-wheel drive

Solution: Use GAMS to solve this linear program

Caitlyn Andrus
a02312721@usu.edu
September 24, 2025
$offText

*Define the sets
Sets vehicles produced /Truck, Sedan/
     materials materials needed /Units, Fuel, Seats, Wheels/;

*Define input data
Parameters
    c(vehicles) Objective function coefficients ($ per vehicle)
            /Truck 100,
            Sedan 110/
    b(materials) Right hand constraint values (per material)
            /Units 10000,
            Fuel 14000,
            Seats 18000,
            Wheels 6000/;

Table A(vehicles,materials) Left hand side of the constraint coefficients
            Units   Fuel    Seats   Wheels
    Truck    1       2      1        1
    Sedan     1       1      2        0;

*Define the variables
Variables X(vehicles) vehicles produced (number)
        VProfit total profit ($);

*non-negativity constraints
Positive Variables X;

*Combine variables and data in Equations
Equations
    Profit Total profit ($) and objective function value
    Materials_Constraints(materials) Material constraints;

Profit..                    VProfit =E= Sum(vehicles, c(vehicles)*X(vehicles));
Materials_Constraints(materials)..  SUM(vehicles, A(vehicles,materials)*X(vehicles)) =L= b(materials);

*define the model from the equations
Model Production /Profit, Materials_Constraints/;

*solve the Model to moximize Vprofit
Solve Production using LP maximizing VProfit;
