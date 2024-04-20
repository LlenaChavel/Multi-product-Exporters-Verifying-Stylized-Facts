// This script simulates data from a statistical model using the permuted Monte-Carlo approach.
// It calculates within-firm local and global product rankings and exports the data for further analysis.
// Expected inputs: Directory path and country code.
// Outputs: Simulated dataset with calculated rankings and export values.

args S dirData country
// 'S' is the number of simulations,
// 'dirData' is the directory containing input data,
// 'country' specifies the country dataset to be used.


// create permuted data 
********************************************************************************
// Use the specified country dataset and establish a fixed initial order based on year, product code, destination, firm, and sales value.

use  "`dirData'\\`country'_1.dta",clear 
sort y hs d f v 

// save the original dataset before starting permuation
save "permute.dta",replace

set seed 1234
keep v
// save the sales variable that is permuated in each iteration 
save "permute0.dta",replace

// The loop below permutes the sales (v) variable 'S' times to generate 'S' sets of permuted sales data (vPMC1, vPMC2, ..., vPMCS).
// Each permutation involves generating a random shuffle, sorting by this shuffle, and then merging the permuted sales back with the original data.

forvalues i=1(1)`S'{

	//    randomly permute sales
	use "permute0.dta",replace
	gen shuffle = runiform()
	sort shuffle
	drop shuffle
	rename v  vPMC`i'
	save "temp_permute.dta",replace

	//    merge the permuted data to the original
	use "permute.dta", clear
	merge 1:1 _n using  "temp_permute.dta",  assert(3) nogenerate
	save "permute.dta",replace
	
}

erase "permute0.dta" 
erase "temp_permute.dta" 

// number of products per firm-country pair at a destination 
use "permute.dta", clear
egen nprod = count(hs), by( d f) 
label var nprod "number of products exported by firm/country/year"

// Local ranks are assigned within each firm-country pair at a destination based on actual and permuted sales data.

//assign local product rank to each product within a firm in the actual data
egen exportrank = rank(v), by(f d ) field
label var exportrank "rank of export value by firm/year/destinantion"

// aassign local product rank to each product within a firm in the permuted data
sort f d exportrank

forvalues i=1(1)`S'{
	egen rankPMC`i' = rank(vPMC`i'), by(f d ) field
	}
save temp,replace


// assign global ranks
// Global ranks are calculated by collapsing the data to sum sales by firm and product, then ranking these sums within firms.
********************************************************************************
collapse (sum) v vPMC*, by(f hs)

// total number of products a firm exports
egen nprod_gl = count(hs), by(f )

//data
egen exportrank_gl = rank(v), by(f) field
label var exportrank_gl "rank of export value by firm/year"

//sim
forvalues i=1(1)`S'{
	egen rank_sim_gl_`i' = rank(vPMC`i'), by(f ) field
	label var rank_sim_gl_`i' "sim rank of export value by firm/year"
}

rename  v export_gl
forvalues i=1(1)`S'{
	rename  vPMC`i' export_gl_sim_`i'
}
label var export_gl "export value by firm/year/nc8 (summed over all countries)"

sort f  hs

save temp1, replace

*******************************************************************************
//add global ranks to the rest of the data
use temp,clear
sort f  hs
merge f  hs using temp1
tab _merge 
drop _merge

//simple Spearman rank correlatiion between global and local ranks
corr exportrank exportrank_gl

//calculate the number of destinations per firm
sort f d hs
by f d : gen dum = _n==1
egen nbctry = sum(dum), by(f)
label variable nbctry "number of countries per firm"
drop dum

save rank_corr_data_PMC, replace

erase "permute.dta"
erase "temp.dta"
erase "temp1.dta"