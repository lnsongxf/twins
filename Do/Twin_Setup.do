* Twin_Setup 2.00                damiancclarke   	 		  yyyy-mm-dd:2013-11-22    
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*
/* This is has been a pretty major refactorisation of the previous twin setup
file.  To rollback to the previous one, return to the git commit made on Nov 11
2013.  Here we are redefining to only look at reduced form and IV with treament
as described in Black et al, Angrist et al, and also to interact with desired
family size.  Our principal specification for desired is:

quality_{ij}=\beta_0+\beta_1*fert_{j}+\beta_2*fert*desired_{j}+X'\beta+u_{ij}


*/

clear all
version 11.2
cap log close
set more off
set mem 1200m
set maxvar 20000


********************************************************************************
****(1) Globals and locals
********************************************************************************
global PATH "~/investigacion/Activa/Twins"
global DATA "~/database/DHS/DHS_Data"
global LOG "$PATH/Log"
global TEMP "$PATH/Temp"

cap mkdir $PATH/Temp

log using "$LOG/Twins_DHS.txt", text replace
********************************************************************************
*** (2) Take necessary variables from BR (mother births) and PR (household me-
*** mber) The IR dataset has the majority of family and maternal characterist-
*** ics used in the regressions, however there is no child education variables
*** in this dataset.  The child education information comes from PR.
********************************************************************************
***Do in parts as merge of full dataset is impossible with 8gb of RAM
foreach num of numlist 1(1)7 {
	use $DATA/World_BR_p`num', clear

	keep _cou _year caseid v000-v026 v101 v106 v107 v130 v131 v133 v136 v137 /*
	*/ v149 v150 v151 v152 v190 v191 v201 v202 v203 v204 v205 v206 v207 v208 /*
	*/ v209 v211 v212 v213 v228 v229 v230 v437 v438 v445 v457 v463a v481 v501/*
	*/ v504 v602 v605 v715 v701 v730 bord b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11/*
	*/ b12 b13 b14 b15 b16 v613 v614 m19 m19a v367 v312 v364
	
	cap rename v010 year_birth
	cap rename v012 agemay
	cap rename v106 educlevel_f
	cap rename v130 religion
	cap rename v133 educf
	cap rename v137 kids_under5
	cap rename v140 rural
	cap rename v190 wealth
	cap rename v201 fert
	cap rename v212 agefirstbirth
	cap rename v228 terminated_preg
	cap rename v437 weightk
	cap rename v438 height
	cap rename v445 bmi
	cap rename v367 wanted_last_child
	cap rename v312 contracep_method
	cap rename v364 contracep_intent
	cap rename b0 twin
	cap rename b2 child_yob
	cap rename b3 child_dob
	cap rename b4 sex
	cap rename b5 child_alive
	cap rename b8 age 

	replace age=floor(v007-child_yob+(v006-b1/12)) if age==.


	**The following lines correct for the fact that we only observe each births'
	**mothers' relationship to the household head.  In this way, if the mother 
	**is the wife, the birth must be the child of the household head.
	gen relationship=3 if v150==1|v150==2|v150==9
	replace relationship=5 if v150==3|v150==4|v150==11
	replace relationship=8 if v150==6|v150==7
	replace relationship=10 if v150==8|v150==10|v150==12|v150==5
	
	egen id=concat(_cou _year v001 v002)

	save $TEMP/BR`num', replace
}


foreach num of numlist 1(1)7 {
	use $DATA/World_PR_p`num', clear

	keep _cou _year hhid hvidx hv000-hv002 hv101 hv104 hv105 hv106 hv121 hv122/*
	*/ hv123 hv129 hv108

	cap rename hv101 relationship
	cap rename hv104 sex
	cap rename hv105 age
	cap rename hv106 educlevel
	cap rename hv121 attend_year
	cap rename hv129 attend
	cap rename hv108 educ
	rename hv001 v001
	rename hv002 v002
	egen id=concat(_cou _year v001 v002)
	
	save $TEMP/PR`num', replace
}

***Merge PR and BR (still in parts)
foreach num of numlist 1(1)7 {
	use $TEMP/PR`num'
	merge m:m id relationship sex age using $TEMP/BR`num'
	keep if _merge==3|_merge==2 //updated Apr 24, 2013
	save $TEMP/twins`num', replace
}

// Remove partial PR/BR datasets
foreach t in PR BR {
	foreach file in `t'1 `t'2 `t'3 `t'4 `t'5 `t'6 `t'7 {
		rm "$TEMP/`file'.dta"
	}
}

use $TEMP/twins1
append using $TEMP/twins2 $TEMP/twins3 $TEMP/twins4 $TEMP/twins5 $TEMP/twins6 /*
*/ $TEMP/twins7

foreach num of numlist 1(1)7 {
	rm $TEMP/twins`num'.dta
}
rmdir $TEMP

replace _cou="CAR" if hv000=="CF3" &_cou==""
replace _cou="Zimbabwe" if hv000=="ZW6" &_cou==""
replace _year="2004" if hv000=="CF3" &_year==""
replace _year="2010" if hv000=="ZW6" &_year==""

***Year of birth for Nepal (convert from Vikram Samvat to Gregorian calendar)
foreach year of varlist child_yob year_birth {
	replace `year'=`year'+2000 if _cou=="Nepal" & `year'<100
	replace `year'=`year'-57 if _cou=="Nepal"
}
***Year of birth for Ethiopia (convert from Ge'ez to Gregorian calendar)
foreach year of varlist child_yob year_birth {
	replace `year'=`year'+8 if _cou=="Ethiopia"
}

replace child_yob=child_yob+1900 if child_yob<100&child_yob>2
replace child_yob=child_yob+2000 if child_yob<=2
replace year_birth=year_birth+1900 if year_birth<100

save $PATH/Data/DHS_twins, replace

********************************************************************************
*** (3) Setup Variables which are used in TwinRegression
********************************************************************************
use $PATH/Data/DHS_twins, clear

********************************************************************************
*** (3A) Generate sibling size subgroups (1+, 2+, 3+,...)  As per Angrist et al.
********************************************************************************
gen mid="a"
drop id
egen id=concat(_cou mid _year mid v001 mid v002 mid v150 mid caseid)
drop mid

local max 1
local fert 2

gen twin_bord=bord-twin+1 if twin>0

foreach num in two three four five {
	gen `num'_plus=(bord>=1&bord<=`max')&fert>=`fert'
	gen `num'_plus_twins=((bord>=1&bord<=`fert')&fert>=`fert')|twin_bord==`fert'
	replace `num'_plus=0 if twin!=0
	gen twin`num'=(twin==1 & bord==`fert')|(twin==2 & bord==`fert'+1)
	bys id: egen twin_`num'_fam=max(twin`num')
	drop twin`num'
	local ++max
	local ++fert
}


********************************************************************************
*** (3B) "Quality" variables
********************************************************************************
*** Attendance (attend_year==2 is sometimes)
gen attendance=0 if attend_year==0
replace attendance=1 if attend_year==2
replace attendance=2 if attend_year==1
replace attendance=. if age<6

*** Z-Score
replace educ=. if educ>25 // come back here when compiling summary stats.
bys _cou age: egen sd_educ=sd(educ)
bys _cou age: egen mean_educ=mean(educ)
gen school_zscore=(educ-mean_educ)/sd_educ
replace school_zscore=. if age<6

*** Highschool
gen highschool=1 if (educlevel==2|educlevel==3)&age>=11
replace highschool=0 if (educlevel==0|educlevel==1)&age>=11

*** No Educ
gen noeduc=1 if educlevel==0&age>6
replace noeduc=0 if (educlevel==1|educlevel==2|educlevel==3)&age>6

*** Health
gen childsurvive=child_alive
gen childageatdeath=b7/12
gen infantmortality=childageatdeath<=1
replace infantmortality=. if age<1
gen childmortality=childageatdeath<=5
replace childmortality=. if age<5

********************************************************************************
*** (3C) Control variables
********************************************************************************
gen gender="F" if sex==2
replace gender="M" if sex==1

gen educfyrs_sq=educf*educf
gen educf_0=educf==0
gen educf_1_4=educf>0&educf<5
gen educf_5_6=educf>4&educf<7
gen educf_7_10=educf>6&educf<11
gen educf_11plus=educf>10
gen twind=1 if twin>=1&twin!=.
replace twind=0 if twin==0
gen twind100=twin*100
gen malec=(gender=="M")

replace height=height/10
replace weight=weight/10
replace bmi=bmi/100

gen poor1=wealth==1
gen agesq=age*age
gen magesq=agemay*agemay

*** General variables (country year)
rename _cou country
rename v005 sweight
encode country, gen(_cou)

********************************************************************************
*** (3D) Twin variables
********************************************************************************
bys id: egen twinfamily=max(twin)
bys id: egen twin_bord_fam=max(twin_bord)
bys id: egen nummultiple=max(twin)
gen finaltwin=(fert==bord)&twind==1
bys id: egen finaltwinfamily=max(finaltwin)
replace finaltwinfamily=0 if finaltwinfamily==.


********************************************************************************
*** (3E) Fertility variables
********************************************************************************
gen idealnumkids=v613 if v613<25
gen lastbirth=fert==bord&twin==0
replace lastbirth=1 if (twin_bord==(fert-1))&nummultiple==2
replace lastbirth=1 if (twin_bord==(fert-2))&nummultiple==3
replace lastbirth=1 if (twin_bord==(fert-3))&nummultiple==4

gen wantedbirth=bord<=idealnumkids
gen idealfam=0 if idealnumkids==fert
replace idealfam=1 if idealnumkids<fert
replace idealfam=-1 if idealnumkids>fert

gen quant_exceed=fert-idealnumkids
gen exceeder=1 if bord-idealnumkids==1
gen twinexceeder=exceeder==1&(twin==2|twin==3|twin==4)
bys id: egen twinexceedfamily=max(twinexceeder)
gen tu=twin_bord>=idealnumkids
gen td=twin_bord>=idealnumkids
bys id: egen twin_undesired=max(tu)
bys id: egen twin_desired=max(td)
drop td tu

*Twins born on final birth causing parents to exceed desired family size
gen twinexceed=finaltwinfamily==1&idealfam==1
gen singlexceed=finaltwinfamily==0&idealfam==1
gen twinattain=finaltwinfamily==1&idealfam==0

**Generate sub-region (and ethnicity) specific desired fertility
bys _cou v101: egen desiredfert_region=mean(idealnumkids)
bys _cou v131: egen desiredfert_ethnic=mean(idealnumkids)


********************************************************************************
*** (4) Labels
********************************************************************************
lab var year_birth "Mother's year of birth"
lab var religion "Reported religion"
lab var fert "Total number of children in the family"
lab var bord "Child's birth order"
lab var agefirstbirth "Mother's age at first birth"
lab var child_yob "Child's year of birth"
lab var two_plus "First born child in families with at least two births"
lab var three_plus "1,2 born children in families with at least 3 births"
lab var four_plus "1,2,3 born children in families with at least 4 births"
lab var five_plus "1,2,3,4 born children in families with at least 5 births"
lab var two_plus_twins "1,2 born children in families with >=2 births"
lab var three_plus_twins "1,2,3 born children in families with >=3 births"
lab var four_plus_twins "1,2,3,4 born children in families with >=4 births"
lab var five_plus_twins "1-5 born children in families with >=5 births"
lab var twin_two_fam "Twin birth at second birth"
lab var twin_three_fam "twin birth at third birth"
lab var twin_four_fam "twin birth at fourth birth"
lab var twin_five_fam "twin birth at fifth birth"
lab var id "Unique family identifier"
lab var attendance "child attends school (1=sometimes, 2=always)"
lab var educ "Years of education (child)"
lab var school_zscore "Standardised educ attainment compared to country cohort"
lab var highschool "Attends or attended highschool (>=12 years)"
lab var noeduc "No education (>7 years)"
lab var infantmortality "child died before 1 year of age"
lab var childmortality "child died before 5 years of age"
lab var gender "string variable: F or M"
lab var educf "Mother's years of education"
lab var educfyrs_sq "Mother's years of education squared"
lab var educf_0 "Mother has 0 years of education (binary)"
lab var educf_1_4 "Mother has 1-4 years of education (binary)"
lab var educf_5_6 "Mother has 5-6 years of education (binary)"
lab var educf_7_10 "Mother has 7-10 years of education (binary)"
lab var educf_11plus "Mother has 11+ years of education (binary)"
lab var twind "Child is a twin (binary)"
lab var twin "Child is a twin (0-4) for no, twin, triplet, ... "
lab var twind100 "Child is twin (binary*100)"
lab var malec "Child is a boy"
lab var height "height in centimetres"
lab var weightk "Weight in kilograms"
lab var bmi "Body Mass Index (weight in kilos squared/height in cm)"
lab var poor1 "In lowest asset quintile"
lab var age "Child's age in years"
lab var agemay "Mother's age in years"
lab var agesq "Child's age squared"
lab var magesq "Mother's age squared"
lab var sweight "Sample weight (from DHS)"
lab var country "Coutry name"
lab var _cou "country (numeric code)"
lab var twinfamily "At least one twin birth in family"
lab var twin_bord "Birth order when twins occur (for twins only)"
lab var twin_bord_fam "Birth order when twins occur (for whole family)"
lab var nummultiple "0 if singleton family, 1 if twins, 2 if triplets, ..."
lab var finaltwinfamily "The family had twins at their final birth"
lab var idealnumkids "Ideal number of children reported (truncate at 25)"
lab var lastbirth "Child is family's last birth (singleton or both twins)"
lab var wantedbirth "Birth occurs before optimal target"
lab var idealfam "Has family obtained ideal size? (negative implies < ideal)"
lab var quant_exceed "Difference between total births and desired births"
lab var exceeder "1 if child causes family to exceed optimal size"
lab var twinexceeder "Twin birth causes parents to exceed optimal size"
lab var twinexceedfamily "Family exceeds desired N and twin caused exceed"
lab var twin_undesired "Family has had twins, and twins were >desired births"
lab var twin_desired "Family has had twins, and twins were <=desired births"
lab var twinexceed "Twin birth causes parents to exceed optimal size"
lab var singlexceed "Single birth causes parents to exceed optimal size"
lab var twinattain "Twin birth causes parents to attain optimal size"
lab var desiredfert_region "Average desired family size by (subcountry) region"
lab var desiredfert_ethnic "Average desired family size by ethnicity"


lab def ideal -1 "< ideal number" 0 "Ideal number" 1 "> than ideal number"
lab val idealfam ideal

replace age=age+100 if age<0
********************************************************************************
*** (5) Create country income levels and weight variables
********************************************************************************
replace country="CAR" if v000=="CF3" & _cou==.
replace _cou=10 if v000=="CF3" & _cou==.
replace country="Zimbabwe" if v000=="ZW6" & _cou==.
replace _cou=69 if v000=="ZW6" & _cou==.

do $PATH/Do/countrynaming

gen income="low" if income_status=="LOWINCOME"
replace income="mid" if income_status=="LOWERMIDDLE"|income_statu=="UPPERMIDDLE"

********************************************************************************
*** (6) Keep required variables.  Save data as working file.
********************************************************************************
keep year_birth religion fert bord agefirstbirth child_yob two_plus three_plus /*
*/ four_plus five_plus two_plus_twins three_plus_twins four_plus_twins         /*
*/ five_plus_twins twin_two_fam twin_three_fam twin_four_fam twin_five_fam id  /*
*/ attendance educ school_zscore highschool noeduc infantmortality             /* 
*/ childmortality gender educf educfyrs_sq educf_0 educf_1_4 educf_5_6         /*
*/ educf_7_10 educf_11plus twind twin twind100 malec height weightk bmi poor1  /*
*/ age agemay agesq magesq sweight country _cou _year twinfamily twin_bord     /*
*/ twin_bord_fam nummultiple finaltwinfamily idealnumkids lastbirth wantedbirth/*
*/ idealfam quant_exceed exceeder twinexceeder twinexceedfamily twin_undesired /*
*/ twin_desired twinexceed singlexceed twinattain desiredfert_region           /*
*/ desiredfert_ethnic income contracep_intent _merge
 

save $PATH/Data/DHS_twins, replace
