CDS 421: Assignment 6
Due: As noted on Blackboard


Prerequisites  
•	Reviewing class notes for Module 6 – Part 3.
•	Reading Section 11.5 in the course textbook (see Module 6 for a complete list of readings for this module).
•	Completing the MapReduce tutorial in AWS Learner Lab (see class notes for Module 6 – Part 3).
•	Anaconda python installed (including Anaconda PowerShell)


Background  
In our review of HDFS and Hadoop we introduced MapReduce, a programming model and tool for processing and generating large data sets that enables fault-tolerant distributed computation. Building on principles of functional programming, we examined 3 basic functions, namely, map, shuffle & sort, and reduce. We also demonstrated how MapReduce works by implementing (in python) a word count of a large corpus of text.
In this assignment you will utilize similar processing steps to analyze airline flight log data obtained from the U.S. Bureau of Transportation Statistics (BTS, www.bts.gov). This data set is comprised of monthly carrier on-time performance reporting from January 2022 to August 2022 (one log file per month with a total of 8 files) and is given in the comma separated values (csv) format. Each record (line) in a log file includes the attributes described below (as given by BTS and also provided in the file Documentation.csv). A sample from a log file is shown in figure 1.

•	FL DATE – Flight Date (yyyymmdd)
•	OP UNIQUE CARRIER – Unique Carrier Code. When the same code has been used by multiple carriers, a numeric suffix is used for earlier users, for example, PA, PA(1), PA(2). Use this field for analysis across a range of years
•	OP CARRIER – Code assigned by IATA and commonly used to identify a carrier. As the same code may have been assigned to different carriers over time, the code is not always unique. For analysis, use the Unique Carrier Code
•	ORIGIN – Origin Airport, e.g. ”DCA”
•	ORIGIN STATE NM – Origin Airport, State Name
•	DEST – Destination Airport, e.g. ”JFK”
