// Program Overview
// This program identifies the 10 most popular export destinations for a given country and year.
// Inputs: Year, Directory Path (dirData), Country

args  year dirData  country

* Identify the most poppular export destinations
use "`dirData'\\`country'_1.dta",clear 

// Check if the 'country_eng' variable exists to use English country names.
// If it doesn't exist, create it from the 'd' variable 
capture confirm  variable country_eng
if _rc>0 {
		   gen country_eng=d
				display "no variable"
		   }
	  else{
			display "Variable country_eng exists"
		   }

keep v y hs d f country_eng
// keep unique observations for each firms
bysort f d: gen exporters_at_dest =_n==1
drop if exporters_at_dest>1

// Aggregate data by destination, summing up the number of unique exporters per destination.
collapse (sum) exporters_at_dest,by(d country_eng)

// Rank destinations based on the number of exporters.
egen rank_dest = rank(-exporters_at_dest), unique

// Filter to keep only the top 10 destinations by the number of exporters.
keep if rank_dest<11

save exporters_at_dest,replace

