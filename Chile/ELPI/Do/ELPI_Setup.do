* ELPI_Setup 1.00                dh:2012-07-23                  Damian C. Clarke
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
clear all
version 11
cap log close
set more off
set mem 100m

*GLOBALS & LOCALS
global PATH "~/investigacion/Activa/Twins/Chile/ELPI"
global DATA "~/database/ELPI/Base"
global COMPUTER "damiancclarke"
global DO "$PATH/Do"
global LOG "$PATH/Log"

log using "$LOG/ELPI_Setup.txt", text replace

********************************************************************************
*** (1) Create relevant vars from Hogar database
********************************************************************************
use $DATA/Hogar
bys folio: egen fert=total(a16==6) //a16==6 is sibling of index child
replace fert=fert+1

gen child=1 if a16==6 | a16==13 //a16==13 is child chosen to be followed
gsort folio child -a19 
bys folio: gen birthorder=_n if child==1

bys folio: gen m_age=a19 if a16==1
bys folio: egen mother_age=mean(m_age)
gen m_age_birth=mother_age-a19 if a16==6 | a16==13
drop m_age
replace m_age_birth=. if m_age_birth<10
gen m_age_sq=m_age_birth^2

gen educ=1 if b02n==19|b02n==99
replace educ=2 if b02n<=4
replace educ=3 if b02n>4 & b02n<=7
replace educ=4 if b02n>7 & b02n<=11 & b02c<4
replace educ=5 if b02n>7 & b02n<=11 & b02c>=4
replace educ=6 if b02n==12|b02n==14
replace educ=7 if b02n==16
replace educ=8 if b02n==13|b02n==15
replace educ=9 if b02n==17|b02n==18
label def educ_lab 1 "None" 2 "Pre-school" 3 "Primary" ///
4 "Secondary incomplete"  5 "Secondary complete" 6 "Technical incomplete" ///
7"University incomplete" 8"Technical complete" 9 "University Complete"
label val educ educ_lab
gen mateduc=educ if a16==1
bys folio: egen mother_educ=mean(mateduc)
gen primary=(educ<4)
gen secondary=(educ>=5&educ<=7)
gen tertiary=(educ>7&educ!=.)

*Gen family income, replacing for ranges
gen family_income=d11m
replace family_income=50000 if d11t==1
replace family_income=98000 if d11t==2
replace family_income=191000 if d11t==3
replace family_income=300000 if d11t==4
replace family_income=400000 if d11t==5
replace family_income=550000 if d11t==6
replace family_income=750000 if d11t==7
replace family_income=950000 if d11t==8
replace family_income=1150000 if d11t==9
replace family_income=1500000 if d11t==10
replace family_income=. if family_income==99

bys folio: egen family_inc=max(family_income)
drop family_income

gen ypc=family_inc/tot_per

rename a18 sex
gen indigenous=(a23!=10&a23!=99)

label var m_age_birth "Age of mother at child's birth"
label var sex "Gender"
label var family_inc "Monthly family income"
label var educ "Education level (not years)"
label var mother_age "Current age of mother"
label var child "Selected child or sibling"
label var fert "Sibship size of selected child"
label var birthorder "Order of births in child's family"
label var ypc "Income per person in the household"
label var mother_educ "Maternal education (of followed child)"


keep folio a16 a19 orden tot_per d11m fexp_hog fert birthorder mother_age /*
*/ m_age_birth educ family_inc sex indigenous child ypc mother_educ m_age_sq

********************************************************************************
*** (2) Create relevant vars from Entrevistada database
********************************************************************************
merge m:1 folio using $DATA/Entrevistada

gen twin=(a03!=5)
*gen child=1 if a16==6 | a16==13
sort folio a03 child a19
bys folio: gen agedif=a19[_n+1]-a19[_n] 
replace agedif=agedif*child
gen agedif2=agedif[_n-1]
replace agedif2=agedif2*child

rename g01 preg_No_attention 
replace preg_No_attention=. if preg_No_attention==9
rename g02 preg_numcontrols
replace preg_numcontrols=. if preg_numcontrols==9
gen preg_anemia=(g03_08==8)

replace g05b=. if g05b>4
rename g05b preg_nutrition
label def nutr 1 "Low weight" 2 "Normal" 3 "Overweight" 4 "Obese"  
label val preg_nutrition nutr
replace g06a=. if g06a>4
rename g06a preg_nutrition_dur
label val preg_nutrition_dur nutr

gen preg_smoked=g07a==1
gen preg_drugs=g11b
replace preg_drugs=. if preg_drugs==8

gen preg_alcohol=g09
replace preg_alcohol=. if preg_alcohol==8

gen preg_publichosp=g16==1

label var preg_No_attention "Mother received no medical attention during pregnancy"
label var preg_numcontrols "Number of pregnancy controls"
label var preg_anemia "Mother suffered from Anemia during pregnancy"
label var preg_nutrition "Mother's nutritional status before pregnancy"
label var preg_nutrition_dur "Mother's nutritional status during pregnancy"

gen poor=ypc<32000
rename a19 age
rename area rural


********************************************************************************
*** (3) Run twin predict regressions
********************************************************************************
***(A) LOCALS FOR VARIABLES
local twincontrols_typical m_age_birth m_age_sq indigenous 
local tc_educ i.mother_educ
local twincontrols_1 poor i.mother_educ i.preg_nutrition preg_anemia preg_No_attention /*
*/ preg_smoked i.preg_drugs i.preg_alcohol preg_publichosp
local twincontrols_2 poor mother_educ i.preg_nutrition preg_anemia preg_No_attention /*
*/ preg_smoked i.preg_drugs i.preg_alcohol preg_publichosp
local region i.region i.age rural //note here controlling for age controls for year of birth

***(B) REGRESSIONS
reg twin `twincontrols_typical' `region' if a16==13 [pw=fexp_enc]
outreg2 using $PATH/Results/Outreg/ELPI_twinpredict.xls, excel replace

reg twin `twincontrols_typical' `twincontrols_2' `region' if a16==13 [pw=fexp_enc]
outreg2 using  $PATH/Results/Outreg/ELPI_twinpredict.xls, excel append

reg twin `twincontrols_typical' `twincontrols_1' `region' if a16==13 [pw=fexp_enc]
outreg2 using $PATH/Results/Outreg/ELPI_twinpredict.xls, excel append

reg twin i.birthorder `twincontrols_typical' `region' if a16==13 [pw=fexp_enc]
outreg2 using $PATH/Results/Outreg/ELPI_twinpredict.xls, excel

reg twin i.birthorder `twincontrols_typical' `twincontrols_2' `region' if a16==13 [pw=fexp_enc]
outreg2 using  $PATH/Results/Outreg/ELPI_twinpredict.xls, excel append

reg twin i.birthorder `twincontrols_typical' `twincontrols_1' `region' if a16==13 [pw=fexp_enc]
outreg2 using $PATH/Results/Outreg/ELPI_twinpredict.xls, excel append


sum birthorder `twincontrols_typical' fert poor mother_educ preg_nutrition age rural /*
*/ preg_nutrition preg_nutrition_dur preg_anemia preg_No_attention preg_smoked preg_drugs /*
*/ preg_alcohol preg_publichosp if a16==13
 
 