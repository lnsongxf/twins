/* TWIN_RESULTS 1.00                 UTF-8                         dh:2012-04-09
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*/

**ADD TWO STARS INSTEAD OF THREE TO OUTREG MAX.
clear all
version 11.2
cap log close
set more off
set mem 2000m

global Base "~/investigacion/Activa/Twins"
global Data "$Base/Data"
log using $Base/Log/TwinRegressions2.log, text replace

*TWIN PREDICT CONTROLS
global twinpredict bord agemay educf_* height bmi wealth i.child_yob i._cou
global twinpredict_i i.bord agemay educf_* height bmi wealth i.child_yob i._cou

global sumstats bord fert agemay educf educ attendance /*poor1*/ height bmi

*Q-Q CONTROLS
global basic malec agemay age17-age38 i.child_yob i._cou /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global socioeconomic educf_* /*poor1*/ malec agemay age17-age38 i.child_yob/*
*/ i._cou borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7
global allcontrols educf_* /*poor1*/ height bmi malec agemay age17-age38 i.child_yob/*
*/ i._cou borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7

*OUTREG Q-Q
global basic_out fert malec agemay borddummy2 borddummy3 borddummy4 
global socioeconomic_out fert malec agemay educf_* /*poor1*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7 
global all_out fert malec agemay educf_* bmi /*poor1*/ height borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 borddummy7



use $Data/DHS_twins, clear

drop if height<800|height>2200 //THIS IS 1728 OBSERVATIONS
rename educf_0 educf00


*******************************************************************************
****(Table 1) Summary Stats
*******************************************************************************

foreach income in LOWINCOME LOWERMIDDLE UPPERMIDDLE {
sum $sumstats if twin==0 & inc=="`income'"
sum $sumstats if twin>0&twin!=. & inc=="`income'"
}


*******************************************************************************
****(Table 2) Predict twins
*******************************************************************************

reg twind100 $twinpredict [pw=sweight], cluster(_cou)
outreg2 bord agemay educf_* height bmi wealth using $Base/Results/TwinPredict/twinpredict_table2, tex(pr) replace 2aster
*reg twind100 $twinpredict_i [pw=sweight]
*outreg2 agemay educf_* height bmi /*poor1*/ using $Base/Results/TwinPredict/twinpredict_table2, excel append 2aster
*test educf_0=educf_1_4=educf_5_6=educf_7_10=height=bmi=poor1=0

foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE {
	reg twind100 $twinpredict [pw=sweight] if income_status=="`incstat'", cluster(_cou)
	outreg2 bord fert agemay educf_* height bmi wealth using $Base/Results/TwinPredict/twinpredict_table2, tex(pr) append 2aster
	*reg twind100 $twinpredict_i [pw=sweight] if income_status=="`incstat'"
	*outreg2 agemay educf_* height bmi poor1 using $Base/Results/TwinPredict/twinpredict_table2, excel append 2aster
}

*******************************************************************************
****(Table 3) Q-Q
*******************************************************************************

*educ
reg educ fert $allcontrols if age>16
predict uhat, resid
reg uhat twind

foreach instat in LOWINCOME LOWERMIDDLE UPPERMIDDLE{
	qui reg attendance fert $allcontrols if age>5 & age<17 & income_status=="`instat'"
	predict uhatatt`instat', resid 
	correlate uhatatt`instat' twind, covariance
}
reg school_zscore fert $allcontrols if age>5
predict uhatz, resid
reg uhatz twind


foreach x in one two three four five six{
	xi: ivreg2 educ (fert=twin_`x'_fam) $allcontrols if age>16 & `x'_plus==1
	outreg2 $all_out using $Base/Results/QQ/educ_table3, excel append 2aster
	xi: ivreg2 educ (fert=twin_`x'_fam) $socioeconomic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/educ_table3, excel append 2aster
	xi: ivreg2 educ (fert=twin_`x'_fam) $basic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/educ_table3, excel append 2aster

	reg educ fert $allcontrols if age>16 & `x'_plus==1 & e(sample)
	outreg2 $all_out using $Base/Results/QQ/educ_table3, excel append 2aster
	reg educ fert $socioeconomic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/educ_table3, excel append 2aster
	reg educ fert $basic if age>16 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/educ_table3, excel append 2aster
}

*attendance gap
replace attendance=1 if attendance==2

foreach y of varlist attendance gap {
	foreach x in one two three four five six{
		xi: ivreg2 `y' (fert=twin_`x'_fam) $allcontrols if age>5 & age<17 & `x'_plus==1
		outreg2 $all_out using $Base/Results/QQ/`y'_table3, excel append 2aster
		xi: ivreg2 `y' (fert=twin_`x'_fam) $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $socioeconomic_out using $Base/Results/QQ/`y'_table3, excel append 2aster
		xi: ivreg2 `y' (fert=twin_`x'_fam) $basic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $basic_out using $Base/Results/QQ/`y'_table3, excel append 2aster

		reg `y' fert $allcontrols if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $all_out using $Base/Results/QQ/`y'_table3, excel append 2aster
		reg `y' fert $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $socioeconomic_out using $Base/Results/QQ/`y'_table3, excel append 2aster
		reg `y' fert $basic if age>5 & age<17 & `x'_plus==1 & e(sample)
		outreg2 $basic_out using $Base/Results/QQ/`y'_table3, excel append 2aster
	}
}

*school_zscore
foreach x in one two three four five six{
	xi: ivreg2 school_zscore (fert=twin_`x'_fam) $allcontrols if age>5 & `x'_plus==1
	outreg2 $all_out using $Base/Results/QQ/school_zscore_table3, excel append 2aster
	xi: ivreg2 school_zscore (fert=twin_`x'_fam) $socioeconomic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/school_zscore_table3, excel append 2aster
	xi: ivreg2 school_zscore (fert=twin_`x'_fam) $basic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/school_zscore_table3, excel append 2aster

	reg school_zscore fert $allcontrols if age>5 & `x'_plus==1 & e(sample)
	outreg2 $all_out using $Base/Results/QQ/school_zscore_table3, excel append 2aster
	reg school_zscore fert $socioeconomic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $socioeconomic_out using $Base/Results/QQ/school_zscore_table3, excel append 2aster
	reg school_zscore fert $basic if age>5 & `x'_plus==1 & e(sample)
	outreg2 $basic_out using $Base/Results/QQ/school_zscore_table3, excel append 2aster
}


*******************************************************************************
****(Table 4) Q-Q with country groups
*******************************************************************************
foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE{
	*educ
	foreach x in one two three four five six{
		xi: ivreg2 educ (fert=twin_`x'_fam) $allcontrols if age>16 & `x'_plus==1 & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		xi: ivreg2 educ (fert=twin_`x'_fam) $socioeconomic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		xi: ivreg2 educ (fert=twin_`x'_fam) $basic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster

		reg educ fert $allcontrols if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		reg educ fert $socioeconomic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
		reg educ fert $basic if age>16 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_educ_`incstat'.xls, excel append 2aster
	}

	*attendance gap
	foreach y of varlist attendance gap {
		foreach x in one two three four five six{
			xi: ivreg2 `y' (fert=twin_`x'_fam) $allcontrols if age>5 & age<17 & `x'_plus==1 & income_status=="`incstat'"
			outreg2 $all_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			xi: ivreg2 `y' (fert=twin_`x'_fam) $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $socioeconomic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			xi: ivreg2 `y' (fert=twin_`x'_fam) $basic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $basic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster

			reg `y' fert $allcontrols if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $all_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			reg `y' fert $socioeconomic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $socioeconomic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
			reg `y' fert $basic if age>5 & age<17 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
			outreg2 $basic_out using $Base/Results/QQ/table4_`y'_`incstat'.xls, excel append 2aster
		}
	}
	
	*school z-score
	foreach x in one two three four five six {
		xi: ivreg2 school_zscore (fert=twin_`x'_fam) $allcontrols if age>5 & `x'_plus==1 & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		xi: ivreg2 school_zscore (fert=twin_`x'_fam) $socioeconomic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		xi: ivreg2 school_zscore (fert=twin_`x'_fam) $basic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster

		reg school_zscore fert $allcontrols if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $all_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		reg school_zscore fert $socioeconomic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $socioeconomic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
		reg school_zscore fert $basic if age>5 & `x'_plus==1 & e(sample) & income_status=="`incstat'"
		outreg2 $basic_out using $Base/Results/QQ/table4_school_zscore_`incstat'.xls, excel append 2aster
	}
}

*******************************************************************************
****(Table 4) Predict terminated pregnancy
*******************************************************************************
replace terminated_preg=. if terminated_preg==8
gen incstat=1 if income_status=="LOWINCOME"
replace incstat=2 if income_status=="LOWERMIDDLE"
replace incstat=3 if income_status=="UPPERMIDDLE"
collapse fert agemay educf_* height bmi wealth yearc _cou /*anemia*/ sweight terminated_preg incstat, by(caseid2)

replace yearc=round(yearc)
reg terminated_preg fert agemay educf_* height bmi wealth i.yearc country2- country46 [pw=sweight]
outreg2 fert agemay educf_* height bmi wealth using $Base/Results/TwinPredict/pregterm_predict, excel replace 2aster
*reg twind100 $twinpredict_i [pw=sweight]
*outreg2 agemay educf_* height bmi poor1 using $Base/Results/TwinPredict/twinpredict_table2, excel append 2aster
*test educf_0=educf_1_4=educf_5_6=educf_7_10=height=bmi=poor1=0

gen income_status="LOWINCOME" if incstat==1
replace income_status="LOWERMIDDLE" if incstat==2
replace income_status="UPPERMIDDLE" if incstat==3

foreach incstat in LOWINCOME LOWERMIDDLE UPPERMIDDLE{
	reg terminated_preg fert agemay educf_* height bmi wealth i.child_yob i._cou [pw=sweight] if income_status=="`incstat'"
	outreg2 fert agemay educf_* height bmi wealth using $Base/Results/TwinPredict/pregterm_predict, excel append 2aster
	*reg twind100 $twinpredict_i [pw=sweight] if income_status=="`incstat'"
	*outreg2 agemay educf_* height bmi poor1 using $Base/Results/TwinPredict/twinpredict_table2, excel append 2aster
}
