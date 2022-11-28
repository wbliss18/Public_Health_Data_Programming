LIBNAME term "Z:\CHS766\TermProject";

DATA test;
SET term.US2020;
*SET term.brfss_nv20;
RUN;

DATA test1;
SET test;

IF VETERAN3 in (1) THEN Veteran = "Yes";
ELSE IF VETERAN3 in (2) THEN Veteran = "No ";

IF _SEX in (1) THEN Sex = "Male  ";
ELSE IF _SEX in (2) THEN Sex = "Female";

IF _IMPRACE in (1) THEN Race = "White                      ";
ELSE IF _IMPRACE in (2) THEN Race = "Black                      ";
ELSE IF _IMPRACE in (3) THEN Race = "Asian                      ";
ELSE IF _IMPRACE in (4) THEN Race = "American Indian / AK Native";
ELSE IF _IMPRACE in (5) THEN Race = "Hispanic                   ";
ELSE IF _IMPRACE in (6) THEN Race = "Other                      ";

IF _AGE_G in (1, 2) THEN Age = "18 - 34";
ELSE IF _AGE_G in (3, 4, 5) THEN Age = "35 - 64";
ELSE IF _AGE_G in (6) THEN Age = "65+    ";

IF EMPLOY1 in (1, 2, 5, 6) THEN Employed = "Yes";
ELSE IF EMPLOY1 in (3, 4, 7, 8) THEN Employed = "No ";

IF _TOTINDA in (1) THEN PhysicallyActive = "Yes";
ELSE IF _TOTINDA in (2) THEN PhysicallyActive = "No ";

IF POORHLTH in (1:30) THEN PoorHealth = "Yes";
ELSE IF POORHLTH in (88) THEN PoorHealth = "No ";

RUN;

* Table 1;

PROC FREQ DATA = test1;
TABLE PoorHealth Veteran Sex Race Age Employed PhysicallyActive / NOCUM;
RUN;

* Table 2;

PROC SURVEYFREQ DATA = test1;
STRATUM _STRWT;
CLUSTER _PSU;
WEIGHT _LLCPWT;

TABLE Veteran*PoorHealth / row chisq;
TABLE Sex*PoorHealth / row chisq;
TABLE Race*PoorHealth / row chisq;
TABLE Age*PoorHealth / row chisq;
TABLE Employed*PoorHealth / row chisq;
TABLE PhysicallyActive*PoorHealth / row chisq;
RUN;

* Table 3;

PROC SURVEYLOGISTIC DATA= test1;
STRATUM _STRWT;
CLUSTER _PSU;
WEIGHT _LLCPWT;

Class PoorHealth Veteran Sex Race Age Employed PhysicallyActive;

MODEL PoorHealth (REF = "No") =  Veteran Sex Race Age Employed PhysicallyActive / LINK = logit CLODDS;

CONTRAST 'Veteran vs Non-Veteran' Veteran -2 /ESTIMATE=exp;

CONTRAST 'Male vs Female' Sex -2 /ESTIMATE=exp;

CONTRAST 'Asian vs White' Race 1 2 1 1 1 /ESTIMATE=exp;
CONTRAST 'Black vs White' Race 1 1 2 1 1 /ESTIMATE=exp;
CONTRAST 'Hispanic vs White' Race 1 1 1 2 1  /ESTIMATE=exp;
CONTRAST 'American Indian / AK Native vs White' Race 2 1 1 1 1 /ESTIMATE=exp;
CONTRAST 'Other vs White' Race 1 1 1 1 2 /ESTIMATE=exp;

CONTRAST '35-64 vs 18-34' Age -1 1 /ESTIMATE=exp;
CONTRAST '65+ vs 18-34' Age -2 -1 /ESTIMATE=exp;

CONTRAST 'Employed vs Not Employed' Employed -2 /ESTIMATE=exp;

CONTRAST 'Physically Active vs Not Active' PhysicallyActive -2 /ESTIMATE=exp;

RUN;


/*

Class Level Information 
Class Value Design Variables 

Veteran No 1         
  		Yes -1  
 
Sex Female 1         
  	Male -1         

Race 	American Indian / AK Native 1 0 0 0 0 
  		Asian 0 1 0 0 0 
  		Black 0 0 1 0 0 
  		Hispanic 0 0 0 1 0 
  		Other 0 0 0 0 1 
  		White -1 -1 -1 -1 -1 

Age 18 - 34 1 0       
  	35 - 64 0 1       
  	64+ -1 -1   
 
Employed 	No 1         
  			Yes -1  
 
PhysicallyActive 	No 1         
  					Yes -1         


*/
