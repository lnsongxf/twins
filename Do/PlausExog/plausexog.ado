*! plausexog: Estimating bounds with a plausibly exogenous exclusion restriction  
*! Version 0.0.0 marzo 27, 2014 @ 14:05:21
*! Author: Damian Clarke (application of code and ideas of Conley et al., 2013)
*! Contact: damian.clarke@economics.ox.ac.uk

/*
TO DO:
- Make variables factorizable for ltz
- Fix ltz to remove redundant variables so matrix always invertible
   > use fvexpand and then just loop through to test presence
   > this also has important implications for omega
- Graphical
- Check for SE options
- Union of Prior Weighted CI
- Full Bayesian??
*/

cap program drop plausexog
program plausexog, eclass
version 8.0
#delimit ;

syntax anything(name=0 id="variable list") [if] [in]
	[,
	Robust
	CLuster(varname)
	grid(real 2)
	gmin(numlist)
	gmax(numlist)
	level(real 0.95)
	omega(string)
	mu(string)
	GRAph(varlist)
	]
	;
#delimit cr

********************************************************************************
*** (1) Unpack arguments, check for valid syntax, general error capture
********************************************************************************
local 0=subinstr(`"`0'"', "=", " = ", 1)	
local 0=subinstr(`"`0'"', "(", " ( ", 1)
local 0=subinstr(`"`0'"', ")", " ) ", 1)	
tokenize `0'

local method `1'
macro shift


if "`method'"!="uci"&"`method'"!="ltz"&"`method'"!="upwci" {
	dis as error "Method of estimation must be specified."
	dis "Re-specify using uci, ltz or upcwi (see help file for more detail)"
	exit 200
}
if regexm(`"`0'"', "=")==0|regexm(`"`0'"', "\(")==0|regexm(`"`0'"', "\)")==0 {
	dis as error "Specification of varlist is incorrect."
	dis as error "Ensure that synatx is: method yvar [exog] (endog=iv), [opts]"	
	exit 200
}
	
local yvar `1'
macro shift

local varlist1
while regexm(`"`1'"', "\(")==0 {
	local varlist1 `varlist1' `1'
	macro shift
}

local varlist2
while regexm(`"`1'"', "=")==0 {
	local var=subinstr(`"`1'"', "(", "", 1)
	local varlist2 `varlist2' `var'
	macro shift
}	

local varlist_iv
while regexm(`"`1'"', "\)")==0 {
	local var=subinstr(`"`1'"', "=", "", 1)
	local varlist_iv `varlist_iv' `var'
	macro shift
}
local allout `varlist1' `varlist2' constant
local allexog `varlist1' `varlist_iv' constant
	
local count2     : word count `varlist2'
local count_iv	  : word count `varlist_iv' 
local count_all  : word count `allout'
local count_exog : word count `allexog'
local countmin   : word count `gmin'
local countmax   : word count `gmax'
	
if `count2'>`count_iv' {
	dis as error "Specify at least as many instruments as endogenous variables"
	exit 200	
}
	
if "`method'"=="uci" {
	if `countmin'!=`count_iv'|`countmax'!=`count_iv' {
		dis as error "You must define as many gamma values as instrumental variables"
		dis "If instruments are believed to be valid, specify gamma=0 for gmin and gmax"
		exit 200	
	}

	foreach item in min max {
		local count=1
		foreach num of numlist `g`item'' {
			local g`count'`item'=`num'
			local ++count
		}
	}
}
if "`method'"=="ltz" {
	if length("`omega'")==0|length("`mu'")==0 {
		dis as error "For ltz, omega and mu matrices must be defined"
		exit 200
	}
	else {
		mat def omega_in=`omega'
		mat def mu_in=`mu'
	}
}


dis "Estimating Conely et al.'s `method' method"
dis "Exogenous variables: `varlist1'"
dis "Endogenous variables: `varlist2'"
dis "Instruments: `varlist_iv'"


********************************************************************************
*** (2) Estimate model under assumption of gamma=0
********************************************************************************
local cEx   : word count `varlist1'
local cEn   : word count `varlist2'
local cIV   : word count `varlist_iv'
	
dis "Trying to run intial reg with `cEx' exog vars `cEn' endog and `cIV' insts"	

qui ivregress 2sls `yvar' `varlist1' (`varlist2'=`varlist_iv') `if' `in',  /*
 */ `robust' cl(`cluster')
qui estimates store __iv
dis "rank of this regression was `e(rank)'"
if `e(rank)'==`cEx'+`cIV'+1 disp "OK"
else dis "Some variable has been dropped or list is specified non-standardly"
	
********************************************************************************
*** (3) Union of Confidence Intervals approach (uci)
***     Here we are creating a grid and testing for each possible gamma combo:
***     ie - {g1min,g2min,g3min}, {g1max,g2min,g3min}, ..., {g1max,g2max,g3max}
***     This conserves much of the original (Conley et al.) code, which does 
***	  this in quite a nice way.
********************************************************************************
if "`method'"=="uci" {

	*****************************************************************************
	*** (3a) Iterate over iter, which is each possible combination of gammas
	*****************************************************************************
	local iter=1
	while `iter' <= (`grid'^`count_iv') {
		local R=`iter'-1
		local w=`count_iv'

		**Create weighting factor to grid gamma.  If grid==2, gamma={max,min}
		while `w'>0 {
			local a`w'     = floor(`R'/(`grid'^(`w'-1)))
			local R        = `R'-(`grid'^(`w'-1))*`a`w''
			local gamma`w' = `g`w'min' + ((`g`w'max'-`g`w'min')/(`grid'-1))*`a`w''
			local --w
		}
			
		tempvar Y_G
		qui gen `Y_G'=`yvar'

		local count=1
		foreach Z of local varlist_iv {
			qui replace `Y_G'=`Y_G'-`Z'*`gamma`count''
			local ++count
		}

		**************************************************************************
		*** (3b) Estimate model based on assumed gammas, memoize conf intervals
		**************************************************************************
		qui ivregress 2sls `Y_G' `varlist1' (`varlist2'=`varlist_iv'), /*
		*/ `robust' cl(`cluster')

		dis "rank of the UCI regression was `e(rank)'"
		if `e(rank)'==`cEx'+`cIV'+1 disp "OK"
		else dis "Some variable has been dropped or varlist is non-standard"

			
		**************************************************************************
		*** (3c) Check if variable is not dropped (ie dummies) and create results
		**************************************************************************
		mat b2SLS   = e(b)
		mat cov2SLS = e(V)

		local vars_final
		local counter=0
		foreach item in `e(exogr)' `e(instd)' _cons {
			if _b[`item']!=0|_se[`item']!=0 {
				local vars_final `vars_final' `item'
				local ++counter
			}
		}
			
		mat b2SLSf   = J(1,`counter',.)
		mat se2SLSf =	J(`counter',`counter',.)
		tokenize `vars_final'

		foreach num of numlist 1(1)`counter' {
			mat b2SLSf[1,`num']=_b[``num'']
			mat se2SLSf[`num',`num']=_se[``num'']
		}
		mat CI    = -invnormal((1 - `level')/2)
		mat ltemp = vec(b2SLSf) - CI*vec(vecdiag(se2SLSf))
		mat utemp = vec(b2SLSf) + CI*vec(vecdiag(se2SLSf))

		**************************************************************************
		*** (3d) Check if CI from this model is lowest/highest in union (so far)
		**************************************************************************
		foreach regressor of numlist 1(1)`counter' {
			if `iter'==1 {
				local l`regressor'=.
				local u`regressor'=.	
			}
			local l`regressor' = min(`l`regressor'',ltemp[`regressor',1])
			local u`regressor' = max(`u`regressor'',utemp[`regressor',1])
		}
		local ++iter
	}

	dis "Variable" _col(13) "Lower Bound" _col(29) "Upper Bound"
	tokenize `vars_final'
	foreach regressor of numlist 1(1)`e(rank)' {
		dis "``regressor''" _col(13) `l`regressor'' _col(29) `u`regressor''
	}
}

********************************************************************************
*** (4) Union of Prior Weighted Confidence Intervals Approach (upwci)
********************************************************************************
if "`method'"=="upwci" {
	

}		
	
********************************************************************************
*** (5) Lower to Zero approach (ltz)
********************************************************************************
if "`method'"=="ltz" {
	tempvar const
	qui gen `const'=1

   *****************************************************************************
	*** (5a) Remove any colinear elements to ensure that matrices are invertible
	*** For the case of the Z vector, this requires running the first stage regs	
	*****************************************************************************		
   *****************************************************************************
	*** (5b) Form moment matrices: Z'X and Z'Z
	*****************************************************************************
	mat ZX = J(1,`count_all',.)
	mat ZZ = J(1,`count_exog',.)

	tokenize `varlist_iv' `varlist1' `const'
	mat vecaccum a = `1' `varlist2' `varlist1' `if' `in'
	mat ZX = a
	while length("`2'")!= 0 {
		mat vecaccum a = `2' `varlist2' `varlist1' `if' `in'
		mat ZX         = ZX\a
		macro shift		
	}
	mat list ZX

	tokenize `varlist_iv' `varlist1' `const'
	mat vecaccum a = `1' `varlist_iv' `varlist1' `if' `in'
	mat ZZ = a
	while length("`2'")!= 0 {	
		mat vecaccum a = `2' `varlist_iv' `varlist1' `if' `in'
		mat ZZ         = ZZ\a
		macro shift	
	}
	mat list ZZ
		
	*****************************************************************************
	*** (5c) Form augmented var-covar and coefficient matrices (see appendix)
	*****************************************************************************
	qui estimates restore __iv
	mat V = e(V) +  inv(ZX'*inv(ZZ)*ZX)*ZX' * omega_in * ZX*inv(ZX'*inv(ZZ)*ZX)
	mat b = e(b) - (inv(ZX'*inv(ZZ)*ZX)*ZX' * mu_in)'

	*****************************************************************************
	*** (5d) Determine lower and upper bounds
	*****************************************************************************
	mat CI  = -invnormal((1-`level')/2)
	mat lb  = b - vecdiag(cholesky(diag(vecdiag(V))))*CI
	mat ub  = b + vecdiag(cholesky(diag(vecdiag(V))))*CI

	mat list b	
	mat list lb
	mat list ub
}

********************************************************************************
*** (6) Visualise as per Conely et al., (2013) Figures 1-2
********************************************************************************
if length("`graph'")!=0 {
	dis "WORK ON GRAPHICAL OUTPUT"
	foreach var of varlist `graph' {
		sum `var'
	}		

}


********************************************************************************
*** (7) Clean up
********************************************************************************
estimates drop __iv


end