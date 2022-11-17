

Assignment #5

Use the same data ﬁle, Numbers1.txt, from assignment #3. Write a Fortran

program with the following speciﬁcations:

• User needs to type in a ﬁlename to read in the data. (Your program will ask

the user to type in the data ﬁle name.)

• Read in the data into an array. Your array that stores the data will be allo-

catable. Only allocate enough memory to store the number of values indicated

by the ﬁrst number. Properly deallocate memory before your program quits.

• Next Part: Implement the Best Bubble Sort with indexing so do not move

any elements in the actual data array. I recommend you ﬁrst take the regular

bubble sort you did in Lab and upgrade it to the best bubble sort without

indexing, test it and get it working before you upgrade that with indexing.

Then, add an integer array that is allocatable for the index. Access the data

’through’ the index throughout the program (except when you read in the

data). Swap only index values, not data values.

• Last Part: Write to a ﬁle named Output.txt as follows. The ﬁrst line is an

integer which is the number of numbers processed. Then, write all the numbers

in sorted order, one per line. They will be written in sorted order if you access

the data through the index. This part of the code will look identical to the

code where you read in the data except there will be a write(42,\*) statement

instead of a read(41,\*) statement and of course the array index will be the

indexed number.

• Print ’Done!’ to the screen as the last line before the end of the program.

• As usual, follow the programming style guide.

10 points Extra Credit: Time how long the program runs (user time). Com-

pute how long it would take 100,000 numbers to be sorted using O() formula from

algorithm complexity. Download Numbers2.txt and run Bubble Sort on it. Compare

the computed time with this run. In the report, be sure to include 1) user time

on ﬁle Numers1.txt, 2) Computed time for 100,000 numbers, 3) user time on ﬁle

Numbers2.txt

1





Submission: Write a short report about your experience with implementing

Bubble Sort. Submit your report in .pdf format on the assignment page. Also

submit your Fortran program on the assignment page. Do not submit the output

ﬁle ’Output.txt’ to the assignment page.

2


