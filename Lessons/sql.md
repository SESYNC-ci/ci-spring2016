Databases using SQL in R
==========================

Introduction
------------
* Relational databases formalize and can enforce concepts of tidy data
* Each variable (or "field") forms a column; each observation is a row; each data type is a table

| tidyr | sql|
|-------|-------|
| filter| WHERE |
| select | SELECT |
| arrange | ORDER BY |
| group_by | GROUP BY (always needs aggregate function in "SELECT")|
| summarize | aggregate functions in the "SELECT" statement |
| mutate | operations on a field in the SELECT statement |
| join | "JOIN" |



How are relational databases different?
----------------------------------------
* The data are distinct from the  questions we ask of them. We interact with the data through queries,
   so if we change the data we can just rerun the query. This also prevents us from accidentally changing the data.
* Queries let us look up data or make calculations based on columns
* The entire data set does not live in memory
 	   
When to consider a relational design
-------------------------------------
### If you want to...
* link data classified or measured at multiple levels (e.g., plots, surveys, and species)
* be able to ask multiple, ad-hoc questions about the data and aggregate and group it in different ways
* enforce relationships between data elements
* allow multiple people to use it

Database Management Systems
---------------------------
There are a number of different database management systems for relational
data. We're going to use SQLite, but most everything 
will apply to the other database systems as well (e.g., MySQL, PostgreSQL, MS
Access, Filemaker Pro). The main differences are in the details of how to import and export data.

<!--- 
The data
--------
This is data on a small mammal community in southern Arizona over the last 35
years.  This is part of a larger project studying the effects of rodents and
ants on the plant community.  The rodents are sampled on a series of 24 plots,
with different experimental manipulations of which rodents are allowed to access
the plots.

This is a real dataset that has been used in over 100 publications.  It's been
simplified just a little bit for the workshop, but you can download the
[full dataset](http://esapubs.org/archive/ecol/E090/118/) and work with it using
exactly the same tools here.
-->

Database Design
---------------
1. Order doesn't matter
2. Every row-column combination contains a single *atomic* value, i.e., not
   containing parts we might want to work with separately.
3. One field per type of information	
4. No redundant information
     * Split into separate tables with one table per class of information
	 * Needs an identifier in common between tables – shared column - to
       reconnect (foreign key).
	   
SQL (and SQL in R)
------------------
SQL (Structured Query Language) is a high-level language for interacting with relational databases. 
Commands use intuitive English words but can be strung together and nested in powerful ways.

To enable us to run these queries in R, we'll "wrap" SQL statements in commands and syntax that R understands.
Keep in mind that the SQL statements themselves could be used as-is from other "gateways" that run SQL.
	   

Connecting R to SQLite
----------------------
One of the things that makes R powerful is that it's open source, so people can contribute new functions in the form of packages.
Packages are collections of functions and related documentation (and sometimes data) that can be installed and loaded.

RSQLite is a package that allows us to interact with a SQLite database in R.

	install.packages("RSQLite")
	library(RSQLite)

Need to "open a connection" to the database so that R can communicate with it.
SQLite requires a "driver" and "dbname." The same dataset from the previous lesson, has been imported into a SQLite database.
This database contains three tables: surveys, species and plots

	drv <- dbDriver("SQLite")
	db <- "/nfs/public-data/ci-spring2016/Data/portal_mammals.sqlite"
	con <- dbConnect(drv, db)

Other types of relational databases may have other arguments like user and pwd.


Basic queries
-------------

Let's start by using the **surveys** table.
Here we have data on every individual that was captured at the site,
including when they were captured, what plot they were captured on,
their species ID, sex and weight in grams.

Let’s write an SQL query that selects only the year column from the surveys
table.

We'll use the R command dbGetQuery to do this. It requires a connection object
and a SQL statement. We created the connection object already, so now, the statement:

    SELECT year FROM surveys;
	
This is a SQL statement. We'll assign it to a character variable

    q1 = "SELECT year FROM surveys;"
	
Now, call dbGetQuery.

	dbGetQuery(con, q1)

The results are returned to the window, but we can easily assign them to a dataframe

	surv_yr <- dbGetQuery(con, q1)
	
Check what's in surv_yr with the head() function

	head(surv_yr)
	
You don't have to assign the SQL statement to a variable. You can call it directly. As with many
things in R, there's more than one way right way, and the most convenient way will depend on
what you're doing.

	surv_yr <- dbGetQuery(con, "SELECT year FROM surveys;")	
	
A note on style: we have capitalized the words SELECT and FROM because they are SQL keywords.
Unlike R, SQL is case insensitive, but it helps for readability – good style. Because the
SQL statement is inside quotation marks, R treats it like any other character string and simply
passes the string to the database via the dbGetQuery function. So, the SQL statement is still case
insensitive.	

If we want more information, we can just add a new column to the list of fields,
right after SELECT:
    
	dbGetQuery(con, "SELECT year, month, day FROM surveys;")
	
We can also nest dbGetQuery within other R commands, anywhere R can accept a dataframe:
	
	head(dbGetQuery(con, "SELECT year, month, day FROM surveys;"))

Or we can select all of the columns in a table using the wildcard *
    
	head(dbGetQuery(con, "SELECT * FROM surveys;"))

### Limit

We've been using head() from R to just look at the first few rows, but
SQL also has a function that will do this, called Limit

	dbGetQuery(con, "SELECT DISTINCT year, species FROM surveys LIMIT 10";)
		
### Unique values

If we want only the unique values so that we can quickly see what species have
been sampled we use ``DISTINCT``

    dbGetQuery(con, "SELECT DISTINCT species FROM surveys;"))

If we select more than one column, then the distinct pairs of values are
returned

    dbGetQuery(con, "SELECT DISTINCT year, species FROM surveys";)
	
	
### Calculated values

We can also do calculations with the values in a query.
For example, if we wanted to look at the mass of each individual
on different dates, but we needed it in kg instead of g we would use

    dbGetQuery(con, "SELECT year, month, day, wgt/1000.0 FROM surveys;")

When we run the query, the expression ``wgt / 1000.0`` is evaluated for each row
and appended to that row, in a new column.  Expressions can use any fields, any
arithmetic operators (+ - * /) and a variety of built-in functions (). For
example, we could round the values to make them easier to read.

    dbGetQuery(con," SELECT plot, species, sex, wgt, ROUND(wgt / 1000.0, 2) FROM surveys;")

The underlying data in the wgt column of the table does not change. The query, which exists separately from the data,
simply displays the calculation we requested in the query result window pane.

***EXERCISE: Write a query that returns
             the year, month, day, species ID, and weight in mg***

Filtering
---------

Databases can also filter data – selecting only the data meeting certain
criteria.  For example, let’s say we only want data for the species Dipodomys
merriami, which has a species code of DM.  We need to add a WHERE clause to our
query:

    dbGetQuery(con, "SELECT * FROM surveys WHERE species='DM';")

We can do the same thing with numbers.
Here, we only want the data since 2000:

    "SELECT * FROM surveys WHERE year >= 2000;"
	
We can use more sophisticated conditions by combining tests with AND and OR.
For example, suppose we want the data on Dipodomys merriami starting in the year
2000:

    dbGetQuery(con, "SELECT * FROM surveys WHERE (year >= 2000) AND (species = 'DM');")

Note that the parentheses aren’t needed, but again, they help with readability.
They also ensure that the computer combines AND and OR in the way that we
intend.

If we wanted to get data for any of the Dipodomys species,
which have species codes DM, DO, and DS we could combine the tests using OR:

    SELECT * FROM surveys WHERE (species = "DM") OR (species = "DO") OR (species = "DS");

***EXERCISE: Write a query that returns
   The day, month, year, species ID, and weight (in kg) for
   individuals caught on Plot 1 that weigh more than 75 g***

<!--- Applicable in Firefox SQLite interface 
Saving & Exporting queries
--------------------------
* Exporting:  **Actions** button and choosing **Save Result to File**.  
[Results set saved as static, external text file.]
* Save: **View** drop down and **Create View**.  
[Result set of query saved dynamically as part of the database.  If underlying table that is queried changes, the view will change too.]
-->

<!---
Building more complex queries
-----------------------------

Now, lets combine the above queries to get data for the 3 Dipodomys species from
the year 2000 on.  This time, let’s use IN as one way to make the query easier
to understand.  It is equivalent to saying ``WHERE (species = "DM") OR (species
= "DO") OR (species = "DS")``, but reads more neatly:

    SELECT * FROM surveys WHERE (year >= 2000) AND (species IN ("DM", "DO", "DS"));

    SELECT *
    FROM surveys
    WHERE (year >= 2000) AND (species IN ("DM", "DO", "DS"));

We started with something simple, then added more clauses one by one, testing
their effects as we went along.  For complex queries, this is a good strategy,
to make sure you are getting what you want.  Sometimes it might help to take a
subset of the data that you can easily see in a temporary database to practice
your queries on before working on a larger or more complicated database.
-->

Sorting
-------

We can also sort the results of our queries by using ORDER BY.
For simplicity, let’s go back to the species table and alphabetize it by taxa.

    dbGetQuery(con, "SELECT * FROM species ORDER BY taxa ASC;")

The keyword ASC tells us to order it in Ascending order.
We could alternately use DESC to get descending order.

    SELECT * FROM species ORDER BY taxa DESC;

ASC is the default.

We can also sort on several fields at once.
To truly be alphabetical, we might want to order by genus then species.

    SELECT * FROM species ORDER BY genus ASC, species ASC;

***Exercise: Write a query that returns
             year, species, and weight in kg from the surveys table, sorted with
             the largest weights at the top***

<!--
Order of execution
------------------

Another note for ordering. We don’t actually have to display a column to sort by
it.  For example, let’s say we want to order by the species ID, but we only want
to see genus and species.

    SELECT genus, species FROM species ORDER BY taxon ASC;

We can do this because sorting occurs earlier in the computational pipeline than
field selection.

The computer is basically doing this:

1. Filtering rows according to WHERE
2. Sorting results according to ORDER BY
3. Displaying requested columns or expressions.
-->

Order of clauses
----------------
The order of the clauses when we write a query is dictated by SQL: SELECT, FROM, WHERE, ORDER BY
and we often write each of them on their own line for readability.


***Exercise: Let's try to combine what we've learned so far in a single query.
Using the surveys table write a query to display the three date
fields, species ID, and weight in kilograms (rounded to two decimal places), for
rodents captured in 1999, ordered alphabetically by the species ID. Save it to a dataframe***


Aggregation
-----------

Aggregation allows us to group records based on field values and
calculate combined values in groups (or for a table as a whole).

Let’s go to the surveys table and find out how many individuals there are.
Using the wildcard simply counts the number of records (rows)

    dbGetQuery(con, "SELECT COUNT(*) FROM surveys;")

We can also find out how much all of those individuals weigh.

    dbGetQuery(con, "SELECT COUNT(*), SUM(wgt) FROM surveys;")

***Do you think you could output this value in kilograms, rounded to 3 decimal
   places?***

    SELECT ROUND(SUM(wgt)/1000.0, 3) FROM surveys

There are many other aggregate functions included in SQL including
MAX, MIN, and AVG.

***From the surveys table, can we use one query to output the total weight,
   average weight, and the min and max weights? How about the range of weight?***

Now, let's see how many individuals were counted in each species. We do this
using a GROUP BY clause

    dbGetQuery(con, "SELECT species, COUNT(*)
				     FROM surveys
				     GROUP BY species;")

GROUP BY tells SQL what field or fields we want to use to aggregate the data.
If we want to group by multiple fields, we give GROUP BY a comma separated list.

***EXERCISE: Write queries that return:***
***1. How many individuals were counted in each year***
***2. Average weight of each species in each year**

<!---
We can order the results of our aggregation by a specific column, including the
aggregated column.  Let’s count the number of individuals of each species
captured, ordered by the count

    SELECT species, COUNT(*)
    FROM surveys
    GROUP BY species
    ORDER BY COUNT(species)
-->

Joins
-----

To combine data from two tables we use the SQL JOIN command, which comes after
the FROM command.

We also need to tell the computer which columns provide the link between the two
tables using the word ON.  We want to join data with the same
species codes.

    dbGetQuery(con, "SELECT *
                     FROM surveys
                     JOIN species ON surveys.species = species.species_id;")

ON is like WHERE, it filters things out according to a test condition.  We use
the table.colname format to tell the manager what column in which table we are
referring to.

We often won't want all of the fields from both tables, so anywhere we would
have used a field name in a non-join query, we can use *table.colname*

For example, what if we wanted information on when individuals of each
species were captured, but instead of their species ID we wanted their
actual species names.

    SELECT surveys.year, surveys.month, surveys.day, species.genus, species.species
    FROM surveys
    JOIN species ON surveys.species = species.species_id

***Exercise: Write a query that returns the genus, the species, and the weight
   of every individual captured at the site***

Joins can be combined with sorting, filtering, and aggregation.  So, if we
wanted average mass of the individuals on each type of plot, we could use

    SELECT plots.plot_type, AVG(surveys.wgt)
    FROM surveys
    JOIN plots
    ON surveys.plot = plots.plot_id
    GROUP BY plots.plot_type
	
Use ```dbDisconnect()``` to close the connection between R and SQL. Only a limited number can be open at a given time..	
	

<!--- Applies in Firefox SQLite
Adding data to existing tables
------------------------------

* Browse & Search -> Add
* Enter data into a csv file and append
-->

<!---
Other database management systems
---------------------------------

* Access or Filemaker Pro
    * GUI
    * Forms w/QAQC
	* But not cross-platform
* MySQL/PostgreSQL
    * Multiple simultaneous users
	* More difficult to setup and maintain
-->

Q & A on Database Design (review if time)
-----------------------------------------

1. Order doesn't matter
2. Every row-column combination contains a single *atomic* value, i.e., not
   containing parts we might want to work with separately.
3. One field per type of information
4. No redundant information
     * Split into separate tables with one table per class of information
	 * Needs an identifier in common between tables – shared column - to
       reconnect (foreign key).
	   
Additional Resources and Information
------------------------------------
* A few types of queries in SQL, in addition to SELECT, will cover most of what you might want to do.
  UPDATE change column values; CREATE generates  a new, blank table; DELETE removes rows from a table. 	   
  All of these can employ the concepts of calculation, filtering, aggregation, and joining in their execution.
 
* Database design tips: https://www.periscope.io/blog/better-sql-schema.html
 
	   
Adapted by Mary Shelley for SESYNC CSI 2015 from Data Carpentry SQL lesson, authored by Ethan White
https://github.com/datacarpentry/archive-datacarpentry/blob/master/lessons/sql/sql.md
