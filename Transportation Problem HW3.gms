$ontext
CEE 6410 - Water Resources Systems Analysis
Example 2 from linear problems graphical solutions notes

THE PROBLEM:

A company can produce 2 types of cars:  coups and minivans.  Data are as fol-lows:

Seasonal Resource
Inputs or Profit        Car        Resource
Availability
                  Coup                 Minivan
Metal           1000 lbs/car       2000 lbs/car        4x106 metal/year
Circuit Boards  4 unit/car        3 unit/car               1.2x104 units
Labor           5hr/car          2.5/hr car               17,500 hours
Profit/car          $6             $7

                Determine the optimal production for both cars.

THE SOLUTION:
Uses General Algebraic Modeling System to Solve this Linear Program

David E Rosenberg



david.rosenberg@usu.edu
September 15, 2015
$offtext

* 1. DEFINE the SETS
SETS plnt crops growing /Eggplant, Tomatoes/
     res resources /Water, Land, Labor/
* cars for production problem     
    cars Cars to produce /Coup, Minivan/
    materials Materials used to produce cars /Metal, CircuitBoards, Labor/;

* 2. DEFINE input data
PARAMETERS
   c(plnt) Objective function coefficients ($ per plant)
         /Eggplant 6,
         Tomatoes 7/
   b(res) Right hand constraint values (per resource)
          /Water 4000000,
           Land  12000,
           Labor  17500/
    carprofit(cars) The profit per car produced ($car)
            /Coup 6,
            Minivan 7/
    carconstraints(materials) Right hand constraint values (per resource)
            /Metal 4000000,
            CircuitBoards 120000,
            Labor 17500/;
            

TABLE A(plnt,res) Left hand side constraint coefficients
                 Water    Land   Labor
 Eggplant        1000      4       5
 Tomatoes        2000      3       2.5;

TABLE Z(cars,materials) Left hand side constraint coefficients
               Metal    CircuitBoards   Labor
 Coup          1000         4             5
 Minivan       2000         3            2.5;

* 3. DEFINE the variables
VARIABLES X(plnt) plants planted (Number)
          VPROFIT  total profit ($)
          W(cars) cars produced (number)
          CPROFIT total profit from producing cars ($);


* Non-negativity constraints
POSITIVE VARIABLES X, W;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT Total profit ($) and objective function value
   RES_CONSTRAIN(res) Resource Constraints
   PROFITCARS Total profit from producing cars ($)
   MATERIALCONSTRAINTS(materials) Resources used to produce cars;

PROFIT..                 VPROFIT =E= SUM(plnt, c(plnt)*X(plnt));
RES_CONSTRAIN(res) ..    SUM(plnt, A(plnt,res)*X(plnt)) =L= b(res);
PROFITCARS..            CPROFIT=E=SUM(cars, carprofit(cars)*W(cars));
MATERIALCONSTRAINTS(materials)..  SUM(cars, carprofit(cars)) =L= carconstraints(materials);

* 5. DEFINE the MODEL from the EQUATIONS
MODEL PLANTING /PROFIT, RES_CONSTRAIN/;
MODEL PRODUCTION /PROFITCARS, MATERIALCONSTRAINTS/;
*Altnerative way to write (include all previously defined equations)
*MODEL PLANTING /ALL/;


* 6. SOLVE the MODEL
* Solve the PLANTING model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to maximize VPROFIT
SOLVE PLANTING USING LP MAXIMIZING VPROFIT;
SOLVE PRODUCTION USING LP MAXIMIZING CPROFIT;

* 6. CLick File menu => RUN (F9) or Solve icon and examine solution report in .LST file