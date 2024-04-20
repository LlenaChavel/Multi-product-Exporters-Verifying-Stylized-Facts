//This program reproduces Figure 1 in the Appendix.
* Arguments:
* - dirData: Directory for data files.
* - Includes: Directory for saving output files.
* - country: Specific country for the analysis.
args   dirData Includes country

//Load the dataset for the specified country, clearing any existing data
use "`dirData'\\`country'_1.dta",clear 

gen lvalue=log(v)
keep lvalue y hs d f

//Filter the dataset to include only records for selected destinations.
keep if (d=="110" | d=="502" | d=="116" |	d=="133"	|  d==  "304"|  d=="303"| d=="143"  |  d=="601"	|d== "501" |	d== "132" | d=="307" | d== "309" | d=="122" | d== "305")

twoway kdensity lvalue if d=="110", color(*.5) || ///
kdensity lvalue if d=="502", color(*.5) ||  ///
kdensity lvalue if d=="116", color(*.5) || ///
kdensity lvalue if d=="133", color(*.5) || ///
kdensity lvalue if d=="304", color(*.5) || ///
kdensity lvalue if d=="303", color(*.5) || ///
kdensity lvalue if d=="143", color(*.5) || ///
kdensity lvalue if d=="601", color(*.5) || ///
kdensity lvalue if d=="501", color(*.5) || ///
kdensity lvalue if d=="132", color(*.5) || ///
kdensity lvalue, color(*.5) , ///
xtitle("ln Sales", size(small)) ///
ytitle("Kernel Density", size(small)) ///
ylabel(, labsize(tiny)) ///
xlabel(, labsize(small)) ///
legend(order(1 "Hong Kong" 2 "US" 3 "Japan" 4 "Korea" 5 "Germany" 6 "UK" 7 "Taiwan" 8 "Australia" 9 "Canada" 10 " Singapore" 11 "World"))  ///
note("The plot shows the density of firm-product-destination sales in 2003 for individual countries and" "world as a whole.")

//Generate kernel density plots for log-transformed export values across the filtered destinations.
//Kernel density estimation provides a smooth estimate of the distribution of log sales, facilitating comparisons across destinations.

graph export "`Includes'\Figure1_Appendix.pdf", as(pdf) name("Graph") replace

