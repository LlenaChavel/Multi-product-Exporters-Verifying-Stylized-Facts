args Includes

use "Ranked_Sales-PMC-by_country.dta", replace
append using "Ranked_Sales-PMC-world.dta"

gen source3 = strrtrim(strltrim(source))
gen source2 = subinstr(source3," ","_",.)
gen source4 = subinstr(source2,"-","_",.)
drop source year source3 source2
rename source4 source

local country_names " US Japan Korea Germany United_Kingdom Taiwan Australia Canada Singapore Italy Netherlands Malaysia France"
local j =1

foreach i of numlist 502 /*116	133	    304     303	        143       601	     501	    132	  307	   309	   122	    305*/	 {
	
	local name: word `j' of `country_names'

// best-selling PMC
	twoway (connected lvalue nprod if (source=="PMC_by_country_data" & rank ==1)) (connected lvalue nprod if (source=="PMC_world_sim" & rank ==1)) (connected lvalue nprod if (source=="PMC_by_country_sim" & rank ==1)) if origin_id==`i', caption(`name')  ytitle(Log of Sales) xtitle(Scope) legend(order(1 "Data" 2 "PMC"  3 "PMC (within destination)")) xlabel(1 2 3 4 5 6 "6+", noticks)
	
	graph export "`Includes'\best_selling-`name'-`i'.pdf", as(pdf) name("Graph") replace


// least-selling
	twoway (connected lvalue nprod if (source=="PMC_by_country_data" & rank ==nprod)) (connected lvalue nprod if (source=="PMC_world_sim" & rank ==nprod)) (connected lvalue nprod if (source=="PMC_by_country_sim" & rank ==nprod)) if origin_id==`i', caption(`name')  ytitle(Log of Sales) xtitle(Scope) legend(order(1 "Data" 2 "PMC"  3 "PMC (within destination)")) xlabel(1 2 3 4 5 6 "6+", noticks)
	
	graph export "`Includes'\least_selling-`name'-`i'.pdf", as(pdf) name("Graph") replace

	local j=`j'+1
}
