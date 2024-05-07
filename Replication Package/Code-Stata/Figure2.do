//Reproduces Figure 2 from the main paper, comparing average sales per product in the data and the simulated data
args  Includes country

// Use the data with data simulated in a PMC simulation within each destination 
use PMC_only_by_country.dta, clear 
// Treat firms with more than 6 products as 6 product f
replace nprod =6 if nprod>6
// Calculate average log-sales by destination, number of products per firm and permuation
collapse (mean) lvalue, by(d  nprod permutation y)
collapse (mean) lvalue, by(d  nprod y )
* Tagging the dataset as simulation data from the PMC within destination
gen source = "PMC_by_country_sim"
// Save average sales per product as a function of scope from the PMC_by_country_data
save AvSales_PMC_by_country.dta, replace


// Use the actual data
use   data_by_country,clear
keep lvalue y hs d f nprod exportrank
// Treat firms with more than 6 products as 6 product firms
replace nprod =6 if nprod>6
// Calculate average log-sales by destination, number of products per firm 
collapse (mean)  lvalue, by(d  nprod)
* Tagging the dataset as actual data
gen source = "PMC_by_country_data"
// Save average sales per product as a function of scope as in the data
save AvSales_Data_by_country.dta, replace


// Apply the same processing to the simulated data from the PMC across destinations
use PMC_only_world.dta,clear
replace nprod =6 if nprod>6
collapse (mean) lvalue, by(d  nprod permutation y)
collapse (mean) lvalue, by(d  nprod y )
gen source = "PMC_world_sim"
save AvSales_PMC_world.dta, replace

//Integrating all datasets for a comprehensive analysis
append using AvSales_PMC_by_country.dta
append using AvSales_Data_by_country.dta

//Renaming the variable for clarity in graphs
rename lvalue av_log_sales

preserve
// Generate the list of countries for which the results are simulated (10 most poppular destinations)
	use exporters_at_dest.dta,clear
	levelsof d, local(pop_dest)

//Customizing destination names for China to include specific countries of interest
if "`country'"=="China"{
							local country_names "Hong_Kong  Japan Singapore Korea Taiwan  United_Kingdom  Germany Canada US Australia"
                            }
							else{
							    local country_names "`pop_dest'"
				    		}
//Recover the main dataset
restore


//Iteratively generate graphs for each destination with distinct symbols for different data sources.
local j =1
foreach i of local pop_dest {
							display "`i'"
							local name: word `j' of `country_names'

							// Plot average log sales against product count (Scope) for different sources.
		
							twoway (connected av_log_sales nprod if source=="PMC_by_country_data", msymbol(s))  (connected av_log_sales nprod if source=="PMC_world_sim", msymbol(d)) (connected av_log_sales nprod if source=="PMC_by_country_sim" , msymbol(t)) if d=="`i'",  caption( "`name'") ytitle(Log of Sales) xtitle(Scope) legend(order(1 "data" 2 "PMC (world)"  3 "PMC (by country)")) xlabel(1 2 3 4 5 6 "6+", noticks)
	
	if `i'==502{ // comment out the if statement if you want to save results for every country
		// Export the graph for each destination and  incorporate the destination name in the file name.
		graph export "`Includes'\av_sales-`name'-`i'.pdf", as(pdf) name("Graph") replace 
	}

							local j=`j'+1
						  }

erase "AvSales_Data_by_country.dta"
erase "AvSales_PMC_by_country.dta"
erase "AvSales_PMC_world.dta"
erase "PMC_only_by_country.dta"
erase "data_by_country.dta"
