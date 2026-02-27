// -----------------------------	
// Time Series - Measurement 
// Topic: Growth Rate Filters
// -----------------------------	
// Author: Stephen Snudden, PhD
// Website: https://stephensnudden.com/
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics
// -----------------------------

// **What this file covers**
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

gen tomg = 2*_pi/omega

// ********************************************
// Filter Gain Comparisons
// ********************************************

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

// QoQ Gain
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

// YoY Gain
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

//Yo2Y Gain
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

//***************************
// Close and save log file
log close
timer off 1
timer list 1
