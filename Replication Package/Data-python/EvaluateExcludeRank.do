// This function evaluates the global rank of a product based on its total sales
// excluding the sales at a given destination
// This measure of the global rank is destination specific
args S 
* Arguments:
* - S: Number of simulations.

use rank_corr_data_PMC.dta,clear


//drop products that are exported to one destination 
bysort f hs: gen ndest=_N 


//(data)
// calculate global sales net of sales at a given destination
gen exclude=export_gl-v
// rank products by their sales elsewhere
egen rankExclude = rank(exclude), by(f d y) field

//(simulation)
// calculate global sales net of sales at a given destination
// and rank products by their sales elsewhere
forvalues i=1(1)`S'{
    gen exclude_`i'=export_gl_sim_`i'-vPMC`i'
	egen rankExclude`i' = rank(exclude_`i'), by(f d y) field
}

// (group products by the number of products for improved presentation) 
replace nbctry =6  if nbctry>5 & nbctry<10
replace nprod_gl =6  if nprod_gl>5 & nprod_gl<10

replace nbctry =10  if nbctry>9 & nbctry<20
replace nprod_gl =10  if nprod_gl>9 & nprod_gl<20

replace nbctry =20  if nbctry>19 
replace nprod_gl =20  if nprod_gl>19 
