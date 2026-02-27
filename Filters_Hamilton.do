// -----------------------------	
// Time Series - Measurement 
// Topic: Hamilton Filter
// -----------------------------	
// Author: Stephen Snudden, PhD
// Website: https://stephensnudden.com/
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics
// -----------------------------

// **What this file covers**
// Hamilton filter

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


//Time trend
gen t=_n
gen t2= t^2
gen t3= t^3

// Y-o-2Y Growth Rate
gen gy8= 100*(y/L8.y-1)
label variable gy8 "Y-o-2Y Growth Rate"

// Detrended Y-o-2Y
reg gy8 t if time>=tq(2000q1)
capture drop gy8_de
predict gy8_de, res
label variable gy8_de "Linearly Detrended Y-o-2Y Growth Rate"

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

//***************************
// Close and save log file
log close
timer off 1
timer list 1
