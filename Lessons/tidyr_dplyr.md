Data manipulation with tidyr and dplyr
======================================

Data frames generally occupy a central place in R analysis workflows. While the base R functions provide most necessary tools to subset, reformat and transform data frames, the specialized packages we will use in this lesson -- **tidyr** and **dplyr** -- offer a more succinct and often computationally faster way to perform the common data frame processing steps. Beyond saving typing time, the simpler syntax also makes scripts more readable and easier to debug.

We will first discuss what is a *tidy* dataset and how to convert data to this standard form with tidyr. Next, we will explore the data processing functions in dplyr, which work particularly well with the tidy data format. The key functions from that package all have close counterparts in SQL (Structured Query Language), which provides the added bonus of facilitating the transition from R to relational databases.

Sample data
-----------

We will use the [Portal teaching database](http://github.com/weecology/portal-teachingdb), a simplified dataset derived from a long-term study of animal populations in the Chihuahuan Desert. The teaching dataset includes three tables: two contain summary information on the study plots and observed species, respectively, while the third and largest one (surveys) lists all individual observations, with columns linking to the appropriate species and plot IDs.

``` r
plots <- read.csv("../Data/plots.csv")
species <- read.csv("../Data/species.csv")
surveys <- read.csv("../Data/surveys.csv", na.strings = "")
```

Tidy data concept
-----------------

R developer Hadley Wickham (author of the tidyr, dplyr and ggplot packages, among others) defines tidy datasets as those where:

-   each variable forms a column;
-   each observation forms a row; and
-   each type of observational unit forms a table. ([Wickham 2014](http://www.jstatsoft.org/v59/i10/paper))

These guidelines may be familiar to some of you, as they closely map to best practices in database design. The three tables in our sample data are already in a tidy format. Let's consider a different example where the counts of three species are recorded for each day in a week:

``` r
counts_df <- data.frame(
  day = c("Monday", "Tuesday", "Wednesday"),
  wolf = c(2, 1, 3),
  hare = c(20, 25, 30),
  fox = c(4, 4, 4)
)
counts_df
```

    ##         day wolf hare fox
    ## 1    Monday    2   20   4
    ## 2   Tuesday    1   25   4
    ## 3 Wednesday    3   30   4

**Question**: How to structure this data in a tidy format as defined above?

**Answer**: *counts\_df* currently has three columns (*wolf*, *hare* and *fox*) representing the same variable (a count). Since each reported observation is the count of individuals from a given species on a given day: the tidy format should have three columns: *day*, *species* and *count*.

To put it another way, if your analysis requires grouping observations based on some characteristic (e.g. draw a graph of the counts over time with a different color for each species), then this characteristic should be recorded as different levels of a categorical variable (species) rather than spread across different variables/columns.

While the tidy format is optimal for many common data frame operations in R (aggregation, plotting, fitting statistical models), it is not the optimal structure for every case. As an example, community ecology analyses often start from a matrix of counts where rows and columns correspond to species and sites.

Reshaping multiple columns into category/value pairs
----------------------------------------------------

Let's load the **tidyr** package and use its `gather` function to reshape *counts\_df* into a tidy format:

``` r
library(tidyr)
counts_gather <- gather(counts_df, key = "species", value = "count", wolf:fox)
counts_gather
```

    ##         day species count
    ## 1    Monday    wolf     2
    ## 2   Tuesday    wolf     1
    ## 3 Wednesday    wolf     3
    ## 4    Monday    hare    20
    ## 5   Tuesday    hare    25
    ## 6 Wednesday    hare    30
    ## 7    Monday     fox     4
    ## 8   Tuesday     fox     4
    ## 9 Wednesday     fox     4

Here, `gather` takes all columns between `wolf` and `fox` and reshapes them into two columns, the names of which are specified as the key and value. For each row, the key column in the new dataset indicates the column that contained that value in the original dataset.

Some notes on the syntax: From a workflow perspective, a big advantage of tidyr and dplyr is that each function takes a data frame as its first parameter and returns the transformed data frame. As we will see later, it makes it very easy to apply these functions in a chain. All functions also let us use column names as variables without having to prefix them with the name of the data frame (i.e. `wolf` instead of `counts_df$wolf`).

If your analysis requires a "wide" data format rather than the tall format produced by `gather`, you can use the opposite operation, named `spread`. Run the code below and verify that it restores the original form of *counts\_df*:

``` r
counts_spread <- spread(counts_gather, key = species, value = count)
counts_spread
```

    ##         day fox hare wolf
    ## 1    Monday   4   20    2
    ## 2   Tuesday   4   25    1
    ## 3 Wednesday   4   30    3

Why are `species` and `count` not quoted here? (They refer to existing column names.)

### Exercise

Try removing a row from `counts_gather` (e.g. `counts_gather <- counts_gather[-8, ]`). How does that affect the outcome of `spread`? Let's say the missing row means that no individual of that species was recorded on that day. How can you reflect that assumption in the outcome of `spread`? (Hint: Look at the help file for that function.)

Key functions in dplyr
----------------------

The table below presents the most commonly used functions in **dplyr**, which we will demonstrate in turn, starting from the *surveys* data frame.

<table style="width:94%;">
<colgroup>
<col width="30%" />
<col width="63%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Function</th>
<th align="left">Returns</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">filter(<em>data</em>, <em>conditions</em>)</td>
<td align="left">rows from <em>data</em> where <em>conditions</em> hold</td>
</tr>
<tr class="even">
<td align="left">select(<em>data</em>, <em>variables</em>)</td>
<td align="left">a subset of the columns in <em>data</em>, as specified in <em>variables</em></td>
</tr>
<tr class="odd">
<td align="left">arrange(<em>data</em>, <em>variables</em>)</td>
<td align="left"><em>data</em> sorted by <em>variables</em></td>
</tr>
<tr class="even">
<td align="left">group_by(<em>data</em>, <em>variables</em>)</td>
<td align="left">a copy of <em>data</em>, with groups defined by <em>variables</em></td>
</tr>
<tr class="odd">
<td align="left">summarize(<em>data</em>, <em>newvar</em> = <em>function</em>)</td>
<td align="left">a data frame with <em>newvar</em> columns that summarize <em>data</em> (or each group in <em>data</em>) based on an aggregation <em>function</em></td>
</tr>
<tr class="even">
<td align="left">mutate(<em>data</em>, <em>newvar</em> = <em>function</em>)</td>
<td align="left">a data frame with <em>newvar</em> columns defined by a <em>function</em> of existing columns</td>
</tr>
<tr class="odd">
<td align="left">join(<em>data1</em>, <em>data2</em>, <em>variables</em>)</td>
<td align="left">a data frame that joins columns from <em>data1</em> and <em>data2</em> based on matching values of <em>variables</em></td>
</tr>
</tbody>
</table>

*Note*: There are in fact multiple join functions (`inner_join`, `left_join`, `full_join`) that differ in how they handle rows without a match in the other data frame.

Subsetting and sorting
----------------------

After loading dplyr, we begin our analysis by extracting the survey observations for the first three months of 1990 with `filter`:

``` r
library(dplyr)
surveys1990_winter <- filter(surveys, year == 1990, month %in% 1:3)
```

Note that a logical "and" is implied when conditions are separated by commas. (This is perhaps the main way in which `filter` differs from the base R `subset` function.) Therefore, the example above is equivalent to `filter(surveys, year == 1990 & month %in% 1:3)`. A logical "or" must be specified explicitly with the `|` operator.

To subset the columns (rather than the rows) of a data frame, we would call `select` with the name of the variables to retain, e.g. `select(df, name, address)` returns a new data frame containing the *name* and *address* columns from *df*. Alternatively, we can *exclude* a column by preceding its name with a minus sign. We use this option here to remove the redundant year column from *surveys\_1990\_winter*:

``` r
surveys1990_winter <- select(surveys1990_winter, -year)
head(surveys1990_winter)
```

    ##   record_id month day plot_id species_id sex hindfoot_length weight
    ## 1     16879     1   6       1         DM   F              37     35
    ## 2     16880     1   6       1         OL   M              21     28
    ## 3     16881     1   6       6         PF   M              16      7
    ## 4     16882     1   6      23         RM   F              17      9
    ## 5     16883     1   6      12         RM   M              17     10
    ## 6     16884     1   6      24         RM   M              17      9

To complete this section, we sort the 1990 winter surveys data by descending order of species name, then by ascending order of weight. For comparison purposes, I include both the dplyr code (`arrange` function) and the base R code performing the same operation. Note that `arrange` assumes ascending order unless the variable name is enclosed by `desc()`.

``` r
sorted1 <- arrange(surveys1990_winter, desc(species_id), weight)
sorted2 <- surveys1990_winter[order(-xtfrm(surveys1990_winter$species_id), surveys1990_winter$weight), ]
head(sorted1)
```

    ##   record_id month day plot_id species_id sex hindfoot_length weight
    ## 1     16929     1   7       3         SH   M              31     61
    ## 2     17172     2  25       3         SH   F              29     67
    ## 3     17327     3  30       2         SH   M              30     69
    ## 4     16886     1   6      24         SH   F              30     73
    ## 5     17359     3  30       3         SH   F              31     77
    ## 6     17170     2  25       3         SH   M              30     80

### Exercise

Write code that returns the *record\_id*, *sex* and *weight* of all surveyed individuals of *Reithrodontomys montanus* (RO).

Grouping and aggregation
------------------------

Another common type of operation on tabular data involves the aggregation of records according to specific grouping variables. In particular, let's say we want to count the number of individuals by species observed in the winter of 1990. We first define a grouping of our *surveys1990\_winter* data frame with `group_by`, then call `summarize` to aggregate values in each group using a given function (here, the built-in function `n()` to count the rows).

``` r
surveys1990_winter <- group_by(surveys1990_winter, species_id)
counts_1990w <- summarize(surveys1990_winter, count = n())
head(counts_1990w)
```

    ## Source: local data frame [6 x 2]
    ## 
    ##   species_id count
    ##       (fctr) (int)
    ## 1         AB    25
    ## 2         AH     4
    ## 3         BA     3
    ## 4         DM   132
    ## 5         DO    65
    ## 6         DS     6

A few notes on these functions:

-   `group_by` makes no changes to the data frame values, but it adds metadata -- in the form of R *attributes* -- to identify groups. You can see those attributes either by running the `str()` function on the data frame or by inspecting it in the RStudio *Environment* pane.
-   You can add multiple variables (separated by commas) in `group_by`; each distinct combination of values across these columns defines a different group. You can also define more than one summary variable in a single call to `summarize`.

### Exercise

Write code that returns the average weight and hindfoot length of *Dipodomys merriami* (DM) individuals observed in each month (irrespective of the year). Make sure to exclude *NA* values.

Transformation of variables
---------------------------

The `mutate` function creates new columns by performing the same operation on each row. Here, we use the previously obtained *count* variable to derive the proportion of individuals represented by each species, and assign the result to a new *prop* column.

``` r
counts_1990w <- mutate(counts_1990w, prop = count / sum(count))
head(counts_1990w)
```

    ## Source: local data frame [6 x 3]
    ## 
    ##   species_id count       prop
    ##       (fctr) (int)      (dbl)
    ## 1         AB    25 0.05091650
    ## 2         AH     4 0.00814664
    ## 3         BA     3 0.00610998
    ## 4         DM   132 0.26883910
    ## 5         DO    65 0.13238289
    ## 6         DS     6 0.01221996

Notes:

-   With `mutate`, you can assign the result of an expression to an existing column name to overwrite that column.
-   As we will see below, `mutate` also works with groups. The key difference between `mutate` and `summarize` is that the former always returns a data frame with the same number of rows, while the latter reduces the number of rows.
-   For a concise way to apply the same transformation to multiple columns, check the `mutate_each` function. There is also a `summarize_each` function to perform the same aggregation operation on multiple columns.

Joining data frames
-------------------

Inspired by relational databases, the join functions combine information in two data frames based on matching the values of variables they share. We use this feature to add information (from the *species* data frame) pertaining to each species listed in the *counts\_1990w* data.

``` r
counts_1990w_join <- inner_join(counts_1990w, species)
```

    ## Joining by: "species_id"

    ## Warning in inner_join_impl(x, y, by$x, by$y): joining factors with
    ## different levels, coercing to character vector

``` r
head(counts_1990w_join)
```

    ## Source: local data frame [6 x 6]
    ## 
    ##   species_id count       prop            genus     species   taxa
    ##        (chr) (int)      (dbl)           (fctr)      (fctr) (fctr)
    ## 1         AB    25 0.05091650       Amphispiza   bilineata   Bird
    ## 2         AH     4 0.00814664 Ammospermophilus     harrisi Rodent
    ## 3         BA     3 0.00610998          Baiomys     taylori Rodent
    ## 4         DM   132 0.26883910        Dipodomys    merriami Rodent
    ## 5         DO    65 0.13238289        Dipodomys       ordii Rodent
    ## 6         DS     6 0.01221996        Dipodomys spectabilis Rodent

The messages output by R point to two useful features of `inner_join`: it automatically joins the tables based on shared column names (here, *species\_id*) and it converts factors to characters when their levels don't match.

It is sometimes useful to manually specify the columns that should be joined, i.e. when corresponding columns don't share the same name, or columns of the same name shouldn't be matched. This can be done with the `by` argument, e.g. if column `id` in *A* matches column `A_id` in *B*, you would write:

``` r
inner_join(tableA, tableB, by = c("id" = "A_id")
```

By inspecting the *counts\_1990w\_join* data frame, you may notice that the last row of *counts\_1990w* (where the *species\_id* was *NA*) was excluded. An `inner_join` only keeps rows for which a match was found in the other table. To keep all rows from the first table, use `left_join` instead.

``` r
counts_1990w_join <- left_join(counts_1990w, species)
```

### Exercise

We often use `group_by` along with `summarize`, but you can also apply `filter` and `mutate` operations on groups. Try it out and answer one or both of the following queries:

-   Return only the rows in *counts\_1990w\_join* that correspond to the most common species in each genus.
-   Calculate the fraction of total counts by taxa (birds or rodents) represented by each species within that taxon.

Chaining operations with pipes (%&gt;%)
---------------------------------------

We have seen that dplyr functions all take a data frame as their first argument and return a transformed data frame. This consistent syntax has the added benefit of making these functions compatible the "pipe" operator (`%>%`). This operator actually comes from another R package, **magrittr**, which is loaded with dplyr by default. What `%>%` does is to take the expression on its left-hand side and pass it as the first argument to the function on its right-hand side. Here is a simple example:

``` r
c(1,3,5,NA) %>% sum(na.rm = TRUE)   # same as sum(c(1,3,5,NA), na.rm = TRUE)
```

    ## [1] 9

This particular syntax may appear strange in the example above. The pipe operator's main utility is to condense a chain of operations applied to the same piece of data, when you don't need to save the intermediate results. To illustrate this, the code below reproduces all the steps that led to the *counts\_1990w\_join* data frame.

``` r
new_counts <- surveys %>%
    filter(year == 1990, month %in% 1:3) %>% 
    select(-year) %>%
    group_by(species_id) %>%
    summarize(count = n()) %>%
    mutate(prop = count / sum(count)) %>%
    inner_join(species)

identical(new_counts, counts_1990w_join)
```

    ## [1] TRUE

Additional information
----------------------

[Data wrangling with dplyr and tidyr (RStudio cheat sheet)](http://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf)

One of several cheat sheets available on the RStudio website, it provides a brief, visual summary of all the key functions discussed in this lesson. It also lists some of the auxiliary functions that can be used within each type of expression, e.g. aggregation functions for summarize, "moving window" functions for mutate, etc.
