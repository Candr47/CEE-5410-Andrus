$ontext

network shipping problem


$offText

* Step 1. Define the sets
sets manufac the manufactureres /Arnold, SuperShelf/
    supply the suppliers /Thomas, Washburn/
    recip the recipients /Zrox, Hewes, RockWright/;
    
* Step 2. Define the input data
Parameter
    Capacity(manufac) the capacity of the manufacturers
            /Arnold 75,
            SuperShelf 75/
            
    Demand(recip) the demand of each recipient
            /Zrox 50
            Hewes 60,
            RockWright 40/;

Table A(manufac,supply) the cost of shipping from manufacturers to suppliers
            Thomas  Washburn
Arnold         5        8
Supershelf     7        4;

Table B(supply, recip) the cost of shipping from the suppliers to the recipients
            Zrox    Hewes   RockWright
Thomas       1        5         8
Washburn     3        4         4;

* Step 3. Define the Variables
variables X(manufac, supply) the number of units shipped from manufacturers to suppliers
        Y(supply,recip) the number of units shipped from suppliers to recipients
        Cost total cost of shipping;
*non negativity
positive variables X,Y;

* Step 4. Define Equations using variables and data
Equations
    TotalCost the total cost of shipping
    ManufacCapacity(manufac) the constraint on manufacturing capcity
    DemandConstraint(recip) the constraint to make sure the demand is met for each recipient
    MtoSConstraint(supply) the constraint for all M to S to be greater than S to R;

TotalCost.. Cost =E= sum((manufac,supply), A(manufac,supply)*X(manufac,supply)) + sum((supply,recip), B(supply,recip)*Y(supply,recip));

ManufacCapacity(manufac).. sum(supply , X(manufac,supply)) =L= Capacity(manufac);

DemandConstraint(recip)..   sum(supply,Y(supply,recip)) =G= Demand(recip);

MtoSConstraint(supply)..   sum(manufac, X(manufac,supply)) =G= sum(recip, Y(supply,recip));


* Step 5. Define the model from the Equations
Model Shipping all the shipping /All/;

* Step 6. Solve the model
Solve Shipping using LP Minimizing Cost;





