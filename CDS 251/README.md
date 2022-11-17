# Assignment #5

Use the same data file, **Numbers1.txt**, from assignment #3. Write a Fortran program with the following specifications:

- User needs to type in a filename to read in the data. (Your program will ask the user to type in the data file name.)
- Read in the data into an array. Your array that stores the data will be allo- catable. Only allocate enough memory to store the number of values indicated by the first number. Properly deallocate memory before your program quits.
- Next Part: Implement the **Best Bubble Sort with indexing** so do not move any elements in the actual data array. I recommend you first take the regular bubble sort you did in Lab and upgrade it to the best bubble sort **without** indexing, test it and get it working before you upgrade that with indexing. Then, add an integer array that is allocatable for the index. Access the data ’through’ the index throughout the program (except when you read in the data). Swap only index values, not data values.
- Last Part: Write to a file named **Output.txt** as follows. The first line is an integer which is the number of numbers processed. Then, write all the numbers in sorted order, one per line. They will be written in sorted order if you access the data through the index. This part of the code will look identical to the code where you read in the data except there will be a **write(42,\*)** statement instead of a **read(41,\*)** statement and of course the array index will be the indexed number.
- Print ’Done!’ to the screen as the last line before the end of the program.
- As usual, follow the programming style guide.
