# NY-Time-Best-Selleres-Database
Compile all books featured on the New York Times Best Sellers list into a MySQL Database

A ruby script calls the NY Times API to get the best sellers list for each week between 01/2011 - and 4/2022. The apple API is used to get the current price listed on apple books. Proxycrawl is used to get the HTML from the Amazon listing, then extracts the price from the HTML. A separate ruby script is used to convert the output into SQL insert statements.
