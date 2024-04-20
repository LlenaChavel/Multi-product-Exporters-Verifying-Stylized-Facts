// This program creates a within destination permutated dataset and calculates lcoal ranks for the simulated data
args  dirData S country

// create permuted data within a country
use "`dirData'\\`country'_1.dta",clear 

keep v y hs d f

//number of products exported to a destination 
egen nprod = count(hs), by(y d f) // number of products per firm-country pair at a destination 
label var nprod "number of products exported by firm/country/year"

//product local rank at a destination
egen exportrank = rank(v), by(f d y) field
label var exportrank "rank of export value by firm/year/destinantion"

// Save the dataset with added rank and product count information for further analysis.
gen lvalue=log(v)
save data_by_country.dta,replace

// Prepare the dataset for permutation by sorting and generating an order variable for each destination.
sort y d hs f v 
bysort d: gen order=_n
save "permute.dta",replace

// Set a seed for the random number generator to ensure reproducibility of the results.
set seed 1234

// save the sales and destinations data to permute sales within d
keep v d 
save "permute0.dta",replace

// Start the permutation loop, creating permuted datasets based on the original data.
forvalues i=1(1)`S'{
    //Generate a random shuffle within each destination to permute sales data.
	use "permute0.dta",replace	
	bysort d: gen shuffle = runiform()
	sort d shuffle
	
	bysort d: gen order=_n
	drop shuffle
	rename v  vPMC`i'
	save "temp_permute.dta",replace

    // Merge the permuted sales data back with the original dataset by destination and order.
	use  "permute.dta",clear 
	merge 1:1 d order using "temp_permute.dta", update replace assert(3 4 5) nogenerate

	save "permute.dta",replace
	
}

erase "permute0.dta" 
erase "temp_permute.dta" 

use  "permute.dta",clear 

//Calculate the local product rank for each firm-country pair in the permuted data.
sort f y hs exportrank
forvalues i=1(1)`S'{
	egen rankPMC`i' = rank(vPMC`i'), by(f d y) field
	}

save tempPMC,replace 

// Arrange the permuted data into long format, adding a 'permutation' identifier.
forvalues i=1(1)`S'{
    use  tempPMC,clear
    keep f y d rankPMC`i' vPMC`i' nprod

	rename rankPMC`i' rank
	rename vPMC`i' v
	
	sort f y d rank
	gen permutation =`i'
	

	save temp`i', replace
	
	}

// Combine all permutations into a single dataset 
forvalues i=2(1)`S'{
   append using temp`i'
}

gen lvalue=log(v)
save PMC_only_by_country.dta, replace
*/

// List files starting with 'temp' and ending with '.dta' and store their names
local files : dir . files "temp*.dta"

// Loop through the list of files and delete each one
foreach file of local files {
    erase "`file'"
}

erase "permute.dta"

