program HW5
	! Zachary Stept
	! CDS 251
	! Assignment 5
	! Due March 3

	! A program that does the following:
    ! 1. Asks user to input file name and then opnes that file as well as creates a new file for output.
    ! 2. Creates an array of the size declared by the first number in the file as well as creating an 
    !    index array of the same size.
    ! 3. Sorts the array by size lowest to greatest by using the best bubble sorting with indexing.
    ! 4. Writes size of array to file as well as the new sorted array.
    ! 5. Closes the files and prints done to screen when the program is finished.
    
	implicit none
    
    character*50 :: InFile ! character that holds user input
    real, allocatable :: A(:)
    integer, allocatable :: inA(:) ! creates allocatable space assigned to A and space for index array
    integer :: n, i, j, h, p, Temp ! integer that determine size of array, integers that act as iterators
                                   ! for do loops, and intenger that holds temporary value for bubble sort algorithm
    logical :: Done ! logical that checks if sorting is already done
    
    real :: start, finish ! declares reals for clalculating cpu time
    call cpu_time(start) ! starts timer
    
    print*, 'What is your input file: ' ! prints to screen for user input
    read(*,*) InFile ! reads in user input
    open(42,file=InFile) ! opens file from user input
    
    open(43,file='Output.txt') ! creates new output file
    
    read(42,*) n ! reads file and sets first integer to n
    
    allocate(A(1:n)) ! allocates an array to size n for A
    allocate(inA(1:n)) ! allocates an array to size n for inA
    
     ! do loop that reads in array and implements indexing
    do p = 1, n
        read(42,*) A(p)
        inA(p) = p
    enddo
    
    ! do loop that bubble sorts array
    do i = 1, n - 1
        Done = .true.
        do j = 1, n - i
            if (A(inA(j)) .gt. A(inA(j+1))) then 
                Temp = inA(j)
                inA(j) = inA(j+1)
                inA(j+1) = Temp
                Done = .false.
            endif
        enddo
        if (Done) exit
    enddo
    
    ! writes size of array to file
    write(43,*) n
    
    ! do loop that writes new array to file
    do h = 1, n
        write(43,*) A(inA(h))
    enddo
    
    ! deallocates the space from A and inA
    deallocate(A)
    deallocate(inA)
    
     ! close files
    close(42)
    close(43)
    
    call cpu_time(finish) ! ends timer
    print '("Time = ",f6.3," seconds.")',finish-start ! prints out time
    
     ! prints done to screen
    print*, 'Done!'
    
end program HW5