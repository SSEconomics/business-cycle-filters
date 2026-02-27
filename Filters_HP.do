// -----------------------------	
// Time Series - Measurement 
// Topic: HP Filter
// -----------------------------	
// Author: Stephen Snudden, PhD
// Website: https://stephensnudden.com/
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics
// -----------------------------

// **What this file covers**
// HP filter

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

// Hodrick-Prescott high-pass filter
tsfilter hp y_hp = ly, smooth(1600) trend(y_hpt)

label variable y_hpt "Hodrick-Prescott Trend"

replace y_hp = 100*y_hp

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

//***************************
// Close and save log file
log close
timer off 1
timer list 1
