/*
This file generates the input files for the python code files Appendix Figure 12-16

As input it takes country files datasets China.dta and MEX.dta each include six main variables: 
•	f (firm identifier): String
•	d (destination): String
•	hs (product code according to the 6-digit Harmonized System): String
•	y (year): Scalar
•	v (sales value for firm-product-destination): Scalar

Before executing the file:
Adjust the global variables to reflect paths on your PC
•	drive: Root location of the entire project (data, .do files, and .tex files).
•	dirData: Location of the country datasets (China.dta, MEX.dta, and China_country_names.dta).
•	stataCodes: Directory where the Main file and all its dependencies are located.

*/

clear all
set more off

// Assign directories and local variables 

global drive  "C:\Users\Lena Sheveleva\OneDrive - Cardiff University\MPF_Facts_And_Fiction\Submit folder\repo Multi-product-Exporters-Verifying-Stylized-Facts\Replication Package"
local dirData "$drive\Data-Stata"

capture mkdir "$drive\wd"
cd "$drive\wd"

local Includes "$drive\Data-python"
capture mkdir "`Includes'"

local country "China"
local year =  2003

//
use  "`dirData'\\`country'.dta",clear 
keep if y==`year'

merge m:1 d using "`dirData'\\China_country_names.dta"
keep if _merge==3|_merge==1
drop _merge

save  "`dirData'\\`country'_1.dta",replace 


********************************************************************************
// HS_shares and HS_codes
use  "`dirData'\\`country'_1.dta",clear 
collapse (sum) v ,by(hs)

export delimited v using "`Includes'\HS_shares.csv", novarnames replace

export delimited hs using "`Includes'\HS_codes.csv", novarnames replace

********************************************************************************

use  "`dirData'\\`country'_1.dta",clear 

collapse (sum) v ,by(f)

export delimited v using "`Includes'\Balls_US.csv", novarnames replace

********************************************************************************

use  "`dirData'\\`country'_1.dta",clear 
keep if d=="502" |d=="USA"

collapse (sum) v ,by(f hs)
gen n_prod=1
collapse (sum) n_prod ,by(f )
export delimited n_prod using "`Includes'\nprod_data.csv", novarnames replace

********************************************************************************

use  "`dirData'\\`country'_1.dta",clear

keep if d=="502" |d=="USA"

bysort f: egen nprod=count(hs)
egen R = rank(v), by(f) field


keep if nprod<10|R==nprod|R==1
replace R=10 if R>10
replace nprod =10 if nprod>10

gen l_sales = log(v)
collapse (mean) l_sales  ,by(R nprod )

export delimited nprod R l_sales using "`Includes'\RankProductData10.csv",   replace

