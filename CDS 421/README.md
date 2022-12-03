- Dr. Arie Croitoru, George Mason University Fall 2022, Ver: 11/11/2022![](rlyztnch.001.png)

CDS 421: Assignment 6

Due: As noted on Blackboard

Prerequisites

- Reviewing class notes for Module 6 – Part 3.
- Reading Section 11.5 in the course textbook (see Module 6 for a complete list of readings for this module).
- Completing the MapReduce tutorial in AWS Learner Lab (see class notes for Module 6 – Part 3).
- Anaconda python installed (including Anaconda PowerShell)

Background

In our review of HDFS and Hadoop we introduced MapReduce, a programming model and tool for processing and generating large data sets that enables fault-tolerant distributed computation. Building on principles of functional programming, we examined 3 basic functions, namely, map, shuffle & sort, and reduce. We also demonstrated how MapReduce works by implementing (in python) a word count of a large corpus of text.

In this assignment you will utilize similar processing steps to analyze airline flight log data obtained from the U.S. Bureau of Transportation Statistics (BTS, [www.bts.gov). This](https://www.bts.gov/) data set is comprised of monthly carrier on-time performance reporting from January 2022 to August 2022 (one log file per month with a total of 8 files) and is given in the comma separated values (csv) format. Each record (line) in a log file includes the attributes described below (as given by BTS and also provided in the file Documentation.csv). A sample from a log file is shown in figure 1[.](#_page0_x198.69_y688.73)

- FL~~ DATE– Flight Date (yyyymmdd)
- OPUNIQUECARRIER– Unique Carrier Code. When the same code has been used by multiple carriers, a![](rlyztnch.002.png)![](rlyztnch.003.png) numeric suffix is used for earlier users, for example, PA, PA(1), PA(2). Use this field for analysis across a range of years
- OPCARRIER– Code assigned by IATA and commonly used to identify a carrier. As the same code may have![](rlyztnch.004.png) been assigned to different carriers over time, the code is not always unique. For analysis, use the Unique Carrier Code
- ORIGIN– Origin Airport, e.g. ”DCA”
- ORIGINSTATENM– Origin Airport, State Name![](rlyztnch.005.png)![](rlyztnch.006.png)
- DEST– Destination Airport, e.g. ”JFK”

![](rlyztnch.007.png)

Figure 1: A sample of an BTS on-time performance reporting log file

- DESTSTATEABR– Destination Airport, State Code![](rlyztnch.008.png)![](rlyztnch.009.png)
- DEPDELAY– Difference in minutes between scheduled and actual departure time. Early departures show![](rlyztnch.010.png) negative numbers.
- ACTUALELAPSEDTIME– Elapsed Time of Flight, in Minutes![](rlyztnch.011.png)![](rlyztnch.012.png)
- DISTANCE– Distance between airports (in miles)

Objective

You have been tasked by BTS to calculate the average departure delay for every airport in the data set between January and August 2022. Since the number of records is expected to be large (BTS has been curating such log data since 1987) you are required to use a distributed computing approach (i.e., Hadoop MapReduce). The analysis product you are required to deliver is a text file (comma or tab separated values)

in which each row i is a ⟨keyi,valuei⟩pair, where keyi is the origin airport code (e.g. ”DCA”) and valuei is the average departure delay in minutes (e.g., ”7.75”). Note that each origin airport code should appear

only once in the file, and that the file should be sorted alphabetically by the airport code.

Approach

Generally, calculating the overall average departure delay d¯(A ) for a given airport A requires two summed

i i

quantities: the sum S (Ai) of all the flight delays (in minutes) at the origin airport (regardless of the airline operating the flight), and the sum of the number of flights N (Ai) originating from that airport. Once these quantities are computed the average departure delay is simply given by:

S (Ai)

d¯(Ai) = N (Ai) (1)

Finding the sums S (Ai) and N (Ai) is, in principle, similar to word counting. When counting words, a value of 1 is added to a “running sum” every time the a given word appears in a text we analyze. The same mechanism can be applied to computing both S (Ai) and N (Ai). Specifically, every time a log record indicates a flight from airport Ai a value of 1 is added to a “running sum” of the flights from that airport, and the departure delay is added to a “running sum” of all departure delays from that airport (remember, per the goal specified, we are not interested in finding the average delay for a specific airline; We are interested only in the overall average delay from that airport). Consequently, the MapReduce approach used in our word counting example could be used here to find S (Ai) and N (Ai).

Having said that, there is a key difference between our MapReduce word counting example and the task at hand. When computing a sum, the order of computation does not affect the result since addition is a commutative operation. This means that during the reduce step of MapReduce partial sums of the data can be computed distributively at any order and then combined into a single value. A division operation between two values, however, is not commutative i.e. it is required to know what both values are from the entire data set in order to obtain a correct division result. In the context of our objective, it is required

to first find what S (Ai) and N (Ai) are for the entire set of log data before d¯(Ai) could be calculated for each airport Ai. One way to accomplish this in a distributed computing environment with MapReduce is to

apply MapReduce twice consecutively (also called MapReduce “chaining”):

- A first MapReduce (“MapReduce–A”) is applied to produce key–value pairs ⟨Ai,(SumDelays,SumFlights)⟩ that are stored in files and used as the input for a second MapReduce processing. Here, SumDelays and SumFlights are the partial sum of delay times (in minutes) and the the partial sum (count) of flights for departing flights from airport Ai (respectively). The reason why these sums are only partial and not the complete sums across all data files is that they are calculated separately (and in a distributed parallel fashion) for each MapReduce job task. Since addition is commutative, adding these partial sums into a single “complete” sum is possible.
- A second MapReduce (“MapReduce–B”)is applied on the results of the first MapReduce. Here, we first need to find the “complete” sum of all reported flight departure delays S (Ai) and the count of all flights N (Ai) that departed from airport Ai in our entire data set. Once these quantities are found

for each airport Ai they can be divided to produce a final result in the form of a ⟨keyi,valuei⟩pairs, where keyi is the code of airport Ai and valuei is the corresponding average flight departure delay.

The tasks in this assignment, which are described below, correspond to these two consecutive MapReduce steps.

Using print() and sys.stdout.write()in MapReduce python scripts![](rlyztnch.013.png)

Please note that while in python print() and sys.stdout.write() produce output that appear visually identical in most cases, there are some important differences between the two. In a nutshell, the print() function simply converts a input parameter(s) into a string, adds a newline \n to that string, and outputs the result to the the screen. [sys.stdout.write(), howe](https://docs.python.org/3/library/sys.html#sys.stdout)ver, is a stream that behaves like a regular text file, much like an object created with the file open() function in python.

Why is this distinction important here? In our simple word count class example, we used print() to produce the output of the map and reduce scripts. This works when running a “simlation” of the MapReduce process (e.g., step 3[ b](#_page2_x72.00_y597.75)elow). However, when working in the MapReduce cluster environment with the hadoop-streaming.jar tool all input and output to and from the python scripts must be through sys.stdin and sys.stdout. For example, sending an output of a key and a value and the number 1 with sys.stdout.write() using lab delimiters would be:

1 sys.stdout.write(’{}\t{}\t{}\n’.format(key, value, 1))

Note the use of the [.format() ](https://www.w3schools.com/python/ref_string_format.asp)method that enables control over the formatting of the output, as well

as the addition of the newline \n at the end of the output string. To ensure that your script will be compatible with the EMR cluster environment please use sys.stdout.write() to produce the output of each script.

Task 1

Develop and run the mapper and reducer python scripts for MapReduce–A. The input for this step is BTS’s on-time performance reporting log files from January 2022 to August 2022 and the output is ⟨Ai,(delay, 1)⟩.

1. Modify the class tutorial (word count) script ebook~~ map.py to process a stream of log file lines (recieved from stdin) and produce for each line a tab–separated tuple ⟨Ai,delay, 1⟩. Here, Ai is the origin airport code (as reported in the logs by ORIGIN), delay is the flight delay in minutes for the logged flight (as reported in the logs by DEPDELAY), and a value 1 is added to indicate that the flight delay value is![](rlyztnch.014.png) counted as one delay time observation. Name your script mapperA.py and include the following statement in the first line of the file: #!/usr/bin/python (this line is required to ensure the python script will run on the AWS EMR cluster).
1. Modify the class tutorial (word count) script ebook~~ reduce.py to take the tuples ⟨Ai,delay, 1⟩as input and produce a tab–separated tuple ⟨Ai,SumDelays,SumFlights⟩, where SumDelays and SumFlights are the a partial sums of delay times (in minutes) and flight counts for departing flights

from airport Ai (respectively) in a MapReduce task. Name your script reducerA.py and include the following statement in the first line of the file: #!/usr/bin/python

3. Test MapReduce–A on your own computer using the small sample of log data provided in the file test~~ data.csv. Open a terminal (Conda PowerShell on Windows) and simulate a hadoop streaming MapReduce task in two steps: first test mapperA.py by running the shell command:

1 $ cat test\_data.csv | mapperA.py | sort

In this command cat prints the lines in the file test~~ data.csv to the terminal, | (a.k.a as “pipe”) redirects the output of the previous operation (e.g., cat or sort) to the next operation in the command (like stdin), and sort sorts the redirected input in ascending ASCII order. Compare your results to

the data in test~~ data.csv and verify that the output of your map and reduce scripts (printed to the terminal screen) are ⟨Ai,delay, 1⟩tuples.

4. Next, test reducerA.py by running the following shell command that complete MapReduce–A process:

1 $ cat test\_data.csv | python mapperA.py | sort | python reducerA.py > MapReduceA.txt

This command, which sends the output of reducerA.py to the text file MapReduceA.txt, should produce the tuples ⟨Ai,(SumDelays,SumFlights)⟩as noted earlier. Compare the results to the data in test~~ data.csv and verify that they are correct.

Task 2

Develop and run the mapper and reducer python scripts for MapReduce–B. The input for this step is the output of MapReduce–A, i.e. tuples of the form ⟨Ai,(SumDelays,SumFlights)⟩, and the result of this

MapReduce process should be tuples ⟨Ai,d¯(Ai)⟩pairs, where keyi is the code of airport Ai and d¯(Ai) is the corresponding average flight departure delay from airport Ai calculated over the entire data set.

1. Modify the class tutorial (word count) script ebook~~ map.py to take the tuples ⟨Ai,SumDelays,SumFlights⟩ as input and produce identical tuples as output. Put differ- ently, the mapper function of MapReduce–B should simply copy its input to its output, a process that is sometimes referred to as “identity mapping”. Name your script mapperB.py and include the following statement in the first line of the file: #!/usr/bin/python.
1. Modify the class tutorial (word count) script ebook~~ reduce.py to take the tuples ⟨A ,SumDelays,SumFlights⟩ as input and produce a tab–separated tuple ⟨Ai,d¯(A )⟩, where

A iis the airport code and d¯(Ai) is the average delay (in minutes) of all flights departinigfrom A

i i between January and August 2022 (respectively). Name your script reducerB.py and include the

following statement in the first line of the file: #!/usr/bin/python.

3. Similarly to the way you tested your MapReducer–A scripts, test MapReduce–B on your own computer using the results of Task 1. Open a terminal (Conda PowerShell on Windows) and simulate a hadoop streaming MapReduce task in two steps: first test mapperB.py by running the shell command:

1 $ cat MapReduceA.txt | mapperB.py | sort

Compare your results to the contents of MapReduceA.txt and verify that the output is identical to the contents of MapReduceA.txt.

4. Next, test reducerB.py by running the following shell command that simulates a complete MapReduce–B task:

1 $ cat MapReduceA.txt | mapperB.py | sort | python reducerB.py > MapReduceB.txt

This command, which sends the output of reducerB.py to the text file MapReduceB.txt, should produce the tuples ⟨Ai,d¯(Ai)⟩as noted earlier.

5. Using the data in test~~ data.csv calculate manually (e.g., in a spreadsheet) the average delay for each airport. Then compare these calculated values to the results in MapReduceB.txt in a table and verify that all airports are included and all average values were computed correctly.

Task 3

Tasks 1 and 2 should result in 4 python scripts, mapperA.py, reducerA.py, mapperB.py, and reducerB.py that have been tested. Using these scripts and the log data set provided in this assignment, you are now ready to run your MapReduce–A and MapReduce–B jobs in the AWS EMR cluster. The first few steps in this task are similar to steps 1–5 in the class tutorial (see slides 56–66 in the Module 6 – Part 3 class notes)

Important!![](rlyztnch.015.png)

Running an AWS EMR cluster has a relatively higher cost compared to the other cloud service we used so far. Please make sure all data and script files are on your computer and are ready for uploading (as described in the steps below) before launching your cluster. When you are done with this task please remember to terminate your cluster (as described in step 15 [of this](#_page6_x72.00_y286.42) task).

1. Create a new folder named assignment6 on your computer and download into it the assignment files from Blackboard. In addition copy the 4 python scripts you created in Tasks 1 and 2 (as noted above).
1. Login to your AWS student account and start a learner lab. Remember, your lab will run for up to 4 hours. If you run out of time you will have to restart a new lab and repeat Task 3.
1. If you do not have a current EC2 SSH key, or if you would like to use a new key for this assignment, please create a new key pair (see slides 58–59 in the class notes) copy it to your assignment6 folder. If you have an existing (working key) please copy it to that folder.
1. Create and configure an EMR cluster. Your cluster should be configured to be identical to the cluster you configured for the class tutorial (see slide 60 in the class notes). When configuring your cluster make sure the EC2 key selected matches the key in your assignment6 folder. Note that it may take some time (sometimes up to 10–15 minutes or so) for your cluster to be created.
1. Set an EC2 inbound security rule to enable an SSH connection to EC2 instances, as shown in slide 63 of the class tutorial (if you already created this rule in the class tutorial you do not need to recreate it, however please verify that it still exists).
1. Return to the EMR Clusters page and check if your cluster is active (i.e. ready for MapReduce jobs). Active clusters will have a ”Waiting” status indicated in the Status column as well as a green disk icon ![](rlyztnch.016.png) next to the name of the cluster (see also Figure 3).[ Once](#_page6_x245.15_y695.06) your EMR cluster is active launch a terminal (or Conda PowerShell) window open an SSH connection to it’s “Master” node (slides 65–66 in the class notes). In the EMR Master node terminal create a new folder named flight-data in the home folder you logged into with your SSH session.
1. Open a second terminal (or Conda PowerShell) on your computer and move to your assignment6 directory. Then, using the scp command copy the following files to the directory you created step 6 on your cluster’s Master node:

Dept. of Computational and Data Sciences 6![](rlyztnch.017.png)
- Dr. Arie Croitoru, George Mason University Fall 2022, Ver: 11/11/2022![](rlyztnch.001.png)
- T~~ ONTIMEREPORTINGlogs~~ 2022.zip![](rlyztnch.018.png)![](rlyztnch.019.png)
- mapperA.py
- reducerA.py
- mapperB.py
- reducerB.py

(the assignment data set)

Dept. of Computational and Data Sciences ![](rlyztnch.017.png)
- Dr. Arie Croitoru, George Mason University Fall 2022, Ver: 11/11/2022![](rlyztnch.001.png)
8. In your EMR Shell (the SSH connection you created in step 6) [unzip](#_page4_x72.00_y371.66) the flight log data with the unzip command, which will uncompress the file at its current directory:

1 $ unzip T\_ONTIME\_REPORTING\_logs\_2022.zip

9. Make a new directory for the flight logs in your cluster with HDFS’s dfs -mkdir command:

1 fs dfs -mkdir flight -data

Then, copy the flight log data files (8 in totoal) to this directory with the HDFS’s dfs -put command:

1 fs dfs -put \*.csv flight -data

10. Run the MapReduce–A job on your EMR cluster using the Hadoop streaming tool by running the following command in your EMR Shell (note that the command shown below is split into several lines to improve readability, however this command should be typed in the Shell window as a single line):

1 $ hadoop jar /usr/lib/hadoop/hadoop -streaming.jar 2 -files mapperA.py,reducerA.py

3 -mapper mapperA.py

4 -reducer reducerA.py

5 -input flight -data

6 -output flight -data-out-A

Once the MapReduce job starts it will begin outputting to the Shell window messages about its progress Figure [2.](#_page5_x178.98_y360.47) Please verify that the job was completed successfully, as shown in the example in Figure [2.](#_page5_x178.98_y360.47)

![](rlyztnch.020.png)

Figure 2: Example of a part of a streaming MapReduce job progress messages

11. Next, run the MapReduce–B job on your EMR cluster. In this job, the output of MapReduce–A is the input, and the result of the job is the set of tuples ⟨keyi,valuei⟩pairs, where keyi is the set of all airport codes in the data Ai and valuei is their corresponding average flight departure delays. Use the following command in your EMR Shell to run this MapReduce job (As before, the command shown below is split into several lines to improve readability, however this command should be typed in the Shell window as a single line):

1 doop jar /usr/lib/hadoop/hadoop -streaming.jar 2 -files mapperB.py,reducerB.py

3 -mapper mapperB.py

4 -reducer reducerB.py

5 -input flight -data-out-A

6 -output flight -data-out-B

As before, please verify that this MapReduce job is also completed successfully.

12. Copy the results of the two MapReduce jobs from the cluster’s HDFS folders to the Master. In your EMR Shell please do the following:
- Create a directory named MapReduce-out-A , move into it, and then copy the results of MapReduce–A from the HDFS directory flight-data-out-A into it using:

1 $ hdfs dfs -get flight -data-out-A/\*

Examine the files in flight-data-out-A. It should now include a set of output files named part-00000, part-00001, and part-00002. Rename these files to part-00000-A.txt, part- 00001-A.txt, and part-00002-A.txt.

- In your EMR Shell return to your home directory and create a directory named flight-data- out-B, move into it, and then copy the results of MapReduce–B from the HDFS directory flight- data-out-B into it using:

1 $ hdfs dfs -get flight -data-out-B/\*

As with the previous job output, rename these files to part-00000-B.txt, part-00001-B.txt, and part-00002-B.txt.

13. Since the output of MapReduce–B includes several files (as described in step 12),[ our](#_page5_x118.82_y620.44) last step is to combine these results into a single file named flight-delays-2022-avg.txt. This can be easily done with the command below. This command utilizes the cat, | (pipe), and sort Shell tools to combine the results into a single sorted list of airports and their corresponding average delays, and then directs it to a file using the > Shell tool (the command shown below is split into two lines to improve readability, however this command should be typed in the Shell window as a single line):

1 $ cat part -00000-B.txt part -00001-B.txt part -00002-B.txt | sort 2 > flight -delays -2022-avg.txt

14. Using the local computer Shell you opened in step 7 [and](#_page4_x72.00_y450.80) the scp command, copy the output files of the MapReduce–A and MapReduce–B jobs from the AWS EMR Master node to your computer (the files in flight-data-out-A and flight-data-out-B directories, see step [12).](#_page5_x72.00_y556.62) In addition, copy the combined results file flight-delays-2022-avg.txt to your computer.
14. Verify that all files you copied in step [14 ](#_page6_x72.00_y231.25)were successfully copied to your computer (if not, please go back to step [14 ](#_page6_x72.00_y231.25)and complete the copying process). Once all files are copied terminate your your EMR cluster by appying the following steps (Figure 3):

Important!![](rlyztnch.021.png)

Once your cluster is terminated you will not be able to retrieve any files from it. Please make sure you have a copy of all necessary files on your local computer before proceeding.

1) Navigate to the AWS EMR service in your learner lab and click on ”Clusters” from the menu

on the left side menu. This will bring you to the control panel shown in Figure 3, [whic](#_page6_x245.15_y695.06)h lists both active and terminated clusters associated with your lab. Active clusters in this list will have a ”Waiting” status indicated in the Status column as well as a green disk icon ![](rlyztnch.016.png) next to the name of the cluster. Terminated clusters will have a ”Terminated” status indicated in the Status column.

2) Select the box to the left of your cluster name. Once selected it will turn blue.
2) Click on the ”Terminate” button located on the top of the list. A pop–up window asking you to confirm the cluster termination will appear, please select ”Terminate” to shutdown your cluster.
2) End your learner lab.

![](rlyztnch.022.jpeg)

Figure 3: Terminating an EMR cluster on AWS

What to submit

Please submit a single zip file with the following files:

- Task 1:
- The python scripts mapperA.py and reducerA.py
- The file MapReduceA.txt (step [4)](#_page3_x72.00_y72.00)
- Task 2:
- The python scripts mapperB.py and reducerB.py
- The file MapReduceB.txt (step [4)](#_page3_x72.00_y460.22)
- A table showing the comparison between your manual average calculations and the results in MapReduceB.txt (step [5).](#_page3_x72.00_y541.69) Please prepare your table in Microsoft Word and submit it as a single document in PDF format.
- Task 3:
- The MapReduce–A and MapReduce–B output files you copied into your computer in step 14, including the file flight-delays-2022-avg.txt
Dept. of Computational and Data Sciences 9![](rlyztnch.017.png)
