* BTB: Corrected ACS results in Doleac and Hansen (2020)
* Use corrected policy assignment variable (BTB instead of dhBTB)
* Correctly specify the fully-interacted linear time trends
* Exclude individuals with an Associate Degree

set more off
capture log close

log using "$analyze_log/analysis_btb_acs_correctDH.txt", text replace

********************************************************************************
local sample "sex == 1 & age >= 25 & age <= 34 & us_citizen == 1"
local demog = "age in_school educd"
local demog_int = "age#dh_group in_school#dh_group educd#dh_group"

********************************************************************************

*** the following dataset is made in "$build/build_acs_data.do": ***
use "$analysis_data/btb_acs_analysis_table.dta", clear

*** analysis dataset ***
keep if `sample'
keep if (no_coll_deg == 1)

save "$analysis_data/dh_acs_analysistable_corrected.dta", replace


*** Graphs of ACS Cell Sizes ***
preserve
keep dh_blackNH dh_hisp dh_whiteNH dh_group metroFIPS year

* count the number of observations in each MSA-year-race cell
bys metroFIPS year: egen cell_black = total(dh_blackNH == 1)
bys metroFIPS year: egen cell_hisp = total(dh_hisp == 1)
bys metroFIPS year: egen cell_white = total(dh_whiteNH == 1)


* count the number of years each MSA-race pair is sampled
egen temp1 = tag(metroFIPS year dh_group)
bys metroFIPS dh_group: egen n_years = total(temp1)
drop temp1

sort year metroFIPS dh_group

* calculate the minimum observations in an MSA-year-race cell for each MSA-race pair
bys metroFIPS: egen cell_black_min = min(cell_black)
bys metroFIPS: egen cell_hisp_min = min(cell_hisp)
bys metroFIPS: egen cell_white_min = min(cell_white)

tab cell_black_min
tab cell_hisp_min
tab cell_white_min

<<<<<<< HEAD
* average observations in an MSA-year-race cell, across the whole sample (every MSA-year
* observation, not one row per MSA), and per MSA (averaged across that MSA's own years)
disp "=== average cell size across all MSA-year cells (whole sample) ==="
summ cell_black cell_hisp cell_white

bys metroFIPS: egen cell_black_mean = mean(cell_black)
bys metroFIPS: egen cell_hisp_mean = mean(cell_hisp)
bys metroFIPS: egen cell_white_mean = mean(cell_white)

disp "=== distribution of MSA-level average cell size (one value per MSA) ==="
egen msa_tag = tag(metroFIPS)
summ cell_black_mean cell_hisp_mean cell_white_mean if msa_tag == 1, detail
drop msa_tag

=======
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea

local races "black hisp white"

* tabulate the MSAs that are sampled every month or every year with at least `i' observations in each MSA-period-race cell
<<<<<<< HEAD
* n_years == 15 (not 16, the true max for this 2004-2019 sample) mirrors the original 2004-2014
* file's use of n_years == 10 rather than its own true max of 11 -- both use the "one year short
* of complete" tier, which is the one with the large, stable count of qualifying MSAs (~600 here,
* vs. only ~124 at the strict true-max tier in either sample)
=======
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea
forvalues i = 0(1)9 {
	foreach race of local races {
	local j = `i' + 1
	disp "at least `j' `race' men sampled every year"
<<<<<<< HEAD
	tab metroFIPS if cell_`race'_min > `i' & n_years == 15
	egen temp = tag(metroFIPS) if cell_`race'_min > `i' & n_years == 15
=======
	tab metroFIPS if cell_`race'_min > `i' & n_years == 10
	egen temp = tag(metroFIPS) if cell_`race'_min > `i' & n_years == 10
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea
	egen n_MSAs_yr_`race'_min`j' = total(temp)
	drop temp
	}
}
sort year metroFIPS dh_group
keep n_MSAs_yr_*
gen id = 1
duplicates drop

reshape long n_MSAs_yr_black_min n_MSAs_yr_hisp_min n_MSAs_yr_white_min, i(id) j(number)
gen numberB = number-0.2
gen numberH = number+0.2

label variable n_MSAs_yr_black_min "Black Men"
label variable n_MSAs_yr_hisp_min "Hispanic Men"
label variable n_MSAs_yr_white_min "White Men"

*** figure 1c: Black/Hispanic ***
twoway (bar n_MSAs_yr_black_min numberB, barw(0.4) fcolor("90 90 90") lcolor(black)) (bar n_MSAs_yr_hisp_min numberH, barw(0.4) fcolor(gs12) lcolor(black)), subtitle(`"Number of MSAs in ACS Sample"', size(5) pos(11) margin(l=-9.5)) xtitle(`"Minimum Number of Men in Each MSA-Year-Race Cell"', size(5)) xscale(range(1 10)) xlabel(1(1)10, labsize(5)) title(`""') graphregion(fcolor(white)) ylabel(0(50)300, angle(horizontal) labsize(5) nogrid) legend(size(5))

graph export "$out/acs_cell_sample_size_BH.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figure1c.emf", replace
=======
graph export "$out/figure1c.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea

*** figure 1d: white ***
twoway (bar n_MSAs_yr_white_min number, barw(0.4) fcolor(gs1) lcolor(black)), ytitle("") subtitle(`"Number of MSAs in ACS Sample"', size(5) pos(11) margin(l=-9.5)) xtitle(`"Minimum Number of Men in Each MSA-Year-Race Cell"', size(5)) xscale(range(1 10)) xlabel(1(1)10, labsize(5)) title(`""') graphregion(fcolor(white)) legend(on) yscale(range(0 300)) ylabel(0(50)300, angle(horizontal) labsize(5) nogrid) legend(size(5))

graph export "$out/acs_cell_sample_size_white.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figure1d.emf", replace
=======
graph export "$out/figure1d.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea

restore


*********************
*** Event Studies ***
*********************

* for years after the treatment date
forvalues i = 1(1)5 {
	local j = `i' - 1
	gen BTBpub_lag_`j'to`i' = (year == btb_eff_year + `j')
}

	// Is the current time at least 4 years after BTB went into effect?
	gen BTBpub_lag4plus = (year >= btb_eff_year + 4)

* for years before the treatment date
forvalues i = 1(1)4 {
	local j = `i' - 1
	gen BTBpub_lead_`j'to`i' = (year == btb_eff_year - `i')
}

	// Is the current time more than 3 years before BTB went into effect?
	gen BTBpub_lead3minus = (year <= btb_eff_year - 4)

	
gen BTBpub_neg1 = 0
replace BTBpub_lead_3to4 = 0

*** appendix figure a.3a: Black ***
eststo clear

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_blackNH==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
<<<<<<< HEAD

scalar pretrend_N_black = e(N)

* Joint test of parallel pre-trends: are the three genuinely-estimated pre-period leads
* (t-3, t-2, t-1) jointly indistinguishable from zero? BTBpub_lead_3to4 (t-4) and BTBpub_neg1
* (the "t-1" shown in the coefplot) are both forced to constant 0 above, so reghdfe drops them
* as collinear -- they are excluded here because testing an omitted coefficient errors out.
* BTBpub_lead_0to1 is the real, estimated t-1 effect; it is included here even though it is
* never plotted in the coefplot above.
disp "----- Black men: joint test of pre-trend leads (H0: t-3 = t-2 = t-1 = 0) -----"
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar pretrend_F_black = r(F)
scalar pretrend_dfm_black = r(df)
scalar pretrend_dfr_black = r(df_r)
scalar pretrend_p_black = r(p)

* Individual lead coefficients, to see which specific pre-period(s) drive the joint test
scalar lead3_b_black = _b[BTBpub_lead_2to3]
scalar lead3_se_black = _se[BTBpub_lead_2to3]
scalar lead3_p_black = 2*ttail(e(df_r), abs(lead3_b_black/lead3_se_black))
scalar lead2_b_black = _b[BTBpub_lead_1to2]
scalar lead2_se_black = _se[BTBpub_lead_1to2]
scalar lead2_p_black = 2*ttail(e(df_r), abs(lead2_b_black/lead2_se_black))
scalar lead1_b_black = _b[BTBpub_lead_0to1]
scalar lead1_se_black = _se[BTBpub_lead_0to1]
scalar lead1_p_black = 2*ttail(e(df_r), abs(lead1_b_black/lead1_se_black))

=======
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea
estimate store baseline_black
coefplot (baseline_black, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black)) ///
		(baseline_black, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_black, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.2(.1)0.2, angle(horizontal) labsize(5) nogrid) yscale(range(-0.2 0.2)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_black_corrected.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA3a.emf", replace
=======
graph export "$out/figureA3a.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea


*** appendix figure a.3b: Hispanic ***
eststo clear

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_hisp==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
<<<<<<< HEAD

scalar pretrend_N_hisp = e(N)

* Joint test of parallel pre-trends -- see note above the Black men regression for why only
* these three leads (t-3, t-2, t-1) are tested
disp "----- Hispanic men: joint test of pre-trend leads (H0: t-3 = t-2 = t-1 = 0) -----"
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar pretrend_F_hisp = r(F)
scalar pretrend_dfm_hisp = r(df)
scalar pretrend_dfr_hisp = r(df_r)
scalar pretrend_p_hisp = r(p)

* Individual lead coefficients, to see which specific pre-period(s) drive the joint test
scalar lead3_b_hisp = _b[BTBpub_lead_2to3]
scalar lead3_se_hisp = _se[BTBpub_lead_2to3]
scalar lead3_p_hisp = 2*ttail(e(df_r), abs(lead3_b_hisp/lead3_se_hisp))
scalar lead2_b_hisp = _b[BTBpub_lead_1to2]
scalar lead2_se_hisp = _se[BTBpub_lead_1to2]
scalar lead2_p_hisp = 2*ttail(e(df_r), abs(lead2_b_hisp/lead2_se_hisp))
scalar lead1_b_hisp = _b[BTBpub_lead_0to1]
scalar lead1_se_hisp = _se[BTBpub_lead_0to1]
scalar lead1_p_hisp = 2*ttail(e(df_r), abs(lead1_b_hisp/lead1_se_hisp))

=======
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea
estimate store baseline_hisp
coefplot (baseline_hisp, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black)) ///
		(baseline_hisp, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_hisp, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.2(.1)0.2, angle(horizontal) labsize(5) nogrid) yscale(range(-0.2 0.2)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_hispanic_corrected.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA3b.emf", replace
=======
graph export "$out/figureA3b.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea


*** appendix figure a.3c: white ***
eststo clear

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_whiteNH==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
<<<<<<< HEAD

scalar pretrend_N_white = e(N)

* Joint test of parallel pre-trends -- see note above the Black men regression for why only
* these three leads (t-3, t-2, t-1) are tested
disp "----- White men: joint test of pre-trend leads (H0: t-3 = t-2 = t-1 = 0) -----"
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar pretrend_F_white = r(F)
scalar pretrend_dfm_white = r(df)
scalar pretrend_dfr_white = r(df_r)
scalar pretrend_p_white = r(p)

* Individual lead coefficients, to see which specific pre-period(s) drive the joint test
scalar lead3_b_white = _b[BTBpub_lead_2to3]
scalar lead3_se_white = _se[BTBpub_lead_2to3]
scalar lead3_p_white = 2*ttail(e(df_r), abs(lead3_b_white/lead3_se_white))
scalar lead2_b_white = _b[BTBpub_lead_1to2]
scalar lead2_se_white = _se[BTBpub_lead_1to2]
scalar lead2_p_white = 2*ttail(e(df_r), abs(lead2_b_white/lead2_se_white))
scalar lead1_b_white = _b[BTBpub_lead_0to1]
scalar lead1_se_white = _se[BTBpub_lead_0to1]
scalar lead1_p_white = 2*ttail(e(df_r), abs(lead1_b_white/lead1_se_white))

=======
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea
estimate store baseline_white
coefplot (baseline_white, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black)) ///
		(baseline_white, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_white, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.2(.1)0.2, angle(horizontal) labsize(5) nogrid) yscale(range(-0.2 0.2)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_white_corrected.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA3c.emf", replace


********************************************************************************
* Robustness check: Hispanic men, excluding 2008-2009 (year >= 2010)
*
* The calendar-year breakdown of the t-3 cell (see the diagnostic_t3_calendar_years table
* built later in this file) shows 55.4% of it falls in 2008-2009, the apex of the Great
* Recession. This drops those two years entirely (all leads and lags, not just the t-3 cell)
* and re-estimates the same event study. Unlike excluding California (which barely moved the
* t-3 point estimate), this cut is cheap in overall sample terms (~14% of the full N) because
* the t-3 cell is itself only ~6% of the full sample -- most of the sample identifies the fixed
* effects, trends, and other lead/lag coefficients, not t-3 specifically, so removing 2008-2009
* barely touches the overall N while removing more than half of what actually identifies t-3.
********************************************************************************

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_hisp==1 & year >= 2010, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)

scalar pretrend_N_hisp2010 = e(N)

disp "----- Hispanic men, excluding 2008-2009 (year>=2010): joint test of pre-trend leads (H0: t-3 = t-2 = t-1 = 0) -----"
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar pretrend_F_hisp2010 = r(F)
scalar pretrend_dfm_hisp2010 = r(df)
scalar pretrend_dfr_hisp2010 = r(df_r)
scalar pretrend_p_hisp2010 = r(p)

scalar lead3_b_hisp2010 = _b[BTBpub_lead_2to3]
scalar lead3_se_hisp2010 = _se[BTBpub_lead_2to3]
scalar lead3_p_hisp2010 = 2*ttail(e(df_r), abs(lead3_b_hisp2010/lead3_se_hisp2010))
scalar lead2_b_hisp2010 = _b[BTBpub_lead_1to2]
scalar lead2_se_hisp2010 = _se[BTBpub_lead_1to2]
scalar lead2_p_hisp2010 = 2*ttail(e(df_r), abs(lead2_b_hisp2010/lead2_se_hisp2010))
scalar lead1_b_hisp2010 = _b[BTBpub_lead_0to1]
scalar lead1_se_hisp2010 = _se[BTBpub_lead_0to1]
scalar lead1_p_hisp2010 = 2*ttail(e(df_r), abs(lead1_b_hisp2010/lead1_se_hisp2010))

eststo clear


********************************************************************************
* Robustness check: Black and White men, excluding 2008-2009 (year >= 2010)
*
* Companion to the Hispanic-specific check above, for comparison: Black and White men's joint
* pre-trend tests were already statistically insignificant on the full 2008+ sample, so this is
* not expected to change much, but it is included so the diagnostic_pretrend table shows the
* same year>=2010 cut applied uniformly across all three race groups rather than singling out
* Hispanic men without a same-specification comparison for the other two.
********************************************************************************

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_blackNH==1 & year >= 2010, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)

scalar pretrend_N_black2010 = e(N)

disp "----- Black men, excluding 2008-2009 (year>=2010): joint test of pre-trend leads (H0: t-3 = t-2 = t-1 = 0) -----"
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar pretrend_F_black2010 = r(F)
scalar pretrend_dfm_black2010 = r(df)
scalar pretrend_dfr_black2010 = r(df_r)
scalar pretrend_p_black2010 = r(p)

scalar lead3_b_black2010 = _b[BTBpub_lead_2to3]
scalar lead3_se_black2010 = _se[BTBpub_lead_2to3]
scalar lead3_p_black2010 = 2*ttail(e(df_r), abs(lead3_b_black2010/lead3_se_black2010))
scalar lead2_b_black2010 = _b[BTBpub_lead_1to2]
scalar lead2_se_black2010 = _se[BTBpub_lead_1to2]
scalar lead2_p_black2010 = 2*ttail(e(df_r), abs(lead2_b_black2010/lead2_se_black2010))
scalar lead1_b_black2010 = _b[BTBpub_lead_0to1]
scalar lead1_se_black2010 = _se[BTBpub_lead_0to1]
scalar lead1_p_black2010 = 2*ttail(e(df_r), abs(lead1_b_black2010/lead1_se_black2010))

eststo clear

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_whiteNH==1 & year >= 2010, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)

scalar pretrend_N_white2010 = e(N)

disp "----- White men, excluding 2008-2009 (year>=2010): joint test of pre-trend leads (H0: t-3 = t-2 = t-1 = 0) -----"
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar pretrend_F_white2010 = r(F)
scalar pretrend_dfm_white2010 = r(df)
scalar pretrend_dfr_white2010 = r(df_r)
scalar pretrend_p_white2010 = r(p)

scalar lead3_b_white2010 = _b[BTBpub_lead_2to3]
scalar lead3_se_white2010 = _se[BTBpub_lead_2to3]
scalar lead3_p_white2010 = 2*ttail(e(df_r), abs(lead3_b_white2010/lead3_se_white2010))
scalar lead2_b_white2010 = _b[BTBpub_lead_1to2]
scalar lead2_se_white2010 = _se[BTBpub_lead_1to2]
scalar lead2_p_white2010 = 2*ttail(e(df_r), abs(lead2_b_white2010/lead2_se_white2010))
scalar lead1_b_white2010 = _b[BTBpub_lead_0to1]
scalar lead1_se_white2010 = _se[BTBpub_lead_0to1]
scalar lead1_p_white2010 = 2*ttail(e(df_r), abs(lead1_b_white2010/lead1_se_white2010))

eststo clear


********************************************************************************
* Joint pre-trend F-test summary table (figures A3a-c)
* Collects the three race-specific joint F-tests (H0: t-3 = t-2 = t-1 = 0) computed
* above into a single side-by-side table. Built from scalars rather than the stored
* baseline_black/baseline_hisp/baseline_white estimates because "eststo clear" (which
* runs again at the start of the next block below) also clears estimates stored via
* plain "estimate store", not just ones stored via eststo -- so those objects cannot
* be relied on to survive past this point.
********************************************************************************

* Two esttab/estpost-based attempts at this table (using cells(mean(...)) and then
* varlabels()) both silently produced a table with headers but no data rows -- estpost
* tabstat's internal e()-matrix naming for a single requested statistic did not match what
* esttab's cells() was asking for, and neither attempt raised any visible error to diagnose
* against. Writing the RTF directly avoids any dependency on that internal convention: this
* uses the same low-level RTF table syntax (\trowd/\cellx/\intbl) seen in the esttab-produced
* diagnostic_yearcutoff.rtf and table2.rtf, just assembled by hand instead of through esttab.
local Nb : di %9.0fc pretrend_N_black
local Nb10 : di %9.0fc pretrend_N_black2010
local Nh : di %9.0fc pretrend_N_hisp
local Nh10 : di %9.0fc pretrend_N_hisp2010
local Nw : di %9.0fc pretrend_N_white
local Nw10 : di %9.0fc pretrend_N_white2010
local Fb : di %9.3f pretrend_F_black
local Fb10 : di %9.3f pretrend_F_black2010
local Fh : di %9.3f pretrend_F_hisp
local Fh10 : di %9.3f pretrend_F_hisp2010
local Fw : di %9.3f pretrend_F_white
local Fw10 : di %9.3f pretrend_F_white2010
local dfmb : di %9.0f pretrend_dfm_black
local dfmb10 : di %9.0f pretrend_dfm_black2010
local dfmh : di %9.0f pretrend_dfm_hisp
local dfmh10 : di %9.0f pretrend_dfm_hisp2010
local dfmw : di %9.0f pretrend_dfm_white
local dfmw10 : di %9.0f pretrend_dfm_white2010
local dfrb : di %9.0f pretrend_dfr_black
local dfrb10 : di %9.0f pretrend_dfr_black2010
local dfrh : di %9.0f pretrend_dfr_hisp
local dfrh10 : di %9.0f pretrend_dfr_hisp2010
local dfrw : di %9.0f pretrend_dfr_white
local dfrw10 : di %9.0f pretrend_dfr_white2010
local pb : di %9.4f pretrend_p_black
local pb10 : di %9.4f pretrend_p_black2010
local ph : di %9.4f pretrend_p_hisp
local ph10 : di %9.4f pretrend_p_hisp2010
local pw : di %9.4f pretrend_p_white
local pw10 : di %9.4f pretrend_p_white2010

* Build "coefficient*** (se)" cell text for each race x lead, so the table shows which
* specific pre-period(s) drive each race's joint F-test above, not just the joint result.
* The "*2010" variants are each race's excluding-2008-2009 (year>=2010) robustness check.
foreach race in black black2010 hisp hisp2010 white white2010 {
	foreach lead in 3 2 1 {
		local b : di %6.4f lead`lead'_b_`race'
		local se : di %6.4f lead`lead'_se_`race'
		local pval = lead`lead'_p_`race'
		local stars ""
		if `pval' < 0.01 local stars "***"
		else if `pval' < 0.05 local stars "**"
		else if `pval' < 0.10 local stars "*"
		local lead`lead'txt_`race' "`b'`stars' (`se')"
	}
}

file open pretrendrtf using "$out/diagnostic_pretrend.rtf", write replace
file write pretrendrtf "{\rtf1\ansi\deff0 {\fonttbl\f0\fnil Times New Roman;}" _n
file write pretrendrtf "\deflang1033\plain\fs24" _n
file write pretrendrtf "{\pard\keepn\ql Pre-trend leads and joint test, H0: t-3 = t-2 = t-1 = 0 (figures A3a-c)\par}" _n
file write pretrendrtf "{" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs\cellx2200\clbrdrt\brdrw10\brdrs\cellx3800\clbrdrt\brdrw10\brdrs\cellx5400\clbrdrt\brdrw10\brdrs\cellx7000\clbrdrt\brdrw10\brdrs\cellx8600\clbrdrt\brdrw10\brdrs\cellx10200\clbrdrt\brdrw10\brdrs\cellx11800\pard\intbl\ql {}\cell \pard\intbl\qc {Black}\cell \pard\intbl\qc {Black, excl. 2008-09 (>=2010)}\cell \pard\intbl\qc {Hispanic}\cell \pard\intbl\qc {Hispanic, excl. 2008-09 (>=2010)}\cell \pard\intbl\qc {White}\cell \pard\intbl\qc {White, excl. 2008-09 (>=2010)}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\cellx2200\cellx3800\cellx5400\cellx7000\cellx8600\cellx10200\cellx11800\pard\intbl\ql {N}\cell \pard\intbl\qc {`Nb'}\cell \pard\intbl\qc {`Nb10'}\cell \pard\intbl\qc {`Nh'}\cell \pard\intbl\qc {`Nh10'}\cell \pard\intbl\qc {`Nw'}\cell \pard\intbl\qc {`Nw10'}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\cellx2200\cellx3800\cellx5400\cellx7000\cellx8600\cellx10200\cellx11800\pard\intbl\ql {t-3}\cell \pard\intbl\qc {`lead3txt_black'}\cell \pard\intbl\qc {`lead3txt_black2010'}\cell \pard\intbl\qc {`lead3txt_hisp'}\cell \pard\intbl\qc {`lead3txt_hisp2010'}\cell \pard\intbl\qc {`lead3txt_white'}\cell \pard\intbl\qc {`lead3txt_white2010'}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\cellx2200\cellx3800\cellx5400\cellx7000\cellx8600\cellx10200\cellx11800\pard\intbl\ql {t-2}\cell \pard\intbl\qc {`lead2txt_black'}\cell \pard\intbl\qc {`lead2txt_black2010'}\cell \pard\intbl\qc {`lead2txt_hisp'}\cell \pard\intbl\qc {`lead2txt_hisp2010'}\cell \pard\intbl\qc {`lead2txt_white'}\cell \pard\intbl\qc {`lead2txt_white2010'}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\clbrdrb\brdrw10\brdrs\cellx2200\clbrdrb\brdrw10\brdrs\cellx3800\clbrdrb\brdrw10\brdrs\cellx5400\clbrdrb\brdrw10\brdrs\cellx7000\clbrdrb\brdrw10\brdrs\cellx8600\clbrdrb\brdrw10\brdrs\cellx10200\clbrdrb\brdrw10\brdrs\cellx11800\pard\intbl\ql {t-1}\cell \pard\intbl\qc {`lead1txt_black'}\cell \pard\intbl\qc {`lead1txt_black2010'}\cell \pard\intbl\qc {`lead1txt_hisp'}\cell \pard\intbl\qc {`lead1txt_hisp2010'}\cell \pard\intbl\qc {`lead1txt_white'}\cell \pard\intbl\qc {`lead1txt_white2010'}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\cellx2200\cellx3800\cellx5400\cellx7000\cellx8600\cellx10200\cellx11800\pard\intbl\ql {Joint F-statistic}\cell \pard\intbl\qc {`Fb'}\cell \pard\intbl\qc {`Fb10'}\cell \pard\intbl\qc {`Fh'}\cell \pard\intbl\qc {`Fh10'}\cell \pard\intbl\qc {`Fw'}\cell \pard\intbl\qc {`Fw10'}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\cellx2200\cellx3800\cellx5400\cellx7000\cellx8600\cellx10200\cellx11800\pard\intbl\ql {df (numerator)}\cell \pard\intbl\qc {`dfmb'}\cell \pard\intbl\qc {`dfmb10'}\cell \pard\intbl\qc {`dfmh'}\cell \pard\intbl\qc {`dfmh10'}\cell \pard\intbl\qc {`dfmw'}\cell \pard\intbl\qc {`dfmw10'}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\cellx2200\cellx3800\cellx5400\cellx7000\cellx8600\cellx10200\cellx11800\pard\intbl\ql {df (denominator)}\cell \pard\intbl\qc {`dfrb'}\cell \pard\intbl\qc {`dfrb10'}\cell \pard\intbl\qc {`dfrh'}\cell \pard\intbl\qc {`dfrh10'}\cell \pard\intbl\qc {`dfrw'}\cell \pard\intbl\qc {`dfrw10'}\cell\row}" _n
file write pretrendrtf "{\trowd\trgaph108\trleft-108\clbrdrb\brdrw10\brdrs\cellx2200\clbrdrb\brdrw10\brdrs\cellx3800\clbrdrb\brdrw10\brdrs\cellx5400\clbrdrb\brdrw10\brdrs\cellx7000\clbrdrb\brdrw10\brdrs\cellx8600\clbrdrb\brdrw10\brdrs\cellx10200\clbrdrb\brdrw10\brdrs\cellx11800\pard\intbl\ql {Joint p-value}\cell \pard\intbl\qc {`pb'}\cell \pard\intbl\qc {`pb10'}\cell \pard\intbl\qc {`ph'}\cell \pard\intbl\qc {`ph10'}\cell \pard\intbl\qc {`pw'}\cell \pard\intbl\qc {`pw10'}\cell\row}" _n
file write pretrendrtf "}" _n
file write pretrendrtf "{\pard\ql\fs20 Cells show the individual lead coefficient (employment effect) with its standard error in parentheses; * p<0.10, ** p<0.05, *** p<0.01\par}" _n
file write pretrendrtf "{\pard \par}" _n
file write pretrendrtf "}" _n
file close pretrendrtf


********************************************************************************
* Robustness check: Hispanic men, leave-one-state-out
*
* The t-3 bucket for the Hispanic joint pre-trend test is heavily concentrated in a handful
* of states: California alone is 38.5% of it (all landing in 2008, from its single 2011
* statewide law), and California + Texas + Florida + New York + Arizona together account for
* ~73%. Since standard errors are clustered by stateFIPS, this concentration also raises a
* "few clusters" concern (Cameron & Miller) independent of the recession-timing question:
* even though the data nominally spans dozens of states, the t-3 coefficient's identification
* is effectively coming from just a handful of them, which can make cluster-robust inference
* unreliable regardless of whether there is a genuine timing story underneath.
*
* This block re-estimates the same Hispanic specification five times, each time excluding one
* of the five largest contributing states, to see how much each one individually moves the
* joint F-test and the t-3 coefficient -- keeping all other ~48 states as the comparison group,
* so clustering stays valid throughout (unlike a true single-state regression, which would have
* only one cluster and could not use vce(cluster) at all).
********************************************************************************

local exclude_codes 0 6 48 12 36 4
local exclude_names None CA TX FL NY AZ

local i = 1
foreach code of local exclude_codes {
	local nm : word `i' of `exclude_names'

	eststo clear
	reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_hisp==1 & year >= 2008 & stateFIPS != `code', vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)

	scalar loso_N_`nm' = e(N)

	test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
	scalar loso_F_`nm' = r(F)
	scalar loso_dfm_`nm' = r(df)
	scalar loso_dfr_`nm' = r(df_r)
	scalar loso_p_`nm' = r(p)

	scalar loso_lead3_b_`nm' = _b[BTBpub_lead_2to3]
	scalar loso_lead3_se_`nm' = _se[BTBpub_lead_2to3]
	scalar loso_lead3_p_`nm' = 2*ttail(e(df_r), abs(loso_lead3_b_`nm'/loso_lead3_se_`nm'))

	eststo clear
	local i = `i' + 1
}

* Build "coefficient*** (se)" cell text for the t-3 lead, same convention as the pretrend table
foreach nm in None CA TX FL NY AZ {
	local b : di %6.4f loso_lead3_b_`nm'
	local se : di %6.4f loso_lead3_se_`nm'
	local pval = loso_lead3_p_`nm'
	local stars ""
	if `pval' < 0.01 local stars "***"
	else if `pval' < 0.05 local stars "**"
	else if `pval' < 0.10 local stars "*"
	local lead3txt_`nm' "`b'`stars' (`se')"

	local Ntxt_`nm' : di %9.0fc loso_N_`nm'
	local Ftxt_`nm' : di %9.3f loso_F_`nm'
	local dfmtxt_`nm' : di %9.0f loso_dfm_`nm'
	local dfrtxt_`nm' : di %9.0f loso_dfr_`nm'
	local ptxt_`nm' : di %9.4f loso_p_`nm'
}

file open losortf using "$out/diagnostic_pretrend_leaveoneout.rtf", write replace
file write losortf "{\rtf1\ansi\deff0 {\fonttbl\f0\fnil Times New Roman;}" _n
file write losortf "\deflang1033\plain\fs24" _n
file write losortf "{\pard\keepn\ql Hispanic men, leave-one-state-out: pre-trend t-3 coefficient and joint test, H0: t-3 = t-2 = t-1 = 0\par}" _n
file write losortf "{" _n
file write losortf "{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs\cellx2000\clbrdrt\brdrw10\brdrs\cellx3600\clbrdrt\brdrw10\brdrs\cellx5600\clbrdrt\brdrw10\brdrs\cellx7200\clbrdrt\brdrw10\brdrs\cellx8800\clbrdrt\brdrw10\brdrs\cellx10400\pard\intbl\ql {State excluded}\cell \pard\intbl\qc {N}\cell \pard\intbl\qc {t-3 coefficient}\cell \pard\intbl\qc {Joint F}\cell \pard\intbl\qc {df}\cell \pard\intbl\qc {Joint p-value}\cell\row}" _n

foreach nm in None CA TX FL NY AZ {
	local lbl "`nm'"
	if "`nm'" == "None" local lbl "None (full sample)"
	file write losortf "{\trowd\trgaph108\trleft-108\cellx2000\cellx3600\cellx5600\cellx7200\cellx8800\cellx10400\pard\intbl\ql {`lbl'}\cell \pard\intbl\qc {`Ntxt_`nm''}\cell \pard\intbl\qc {`lead3txt_`nm''}\cell \pard\intbl\qc {`Ftxt_`nm''}\cell \pard\intbl\qc {`dfmtxt_`nm'', `dfrtxt_`nm''}\cell \pard\intbl\qc {`ptxt_`nm''}\cell\row}" _n
}

file write losortf "}" _n
file write losortf "{\pard\ql\fs20 Each row re-estimates the Hispanic event study excluding the named state (or no state, for the full-sample baseline); all other ~48-49 states remain as the comparison group. t-3 coefficient cell shows the individual lead with standard error in parentheses; * p<0.10, ** p<0.05, *** p<0.01. Joint test covers t-3, t-2, and t-1 together.\par}" _n
file write losortf "{\pard \par}" _n
file write losortf "}" _n
file close losortf


********************************************************************************
* Robustness check: Hispanic men, event study without the MSA-specific linear trend
*
* The leave-one-state-out results showed the Hispanic t-3 anomaly is not attributable to any
* single state, and the calendar-year tabulation showed the t-3 bucket is NOT simply pooling
* the worst-employment years (2011, the true trough, is barely represented; 2008, which
* dominates the bucket, is one of the better post-2007 years in raw terms). That combination
* points away from a raw compositional/timing artifact and toward the metro-specific *linear*
* trend control itself: for the MSAs whose t-3 lands in 2008 (heavily California), a straight
* line fit across the full 2008-2019 window (which includes the sharp 2012-2019 recovery) can
* extrapolate backward to a higher counterfactual for 2008 than those MSAs actually delivered,
* manufacturing a spurious negative pre-trend residual that has nothing to do with BTB.
*
* This block re-estimates the same Hispanic event study using the Column (1)/m1 no-trend
* specification from the main DID table (metroFIPS level fixed effects only, no ##c.dh_time
* interaction) instead of the Column (2)/m2-style trend specification (metroFIPS##c.dh_time)
* used everywhere else in this file. If t-3 loses significance here, that is strong evidence
* the linear trend control -- not a real confound -- is generating the artifact. If it survives
* without the trend too, the trend is not the culprit and a different explanation (or an honest
* disclaimer) is needed.
********************************************************************************

eststo clear

* With trend (m2-style; same as the original Hispanic result throughout this file)
reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_hisp==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)

scalar trend_N_with = e(N)
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar trend_F_with = r(F)
scalar trend_dfm_with = r(df)
scalar trend_dfr_with = r(df_r)
scalar trend_p_with = r(p)
scalar trend_lead3_b_with = _b[BTBpub_lead_2to3]
scalar trend_lead3_se_with = _se[BTBpub_lead_2to3]
scalar trend_lead3_p_with = 2*ttail(e(df_r), abs(trend_lead3_b_with/trend_lead3_se_with))
scalar trend_lead2_b_with = _b[BTBpub_lead_1to2]
scalar trend_lead2_se_with = _se[BTBpub_lead_1to2]
scalar trend_lead2_p_with = 2*ttail(e(df_r), abs(trend_lead2_b_with/trend_lead2_se_with))
scalar trend_lead1_b_with = _b[BTBpub_lead_0to1]
scalar trend_lead1_se_with = _se[BTBpub_lead_0to1]
scalar trend_lead1_p_with = 2*ttail(e(df_r), abs(trend_lead1_b_with/trend_lead1_se_with))

eststo clear

* Without trend (m1-style; metroFIPS level fixed effect only, no ##c.dh_time)
reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_hisp==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS)

scalar trend_N_without = e(N)
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar trend_F_without = r(F)
scalar trend_dfm_without = r(df)
scalar trend_dfr_without = r(df_r)
scalar trend_p_without = r(p)
scalar trend_lead3_b_without = _b[BTBpub_lead_2to3]
scalar trend_lead3_se_without = _se[BTBpub_lead_2to3]
scalar trend_lead3_p_without = 2*ttail(e(df_r), abs(trend_lead3_b_without/trend_lead3_se_without))
scalar trend_lead2_b_without = _b[BTBpub_lead_1to2]
scalar trend_lead2_se_without = _se[BTBpub_lead_1to2]
scalar trend_lead2_p_without = 2*ttail(e(df_r), abs(trend_lead2_b_without/trend_lead2_se_without))
scalar trend_lead1_b_without = _b[BTBpub_lead_0to1]
scalar trend_lead1_se_without = _se[BTBpub_lead_0to1]
scalar trend_lead1_p_without = 2*ttail(e(df_r), abs(trend_lead1_b_without/trend_lead1_se_without))

eststo clear

* Build "coefficient*** (se)" cell text for each lead x spec
foreach spec in with without {
	foreach lead in 3 2 1 {
		local b : di %6.4f trend_lead`lead'_b_`spec'
		local se : di %6.4f trend_lead`lead'_se_`spec'
		local pval = trend_lead`lead'_p_`spec'
		local stars ""
		if `pval' < 0.01 local stars "***"
		else if `pval' < 0.05 local stars "**"
		else if `pval' < 0.10 local stars "*"
		local lead`lead'txt_`spec' "`b'`stars' (`se')"
	}
	local Ntxt_`spec' : di %9.0fc trend_N_`spec'
	local Ftxt_`spec' : di %9.3f trend_F_`spec'
	local dfmtxt_`spec' : di %9.0f trend_dfm_`spec'
	local dfrtxt_`spec' : di %9.0f trend_dfr_`spec'
	local ptxt_`spec' : di %9.4f trend_p_`spec'
}

file open trendrtf using "$out/diagnostic_pretrend_notrend.rtf", write replace
file write trendrtf "{\rtf1\ansi\deff0 {\fonttbl\f0\fnil Times New Roman;}" _n
file write trendrtf "\deflang1033\plain\fs24" _n
file write trendrtf "{\pard\keepn\ql Hispanic men, with vs. without MSA-specific linear trend: pre-trend leads and joint test, H0: t-3 = t-2 = t-1 = 0\par}" _n
file write trendrtf "{" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs\cellx2600\clbrdrt\brdrw10\brdrs\cellx6600\clbrdrt\brdrw10\brdrs\cellx10600\pard\intbl\ql {}\cell \pard\intbl\qc {With trend (metroFIPS##c.dh_time, main spec)}\cell \pard\intbl\qc {Without trend (metroFIPS only, m1-style)}\cell\row}" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {N}\cell \pard\intbl\qc {`Ntxt_with'}\cell \pard\intbl\qc {`Ntxt_without'}\cell\row}" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {t-3}\cell \pard\intbl\qc {`lead3txt_with'}\cell \pard\intbl\qc {`lead3txt_without'}\cell\row}" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {t-2}\cell \pard\intbl\qc {`lead2txt_with'}\cell \pard\intbl\qc {`lead2txt_without'}\cell\row}" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\clbrdrb\brdrw10\brdrs\cellx2600\clbrdrb\brdrw10\brdrs\cellx6600\clbrdrb\brdrw10\brdrs\cellx10600\pard\intbl\ql {t-1}\cell \pard\intbl\qc {`lead1txt_with'}\cell \pard\intbl\qc {`lead1txt_without'}\cell\row}" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {Joint F-statistic}\cell \pard\intbl\qc {`Ftxt_with'}\cell \pard\intbl\qc {`Ftxt_without'}\cell\row}" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {df}\cell \pard\intbl\qc {`dfmtxt_with', `dfrtxt_with'}\cell \pard\intbl\qc {`dfmtxt_without', `dfrtxt_without'}\cell\row}" _n
file write trendrtf "{\trowd\trgaph108\trleft-108\clbrdrb\brdrw10\brdrs\cellx2600\clbrdrb\brdrw10\brdrs\cellx6600\clbrdrb\brdrw10\brdrs\cellx10600\pard\intbl\ql {Joint p-value}\cell \pard\intbl\qc {`ptxt_with'}\cell \pard\intbl\qc {`ptxt_without'}\cell\row}" _n
file write trendrtf "}" _n
file write trendrtf "{\pard\ql\fs20 Both columns use the identical Hispanic event-study sample and lead/lag structure; the only difference is whether metroFIPS enters as metroFIPS##c.dh_time (MSA fixed effect plus MSA-specific linear trend, the specification used elsewhere in this file) or as metroFIPS alone (MSA fixed effect only, matching the Column 1/m1 no-trend specification in the main DID table). * p<0.10, ** p<0.05, *** p<0.01.\par}" _n
file write trendrtf "{\pard \par}" _n
file write trendrtf "}" _n
file close trendrtf


********************************************************************************
* Descriptive: aggregate share of the analysis sample covered by BTB, by year
*
* Simple, all-races-pooled summary of BTB coverage growth across the full 2004-2019 window
* (not restricted to year>=2008 like the regressions above): what share of the analysis
* sample lives in a BTB-covered metroFIPS-stateFIPS-year cell each year, and the N behind it.
********************************************************************************

forvalues y = 2004/2019 {
	quietly count if year==`y' & dh_group != .
	local n_`y' = r(N)
	quietly summarize BTB if year==`y' & dh_group != .
	local rate_`y' : di %5.3f r(mean)
	local Ntxt_`y' : di %9.0fc `n_`y''
}

file open btbshare using "$out/diagnostic_btb_share_by_year.rtf", write replace
file write btbshare "{\rtf1\ansi\deff0 {\fonttbl\f0\fnil Times New Roman;}" _n
file write btbshare "\deflang1033\plain\fs24" _n
file write btbshare "{\pard\keepn\ql Share of analysis sample covered by BTB, by year (all races pooled)\par}" _n
file write btbshare "{" _n
file write btbshare "{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs\cellx1500\clbrdrt\brdrw10\brdrs\cellx4500\clbrdrt\brdrw10\brdrs\cellx7500\pard\intbl\ql {Year}\cell \pard\intbl\qc {Share under BTB}\cell \pard\intbl\qc {N}\cell\row}" _n

forvalues y = 2004/2019 {
	file write btbshare "{\trowd\trgaph108\trleft-108\cellx1500\cellx4500\cellx7500\pard\intbl\ql {`y'}\cell \pard\intbl\qc {`rate_`y''}\cell \pard\intbl\qc {`Ntxt_`y''}\cell\row}" _n
}

file write btbshare "}" _n
file write btbshare "{\pard\ql\fs20 Share of the analysis sample (men age 25-34, US citizens, less than a college degree; all races pooled) whose metroFIPS-stateFIPS-year cell is covered by BTB (BTB==1) that year. N is the number of person-year observations that year.\par}" _n
file write btbshare "{\pard \par}" _n
file write btbshare "}" _n
file close btbshare


********************************************************************************
* Verification: calendar-year breakdown of the Hispanic t-3 pre-trend bucket
*
* Stata reproduction of the earlier Python-based tabulation of which actual calendar years
* populate the "3 years before treatment" cell for Hispanic men (the cell driving the joint
* pre-trend F-test above). Cross-checks that investigation directly against the built dataset
* rather than relying on an external computation. N = number of Hispanic men observed exactly
* 3 years before their MSA's BTB effective date, in each calendar year that distance can land
* on; "mean employed (t-3 cell)" is the raw employment rate within that specific t-3 cell;
* "national Hispanic rate" is the raw employment rate for ALL Hispanic men that calendar year,
* not restricted to the t-3 cell, included for comparison.
********************************************************************************

quietly count if dh_hisp==1 & year>=2008 & btb_eff_year!=. & year==btb_eff_year-3
local total_t3 = r(N)

local cumshare = 0
forvalues y = 2008/2016 {
	quietly count if dh_hisp==1 & year==`y' & btb_eff_year!=. & year==btb_eff_year-3
	local n_`y' = r(N)
	local sharepct = 100*`n_`y''/`total_t3'
	local cumshare = `cumshare' + `sharepct'

	local Ntxt_`y' : di %9.0fc `n_`y''
	local sharetxt_`y' : di %5.1f `sharepct'
	local cumtxt_`y' : di %5.1f `cumshare'

	quietly summarize employed if dh_hisp==1 & year==`y' & btb_eff_year!=. & year==btb_eff_year-3
	local meanemp_`y' : di %5.3f r(mean)

	quietly summarize employed if dh_hisp==1 & year==`y'
	local natrate_`y' : di %5.3f r(mean)
}

local Ntxt_total : di %9.0fc `total_t3'

file open t3verify using "$out/diagnostic_t3_calendar_years.rtf", write replace
file write t3verify "{\rtf1\ansi\deff0 {\fonttbl\f0\fnil Times New Roman;}" _n
file write t3verify "\deflang1033\plain\fs24" _n
file write t3verify "{\pard\keepn\ql Hispanic men: calendar years underlying the t-3 pre-trend cell (total N = `Ntxt_total')\par}" _n
file write t3verify "{" _n
file write t3verify "{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs\cellx1300\clbrdrt\brdrw10\brdrs\cellx3300\clbrdrt\brdrw10\brdrs\cellx5300\clbrdrt\brdrw10\brdrs\cellx7300\clbrdrt\brdrw10\brdrs\cellx9800\clbrdrt\brdrw10\brdrs\cellx12300\pard\intbl\ql {Year}\cell \pard\intbl\qc {N}\cell \pard\intbl\qc {Share}\cell \pard\intbl\qc {Cum. share}\cell \pard\intbl\qc {Mean employed (t-3 cell)}\cell \pard\intbl\qc {National Hispanic rate}\cell\row}" _n

forvalues y = 2008/2016 {
	file write t3verify "{\trowd\trgaph108\trleft-108\cellx1300\cellx3300\cellx5300\cellx7300\cellx9800\cellx12300\pard\intbl\ql {`y'}\cell \pard\intbl\qc {`Ntxt_`y''}\cell \pard\intbl\qc {`sharetxt_`y''%}\cell \pard\intbl\qc {`cumtxt_`y''%}\cell \pard\intbl\qc {`meanemp_`y''}\cell \pard\intbl\qc {`natrate_`y''}\cell\row}" _n
}

file write t3verify "}" _n
file write t3verify "{\pard\ql\fs20 Sample: Hispanic men, year>=2008, with a defined BTB effective date for their MSA, restricted to observations exactly 3 years before that date (BTBpub_lead_2to3==1). Share and cumulative share are of the total t-3 cell (N=`Ntxt_total'). Mean employed (t-3 cell) and National Hispanic rate are both raw, unconditional means -- not regression-adjusted.\par}" _n
file write t3verify "{\pard \par}" _n
file write t3verify "}" _n
file close t3verify


********************************************************************************
* Robustness check: Hispanic men, dropping 2008-2009 (year >= 2010 only)
*
* The calendar-year breakdown above shows 55.4% of the entire Hispanic t-3 cell falls in
* 2008-2009, squarely at the apex of the Great Recession. This block drops those two years
* entirely (not just from the t-3 cell -- the whole sample, all leads and lags, restricted to
* year >= 2010) and re-estimates the same event study, to test whether the pre-trend survives
* once the years right at the recession's peak are removed altogether.
********************************************************************************

eststo clear

* Full sample (year>=2008; same as the original Hispanic result throughout this file)
reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_hisp==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)

scalar recession_N_full = e(N)
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar recession_F_full = r(F)
scalar recession_dfm_full = r(df)
scalar recession_dfr_full = r(df_r)
scalar recession_p_full = r(p)
scalar recession_lead3_b_full = _b[BTBpub_lead_2to3]
scalar recession_lead3_se_full = _se[BTBpub_lead_2to3]
scalar recession_lead3_p_full = 2*ttail(e(df_r), abs(recession_lead3_b_full/recession_lead3_se_full))
scalar recession_lead2_b_full = _b[BTBpub_lead_1to2]
scalar recession_lead2_se_full = _se[BTBpub_lead_1to2]
scalar recession_lead2_p_full = 2*ttail(e(df_r), abs(recession_lead2_b_full/recession_lead2_se_full))
scalar recession_lead1_b_full = _b[BTBpub_lead_0to1]
scalar recession_lead1_se_full = _se[BTBpub_lead_0to1]
scalar recession_lead1_p_full = 2*ttail(e(df_r), abs(recession_lead1_b_full/recession_lead1_se_full))

eststo clear

* Excluding 2008-2009 (year>=2010 only)
reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_lead_0to1 BTBpub_neg1 BTBpub_lag_* if dh_hisp==1 & year >= 2010, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)

* stored (not re-run) so the post-treatment lags already estimated here can be
* plotted below, alongside the leads used for the pre-trend test that follows
estimate store hisp_2010

scalar recession_N_post2010 = e(N)
test BTBpub_lead_2to3 = BTBpub_lead_1to2 = BTBpub_lead_0to1 = 0
scalar recession_F_post2010 = r(F)
scalar recession_dfm_post2010 = r(df)
scalar recession_dfr_post2010 = r(df_r)
scalar recession_p_post2010 = r(p)
scalar recession_lead3_b_post2010 = _b[BTBpub_lead_2to3]
scalar recession_lead3_se_post2010 = _se[BTBpub_lead_2to3]
scalar recession_lead3_p_post2010 = 2*ttail(e(df_r), abs(recession_lead3_b_post2010/recession_lead3_se_post2010))
scalar recession_lead2_b_post2010 = _b[BTBpub_lead_1to2]
scalar recession_lead2_se_post2010 = _se[BTBpub_lead_1to2]
scalar recession_lead2_p_post2010 = 2*ttail(e(df_r), abs(recession_lead2_b_post2010/recession_lead2_se_post2010))
scalar recession_lead1_b_post2010 = _b[BTBpub_lead_0to1]
scalar recession_lead1_se_post2010 = _se[BTBpub_lead_0to1]
scalar recession_lead1_p_post2010 = 2*ttail(e(df_r), abs(recession_lead1_b_post2010/recession_lead1_se_post2010))

eststo clear

* Build "coefficient*** (se)" cell text for each lead x spec
foreach spec in full post2010 {
	foreach lead in 3 2 1 {
		local b : di %6.4f recession_lead`lead'_b_`spec'
		local se : di %6.4f recession_lead`lead'_se_`spec'
		local pval = recession_lead`lead'_p_`spec'
		local stars ""
		if `pval' < 0.01 local stars "***"
		else if `pval' < 0.05 local stars "**"
		else if `pval' < 0.10 local stars "*"
		local lead`lead'txt_`spec' "`b'`stars' (`se')"
	}
	local Ntxt_`spec' : di %9.0fc recession_N_`spec'
	local Ftxt_`spec' : di %9.3f recession_F_`spec'
	local dfmtxt_`spec' : di %9.0f recession_dfm_`spec'
	local dfrtxt_`spec' : di %9.0f recession_dfr_`spec'
	local ptxt_`spec' : di %9.4f recession_p_`spec'
}

file open recessionrtf using "$out/diagnostic_pretrend_post2010.rtf", write replace
file write recessionrtf "{\rtf1\ansi\deff0 {\fonttbl\f0\fnil Times New Roman;}" _n
file write recessionrtf "\deflang1033\plain\fs24" _n
file write recessionrtf "{\pard\keepn\ql Hispanic men, full sample vs. dropping 2008-2009: pre-trend leads and joint test, H0: t-3 = t-2 = t-1 = 0\par}" _n
file write recessionrtf "{" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\clbrdrt\brdrw10\brdrs\cellx2600\clbrdrt\brdrw10\brdrs\cellx6600\clbrdrt\brdrw10\brdrs\cellx10600\pard\intbl\ql {}\cell \pard\intbl\qc {Full sample (year>=2008)}\cell \pard\intbl\qc {Excl. 2008-2009 (year>=2010)}\cell\row}" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {N}\cell \pard\intbl\qc {`Ntxt_full'}\cell \pard\intbl\qc {`Ntxt_post2010'}\cell\row}" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {t-3}\cell \pard\intbl\qc {`lead3txt_full'}\cell \pard\intbl\qc {`lead3txt_post2010'}\cell\row}" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {t-2}\cell \pard\intbl\qc {`lead2txt_full'}\cell \pard\intbl\qc {`lead2txt_post2010'}\cell\row}" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\clbrdrb\brdrw10\brdrs\cellx2600\clbrdrb\brdrw10\brdrs\cellx6600\clbrdrb\brdrw10\brdrs\cellx10600\pard\intbl\ql {t-1}\cell \pard\intbl\qc {`lead1txt_full'}\cell \pard\intbl\qc {`lead1txt_post2010'}\cell\row}" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {Joint F-statistic}\cell \pard\intbl\qc {`Ftxt_full'}\cell \pard\intbl\qc {`Ftxt_post2010'}\cell\row}" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\cellx2600\cellx6600\cellx10600\pard\intbl\ql {df}\cell \pard\intbl\qc {`dfmtxt_full', `dfrtxt_full'}\cell \pard\intbl\qc {`dfmtxt_post2010', `dfrtxt_post2010'}\cell\row}" _n
file write recessionrtf "{\trowd\trgaph108\trleft-108\clbrdrb\brdrw10\brdrs\cellx2600\clbrdrb\brdrw10\brdrs\cellx6600\clbrdrb\brdrw10\brdrs\cellx10600\pard\intbl\ql {Joint p-value}\cell \pard\intbl\qc {`ptxt_full'}\cell \pard\intbl\qc {`ptxt_post2010'}\cell\row}" _n
file write recessionrtf "}" _n
file write recessionrtf "{\pard\ql\fs20 The year>=2010 column drops 2008-2009 entirely (all leads and lags, not just the t-3 cell), re-estimating the full event study on the restricted window. * p<0.10, ** p<0.05, *** p<0.01.\par}" _n
file write recessionrtf "{\pard \par}" _n
file write recessionrtf "}" _n
file close recessionrtf


********************************************************************************
* Event study, Hispanic men, year >= 2010: same regression as the recession
* robustness check just above (BTBpub_lag_* was already in that model, so
* nothing is re-estimated here), now plotted with the post-treatment lags
* included rather than just the leads.
*
* The recession check establishes that the pre-trend problem is resolved in
* this window (clean leads, see diagnostic_pretrend_post2010.rtf). This plot
* answers the separate question that motivated it in the first place: once
* the confounded 2008-2009 years are dropped, does the *post*-treatment path
* stay flat, or does it keep moving the way Kaestner and Wang's period-split
* CPS results suggest it might for this group? A flat post-period here, next
* to the DIAGNOSTIC 6 bacondecomp below, is the actual test of whether
* staggered timing (as opposed to the now-resolved pre-trend) is a live
* concern for the Hispanic estimates specifically. Same styling/coeflabels/
* axis range as figure A.3b so the two are directly comparable.
********************************************************************************

coefplot (hisp_2010, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black)) ///
		(hisp_2010, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black) offset(-0.01)) ///
		(hisp_2010, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.2(.1)0.2, angle(horizontal) labsize(5) nogrid) yscale(range(-0.2 0.2)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_hispanic_2010restricted.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
graph export "$out/figureA3b_2010restricted.emf", replace

=======
graph export "$out/figureA3c.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace


>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea

*** public-sector employment ***

*** appendix figure a4.a: Black ***
eststo clear

reghdfe employed_public BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_neg1  BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5 if dh_blackNH==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
estimate store baseline_black
coefplot (baseline_black, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black)) ///
		(baseline_black, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_black, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.1(.05)0.1, angle(horizontal) labsize(5) nogrid) yscale(range(-0.1 0.1)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_black_public.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA4a.emf", replace
=======
graph export "$out/figureA4a.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea


*** appendix figure a4.b: Hispanic ***
eststo clear

reghdfe employed_public BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_neg1  BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5 if dh_hisp==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
estimate store baseline_hisp
coefplot (baseline_hisp, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_hisp, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black)) ///
		(baseline_hisp, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.1(.05)0.1, angle(horizontal) labsize(5) nogrid) yscale(range(-0.1 0.1)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_hispanic_public.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA4b.emf", replace
=======
graph export "$out/figureA4b.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea


*** appendix figure a4.c: white ***

eststo clear
	
reghdfe employed_public BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_neg1  BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5 if dh_whiteNH==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
estimate store baseline_white
coefplot (baseline_white, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_white, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black)) ///
		(baseline_white, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.1(.05)0.1, angle(horizontal) labsize(5) nogrid) yscale(range(-0.1 0.1)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")
	
graph export "$out/event_study_acs_annual_white_public.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA4c.emf", replace
=======
graph export "$out/figureA4c.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea



*** drop group quarters ***
preserve

drop if (gq == 3 | gq == 4)

*** appendix figure a.5a: Black ***
eststo clear

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_neg1  BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5 if dh_blackNH==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
estimate store baseline_black
coefplot (baseline_black, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black)) ///
		(baseline_black, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_black, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.2(.1)0.2, angle(horizontal) labsize(5) nogrid) yscale(range(-0.2 0.2)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_black_nogq.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA5a.emf", replace
=======
graph export "$out/figureA5a.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea


*** appendix figure a.5b: Hispanic ***
eststo clear

reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_neg1  BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5 if dh_hisp==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
estimate store baseline_hisp
coefplot (baseline_hisp, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_hisp, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black)) ///
		(baseline_hisp, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.2(.1)0.2, angle(horizontal) labsize(5) nogrid) yscale(range(-0.2 0.2)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")

graph export "$out/event_study_acs_annual_hispanic_nogq.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA5b.emf", replace
=======
graph export "$out/figureA5b.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea

	
*** appendix figure a.5c: white ***
eststo clear
	
reghdfe employed BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2 BTBpub_neg1  BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5 if dh_whiteNH==1 & year >= 2008, vce(cluster stateFIPS) absorb(age in_school educd dh_time#gereg metroFIPS##c.dh_time)
estimate store baseline_white
coefplot (baseline_white, keep(BTBpub_lead_3to4 BTBpub_lead_2to3 BTBpub_lead_1to2) lcolor(black) mcolor(black) offset(-0.01)) ///
		(baseline_white, keep(BTBpub_neg1) omitted lcolor(black) mcolor(black)) ///
		(baseline_white, keep(BTBpub_lag_0to1 BTBpub_lag_1to2 BTBpub_lag_2to3 BTBpub_lag_3to4 BTBpub_lag_4to5) lcolor(black) mcolor(black) offset(-0.01)) ///
	, vertical ytitle("") xtitle("Years Since BTB Implementation", size(5)) subtitle("Effect Size", size(5) pos(11) margin(l=-9.5)) title(`""') xlabel(, labsize(5)) ylabel(-0.2(.1)0.2, angle(horizontal) labsize(5) nogrid) yscale(range(-0.2 0.2)) recast(connected) label  graphregion(fcolor(white))  lwidth(*2)  legend(off) yline(0, lcolor(gs12)) xline(4, lpattern(dash)) ciopts(recast(rline) lpattern(dash) lcolor(black)) coeflabels(BTBpub_lead_3to4 = "t-4" BTBpub_lead_2to3 = "t-3" BTBpub_lead_1to2 = "t-2" BTBpub_neg1 = "t-1" BTBpub_lag_0to1 = "t" BTBpub_lag_1to2 = "t+1" BTBpub_lag_2to3 = "t+2" BTBpub_lag_3to4 = "t+3" BTBpub_lag_4to5 = "t+4")
	
graph export "$out/event_study_acs_annual_white_nogq.eps", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
<<<<<<< HEAD
graph export "$out/figureA5c.emf", replace
=======
graph export "$out/figureA5c.pdf", fontface(Times) fontfacesans(Times) fontfaceserif(Times) fontfacemono(Times) fontfacesymbol(Times) replace
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea


restore
	
*******************
*** Regressions ***
*******************

eststo clear

local outcome "employed"

* table 2, column 1: reproduction of Doleac and Hansen (2020) preferred ACS specification, made in "analysis_btb_acs_reproduceDH.do"

* table 2, column 2: specification not included in Doleac and Hansen (2020): "fully interacted" controls, all sample years, no time trends
eststo m1: reghdfe `outcome' BTBxBlackNH BTBxHisp BTBxWhiteNH, vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH metroFIPS#dh_hisp metroFIPS#dh_whiteNH)

qui summ `outcome' if (dh_blackNH == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ `outcome' if (dh_hisp == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ `outcome' if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar white_mean = r(mean), replace 
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))

* table 2, column 3: correction of Doleac and Hansen (2020) preferred ACS specification--"fully interacted" controls and linear time trends
eststo m2: reghdfe `outcome' BTBxBlackNH BTBxHisp BTBxWhiteNH, vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

qui summ `outcome' if (dh_blackNH == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ `outcome' if (dh_hisp == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ `outcome' if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar white_mean = r(mean), replace 
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))

* table 2, column 4: MSAs only 
eststo m3: reghdfe `outcome' BTBxBlackNH BTBxHisp BTBxWhiteNH  if (metroFIPS != stateFIPS), vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

qui summ `outcome' if (dh_blackNH == 1 & BTB == 0 & BTBever == 1 & metroFIPS != stateFIPS)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ `outcome' if (dh_hisp == 1 & BTB == 0 & BTBever == 1 & metroFIPS != stateFIPS)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ `outcome' if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1 & metroFIPS != stateFIPS)
qui estadd scalar white_mean = r(mean), replace 
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))

* table 2, column 5: BTB adopting-only 
eststo m4: reghdfe `outcome' BTBxBlackNH BTBxHisp BTBxWhiteNH if (BTBever == 1), vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

qui summ `outcome' if (dh_blackNH == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ `outcome' if (dh_hisp == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ `outcome' if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1)
qui estadd scalar white_mean = r(mean), replace 
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))

* table 2, column 6 (corrected Doleac and Hansen, 2020 preferred specification): full sample, 2008 and later 
eststo m5: reghdfe `outcome' BTBxBlackNH BTBxHisp BTBxWhiteNH if (year >= 2008), vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

qui summ `outcome' if (dh_blackNH == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ `outcome' if (dh_hisp == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ `outcome' if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar white_mean = r(mean), replace 
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))

* Save estimates for retro_design_analysis
global acs_blk_correct = e(b)[1,1]
global acs_his_correct = e(b)[1,2]
global acs_wht_correct = e(b)[1,3]
global s_acs_blk_correct = sqrt(e(V)[1,1])
global s_acs_his_correct = sqrt(e(V)[2,2])
global s_acs_wht_correct = sqrt(e(V)[3,3])

global df_acs = e(df_r)

<<<<<<< HEAD
* table 2, column 7: full sample, 2010 and later. Added after the pre-trend diagnostics above
* found that the Hispanic joint pre-trend test (t-3 = t-2 = t-1 = 0) is driven almost entirely
* by 2008-2009, the apex of the Great Recession -- excluding those two years reduces the joint
* F-test from 5.666 (p=0.002) to 0.506 (p=0.680), with the t-3 point estimate itself falling by
* roughly two-thirds, at a cost of only ~14% of the sample (the recession years are heavily
* overrepresented in the narrow pre-trend comparison window but are a much smaller share of the
* full estimation sample). For Hispanic men specifically, this year>=2010 cut is accordingly the
* preferred specification; Black and White men's coefficients are reported alongside for
* comparison, since they come from the same pooled regression.
eststo m6: reghdfe `outcome' BTBxBlackNH BTBxHisp BTBxWhiteNH if (year >= 2010), vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

qui summ `outcome' if (dh_blackNH == 1 & BTB == 0 & BTBever == 1 & year >= 2010)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ `outcome' if (dh_hisp == 1 & BTB == 0 & BTBever == 1 & year >= 2010)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ `outcome' if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1 & year >= 2010)
qui estadd scalar white_mean = r(mean), replace
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))


local include_models "m1 m2 m3 m4 m5 m6"
=======

local include_models "m1 m2 m3 m4 m5"
>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea

* Output regression table
estfe `include_models', labels(metroFIPS "MSA FE" dh_time#gereg "Year-Region FE" age#dh_group "Demographics" metroFIPS#c.dh_time "MSA-Specific Trends")

<<<<<<< HEAD
esttab `include_models' using "$out/table2.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("black_mean Pre-BTB Mean: Black" "hispanic_mean Pre-BTB Mean: Hispanic" "white_mean Pre-BTB Mean: White" "black_percent \% Effect: Black" "hispanic_percent \% Effect: Hispanic" "white_percent \% Effect: White") sfmt(4 4 4 2 2 2) nomtitles keep(BTBx*) coeflabels(BTBxWhiteNH "BTB x White" BTBxBlackNH "BTB x Black" BTBxHisp "BTB x Hispanic") star(* 0.10 ** 0.05 *** 0.01)


********************************************************************************
* DIAGNOSTIC 1: Incremental year-cutoff check
* Re-estimate the preferred specification (fully interacted, MSA-by-race linear trends)
* while progressively extending the sample end-year from 2014 to 2019. This shows whether
* the shift documented between Table 1 (2004-2014) and Table 2 (2004-2019) emerges gradually,
* or jumps sharply at a specific year (which would point to a data/coding artifact rather than
* a genuine change in the estimated effect over time).
*
* Sample start year is 2010, not 2008 (matching table 2's m6 column and the "preferred
* specification for Hispanic men" finding above): the pre-trend diagnostics showed 2008-2009,
* the apex of the Great Recession, are responsible for the Hispanic pre-trend anomaly, so this
* diagnostic is re-run on the same 2010+ window rather than the original 2008+ window.
********************************************************************************

eststo clear

forvalues endyr = 2014(1)2019 {
	eststo cutoff_`endyr': reghdfe `outcome' BTBxBlackNH BTBxHisp BTBxWhiteNH if (year >= 2010 & year <= `endyr'), ///
		vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)
}

local cutoff_models "cutoff_2014 cutoff_2015 cutoff_2016 cutoff_2017 cutoff_2018 cutoff_2019"

* Output a table of the six models side by side
esttab `cutoff_models' using "$out/diagnostic_yearcutoff.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps keep(BTBx*) coeflabels(BTBxWhiteNH "BTB x White" BTBxBlackNH "BTB x Black" BTBxHisp "BTB x Hispanic") star(* 0.10 ** 0.05 *** 0.01) mtitles("2010-2014" "2010-2015" "2010-2016" "2010-2017" "2010-2018" "2010-2019")

* Coefficient plots by race, one point per end-year, for visual inspection of
* whether the shift is gradual or discrete
*
* Note: coefplot does not reliably place separate stored estimates at distinct
* x-axis positions when they all share the same coefficient name (it instead
* groups them at one shared position, distinguished only by color/legend).
* To avoid this, the six point estimates and standard errors are extracted by
* hand into a small dataset and plotted directly with twoway.

preserve
clear
set obs 6
gen endyear = 2013 + _n

gen b_black = .
gen se_black = .
gen b_hisp = .
gen se_hisp = .
gen b_white = .
gen se_white = .

local i = 1
foreach m of local cutoff_models {
	estimates restore `m'
	replace b_black  = _b[BTBxBlackNH]  in `i'
	replace se_black = _se[BTBxBlackNH] in `i'
	replace b_hisp   = _b[BTBxHisp]     in `i'
	replace se_hisp  = _se[BTBxHisp]    in `i'
	replace b_white  = _b[BTBxWhiteNH]  in `i'
	replace se_white = _se[BTBxWhiteNH] in `i'
	local i = `i' + 1
}

foreach v in black hisp white {
	gen ci_lo_`v' = b_`v' - 1.96*se_`v'
	gen ci_hi_`v' = b_`v' + 1.96*se_`v'
}

twoway (rcap ci_lo_black ci_hi_black endyear, lcolor(gs8)) (scatter b_black endyear, mcolor(navy) msymbol(O)), ///
	yline(0, lcolor(gs12) lpattern(dash)) xlabel(2014(1)2019) xtitle("Sample End Year") ytitle("Effect Size") title("Black Men") legend(off) graphregion(fcolor(white))
graph export "$out/diagnostic_yearcutoff_black.eps", replace
graph export "$out/diagnostic_yearcutoff_black.emf", replace

twoway (rcap ci_lo_hisp ci_hi_hisp endyear, lcolor(gs8)) (scatter b_hisp endyear, mcolor(navy) msymbol(O)), ///
	yline(0, lcolor(gs12) lpattern(dash)) xlabel(2014(1)2019) xtitle("Sample End Year") ytitle("Effect Size") title("Hispanic Men") legend(off) graphregion(fcolor(white))
graph export "$out/diagnostic_yearcutoff_hispanic.eps", replace
graph export "$out/diagnostic_yearcutoff_hispanic.emf", replace

twoway (rcap ci_lo_white ci_hi_white endyear, lcolor(gs8)) (scatter b_white endyear, mcolor(navy) msymbol(O)), ///
	yline(0, lcolor(gs12) lpattern(dash)) xlabel(2014(1)2019) xtitle("Sample End Year") ytitle("Effect Size") title("White Men") legend(off) graphregion(fcolor(white))
graph export "$out/diagnostic_yearcutoff_white.eps", replace
graph export "$out/diagnostic_yearcutoff_white.emf", replace

restore


********************************************************************************
* DIAGNOSTIC 2: Formal test of whether the BTB effect differs
* pre- vs. post-2014
*
* Rather than informally comparing Table 1 (2004-2014) to Table 2 (2004-2019),
* this interacts the treatment variables with a post-2014 indicator within a
* single model estimated on the full 2008-2019 sample. The interaction
* coefficients (BTBxBlackNH#1.post2014, etc.) give a direct, formal test of
* whether the estimated effect for each group is significantly different in
* 2015-2019 relative to 2008-2014, with a proper standard error on the
* difference itself (rather than eyeballing two separately-estimated tables).
********************************************************************************

eststo clear

gen post2014 = (year > 2014)
label var post2014 "=1 if year is 2015 or later"

eststo posttest: reghdfe `outcome' c.BTBxBlackNH##i.post2014 c.BTBxHisp##i.post2014 c.BTBxWhiteNH##i.post2014 if (year >= 2008), ///
	vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

* Report the pre-2014 effect, the post-2014 effect, and the difference between them for each group
disp "----- Black men -----"
lincom BTBxBlackNH
disp "pre-2014 effect (above)"
lincom BTBxBlackNH + 1.post2014#c.BTBxBlackNH
disp "post-2014 effect (above)"
lincom 1.post2014#c.BTBxBlackNH
disp "difference (post - pre), with test of H0: no change (above)"

disp "----- Hispanic men -----"
lincom BTBxHisp
disp "pre-2014 effect (above)"
lincom BTBxHisp + 1.post2014#c.BTBxHisp
disp "post-2014 effect (above)"
lincom 1.post2014#c.BTBxHisp
disp "difference (post - pre), with test of H0: no change (above)"

disp "----- White men -----"
lincom BTBxWhiteNH
disp "pre-2014 effect (above)"
lincom BTBxWhiteNH + 1.post2014#c.BTBxWhiteNH
disp "post-2014 effect (above)"
lincom 1.post2014#c.BTBxWhiteNH
disp "difference (post - pre), with test of H0: no change (above)"

esttab posttest using "$out/diagnostic_posttest.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps nomtitles star(* 0.10 ** 0.05 *** 0.01)


********************************************************************************
* DIAGNOSTIC 3: Migration compositional check
*
* The main ITT design assigns treatment by current MSA of residence. If BTB
* adoption draws in job-seekers from elsewhere (or pushes others out), the
* post-adoption sample is no longer a fixed population -- the employment
* effect in Table 2 could partly reflect a compositional shift rather than a
* fixed set of people getting hired more/less. ACS is a repeated cross-section
* (no individual panel), but each respondent reports whether they lived in a
* different house one year ago (migrate1), so we can test whether the *share*
* of recent in-migrants in the treated demographic groups moves differentially
* in BTB-adopting MSAs after adoption, using the same specification as Table 2
* column 6 (m5: fully interacted controls, MSA-by-race linear trends, 2008+).
*
* migrate1 codes: 1 = same house one year ago (non-mover), 2 = moved within
* state, 3 = moved from a different state, 4 = moved from abroad, 0 = N/A.
*
* any_mover: moved at all (2/3/4) vs. stayed (1) -- broadest compositional test.
* interstate_mover: moved from a different state or abroad (3/4) vs. stayed
* (1); within-state movers (2) are set to missing and dropped, isolating the
* longer-distance moves most plausibly linked to a state-level policy change
* rather than routine local churn (which could still cross MSA lines, but is
* less likely to be BTB-driven).
********************************************************************************

eststo clear

gen any_mover = (migrate1 >= 2) if migrate1 != 0 & migrate1 != .
label var any_mover "=1 if moved (any distance) in the past year, 0 if same house"

gen interstate_mover = (migrate1 >= 3) if inlist(migrate1, 1, 3, 4)
label var interstate_mover "=1 if moved from a different state/abroad in the past year, 0 if same house"

eststo mig1: reghdfe any_mover BTBxBlackNH BTBxHisp BTBxWhiteNH if (year >= 2008), ///
	vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

qui summ any_mover if (dh_blackNH == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ any_mover if (dh_hisp == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ any_mover if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar white_mean = r(mean), replace
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))

eststo mig2: reghdfe interstate_mover BTBxBlackNH BTBxHisp BTBxWhiteNH if (year >= 2008), ///
	vce(cluster stateFIPS) absorb(dh_time#gereg#dh_group `demog_int' metroFIPS#dh_blackNH##c.dh_time metroFIPS#dh_hisp##c.dh_time metroFIPS#dh_whiteNH##c.dh_time)

qui summ interstate_mover if (dh_blackNH == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar black_mean = r(mean), replace
qui estadd scalar black_percent = 100*(e(b)[1,1]/r(mean))
qui summ interstate_mover if (dh_hisp == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar hispanic_mean = r(mean), replace
qui estadd scalar hispanic_percent = 100*(e(b)[1,2]/r(mean))
qui summ interstate_mover if (dh_whiteNH == 1 & BTB == 0 & BTBever == 1 & year >= 2008)
qui estadd scalar white_mean = r(mean), replace
qui estadd scalar white_percent = 100*(e(b)[1,3]/r(mean))

esttab mig1 mig2 using "$out/diagnostic_migration_composition.rtf", replace compress noconstant se(4) b(4) r2(4) nogaps noomitted nobase ///
	scalars("black_mean Pre-BTB Mover Share: Black" "hispanic_mean Pre-BTB Mover Share: Hispanic" "white_mean Pre-BTB Mover Share: White" "black_percent \% Effect: Black" "hispanic_percent \% Effect: Hispanic" "white_percent \% Effect: White") ///
	sfmt(4 4 4 2 2 2) mtitles("Any move" "Interstate/abroad move") keep(BTBx*) coeflabels(BTBxWhiteNH "BTB x White" BTBxBlackNH "BTB x Black" BTBxHisp "BTB x Hispanic") star(* 0.10 ** 0.05 *** 0.01)


********************************************************************************
* DIAGNOSTIC 4: Do pre-period characteristics predict BTB adoption (likelihood/timing)?
*
* Collapses the analysis sample (men 25-34, US citizens, less than a college
* degree -- the same population used throughout) down to one observation per
* MSA, using only 2004-2007 as the baseline period. Per
* diagnostic_btb_share_by_year.rtf, BTB coverage is 0.5%-2.5% of the sample in
* these years, i.e. essentially pre-treatment for everyone, so these years are
* a clean "before any of this happened" snapshot of each MSA.
*
* Two simple cross-sectional models test different questions:
*   (a) Selection into ever adopting: logit of ever_adopted (by 2019) on
*       baseline race-specific employment rates and racial composition,
*       comparing ever-treated MSAs to those that never adopt in-sample.
*   (b) Selection into adoption *timing*, among adopters only: OLS of
*       btb_eff_year on the same baseline characteristics, restricted to
*       ever-treated MSAs, testing whether early vs. late adopters looked
*       different at baseline.
*
* This is a cross-sectional sketch, not a formal hazard model: it doesn't
* left-truncate the handful of very early adopters (1999, 2005, 2007) as
* already-exited risk-set members, doesn't weight by population, and uses
* heteroskedasticity-robust (not clustered) SEs, since a given MSA can span
* multiple states in this MSA-level ITT design (e.g. Chattanooga TN-GA,
* Boston-Cambridge-Newton MA-NH), so there is no single well-defined state to
* cluster an MSA-level observation on. A Cox model (stcox) would be the
* natural next step if these baseline results suggest selection is worth
* modeling more carefully.
*
* Estimation N is well below the full 341-MSA count, for three distinct
* reasons (checked directly against the data, not just inferred):
*   (i)   25 metroFIPS codes have zero rows at all in 2004-2007 -- every one
*         of them first appears in exactly 2012, which is a metro-area
*         delineation/crosswalk vintage change, not a real absence of people.
*   (ii)  Of the remaining 316, 12 have zero Black (5) or zero Hispanic (7)
*         respondents in 2004-2007, so their race-specific baseline
*         employment rate is missing and they drop via listwise deletion.
*         These skew smaller (median ~152 obs vs. ~412 for retained MSAs).
*   (iii) model (b) additionally loses 31 more ever-treated units that clear
*         (i) and (ii) fine: these are the metroFIPS == stateFIPS "residual,
*         non-MSA, state-law-covered" pseudo-units (people outside any
*         identified MSA in a state with a public-sector BTB law -- see the
*         hardcoded `replace BTB = 1 if (metroFIPS == ## & year >= ####)`
*         block in build_acs_data.do). Those lines set BTB directly and never
*         populate btb_eff_year, so it is missing in literally every year for
*         these 31 units, not just 2004-2007 -- there is no "year they
*         adopted" to regress on. This is the same set of units Table 2's
*         own m3 column ("MSAs only") deliberately drops via
*         `if (metroFIPS != stateFIPS)`; model (b) below now does the same,
*         explicitly, instead of relying on incidental missingness. Model (a)
*         keeps them, since BTBever (unlike btb_eff_year) is well-defined for
*         them and "does this place ever adopt" is still a meaningful
*         question for a state-covered non-MSA area.
********************************************************************************

preserve

keep if year >= 2004 & year <= 2007

gen emp_black = employed if dh_blackNH == 1
gen emp_hisp  = employed if dh_hisp == 1
gen emp_white = employed if dh_whiteNH == 1

gen is_black = (dh_blackNH == 1)
gen is_hisp  = (dh_hisp == 1)
gen is_white = (dh_whiteNH == 1)

* flag the residual "non-MSA, state-law-covered" pseudo-units (constant
* within metroFIPS by construction) before collapsing, since stateFIPS itself
* isn't collapsible to a single value for MSAs that span multiple states
gen non_msa_residual = (metroFIPS == stateFIPS)

collapse (mean) baseline_emp_black=emp_black baseline_emp_hisp=emp_hisp baseline_emp_white=emp_white ///
	share_black=is_black share_hisp=is_hisp share_white=is_white ///
	(max) BTBever btb_eff_year non_msa_residual ///
	(count) n_obs=employed, by(metroFIPS)

gen ever_adopted = (BTBever == 1)
label var ever_adopted "=1 if MSA ever adopts BTB by 2019"

count if ever_adopted == 1
count if ever_adopted == 0
count if (ever_adopted == 1 & non_msa_residual == 1)
disp "^ ever-treated residual (non-MSA) units excluded from model (b) only, due to always-missing btb_eff_year"

eststo clear

* share_white omitted as the reference category: share_black, share_hisp, and
* share_white are collinear (all three constrained by the omitted "other race"
* share), so including all three produced three near-identical, hard-to-
* interpret coefficients. Dropping one lets the remaining two be read as
* "relative to White share."
eststo adopt_logit: logit ever_adopted baseline_emp_black baseline_emp_hisp baseline_emp_white share_black share_hisp, vce(robust)

eststo adopt_timing: reg btb_eff_year baseline_emp_black baseline_emp_hisp baseline_emp_white share_black share_hisp if (ever_adopted == 1 & non_msa_residual == 0), vce(robust)

esttab adopt_logit adopt_timing using "$out/diagnostic_adoption_selection.rtf", replace compress se(4) b(4) r2(4) nogaps ///
	mtitles("Ever adopts (logit)" "Adoption year (OLS, adopters only)") ///
	coeflabels(baseline_emp_black "Baseline Black emp. rate (2004-07)" baseline_emp_hisp "Baseline Hispanic emp. rate (2004-07)" baseline_emp_white "Baseline White emp. rate (2004-07)" share_black "Black pop. share (rel. to White)" share_hisp "Hispanic pop. share (rel. to White)") ///
	star(* 0.10 ** 0.05 *** 0.01)

restore


********************************************************************************
* DIAGNOSTIC 5: Goodman-Bacon (2021) decomposition
*
* Goodman-Bacon shows that a "vanilla" two-way fixed effects DD estimator
* (outcome on unit FE, time FE, and a single 0/1 treatment dummy -- no
* controls, no unit-specific trends) is a weighted average of every possible
* 2x2 DD comparison in a staggered-adoption design. Three kinds of 2x2s show
* up: (i) a timing group vs. never-treated units, (ii) an earlier-treated
* group vs. a later-treated group (using the later group as a control before
* it switches on), and (iii) a later-treated group vs. an earlier-treated
* group (using the already-treated earlier group as a control after it
* switches on). Comparisons of type (iii) subtract the later change in the
* *already-treated* group's own outcome, so if treatment effects grow or
* shrink over time in that group, the comparison is contaminated by its own
* treatment effect dynamics, not just by a violation of parallel trends. This
* decomposition tells us how much weight lands on the clean comparisons (i)
* vs. the potentially-contaminated timing comparisons (ii)-(iii), which is
* exactly the concern our MSA-specific linear trends and race-specific
* event-study checks are meant to address -- this diagnostic quantifies how
* much that concern applies here in the first place.
*
* Run separately by race (Black, Hispanic, White), matching every other
* diagnostic in this file, using the same year >= 2008 window as the
* preferred specification (m5/m6 in table2.rtf and all the pre-trend work
* above) so the decomposition describes the same design being used
* elsewhere. BTB (not the race-interacted BTBx* variables) is the right
* treatment variable here since each block is already restricted to one
* race.
*
* The underlying command, `bacondecomp`, only implements the "vanilla" TWFE
* model in Eq. (2) of the paper -- no covariates, no unit-specific trends --
* since Goodman-Bacon shows in Section 5 that those require a separate,
* more involved derivation the canned command doesn't cover. So this
* decomposes the simple, unadjusted version of the design, not our actual
* preferred specification (which adds demographic controls and MSA-by-race
* trends). That's the intended use here: it diagnoses whether the *timing*
* structure alone would be a problem for a naive TWFE estimate, which is the
* motivation for using the richer specification and event-study checks
* elsewhere in this file, not a decomposition of the richer model itself.
*
* Since our main regressions are unweighted at the person level (no perwt),
* each MSA-year cell is collapsed to an unweighted mean here too, so every
* MSA-year counts equally -- this is the standard way to apply
* bacondecomp to repeated cross-sectional data, though it is not a perfect
* numerical replica of the person-level regression (which implicitly
* upweights larger cells). cell_n is kept only for inspecting cell sizes,
* not used as a regression weight.
*
* Requires the user-written `bacondecomp` command (Goodman-Bacon, Goldring,
* and Nichols 2019), installed below via SSC if not already present. I
* cannot run Stata in this environment, so the option list here
* (`ddetail`) reflects the package's documented usage in the literature but
* has not been executed end-to-end -- run `help bacondecomp` after
* installing and adjust the option list below if your installed version
* differs. Each call prints its own summary table (weight and average 2x2
* estimate for the treated/untreated, earlier-vs-later, and
* later-vs-earlier comparisons) directly to the log open above, and produces
* a weight-vs-estimate scatter (Goodman-Bacon Fig. 6 style) that gets
* exported immediately after each call. Building a matching RTF summary
* table is a natural follow-up once we can see the exact names of the
* results the command stores.
********************************************************************************

cap ssc install bacondecomp
which bacondecomp

foreach race in black hisp white {

	preserve

	if "`race'" == "black" keep if (dh_blackNH == 1 & year >= 2008)
	if "`race'" == "hisp"  keep if (dh_hisp == 1 & year >= 2008)
	if "`race'" == "white" keep if (dh_whiteNH == 1 & year >= 2008)

	collapse (mean) employed (max) BTB (count) cell_n = employed, by(metroFIPS year)

	* bacondecomp runs on xtreg internally, which requires a strongly balanced
	* panel (every metroFIPS present in every year of the window). Ours isn't
	* -- ACS metro identifiability changes over time (see DIAGNOSTIC 4), so
	* some MSAs only appear in the collapsed data for part of 2008-2019.
	* Keep only MSAs with the maximum observed year coverage, mirroring the
	* same "at least X observations every year" logic used for the ACS
	* cell-size check at the very top of this file.
	bysort metroFIPS: gen n_years_present = _N
	summ n_years_present
	local maxyrs = r(max)
	count if n_years_present == `maxyrs'
	local n_msa_kept = r(N) / `maxyrs'
	disp "`race' men: keeping the `n_msa_kept' MSAs present in all `maxyrs' years of the window"
	keep if n_years_present == `maxyrs'
	drop n_years_present

	xtset metroFIPS year

	disp "===== Goodman-Bacon decomposition: `race' men ====="
	bacondecomp employed BTB, ddetail

	graph export "$out/diagnostic_bacon_`race'.eps", replace

	restore
}


********************************************************************************
* DIAGNOSTIC 6: Goodman-Bacon decomposition, Hispanic men, year >= 2010
*
* DIAGNOSTIC 5 above runs the vanilla decomposition on the same year >= 2008
* window used everywhere else in this file. For Hispanic men specifically,
* the t-3 pre-trend documented in the recession diagnostic (see "Robustness
* check: Hispanic men, dropping 2008-2009" and diagnostic_pretrend_post2010.rtf
* above) means that window's VWCT = 0 (parallel pre-trends) assumption does
* not hold, and Goodman-Bacon's decomposition is silent on that failure mode
* -- it only speaks to ΔATT (dynamic post-treatment effects contaminating
* already-treated units used as controls), a different assumption. Reading a
* weight split from the 2008+ window would confound the two. This block
* re-runs the Hispanic-only decomposition on year >= 2010, the window where
* the leads are already clean, so any divergence between the clean
* (treated/never-treated, earlier-vs-later-not-yet-treated) and at-risk
* (later-treated-vs-already-treated-earlier) comparison types here isolates
* ΔATT specifically, rather than picking up the recession confound.
*
* This restriction is not a free fix, though: every MSA that adopted BTB
* before 2010 becomes an always-treated unit within a 2010-2019 window, and
* per Goodman-Bacon Section 2, always-treated units "enter into the
* decomposition theorem exactly like never-treated units" -- i.e. they can
* only ever serve as controls, never as the treatment group in a 2x2. That
* shrinks the never-treated reservoir relative to DIAGNOSTIC 5's 2008+
* window and mechanically pushes more weight onto timing-only comparisons.
* So this is, if anything, a more demanding test of ΔATT bias than the
* full-window version, not a weaker one.
*
* Same vanilla-TWFE / unweighted MSA-year collapse / balanced-panel
* subsetting logic as DIAGNOSTIC 5 -- see the notes above that block for why
* bacondecomp is run this way rather than on the person-level, trend-and-
* control-adjusted preferred specification.
********************************************************************************

preserve

keep if (dh_hisp == 1 & year >= 2010)

collapse (mean) employed (max) BTB (count) cell_n = employed, by(metroFIPS year)

bysort metroFIPS: gen n_years_present = _N
summ n_years_present
local maxyrs = r(max)
count if n_years_present == `maxyrs'
local n_msa_kept = r(N) / `maxyrs'
disp "Hispanic men, 2010-2019: keeping the `n_msa_kept' MSAs present in all `maxyrs' years of the window"
keep if n_years_present == `maxyrs'
drop n_years_present

xtset metroFIPS year

disp "===== Goodman-Bacon decomposition: Hispanic men, 2010-2019 ====="
bacondecomp employed BTB, ddetail

graph export "$out/diagnostic_bacon_hisp_2010restricted.eps", replace

restore

=======
esttab `include_models' using "$out/table2.tex", replace compress noconstant se(4) b(4) r2(4) nogaps indicate(`r(indicate_fe)') noomitted nobase scalars("black_mean Pre-BTB Mean: Black" "hispanic_mean Pre-BTB Mean: Hispanic" "white_mean Pre-BTB Mean: White" "black_percent \% Effect: Black" "hispanic_percent \% Effect: Hispanic" "white_percent \% Effect: White") sfmt(4 4 4 2 2 2) nomtitles keep(BTBx*) coeflabels(BTBxWhiteNH "BTB x White" BTBxBlackNH "BTB x Black" BTBxHisp "BTB x Hispanic") star(* 0.10 ** 0.05 *** 0.01)


>>>>>>> 2c34ba91382b7f3e9ed86be331b5c0dd65be2bea
log close