// -----------------------------	
// Time Series - Measurement 
// Topic: HP, Hamilton, and Growth Rate Filters
// -----------------------------	
// Author: Stephen Snudden, PhD
// Website: https://stephensnudden.com/
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics
// -----------------------------

// **What this file covers**
// HP filter
// Hamilton filter
// Growth rate filter

// ***************************
// Intro 
// ***************************

capture drop _all
// Log Results
capture log close
capture log using results.log, replace
// Turn off pausing during output
set more off
// Make subfolder to put figures if it doesnt exist 
capture mkdir Figures 

// *********
// Load Quarterly Data
// *********

// Load Series
insheet using "CDataQ.csv", clear

// Set Quarterly Dates
display tq(1961q1)
gen time=tq(1961q1)+ _n-1
format time %tq
tsset time

replace y=y/1000 //Billions

label variable y "Real GDP Level"
notes y : CAD, in Billions
notes y : Canada
notes y : Statistics Canada

gen ly=ln(y)

label variable ly "Real GDP"

tsline ly if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Log-level (Real GDP)", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\loggdp.png", replace width(4000)

save DataQ, replace
// *********
// Compare Filters

// Baxter-King band-pass filter
tsfilter bk y_bk = ly, minperiod(6) maxperiod(32) trend(y_bkt)

// Butterworth filter high-pass filter
tsfilter bw y_bw = ly, maxperiod(32) order(8) trend(y_bwt)

// Christiano-Fitzgerald band-pass filter 
tsfilter cf y_cf = ly, minperiod(2) maxperiod(32) trend(y_cft)

// Hodrick-Prescott high-pass filter
tsfilter hp y_hp = ly, smooth(1600) trend(y_hpt)

label variable y_cft "Christiano-Fitzgerald Trend"
label variable y_bwt "Butterworth Trend"
label variable y_hpt "Hodrick-Prescott Trend"
label variable y_bkt "Baxter-King Trend"

replace y_bk = 100*y_bk
replace y_bw = 100*y_bw
replace y_cf = 100*y_cf
replace y_hp = 100*y_hp

label variable y_bk "Baxter-King Band Pass"
label variable y_bw "Butterworth High Pass"
label variable y_cf "Christiano-Fitzgerald Band Pass"
label variable y_hp "Hodrick-Prescott High Pass"

// Trend components (HP vs Actual)
tsline ly y_hpt if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Log-level", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(position(6) bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\loggdp_trend_hp.png", replace width(4000)

// Trend components (All Filters)
tsline ly y_hpt y_cft y_bwt if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Log-level", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(position(6) bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\loggdp_trend_all.png", replace width(4000)

// Cyclical components (HP Only)
tsline y_hp if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Percent Deviation From Trend", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(position(6) bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\bc_hp.png", replace width(4000)

// Cyclical components (All Filters)
tsline y_hp y_bw  y_cf if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Percent Deviation From Trend", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(position(6) bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\bc_bw_hp.png", replace width(4000)

// Hodrick-Prescott -- Tail Wag
gen lxy1=ly if tin(2000q1, 2019q3)
gen lxy2=ly if tin(2000q1, 2019q4)
gen lxy3=ly if tin(2000q1, 2020q1)
gen lxy4=ly if tin(2000q1, 2020q2)
gen lxy5=ly if tin(2000q1, 2020q3)
gen lxy6=ly if tin(2000q1, 2020q4)
gen lxy7=ly if tin(2000q1, 2021q1)
tsfilter hp xy_hp1 = lxy1, smooth(1600) trend(xy_hpt1)
tsfilter hp xy_hp2 = lxy2, smooth(1600) trend(xy_hpt2)
tsfilter hp xy_hp3 = lxy3, smooth(1600) trend(xy_hpt3)
tsfilter hp xy_hp4 = lxy4, smooth(1600) trend(xy_hpt4)
tsfilter hp xy_hp5 = lxy5, smooth(1600) trend(xy_hpt5)
tsfilter hp xy_hp6 = lxy6, smooth(1600) trend(xy_hpt6)
tsfilter hp xy_hp7 = lxy7, smooth(1600) trend(xy_hpt7)

tsline ly xy_hpt1 xy_hpt2 xy_hpt3 xy_hpt4 xy_hpt5 xy_hpt6 xy_hpt7 y_hpt if time>=tq(2015q1), ///
    lwidth(medthick) ///
    xlabel(220(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Log-level", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(off) ///
    graphregion(color(white))
graph export "Figures\tailwag.png", replace width(4000)

local lbm1 = 1/6
local ubm1 = 1/32

local lbm1 = 1/6
local ubm1 = 1/32
local seas = 1/4

// HP Filter Periodogram
pergram y_hp, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(dash) lwidth(medthick)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    lwidth(medthick) ///
    xtitle("Frequency (cycles per quarter)", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    title(" ") ///
    ytitle("Spectral density", size(medlarge)) ///
    note("") ///
    graphregion(color(white))
graph export "Figures\per_hp.png", replace width(4000)

// Butterworth Filter Periodogram
pergram y_bw, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(dash) lwidth(medthick)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    lwidth(medthick) ///
    xtitle("Frequency (cycles per quarter)", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    title(" ") ///
    ytitle("Spectral density", size(medlarge)) ///
    note("") ///
    graphregion(color(white))
graph export "Figures\per_bw.png", replace width(4000)
// *********
// Growth rate

// Y-o-Y Growth Rate
gen gy1= 100*(y/L1.y-1)
gen gy4= 100*(y/L4.y-1)
gen gy8= 100*(y/L8.y-1)

label variable gy1 "Q-o-Q Growth Rate"
label variable gy4 "Y-o-Y Growth Rate"
label variable gy8 "Y-o-2Y Growth Rate"

// ********************************************
// Growth Rate Comparisons (Time Series)
// ********************************************

// QoQ vs YoY Growth
twoway (tsline gy1 if time>=tq(2000q1), lwidth(medthick)) ///
       (tsline gy4 if time>=tq(2000q1), yaxis(2) lwidth(medthick)), ///
       ytitle("Percent Change (QoQ)", size(medlarge)) ///
       ytitle("Percent Change (YoY)", axis(2) size(medlarge)) ///
       xtitle("Quarter", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge)) ///
       ylabel(, axis(2) labsize(medlarge)) ///
       legend(position(6) rows(1) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
       graphregion(color(white))
graph export "Figures\growthrate.png", replace width(4000)

// YoY vs Yo2Y Growth
twoway (tsline gy4 if time>=tq(2000q1), lwidth(medthick)) ///
       (tsline gy8 if time>=tq(2000q1), yaxis(2) lwidth(medthick)), ///
       ytitle("Percent Change (YoY)", size(medlarge)) ///
       ytitle("Percent Change (Yo2Y)", axis(2) size(medlarge)) ///
       xtitle("Quarter", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge)) ///
       ylabel(, axis(2) labsize(medlarge)) ///
       legend(position(6) rows(1) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
       graphregion(color(white))
graph export "Figures\growthrateall.png", replace width(4000)

// HP Filter vs YoY Growth
twoway (tsline y_hp if time>=tq(2000q1) & time<=tq(2020q1), lwidth(medthick)) ///
       (tsline gy4 if time>=tq(2000q1) & time<=tq(2020q1), yaxis(2) lwidth(medthick)), ///
       ytitle("Percent Deviation", size(medlarge)) ///
       ytitle("Percent Change", axis(2) size(medlarge)) ///
       xtitle("Quarter", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge)) ///
       ylabel(, axis(2) labsize(medlarge)) ///
       legend(position(6) rows(1) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
       graphregion(color(white))
graph export "Figures\gdp_gy4_hp.png", replace width(4000)

// HP Filter vs QoQ Growth
twoway (tsline y_hp if time>=tq(2000q1) & time<=tq(2020q1), lwidth(medthick)) ///
       (tsline gy1 if time>=tq(2000q1) & time<=tq(2020q1), yaxis(2) lwidth(medthick)), ///
       ytitle("Percent Deviation", size(medlarge)) ///
       ytitle("Percent Change", axis(2) size(medlarge)) ///
       xtitle("Quarter", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge)) ///
       ylabel(, axis(2) labsize(medlarge)) ///
       legend(position(6) rows(1) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
       graphregion(color(white))
graph export "Figures\gdp_gy1_hp.png", replace width(4000)


// ********************************************
// Spectral Densities (Periodograms)
// ********************************************

local seas = 1/4
local lbm1 = 1/6
local ubm1 = 1/32

// Periodogram: QoQ Growth
pergram gy1, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(solid) lwidth(medthick)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    lwidth(medthick) ///
    title(" ") ///
    ytitle("Spectral Density", size(medlarge)) ///
    xtitle("Frequency (cycles per quarter)", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    legend(off) ///
    note("") ///
    graphregion(color(white))
graph export "Figures\per_gy1.png", replace width(4000)

// Periodogram: YoY Growth
pergram gy4, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(solid) lwidth(medthick)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    lwidth(medthick) ///
    title(" ") ///
    ytitle("Spectral Density", size(medlarge)) ///
    xtitle("Frequency (cycles per quarter)", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    legend(off) ///
    note(" ") ///
    graphregion(color(white))
graph export "Figures\per_gy4.png", replace width(4000)

// Periodogram: Yo2Y Growth
pergram gy8, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(solid) lwidth(medthick)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    lwidth(medthick) ///
    title(" ") ///
    ytitle("Spectral Density", size(medlarge)) ///
    xtitle("Frequency (cycles per quarter)", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    legend(off) ///
    note(" ") ///
    graphregion(color(white))
graph export "Figures\per_gy8.png", replace width(4000)


// **************
// Hamilton Filter
// **************

// Hamilton's regression method
reg ly L(8/11).ly
// Fit=Trend
predict y_hat
// Fit=Cycle
predict y_ha, resid
// Percent deviation from Trend
replace y_ha = 100*y_ha

// Label

label variable y_ha "Hamilton Filter"
label variable y_hat "Hamilton Trend"

local seas = 1/4
local lbm1 = 1/6
local ubm1 = 1/32

// Hamilton Filter Periodogram
pergram y_ha, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(solid) lwidth(medthick)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    lwidth(medthick) ///
    xtitle("Frequency (cycles per quarter)", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    title(" ") ///
    ytitle("Spectral density", size(medlarge)) ///
    note("") ///
    graphregion(color(white))
graph export "Figures\per_ham.png", replace width(4000)

// Phase Shift Comparison
twoway (tsline y_hp y_ha if time>=tq(2000q1), lwidth(medthick)) ///
       (tsline gy1 gy4 if time>=tq(2000q1), yaxis(2) lwidth(medthick)), ///
       ytitle("Percent Deviation", size(medlarge)) ///
       ytitle("Percent Change", axis(2) size(medlarge)) ///
       xtitle("Quarter", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge)) ///
       ylabel(, axis(2) labsize(medlarge)) ///
       legend(position(6) rows(2) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
       graphregion(color(white))
graph export "Figures\phaseshift.png", replace width(4000)

//Time trend
gen t=_n
gen t2= t^2
gen t3= t^3

// Detrended Y-o-2Y
reg gy8 t if time>=tq(2000q1)
capture drop gy8_de
predict gy8_de, res
label variable gy8_de "Linearly Detrended Y-o-2Y Growth Rate"
// ********************************************
// Hamilton Comparisons
// ********************************************

// Hamilton vs Detrended Yo2Y
tsline gy8_de y_ha if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Percent Change", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\gdp_ham_det.png", replace width(4000)

// Compare Hamilton to Y-o-2Y (Single Axis)
tsline gy8 y_ha if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Percent Change", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\gdp_ham.png", replace width(4000)

// Compare Hamilton to Y-o-2Y (Dual Axis)
// Note: This overwrites the previous file, as in your original script
twoway (tsline y_ha if time>=tq(2000q1), lwidth(medthick)) ///
       (tsline gy8 if time>=tq(2000q1), yaxis(2) lwidth(medthick)), ///
       ytitle("Percent Deviation from Trend", size(medlarge)) ///
       ytitle("Percent Change", axis(2) size(medlarge)) ///
       xtitle("Quarter", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge)) ///
       ylabel(, axis(2) labsize(medlarge)) ///
       legend(position(6) rows(1) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
       graphregion(color(white))
graph export "Figures\gdp_ham.png", replace width(4000)

// Hamilton Cycle Only
tsline y_ha if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Percent Deviation from Trend", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(1) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\ham_cyc.png", replace width(4000)

// Hamilton Trend vs Level
tsline ly y_hat if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Log Level / Trend", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\gdp_ham_trend.png", replace width(4000)

// ********************************************
// The "Everything" Comparison
// ********************************************

twoway (tsline y_hp y_ha y_cf if time>=tq(2000q1), lwidth(medthick)) ///
       (tsline gy4 gy8 if time>=tq(2000q1), yaxis(2) lwidth(medthick)), ///
       ytitle("Percent Deviation", size(medlarge)) ///
       ytitle("Percent Change", axis(2) size(medlarge)) ///
       xtitle("Quarter", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge)) ///
       ylabel(, axis(2) labsize(medlarge)) ///
       legend(position(6) rows(3) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
       graphregion(color(white))
graph export "Figures\gdp_alt_filters.png", replace width(4000)


// *********
// Hamilton-Filter -- Sample Dependency
clear all
use DataQ

gen lyx = ly if tin(1990q1, 2025q3)
drop ly
rename lyx ly

reg ly L(8/11).ly 
predict y_ha, resid

// Hamilton's regression method
reg F8.ly L(0/3).ly if tin(1990q1, 2025q3)
predict y_ha0, resid
reg F8.ly L(0/3).ly if tin(1990q1, 2022q1)
predict y_ha1 if time<=tq(2022q1), resid 
reg F8.ly L(0/3).ly if tin(1990q1, 2019q1)
predict y_ha2 if time<=tq(2019q1), resid
reg F8.ly L(0/3).ly if tin(1990q1, 2016q1)
predict y_ha3 if time<=tq(2016q1), resid
reg F8.ly L(0/3).ly if tin(1990q1, 2013q1)
predict y_ha4 if time<=tq(2013q1), resid
reg F8.ly L(0/3).ly if tin(1990q1, 2010q1)
predict y_ha5 if time<=tq(2010q1), resid
reg F8.ly L(0/3).ly if tin(1990q1, 2007q1)
predict y_ha6 if time<=tq(2007q1), resid

replace y_ha = 100*y_ha
gen y_h0 = 100*(L8.y_ha0)
gen y_h1 = 100*(L8.y_ha1)
gen y_h2 = 100*(L8.y_ha2)
gen y_h3 = 100*(L8.y_ha3)
gen y_h4 = 100*(L8.y_ha4)
gen y_h5 = 100*(L8.y_ha5)
gen y_h6 = 100*(L8.y_ha6)

label variable y_h0 "Hamilton Filter"
label variable y_ha "Hamilton Filter Shifted "

// ********************************************
// Robustness Checks
// ********************************************

// Specification Robustness
tsline y_h0 y_ha if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Percent Deviation from Trend", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(position(6) rows(1) bmargin(small) nobox region(lstyle(none) lcolor(white)) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\specrobust.png", replace width(4000)

// Sample Robustness
tsline y_h0 y_h1 y_h2 y_h3 y_h4 y_h5 if time>=tq(2000q1), ///
    lwidth(medthick) ///
    xlabel(160(20)260, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    ytitle("Percent Deviation from Trend", size(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    legend(off) ///
    graphregion(color(white))
graph export "Figures\samplerobust.png", replace width(4000)


// **************
// Hodrick-Prescott high-pass filter vs Ideal Filter
// **************

clear all
use DataQ

local lbm = 32
// natural-frequency cutoffs: lower (1/32 = 0.03125); upper (1/6 ~ 0.16667).
tsfilter hp y_hp = ly, smooth(1600) gain(hpgain ahp) trend(y_hpt)
tsfilter hp y_hp2 = ly, smooth(600) gain(hpgain2 ahp2) trend(y_hpt2)
label variable y_hpt "Hodrick-Prescott High Pass"

// Compare the Gains of BK and ideal filters
gen hpgain1 = 1-hpgain
label variable hpgain "Hodrick-Prescott (1600)"
label variable hpgain2 "Hodrick-Prescott (600)"
local lb = 2*_pi/`lbm'

// Generate ideal filter
generate f = _pi*(_n-1)/_N
generate ideal = (f>=`lb')
label variable ideal "Ideal filter"

gen t_ahp = 2*_pi/ahp
gen t_ahp2 = 2*_pi/ahp2
gen t_f = 2*_pi/f

twoway (line ideal t_f if t_f<80, lwidth(medthick)), ///
       legend(position(6) rows(1) size(medsmall)) ///
       graphregion(color(white)) ///
	   xline(`lbm', lcolor(red) lpattern(dash) lwidth(medthick)) ///
	   text(0.95 `lbm' "32Q", place(c) size(medium) color(gs8)) ///
       xtitle("Quarters", size(medlarge)) ///
       ytitle("Squared Gain", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge))
graph export "Figures\t_hpgain0.png", replace width(4000)

twoway (line ideal t_f if t_f<80, lwidth(medthick)) ///
       (line hpgain t_ahp if t_ahp<80, lwidth(medthick)), ///
	   	   xline(`lbm', lcolor(red) lpattern(dash) lwidth(medthick)) ///
	   text(0.95 `lbm' "32Q", place(c) size(medium) color(gs8)) ///
       legend(position(6) rows(1) size(medsmall)) ///
       graphregion(color(white)) ///
       xtitle("Quarters", size(medlarge)) ///
       ytitle("Squared Gain", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge))
graph export "Figures\t_hpgain1.png", replace width(4000)

twoway (line ideal t_f if t_f<80, lwidth(medthick)) ///
       (line hpgain t_ahp if t_ahp<80, lwidth(medthick)) ///
       (line hpgain2 t_ahp2 if t_ahp2<80, lwidth(medthick)), ///
	   	   xline(`lbm', lcolor(red) lpattern(dash) lwidth(medthick)) ///
	   text(0.95 `lbm' "32Q", place(c) size(medium) color(gs8)) ///
       legend(position(6) rows(1) size(medsmall)) ///
       graphregion(color(white)) ///
       xtitle("Quarters", size(medlarge)) ///
       ytitle("Squared Gain", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge))
graph export "Figures\t_hpgain.png", replace width(4000)

// **************
//  Butterworth Filter vs Ideal Filter
// **************

clear all
use DataQ

local lbm = 32
// natural-frequency cutoffs: lower (1/32 = 0.03125); upper (1/6 ~ 0.16667).
tsfilter bw y_bw = y, maxperiod(`lbm') gain(bwgain abw) trend(y_bwt) order(8) 
label variable y_bwt "Butterworth low pass trend"
// Compare the Gains of BK and ideal filters
gen bwgain1 = 1-bwgain
label variable bwgain "Butterworth High-Pass"
local lb = 2*_pi/`lbm'
// Generate ideal filter
generate f = _pi*(_n-1)/_N
generate ideal = cond(f>`lb', 1,0)
label variable ideal "Ideal filter"
*twoway line ideal f || line bwgain1 abw,  graphregion(color(white))
*graph export "Figures\bpgain.png", replace

gen t_abw = 2*_pi/abw
gen t_f = 2*_pi/f

twoway (line ideal t_f if t_f<80, lwidth(medthick)) ///
       (line bwgain t_abw if t_abw<80, lwidth(medthick)), ///
       legend(position(6) rows(1) size(medsmall)) ///
       graphregion(color(white)) ///
       xtitle("Quarters", size(medlarge)) ///
       ytitle("Weight", size(medlarge)) ///
       xlabel(, labsize(medlarge)) ///
       ylabel(, labsize(medlarge))
graph export "Figures\t_bwgain.png", replace width(4000)

// **************
// Growth Rate Filter
// **************

clear all
use DataQ
gen gy1= 100*(y/L1.y-1)
arima gy1, arima(1,0,0) vce(robust)
estat ic
psdensity psden1 omega
label variable psden1 "ARIMA(BIC) Level"
gen w1 = 2-2*cos(omega)
label variable w1 "Quarter-over-quarter growth"
gen w2 = 2-2*cos(2*omega)
label variable w2 "%Δ Z=2"
gen w4 = 2-2*cos(4*omega)
label variable w4 "Year-over-year growth"
gen w6 = 2-2*cos(6*omega)
label variable w6 "%Δ Z=6"
gen w8 = 2-2*cos(8*omega)
label variable w8 "Year-over-two-year growth"
gen w12 = 2-2*cos(12*omega)
label variable w12 "%Δ Z=12"

graph twoway line w1 w2 w4 omega, title(Spectral Density Filter of Log-Difference at Lag Z)  clcolor(blue purple black green) clpattern(solid dash dot dash_dot) xline(`=1/6*_pi' `=1/3*_pi' `=1/2*_pi') legend( rows(1) position(6) region(lcolor(white))) xtitle(Frequency) ytitle(Squared Gain) graphregion(color(white)) 
graph export "Figures\o_growth.tif", replace width(4000)

// Hamilton Filter
gen p = 4
gen h = 8
gen sum_cos = cos(0*omega) + cos(1*omega) + cos(2*omega) + cos(3*omega)
gen sum_sin = sin(0*omega) + sin(1*omega) + sin(2*omega) + sin(3*omega)

* Gain calculation (Simplified for RW case)
gen ham_gain = 1 + (1/p^2)*(sum_cos^2 + sum_sin^2) - (2/p)*(cos(h*omega)*sum_cos - sin(h*omega)*sum_sin)

label variable ham_gain "Hamilton Filter"

// NOT ALL EQUAL TO 2~!
gen tomg = 2*_pi/omega

// ********************************************
// Filter Gain Comparisons
// ********************************************

// Hamilton Gain vs Yo2Y Gain
graph twoway ///
    line w8 ham_gain tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    clcolor(blue purple black green) ///
    clpattern(solid dash dash_dot dot) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
    xline(4, lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    legend(position(6) region(lcolor(white)) rows(1) size(medsmall)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_ham.png", replace width(4000)

// QoQ vs YoY Gain
graph twoway ///
    line w1 w4 tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    clcolor(blue purple black green) ///
    clpattern(solid dash dash_dot dot) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
	    xline(4, lcolor(gray) lpattern(dash) lwidth(medthick)) ///
    legend(position(6) region(lcolor(white)) rows(1) size(medsmall)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_growth.png", replace width(4000)

// QoQ vs YoY Gain
graph twoway ///
    line w1 tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    clcolor(blue purple black green) ///
    clpattern(solid dash dash_dot dot) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
	xline(4, lcolor(gray) lpattern(dash) lwidth(medthick)) ///
	text(0.95 32 "32Q", place(c) size(medium) color(gs8)) ///
	text(0.95 4 "4Q", place(c) size(medium) color(gs8)) ///
	text(0.95 6 "6Q", place(c) size(medium) color(gs8)) ///
    legend(position(6) region(lcolor(white)) rows(1) size(medsmall)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_growth1.png", replace width(4000)

// QoQ vs YoY Gain
graph twoway ///
    line w4 tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    clcolor(purple) ///
    clpattern(solid) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
	    xline(4, lcolor(gray) lpattern(dash) lwidth(medthick)) ///
			text(0.95 32 "32Q", place(c) size(medium) color(gs8)) ///
	text(0.95 4 "4Q", place(c) size(medium) color(gs8)) ///
	text(0.95 6 "6Q", place(c) size(medium) color(gs8)) ///
    legend(position(6) region(lcolor(white)) rows(1) size(medsmall)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_growth4.png", replace width(4000)

// YoY vs Yo2Y Gain
graph twoway ///
    line w8 tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    clcolor(green) ///
    clpattern(solid) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
	    xline(4, lcolor(gray) lpattern(dash) lwidth(medthick)) ///
			text(0.95 32 "32Q", place(c) size(medium) color(gs8)) ///
	text(0.95 4 "4Q", place(c) size(medium) color(gs8)) ///
	text(0.95 6 "6Q", place(c) size(medium) color(gs8)) ///
    legend(position(6) region(lcolor(white)) rows(1) size(medsmall)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_growth8.png", replace width(4000)

// *********

clear all
use DataQ

* 1. Define the grid (Frequency domain 0 to pi)
range omega 0 3.14159265 500
gen tomg = 2*_pi/omega

* 2. Calculate Comparison Filters (Growth Rates)
gen w8 = 2-2*cos(8*omega)
label variable w8 "Year-over-two-year growth"

* ---------------------------------------------------------
* 3. THEORETICAL Hamilton Gain (Assuming Random Walk)
* Weights are fixed at 0.25 for lags 8, 9, 10, 11
* ---------------------------------------------------------
gen p = 4
gen h = 8
gen sum_cos_rw = cos(8*omega) + cos(9*omega) + cos(10*omega) + cos(11*omega)
gen sum_sin_rw = sin(8*omega) + sin(9*omega) + sin(10*omega) + sin(11*omega)

* Gain = |1 - 0.25*Sum(e^-iw)|^2
gen ham_gain_rw = (1 - (1/p)*sum_cos_rw)^2 + ((1/p)*sum_sin_rw)^2
label variable ham_gain_rw "Hamilton (Theoretical RW)"

* ---------------------------------------------------------
* 4. EMPIRICAL Hamilton Gain (Using Your Regression Estimates)
* Coefficients taken from your regression output
* ---------------------------------------------------------
scalar b8  = .7474869
scalar b9  = .0126226
scalar b10 = .077362
scalar b11 = .1179767

* The Filter is: 1 - (b8*L8 + b9*L9 + b10*L10 + b11*L11)
* Real Part (Sum of Cosines weighted by betas)
gen sum_cos_est = b8*cos(8*omega) + b9*cos(9*omega) + b10*cos(10*omega) + b11*cos(11*omega)

* Imaginary Part (Sum of Sines weighted by betas)
gen sum_sin_est = b8*sin(8*omega) + b9*sin(9*omega) + b10*sin(10*omega) + b11*sin(11*omega)

* Squared Gain = (1 - Real)^2 + (Imaginary)^2
gen ham_gain_est = (1 - sum_cos_est)^2 + (sum_sin_est)^2
label variable ham_gain_est "Hamilton (Estimated)"

* ---------------------------------------------------------
* 5. Graphing the Comparison
* ---------------------------------------------------------

graph twoway ///
    line ham_gain_rw tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    xline(4, lcolor(gray) lpattern(dotted) lwidth(medthick)) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
    clcolor(black blue green) ///
    clpattern(dash solid solid) ///
    legend(position(6) rows(1) size(medsmall)) ///
    xtitle("Period (Quarters)", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_ham_rw.png", replace width(4000)

graph twoway ///
    line ham_gain_rw ham_gain_est tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    xline(4, lcolor(gray) lpattern(dotted) lwidth(medthick)) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
    clcolor(black blue green) ///
    clpattern(dash solid solid) ///
    legend(position(6) rows(1) size(medsmall)) ///
    xtitle("Period (Quarters)", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_ham_est.png", replace width(4000)

graph twoway ///
    line w8 ham_gain_est tomg if tomg<=40, ///
    lwidth(medthick) ///
    title(" ") ///
    yline(1, lcolor(gs12) lpattern(shortdash)) ///
    xline(4, lcolor(gray) lpattern(dotted) lwidth(medthick)) ///
    xline(6 32, lcolor(red) lpattern(solid) lwidth(medthick)) ///
    clcolor(black blue green) ///
    clpattern(dash solid solid) ///
    legend(position(6) rows(1) size(medsmall)) ///
    xtitle("Period (Quarters)", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    graphregion(color(white))
graph export "Figures\filt_ham_est_w8.png", replace width(4000)

// ***************************
// Monthly Employment Data
clear all
import delimited CDataM.csv, clear 
generate month=tm(1961m1)+_n-1 
format %tm month
tsset month

gen lemp=ln(emp)
gen d24emp =100*(emp/l24.emp-1)

// Hamilton's regression method
reg lemp L(24/35).lemp
// Fit=Trend
predict y_hat
// Fit=Cycle
predict y_ha, resid
// Percent deviation from Trend
replace y_ha = 100*y_ha

//Time trend
gen t=_n
gen t2= t^2
gen t3= t^3

// Detrended Y-o-2Y
reg d24emp t if month>=tm(2000m1)
capture drop gy8_de
predict d24emp_res, res
label variable d24emp_res "Growth rate Y-o-2Y"

label variable d24emp "Growth Rate Y-o-2Y"
label variable y_ha "Hamilton Filter"
label variable emp "Employment"
label variable emp_sa "Employment Seasonally Adjusted"

// Employment Level (SA vs Non-SA)
tsline emp emp_sa if month>=tm(2000m1), ///
    lwidth(medthick) ///
    ytitle("Level (x1000)", size(medlarge)) ///
    xtitle("Months", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    legend(bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\emp.png", replace width(4000)

// Hamilton vs Growth Rate Residuals (Monthly)
tsline y_ha d24emp_res if month>=tm(2000m1), ///
    lwidth(medthick) ///
    ytitle("Percent", size(medlarge)) ///
    xtitle("Month", size(medlarge)) ///
    xlabel(, labsize(medlarge)) ///
    ylabel(, labsize(medlarge)) ///
    legend(bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2) size(medsmall)) ///
    graphregion(color(white))
graph export "Figures\emp_cyc2.png", replace width(4000)

local seas = 1/12
local lbm1 = 1/18
local ubm1 = 1/96
pergram y_ha, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(solid) lwidth(medthin)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthin)) ///
    xtitle("Frequency (cycles per month)") ///
    title(" ") ///
    ytitle("Spectral density") ///
    note("") ///
    graphregion(color(white)) 
graph export "Figures\per_ham_monthly.png", replace width(4000)

pergram d24emp, ///
    xline(`lbm1' `ubm1', lcolor(red) lpattern(solid) lwidth(medthin)) ///
    xline(`seas', lcolor(gray) lpattern(dash) lwidth(medthin)) ///
    xtitle("Frequency (cycles per month)") ///
    title(" ") ///
    ytitle("Spectral density") ///
    note("") ///
    graphregion(color(white)) 
graph export "Figures\per_g24_monthly.png", replace width(4000)

*/

// ***********************************************
// GOLDILOCKS FREQUENCY VISUALIZATION
// ***********************************************

clear all
set scheme s2color
graph set window fontface "Arial" // Clean font for video

// 1. Generate High-Resolution Sine Wave Data
set obs 1000
range t 0 60 // Time from 0 to 60 quarters
label var t "Quarters"

// Generate the three waves
// Formula: sin(2 * pi * t / Period)
gen y_short = sin(2*_pi*t/4)   // Period = 4Q (Too Short)
gen y_cycle = sin(2*_pi*t/16)  // Period = 16Q (Business Cycle)
gen y_cycle24 = sin(2*_pi*t/24)  // Period = 16Q (Business Cycle)
gen y_cycle32 = sin(2*_pi*t/32)  // Period = 16Q (Business Cycle)
gen y_long  = sin(2*_pi*t/60)  // Period = 60Q (Too Long)

// Set Common Graph Options for Consistency
local graph_opts ///
    graphregion(color(white)) ///
    xlabel(0(10)60, labsize(medlarge)) ///
    ylabel(-1(0.5)1, labsize(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("GDP Component (Normalized)", size(medlarge)) ///
    xline(6 32, lcolor(gs10) lpattern(dash) lwidth(medthick)) ///
    text(1.05 6 "6Q", place(c) size(medium) color(gs8)) ///
    text(1.05 32 "32Q", place(c) size(medium) color(gs8)) ///
    legend(size(medsmall) region(lcolor(white)) position(6) rows(1))

// ***********************************************
// 2. CREATE THE THREE VERSIONS (BUILD-UP)
// ***********************************************
//*
// VERSION 1: TOO SHORT (High Frequency / Noise)
// "Too Hot" - Using Red/Cranberry
twoway (line y_short t, lcolor(cranberry) lwidth(medthick)), ///
    title("4 Quarters", color(cranberry) size(large)) ///
    legend(label(1 "Noise / Seasonality (4Q)")) ///
    `graph_opts'
graph export "Figures/freq_1_short.png", replace width(4000)

// VERSION 2: TOO LONG (Low Frequency / Trend)
// "Too Cold" - Using Green/Forest
twoway (line y_long t, lcolor(blue) lwidth(medthick)), ///
    title("60 Quarters", color(blue) size(large)) ///
    legend(label(1 "Trend / Demographics (60Q)")) ///
    `graph_opts'
graph export "Figures/freq_2_long.png", replace width(4000)

// VERSION 3: JUST RIGHT (The Business Cycle)
// "Goldilocks" - Using Orange or Standard Blue
twoway (line y_cycle t, lcolor(forest_green) lwidth(medthick)), ///
    title("16 Quarters", color(forest_green) size(large)) ///
    legend(label(1 "Business Cycle (16Q)")) ///
    `graph_opts'
graph export "Figures/freq_3_goldilocks.png", replace width(4000)
*/
// ***********************************************
// 3. THE IDEAL FILTER (Frequency / Period Domain)
// ***********************************************

// Define the Business Cycle Bounds (in Quarters)
local p_min = 6
local p_max = 32

// Generate the Ideal Bandpass Filter (Gain)
// It perfectly preserves (Gain=1) frequencies between omega_min and omega_max, and destroys (Gain=0) the rest.
gen ideal = (t >= 6 & t <= 32)
label variable ideal "Ideal Filter (6-32 Quarters)"

// Graph the Ideal Filter
twoway line ideal t , /// // if t_f <= 60
    lcolor(navy) lwidth(medthick) ///
    xlabel(0(10)60, labsize(medlarge)) ///
    ylabel(0(0.5)1.2, labsize(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("Squared Gain", size(medlarge)) ///
    xline(`p_min' `p_max', lcolor(red) lpattern(dash) lwidth(medthick)) ///
    text(1.05 `p_min' "6Q", place(c) size(medium) color(gs8)) ///
    text(1.05 `p_max' "32Q", place(c) size(medium) color(gs8)) ///
    legend(position(6) rows(1) size(medsmall) region(lcolor(white))) ///
    graphregion(color(white))
graph export "Figures/ideal.png", replace width(4000)


// ***********************************************
// 3. THE IDEAL FILTER & CYCLE OVERLAYS
// ***********************************************


// Scale the waves to fit between 0 and 1 
// Transformation: (y + 1) / 2
gen y_short_scaled = (y_short + 1) / 2
gen y_cycle_scaled = (y_cycle + 1) / 2
gen y_cycle24_scaled = (y_cycle24 + 1) / 2
gen y_cycle32_scaled = (y_cycle32 + 1) / 2
gen y_long_scaled  = (y_long + 1) / 2

// Define the Business Cycle Bounds (in Quarters)
local p_min = 6
local p_max = 32

// Macro for Common Graph Options to keep code clean
local base_opts ///
    xlabel(0(10)60, labsize(medlarge)) ///
    ylabel(0(0.5)1.2, labsize(medlarge)) ///
    xtitle("Quarters", size(medlarge)) ///
    ytitle("Gain / Scaled Amplitude", size(medlarge)) ///
    xline(`p_min' `p_max', lcolor(red) lpattern(dash) lwidth(medthick)) ///
    text(1.05 `p_min' "6Q", place(c) size(medium) color(gs8)) ///
    text(1.05 `p_max' "32Q", place(c) size(medium) color(gs8)) ///
    legend(position(6) rows(1) size(medsmall) region(lcolor(white))) ///
    graphregion(color(white))

// GRAPH A: The Ideal Filter Alone
twoway (line ideal t, lwidth(medthick)), /// 
    legend(label(1 "Ideal Gain")) ///
    `base_opts'
graph export "Figures/ideal.png", replace width(4000)

// GRAPH B: Ideal Filter + 4Q Cycle (Noise)
// Plots only the first 4 quarters (one cycle)
twoway (line ideal t, lwidth(medthick)) ///
       (line y_short_scaled t if t <= 4, lcolor(cranberry) lwidth(medthick)), ///
    legend(label(1 "Ideal Gain") label(2 "4Q Cycle")) ///
    `base_opts'
graph export "Figures/ideal_freq4.png", replace width(4000)

// GRAPH C: Ideal Filter + 16Q Cycle (Business Cycle)
// Plots only the first 16 quarters (one cycle)
twoway (line ideal t,  lwidth(medthick)) ///
       (line y_cycle_scaled t if t <= 16, lcolor(forest_green) lwidth(medthick)), ///
    legend(label(1 "Ideal Gain") label(2 "16Q Cycle")) ///
    `base_opts'
graph export "Figures/ideal_freq16.png", replace width(4000)

// GRAPH C: Ideal Filter + 16Q Cycle (Business Cycle)
// Plots only the first 16 quarters (one cycle)
twoway (line ideal t,  lwidth(medthick)) ///
       (line y_cycle24_scaled t if t <= 24, lcolor(forest_green) lwidth(medthick)), ///
    legend(label(1 "Ideal Gain") label(2 "24Q Cycle")) ///
    `base_opts'
graph export "Figures/ideal_freq24.png", replace width(4000)

// GRAPH C: Ideal Filter + 16Q Cycle (Business Cycle)
// Plots only the first 16 quarters (one cycle)
twoway (line ideal t,  lwidth(medthick)) ///
       (line y_cycle32_scaled t if t <= 32, lcolor(forest_green) lwidth(medthick)), ///
    legend(label(1 "Ideal Gain") label(2 "32Q Cycle")) ///
    `base_opts'
graph export "Figures/ideal_freq32.png", replace width(4000)

// GRAPH D: Ideal Filter + 60Q Cycle (Trend)
// Plots the full 60 quarters (one cycle)
twoway (line ideal t,  lwidth(medthick)) ///
       (line y_long_scaled t if t <= 60, lcolor(blue) lwidth(medthick)), ///
    legend(label(1 "Ideal Gain") label(2 "60Q Cycle")) ///
    `base_opts'
graph export "Figures/ideal_freq60.png", replace width(4000)

// ***********************************************
// 3. CREATE THE COMBINED REPLICATION
// ***********************************************

twoway (line y_short t, lcolor(cranberry) lwidth(medthick)) ///
       (line y_long t, lcolor(forest_green) lwidth(medthick)) ///
       (line y_cycle t, lcolor(navy) lwidth(medthick)), ///
       title("The Frequency Domain", color(black) size(large)) ///
       legend(order(1 "Too Short (4Q)" 3 "Business Cycle (16Q)" 2 "Too Long (60Q)") ///
              cols(2)) ///
       `graph_opts'
graph export "Figures/freq_combined.png", replace width(4000)

// ***********************************************
// Regression Table
// ***********************************************

clear all
import delimited CDataM.csv, clear 
generate month=tm(1961m1)+_n-1 
format %tm month
tsset month

gen lemp=ln(emp)
eststo AR1: reg F24.lemp L(0/12).lemp

// Load Series
insheet using "CDataQ.csv", clear

// Set Quarterly Dates
display tq(1961q1)
gen time=tq(1961q1)+ _n-1
format time %tq
tsset time

gen lgdp=ln(gdp_nsa)
eststo AR2: reg F8.lgdp L(0/3).lgdp

// Word export (.rtf opens cleanly in Word)
esttab using "TableRegressions.rtf", replace ///
    se ar2 label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table: Hamilton Filter Estimates, Employment") ///
    addnotes("Notes: Robust standard errors in parentheses.")

//***************************
// Close and save log file
log close
timer off 1
timer list 1
