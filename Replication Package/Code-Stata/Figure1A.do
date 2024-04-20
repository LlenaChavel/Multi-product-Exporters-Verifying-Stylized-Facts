// This file replicates mean sales of the best-selling products as a function of scope (e.g Figure 1A)

// Set up script with directory for saving files and country of analysis for inputs
args Includes country

// Processing Actual Data

// Load the dataset generated in PNC-within-country-data-permutation
use data_by_country.dta, clear
keep  f y d exportrank lvalue nprod // keeping only actual data variables
rename  exportrank rank

// Keep only top-ranked products, treating products beyond rank 6 as a single group.
keep if rank==1 
replace nprod =6 if nprod>6

// Calculate the mean log value of sales by destination, rank, and product count.
collapse (mean) lvalue, by(d rank nprod)
// Tag the dataset source for identification after combining datasets.
gen source = "PMC_by_country_data"
// Save the processed dataset for actual data.
save data_by_country_1A.dta,replace

***

//Processing Simulated Data (By Country)

// Load the dataset generated in PNC-within-country-data-permutation
use PMC_only_by_country.dta,clear

// Apply the same processing as for actual data to the simulated dataset.
keep if rank==1
replace nprod =6 if nprod>6
collapse (mean) lvalue, by(d rank nprod permutation)
collapse (mean) lvalue, by(d rank nprod )
gen source = "PMC_by_country_sim"
// Save the processed simulated dataset
save PMC_only_by_country_1A.dta,replace


//Processing Simulated Data (Global)

// Load the simulated data generated in PMC-world-data-permutation.do
use PMC_only_world.dta,clear

// Repeat the processing steps for the global simulated data.
keep if rank==1
replace nprod =6 if nprod>6
collapse (mean) lvalue, by(d rank nprod permutation)
collapse (mean) lvalue, by(d rank nprod )
gen source = "PMC_world_sim"

// Save the processed global simulated dataset.
save PMC_only_world_1A.dta,replace

// Combine the 3 datasets
use data_by_country_1A.dta,clear
append using PMC_only_by_country_1A.dta
append using PMC_only_world_1A.dta

// Preserve the current dataset for generating graphs for the top export destinations.
preserve
	// Load dataset containing the most popular export destinations.
	use exporters_at_dest.dta,clear
	levelsof d, local(pop_dest)
	// Set specific country names for China or use destiantions names availiable in the file

	if "`country'"=="China"{
							local country_names "Hong_Kong  Japan Singapore Korea Taiwan  United_Kingdom  Germany Canada US Australia"
                            }
							else{
							    local country_names "`pop_dest'"
				    		}
// Restore the main dataset.
restore

local j =1
// Loop through each popular destination to generate mean sales of the best-selling products for exporters of different scope
foreach i of local pop_dest{
							display "`i'"
							local name: word `j' of `country_names'
							
							twoway (connected lvalue nprod if (source=="PMC_by_country_data" & rank ==1) , msymbol(s)) ///
       (connected lvalue nprod if (source=="PMC_world_sim" & rank ==1) , msymbol(d)) ///
       (connected lvalue nprod if (source=="PMC_by_country_sim" & rank ==1) , msymbol(t)) ///
       if d=="`i'", caption("`name'") ytitle(Log of Sales) xtitle(Scope) ///
       legend(order(1 "Data" 2 "PMC" 3 "PMC (within destination)")) xlabel(1 2 3 4 5 6 "6+", noticks)

						
							graph export "`Includes'\best_selling-`name'-`i'.pdf", as(pdf) name("Graph") replace
							
							local j=`j'+1
						  }

						  
erase data_by_country_1A.dta
erase PMC_only_by_country_1A.dta
erase PMC_only_world_1A.dta
