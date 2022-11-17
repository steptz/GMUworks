

assignment-7

November 16, 2022

**1 Assignment 7**

In this assignment we will be using an extracted subset of a CDC dataset covering individual US

Covid Cases

Link:

https://data.cdc.gov/Case-Surveillance/COVID-19-Case-Surveillance-Public-Use-Data-

with-Ge/n8mc-b4w4

**2 Steps to Complete**

To complete this assignment, complete each step below. Please turn in both your .ipynb ﬁle, and

a PDF your notebook

Review the link above describing the full dataset, due to its size I have extracted a subset covering

virginia only

• Step 0 - Copy and save this notebook. Name it using your GMU netid, netid-assignment-7

**–** For example (for me) this would be jboone-assignment-7.ipynb

• Step 1 - Connect to the dataset provided

**–** The data is provided in CSV ﬁle located in the ./data subdirectory (see va-cases-0.csv)

• Step 2 - Summarize the dataset as prompted

• Step 3 - Clean the dataset as prompted

• Step 4 - Add the new table to our existing SQLite database (created in the Pandas Part 1

notebook)

• Step 5 - Build an index on the new table

• Step 6 - Query the database using pandas

[1]: # basics

**import os**

**import sys**

**import numpy as np**

**import matplotlib.pyplot as plt**

**import matplotlib.dates as mdates**

**from mpl\_toolkits.axes\_grid1 import** make\_axes\_locatable

\# needed for direct http requests for COVID data

**import io**

**import requests**

1





\# time

**import time**

\# datetimes

**import datetime as dt**

\# pandas - depending on your environment

\# you may need to add these modules to your enviornment via

\#

\# pip install pandas

\#

\# OR

\#

\# conda install pandas

\#

\#

**import pandas as pd**

\# sqlite

**import sqlite3 as sql**

**2.1 Step 1 - Connect to the Data Source**

[2]: filepath = './data/va-cases-0.csv'

db\_dir = './databases'

\# note this should point to a location on␣

,→your drive of the database resulting from running the pandas-0.ipynb␣

,→notebook (see week 11)

\# Your Code Here:

**2.2 Step 2 - Summarize**

[3]: # Display the number of rows and columns in the dataset

\# Your Code Here

[4]: # Display the columns in the dataset

\# Your Code Here

[5]: # Display the data types for each column

\# Your Code Here

[6]: # dump the summary contents of the data frame, or print the first few rows

\# Your Code Here

2





**2.3 Step 3 - Perform minor clean-up on the dataset**

[7]: # display the unique values present for the counties present (use: res\_county)

\# Your Code Here

[8]: # Note that there are null values for res\_county (nan)

\# Drop the rows from the dataframe if the res\_county field is null

\# Hint: you can also think of this as only keeping the rows where the␣

,→res\_county column is not null

\# Your Code Here

[9]: # display the unique values present for the counties present (again)

\# to ensure that the nan values have been removed

\# Your Code Here

[10]: # Note the column 'Unnamed: 0' - this is likely a row identifier from the␣

,→original

\# data set - drop this column

\# Your Code Here

[11]: # Drop any row where age\_group and sex are are both null

\# Your Code Here

[12]: # add two new columns that split case\_month into year, month

\#

\# Some hints:

\#

\# You may add a new column to a dataframe in more than one way

\# in the lectures, I use the insert() function, but you can also

\# do this directly...like this:

\#

\# df['new\_column'] = (some function of another column)

\#

\# F urther hints - see the .str and .slice functions in pandas

\#

\# Your Code Here

**2.4 Step 4 - Add the new table to the database**

[13]: # add a new columns that for our new table that acts as a the 'UID' (unique␣

,→identifier)

\# (see the Pandas Part 1 Lecture)

\#

\# Some hints:

\#

3





\# You can use a series of converstions to convert county\_fips\_code field into␣

,→the

\# needed value, prepend the this with '840' (USA)

\# and then covert all of that into an integer (You do not need to do this all␣

,→in one statement)

\#

\# Your Code Here

[14]: # Save the new table to the existing database

\# Your Code Here

**2.5 Step 5 - Create an Index on the New Table**

[15]: # Create the SQL commands to create the index as strings - index on UID

\# Your Code Here

[16]: # Connect to the database and create the new index on the UID attribute by␣

,→executing the

\# SQL you defined above

\# Your Code Here

**2.6 Step 6 - Query the New Database**

[17]: # Query - this query will be simple and only involve the new table

\# define two new python variables selected\_year, and selected\_month (integers)

\# Your Code Here

\# Now define a python string holding the query

\# The query should select the number of rows in the

\# case\_details table for each age\_group during the month, year selected

\# Hint: this is a simple query, one table with a group by on age\_group

\# Your Code Here

\# Now execute and time the query

\# Your Code Here

\# show the result dataframe

\# Your Code Here

[ ]:

4

