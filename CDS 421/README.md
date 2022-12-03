

©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

CDS 421: Assignment 6

Due: As noted on Blackboard

Prerequisites

• Reviewing class notes for Module 6 – Part 3.

• Reading Section 11.5 in the course textbook (see Module 6 for a complete list of readings for this

module).

• Completing the MapReduce tutorial in AWS Learner Lab (see class notes for Module 6 – Part 3).

• Anaconda python installed (including Anaconda PowerShell)

Background

In our review of HDFS and Hadoop we introduced MapReduce, a programming model and tool for processing

and generating large data sets that enables fault-tolerant distributed computation. Building on principles of

functional programming, we examined 3 basic functions, namely, map, shuﬄe & sort, and reduce. We also

demonstrated how MapReduce works by implementing (in python) a word count of a large corpus of text.

In this assignment you will utilize similar processing steps to analyze airline ﬂight log data obtained from

the U.S. Bureau of Transportation Statistics (BTS, [www.bts.gov](https://www.bts.gov/)). This data set is comprised of monthly

carrier on-time performance reporting from January 2022 to August 2022 (one log ﬁle per month with a

total of 8 ﬁles) and is given in the comma separated values (csv) format. Each record (line) in a log ﬁle

includes the attributes described below (as given by BTS and also provided in the ﬁle Documentation.csv).

A sample from a log ﬁle is shown in ﬁgure [1](#br1).

• FL DATE – Flight Date (yyyymmdd)

• OP UNIQUE CARRIER – Unique Carrier Code. When the same code has been used by multiple carriers,

a numeric suﬃx is used for earlier users, for example, PA, PA(1), PA(2). Use this ﬁeld for analysis

across a range of years

• OP CARRIER – Code assigned by IATA and commonly used to identify a carrier. As the same code may

have been assigned to diﬀerent carriers over time, the code is not always unique. For analysis, use the

Unique Carrier Code

• ORIGIN – Origin Airport, e.g. ”DCA”

• ORIGIN STATE NM – Origin Airport, State Name

• DEST – Destination Airport, e.g. ”JFK”

Figure 1: A sample of an BTS on-time performance reporting log ﬁle

Dept. of Computational and Data Sciences

1





©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

• DEST STATE ABR – Destination Airport, State Code

• DEP DELAY – Diﬀerence in minutes between scheduled and actual departure time. Early departures

show negative numbers.

• ACTUAL ELAPSED TIME – Elapsed Time of Flight, in Minutes

• DISTANCE – Distance between airports (in miles)

Objective

You have been tasked by BTS to calculate the average departure delay for every airport in the data set

between January and August 2022. Since the number of records is expected to be large (BTS has been

curating such log data since 1987) you are required to use a distributed computing approach (i.e., Hadoop

MapReduce). The analysis product you are required to deliver is a text ﬁle (comma or tab separated values)

in which each row i is a ⟨key , value ⟩ pair, where key is the origin airport code (e.g. ”DCA”) and value

i

i

i

i

is the average departure delay in minutes (e.g., ”7.75”). Note that each origin airport code should appear

only once in the ﬁle, and that the ﬁle should be sorted alphabetically by the airport code.

Approach

¯

Generally, calculating the overall average departure delay d (A ) for a given airport A requires two summed

i

i

quantities: the sum S (Ai) of all the ﬂight delays (in minutes) at the origin airport (regardless of the airline

operating the ﬂight), and the sum of the number of ﬂights N (Ai) originating from that airport. Once these

quantities are computed the average departure delay is simply given by:

S (Ai)

¯

d (A ) =

(1)

i

N (Ai)

Finding the sums S (A ) and N (A ) is, in principle, similar to word counting. When counting words, a

i

value of 1 is added to a “running sum” every time the a given word appears in a text we analyze. The

i

same mechanism can be applied to computing both S (A ) and N (A ). Speciﬁcally, every time a log record

i

i

indicates a ﬂight from airport Ai a value of 1 is added to a “running sum” of the ﬂights from that airport, and

the departure delay is added to a “running sum” of all departure delays from that airport (remember, per

the goal speciﬁed, we are not interested in ﬁnding the average delay for a speciﬁc airline; We are interested

only in the overall average delay from that airport). Consequently, the MapReduce approach used in our

word counting example could be used here to ﬁnd S (A ) and N (A ).

i

i

Having said that, there is a key diﬀerence between our MapReduce word counting example and the task

at hand. When computing a sum, the order of computation does not aﬀect the result since addition is a

commutative operation. This means that during the reduce step of MapReduce partial sums of the data

can be computed distributively at any order and then combined into a single value. A division operation

between two values, however, is not commutative i.e. it is required to know what both values are from the

entire data set in order to obtain a correct division result. In the context of our objective, it is required

¯

to ﬁrst ﬁnd what S (A ) and N (A ) are for the entire set of log data before d (A ) could be calculated for

i

i

i

each airport Ai. One way to accomplish this in a distributed computing environment with MapReduce is to

apply MapReduce twice consecutively (also called MapReduce “chaining”):

• A

ﬁrst

MapReduce

(“MapReduce–A”)

is

applied

to

produce

key–value

pairs

⟨A , (SumDelays, SumFlights)⟩ that are stored in ﬁles and used as the input for a second

i

MapReduce processing. Here, SumDelays and SumFlights are the partial sum of delay times (in

minutes) and the the partial sum (count) of ﬂights for departing ﬂights from airport Ai (respectively).

The reason why these sums are only partial and not the complete sums across all data ﬁles is that

they are calculated separately (and in a distributed parallel fashion) for each MapReduce job task.

Since addition is commutative, adding these partial sums into a single “complete” sum is possible.

• A second MapReduce (“MapReduce–B”)is applied on the results of the ﬁrst MapReduce. Here, we

ﬁrst need to ﬁnd the “complete” sum of all reported ﬂight departure delays S (Ai) and the count of

all ﬂights N (A ) that departed from airport A in our entire data set. Once these quantities are found

i

i

Dept. of Computational and Data Sciences

2





©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

for each airport A they can be divided to produce a ﬁnal result in the form of a ⟨key , value ⟩ pairs,

i

where key is the code of airport A and value is the corresponding average ﬂight departure delay.

i

i

i

i

i

The tasks in this assignment, which are described below, correspond to these two consecutive MapReduce

steps.

Using print() and sys.stdout.write()in MapReduce python scripts

Please note that while in python print() and sys.stdout.write() produce output that appear

visually identical in most cases, there are some important diﬀerences between the two. In a nutshell,

the print() function simply converts a input parameter(s) into a string, adds a newline \n to that

string, and outputs the result to the the screen. [sys.stdout.write()](https://docs.python.org/3/library/sys.html#sys.stdout), however, is a stream that

behaves like a regular text ﬁle, much like an object created with the ﬁle open() function in python.

Why is this distinction important here? In our simple word count class example, we used print()

to produce the output of the map and reduce scripts. This works when running a “simlation” of

the MapReduce process (e.g., step [3](#br3)[ ](#br3)below). However, when working in the MapReduce cluster

environment with the hadoop-streaming.jar tool all input and output to and from the python scripts

must be through sys.stdin and sys.stdout. For example, sending an output of a key and a value

and the number 1 with sys.stdout.write() using lab delimiters would be:

1

sys.stdout.write(’{}\t{}\t{}\n’.format(key , value , 1))

Note the use of the [.format()](https://www.w3schools.com/python/ref_string_format.asp)[ ](https://www.w3schools.com/python/ref_string_format.asp)method that enables control over the formatting of the output, as well

as the addition of the newline \n at the end of the output string. To ensure that your script will be

compatible with the EMR cluster environment please use sys.stdout.write() to produce the output

of each script.

Task 1

Develop and run the mapper and reducer python scripts for MapReduce–A. The input for this step is BTS’s

on-time performance reporting log ﬁles from January 2022 to August 2022 and the output is ⟨Ai, (delay, 1)⟩.

\1. Modify the class tutorial (word count) script ebook map.py to process a stream of log ﬁle lines (recieved

from stdin) and produce for each line a tab–separated tuple ⟨A , delay, 1⟩. Here, A is the origin airport

i

i

code (as reported in the logs by ORIGIN), delay is the ﬂight delay in minutes for the logged ﬂight (as

reported in the logs by DEP DELAY), and a value 1 is added to indicate that the ﬂight delay value

is counted as one delay time observation. Name your script mapperA.py and include the following

statement in the ﬁrst line of the ﬁle: #!/usr/bin/python (this line is required to ensure the python

script will run on the AWS EMR cluster).

\2. Modify the class tutorial (word count) script ebook reduce.py to take the tuples ⟨A , delay, 1⟩ as

i

input and produce a tab–separated tuple ⟨A , SumDelays, SumFlights⟩, where SumDelays and

i

SumFlights are the a partial sums of delay times (in minutes) and ﬂight counts for departing ﬂights

from airport Ai (respectively) in a MapReduce task. Name your script reducerA.py and include the

following statement in the ﬁrst line of the ﬁle: #!/usr/bin/python

\3. Test MapReduce–A on your own computer using the small sample of log data provided in the ﬁle

test data.csv. Open a terminal (Conda PowerShell on Windows) and simulate a hadoop streaming

MapReduce task in two steps: ﬁrst test mapperA.py by running the shell command:

1

$ cat test\_data.csv | mapperA.py | sort

In this command cat prints the lines in the ﬁle test data.csv to the terminal, | (a.k.a as “pipe”)

redirects the output of the previous operation (e.g., cat or sort) to the next operation in the command

(like stdin), and sort sorts the redirected input in ascending ASCII order. Compare your results to

the data in test data.csv and verify that the output of your map and reduce scripts (printed to the

terminal screen) are ⟨Ai, delay, 1⟩ tuples.

Dept. of Computational and Data Sciences

3





©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

\4. Next, test reducerA.py by running the following shell command that complete MapReduce–A process:

1

$ cat test\_data.csv | python mapperA.py | sort | python reducerA.py > MapReduceA.txt

This command, which sends the output of reducerA.py to the text ﬁle MapReduceA.txt, should

produce the tuples ⟨A , (SumDelays, SumFlights)⟩ as noted earlier. Compare the results to the data

i

in test data.csv and verify that they are correct.

Task 2

Develop and run the mapper and reducer python scripts for MapReduce–B. The input for this step is the

output of MapReduce–A, i.e. tuples of the form ⟨A , (SumDelays, SumFlights)⟩, and the result of this

i

¯

¯

MapReduce process should be tuples ⟨A , d (A )⟩ pairs, where key is the code of airport A and d (A ) is the

i

corresponding average ﬂight departure delay from airport A calculated over the entire data set.

i

i

i

i

i

\1. Modify the class tutorial (word count) script ebook map.py to take the tuples

⟨A , SumDelays, SumFlights⟩ as input and produce identical tuples as output. Put diﬀer-

i

ently, the mapper function of MapReduce–B should simply copy its input to its output, a process

that is sometimes referred to as “identity mapping”. Name your script mapperB.py and include the

following statement in the ﬁrst line of the ﬁle: #!/usr/bin/python.

\2. Modify the class tutorial (word count) script ebook reduce.py to take the tuples

¯

⟨A , SumDelays, SumFlights⟩ as input and produce a tab–separated tuple ⟨A , d (A )⟩, where

i

i

i

¯

A is the airport code and d (A ) is the average delay (in minutes) of all ﬂights departing from A

i

i

i

between January and August 2022 (respectively). Name your script reducerB.py and include the

following statement in the ﬁrst line of the ﬁle: #!/usr/bin/python.

\3. Similarly to the way you tested your MapReducer–A scripts, test MapReduce–B on your own computer

using the results of Task 1. Open a terminal (Conda PowerShell on Windows) and simulate a hadoop

streaming MapReduce task in two steps: ﬁrst test mapperB.py by running the shell command:

1

$ cat MapReduceA.txt | mapperB.py | sort

Compare your results to the contents of MapReduceA.txt and verify that the output is identical to the

contents of MapReduceA.txt.

\4. Next, test reducerB.py by running the following shell command that simulates a complete

MapReduce–B task:

1

$ cat MapReduceA.txt | mapperB.py | sort | python reducerB.py > MapReduceB.txt

This command, which sends the output of reducerB.py to the text ﬁle MapReduceB.txt, should

¯

produce the tuples ⟨A , d (A )⟩ as noted earlier.

i

i

\5. Using the data in test data.csv calculate manually (e.g., in a spreadsheet) the average delay for each

airport. Then compare these calculated values to the results in MapReduceB.txt in a table and verify

that all airports are included and all average values were computed correctly.

Task 3

Tasks 1 and 2 should result in 4 python scripts, mapperA.py, reducerA.py, mapperB.py, and reducerB.py

that have been tested. Using these scripts and the log data set provided in this assignment, you are now

ready to run your MapReduce–A and MapReduce–B jobs in the AWS EMR cluster. The ﬁrst few steps in

this task are similar to steps 1–5 in the class tutorial (see slides 56–66 in the Module 6 – Part 3 class notes)

Dept. of Computational and Data Sciences

4





©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

Important!

Running an AWS EMR cluster has a relatively higher cost compared to the other cloud service we used

so far. Please make sure all data and script ﬁles are on your computer and are ready for uploading (as

described in the steps below) before launching your cluster. When you are done with this task please

remember to terminate your cluster (as described in step [15](#br7)[ ](#br7)of this task).

\1. Create a new folder named assignment6 on your computer and download into it the assignment ﬁles

from Blackboard. In addition copy the 4 python scripts you created in Tasks 1 and 2 (as noted above).

\2. Login to your AWS student account and start a learner lab. Remember, your lab will run for up to 4

hours. If you run out of time you will have to restart a new lab and repeat Task 3.

\3. If you do not have a current EC2 SSH key, or if you would like to use a new key for this assignment,

please create a new key pair (see slides 58–59 in the class notes) copy it to your assignment6 folder.

If you have an existing (working key) please copy it to that folder.

\4. Create and conﬁgure an EMR cluster. Your cluster should be conﬁgured to be identical to the cluster

you conﬁgured for the class tutorial (see slide 60 in the class notes). When conﬁguring your cluster

make sure the EC2 key selected matches the key in your assignment6 folder. Note that it may take

some time (sometimes up to 10–15 minutes or so) for your cluster to be created.

\5. Set an EC2 inbound security rule to enable an SSH connection to EC2 instances, as shown in slide 63

of the class tutorial (if you already created this rule in the class tutorial you do not need to recreate

it, however please verify that it still exists).

\6. Return to the EMR Clusters page and check if your cluster is active (i.e. ready for MapReduce jobs).

Active clusters will have a ”Waiting” status indicated in the Status column as well as a green disk

icon

next to the name of the cluster (see also Figure [3](#br7)). Once your EMR cluster is active launch a

terminal (or Conda PowerShell) window open an SSH connection to it’s “Master” node (slides 65–66

in the class notes). In the EMR Master node terminal create a new folder named flight-data in the

home folder you logged into with your SSH session.

\7. Open a second terminal (or Conda PowerShell) on your computer and move to your assignment6

directory. Then, using the scp command copy the following ﬁles to the directory you created step [6](#br5)

on your cluster’s Master node:

• T ONTIME REPORTING logs 2022.zip (the assignment data set)

• mapperA.py

• reducerA.py

• mapperB.py

• reducerB.py

\8. In your EMR Shell (the SSH connection you created in step [6](#br5)[)](#br5)[ ](#br5)unzip the ﬂight log data with the unzip

command, which will uncompress the ﬁle at its current directory:

1

$ unzip T\_ONTIME\_REPORTING\_logs\_2022 .zip

\9. Make a new directory for the ﬂight logs in your cluster with HDFS’s dfs -mkdir command:

1

fs dfs -mkdir flight -data

Then, copy the ﬂight log data ﬁles (8 in totoal) to this directory with the HDFS’s dfs -put command:

1

fs dfs -put \*.csv flight -data

Dept. of Computational and Data Sciences

5





©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

\10. Run the MapReduce–A job on your EMR cluster using the Hadoop streaming tool by running the

following command in your EMR Shell (note that the command shown below is split into several lines

to improve readability, however this command should be typed in the Shell window as a single line):

1

2

3

4

5

6

$ hadoop jar /usr/lib/hadoop/hadoop -streaming.jar

-files mapperA.py ,reducerA.py

-mapper mapperA.py

-reducer reducerA.py

-input flight -data

-output flight -data -out -A

Once the MapReduce job starts it will begin outputting to the Shell window messages about its progress

Figure [2](#br6). Please verify that the job was completed successfully, as shown in the example in Figure

[2](#br6).

Figure 2: Example of a part of a streaming MapReduce job progress messages

\11. Next, run the MapReduce–B job on your EMR cluster. In this job, the output of MapReduce–A is

the input, and the result of the job is the set of tuples ⟨key , value ⟩ pairs, where key is the set of all

i

airport codes in the data A and value is their corresponding average ﬂight departure delays. Use the

i

i

i

i

following command in your EMR Shell to run this MapReduce job (As before, the command shown

below is split into several lines to improve readability, however this command should be typed in the

Shell window as a single line):

1

2

3

4

5

6

doop jar /usr/lib/hadoop/hadoop -streaming.jar

-files mapperB.py ,reducerB.py

-mapper mapperB.py

-reducer reducerB.py

-input flight -data -out -A

-output flight -data -out -B

As before, please verify that this MapReduce job is also completed successfully.

\12. Copy the results of the two MapReduce jobs from the cluster’s HDFS folders to the Master. In your

EMR Shell please do the following:

• Create a directory named MapReduce-out-A, move into it, and then copy the results of

MapReduce–A from the HDFS directory flight-data-out-A into it using:

1

$ hdfs dfs -get flight -data -out -A/\*

Examine the ﬁles in flight-data-out-A. It should now include a set of output ﬁles named

part-00000, part-00001, and part-00002. Rename these ﬁles to part-00000-A.txt, part-

00001-A.txt, and part-00002-A.txt.

• In your EMR Shell return to your home directory and create a directory named flight-data-

out-B, move into it, and then copy the results of MapReduce–B from the HDFS directory flight-

data-out-B into it using:

Dept. of Computational and Data Sciences

6





©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

1

$ hdfs dfs -get flight -data -out -B/\*

As with the previous job output, rename these ﬁles to part-00000-B.txt, part-00001-B.txt,

and part-00002-B.txt.

\13. Since the output of MapReduce–B includes several ﬁles (as described in step [12](#br6)), our last step is to

combine these results into a single ﬁle named flight-delays-2022-avg.txt. This can be easily done

with the command below. This command utilizes the cat, | (pipe), and sort Shell tools to combine

the results into a single sorted list of airports and their corresponding average delays, and then directs it

to a ﬁle using the > Shell tool (the command shown below is split into two lines to improve readability,

however this command should be typed in the Shell window as a single line):

1

2

$ cat part -00000 -B.txt part -00001 -B.txt part -00002 -B.txt | sort

\> flight -delays -2022 - avg.txt

\14. Using the local computer Shell you opened in step [7](#br5)[ ](#br5)and the scp command, copy the output ﬁles of

the MapReduce–A and MapReduce–B jobs from the AWS EMR Master node to your computer (the

ﬁles in flight-data-out-A and flight-data-out-B directories, see step [12](#br6)). In addition, copy the

combined results ﬁle flight-delays-2022-avg.txt to your computer.

\15. Verify that all ﬁles you copied in step [14](#br7)[ ](#br7)were successfully copied to your computer (if not, please go

back to step [14](#br7)[ ](#br7)and complete the copying process). Once all ﬁles are copied terminate your your EMR

cluster by appying the following steps (Figure [3](#br7)):

Important!

Once your cluster is terminated you will not be able to retrieve any ﬁles from it. Please make

sure you have a copy of all necessary ﬁles on your local computer before proceeding.

(a) Navigate to the AWS EMR service in your learner lab and click on ”Clusters” from the menu

on the left side menu. This will bring you to the control panel shown in Figure [3](#br7), which lists

both active and terminated clusters associated with your lab. Active clusters in this list will have

a ”Waiting” status indicated in the Status column as well as a green disk icon

next to the

name of the cluster. Terminated clusters will have a ”Terminated” status indicated in the Status

column.

(b) Select the box to the left of your cluster name. Once selected it will turn blue.

(c) Click on the ”Terminate” button located on the top of the list. A pop–up window asking you to

conﬁrm the cluster termination will appear, please select ”Terminate” to shutdown your cluster.

(d) End your learner lab.

Figure 3: Terminating an EMR cluster on AWS

Dept. of Computational and Data Sciences

7





©Dr. Arie Croitoru, George Mason University

Fall 2022, Ver: 11/11/2022

What to submit

Please submit a single zip ﬁle with the following ﬁles:

• Task 1:

– The python scripts mapperA.py and reducerA.py

– The ﬁle MapReduceA.txt (step [4](#br4))

• Task 2:

– The python scripts mapperB.py and reducerB.py

– The ﬁle MapReduceB.txt (step [4](#br4))

– A table showing the comparison between your manual average calculations and the results in

MapReduceB.txt (step [5](#br4)). Please prepare your table in Microsoft Word and submit it as a single

document in PDF format.

• Task 3:

– The MapReduce–A and MapReduce–B output ﬁles you copied into your computer in step [14](#br7),

including the ﬁle flight-delays-2022-avg.txt

Dept. of Computational and Data Sciences

8

