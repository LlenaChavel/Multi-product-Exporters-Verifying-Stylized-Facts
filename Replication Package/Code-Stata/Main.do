/*
The Main.do  is the master file that constructs Figures 1-2, Tables 1-3 in the main text, and Figures 1-9, Tables 1-8 in the Appendix.

Before executing the file:
Adjust the global variables to reflect paths on your PC
•	drive: Root location of the entire project (data, .do files, and .tex files).
•	dirData: Location of the country datasets (China.dta, MEX.dta, and China_country_names.dta).
•	stataCodes: Directory where the Main file and all its dependencies are located.

•	For main paper results (Tables 1-3, Figures 1-2) and Appendix Figures 1-6, Tables 1-3: Set local Includes to "${drive}\path\Includes-China" and set local country to "China" and execute the Main.do file. The outputs will be saved in "${drive}\path\Includes-China".
•	For Appendix 4 results: Set local Includes to "${drive}\path\Includes-MEX" and set local country to "MEX" and execute the Main.do file. The outputs will be saved in "${drive}\path\Includes-MEX".

*/

clear all
set more off

// adjust drive and country variables 
// change drive to location of the 
global drive  "C:\Users\Lena Sheveleva\OneDrive - Cardiff University\MPF_Facts_And_Fiction\Submit folder\Replication Package"
local country "China" // can take value "MEX" or China (aas well as ALB (years 2004-2014))
local year =  2003

// sets up directories inside the drive folder 
capture mkdir "$drive\wd"
cd "$drive\wd"

local dirData "$drive\Data-Stata"
capture mkdir "`dirData'"

local stataCodes "$drive\Code-Stata"
capture mkdir "`stataCodes'"

local Includes "$drive\Includes-`country'-`year'"
capture mkdir "`Includes'"

//
use  "`dirData'\\`country'.dta",clear 
keep if y==`year'
if "`country'" == "China"{
	merge m:1 d using "`dirData'\\China_country_names.dta"
	keep if _merge==3|_merge==1
	drop _merge
}
save  "`dirData'\\`country'_1.dta",replace 

local S= 50 // number of times a permuation is simulated

// Main paper & Appendix 

// Generate data from the statistical model by permuting sales across firms/products/destinations 
do "`stataCodes'\PMC-world-data-permutation.do"  "`S'"  "`dirData'"  "`country'"

// Tables 3-5 Appendix
do "`stataCodes'\Table 3-5 - Appendix.do" "`stataCodes'" "`Includes'" "`S'"   "`country'"

// prepare the permuted data created in the previous file for plotting Figures 1 and 2 
do "`stataCodes'\PMC-world-for-plots.do"  "`S'"

// generate data from the stat model by permuting sales across firms/products within each destinations 
do "`stataCodes'\PMC-within-country-data-permutation.do"  "`dirData'"  "`S'"  "`country'"

// identify the most poppular destinations
do "`stataCodes'\Most_Poppular_Destinations.do"  `year' "`dirData'" "`country'"

//Figure 1-A (Figure 2-10 A in the Appendix)
do "`stataCodes'\Figure1A.do"  "`Includes'" "`country'"

//Figure 1-B (Figure 2-10 B in the Appendix)
do "`stataCodes'\Figure1B.do"  "`Includes'"  "`country'"

//Figure 2
do "`stataCodes'\Figure2.do"  "`Includes'"  "`country'"

//Table 1
do "`stataCodes'\Table1.do" "`Includes'" "`S'" "`country'"

// Tables 2 & 3 
do "`stataCodes'\Tables-2-and-3.do"   "`dirData'" "`Includes'" "`S'" "`country'" // 

// Table 1  and Figure 1 Appendix
if "`country'"=="China"{
	do "`stataCodes'\Figure-1-Appendix.do"  "`dirData'" "`Includes'" "`country'"
	do "`stataCodes'\Table1-Appendix.do"  "`dirData'" "`Includes'" 
	}

*Appendix Table 2 
do "`stataCodes'\Table2-Appendix.do" "`dirData'" "`Includes'" "`S'" "`country'" // 

*Appendix Table 6
do "`stataCodes'\Tables-6-ADjR2.do"   "`dirData'" "`Includes'" "`S'" "`country'" // 

*Appendix Table 7
do "`stataCodes'\Table7-Appendix.do"  "`dirData'" "`Includes'" "`S'"   "`stataCodes'" "`country'"// 

