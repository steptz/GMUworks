%Zachary Stept
%November 20, 2019
%WA13_P1
%Clear workspace and command window
clear; clc
%Array A Assignment
A = [1 1 0 1 1 0 0 1 0 1 0 1 0 0 1 1 0 0 0 1 1 0 1 0 1 0 1 1 0 1 0 0 1 0 1; 
     0 0 1 0 1 1 0 1 1 0 0 0 0 0 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 1 1 1 0 1 0; 
     1 1 1 0 0 0 1 1 0 0 0 0 0 0 1 1 0 0 1 0 0 1 1 0 1 1 0 1 0 1 0 1 0 0 0; 
     1 1 0 0 1 1 0 1 1 1 0 0 1 1 1 0 0 0 1 0 1 1 0 1 1 1 0 0 0 0 0 0 1 1 0; 
     0 1 1 1 1 0 0 0 0 1 1 0 0 1 1 1 0 1 1 0 1 0 1 0 0 1 1 0 1 1 1 1 0 0 0; 
     1 1 1 1 0 1 1 0 1 0 0 0 1 0 1 0 1 0 1 0 1 0 0 1 1 1 1 0 1 0 0 1 0 0 0; 
     1 0 0 1 0 0 1 0 0 1 1 0 0 1 0 1 1 1 1 1 0 0 0 1 1 0 1 0 0 0 1 0 1 1 0; 
     1 1 1 1 1 1 1 1 1 0 0 0 1 0 0 0 1 1 0 1 1 0 0 0 1 1 0 0 1 1 1 1 1 0 1; 
     0 1 1 0 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 0 1 1 1 0 0 1 1 0 1 0 1; 
     1 1 0 1 0 0 0 1 1 1 0 0 1 1 1 0 0 1 0 0 0 0 1 0 1 0 1 0 1 1 1 0 1 1 1; 
     1 1 1 1 1 1 0 0 1 1 1 0 0 1 1 0 1 0 1 1 0 0 0 1 0 0 0 1 0 0 0 0 1 0 0; 
     1 1 1 1 0 0 1 1 1 0 1 1 1 0 1 1 0 0 0 1 0 0 0 1 0 0 0 1 0 1 1 0 1 0 1; 
     1 0 0 1 0 0 1 1 0 1 1 1 1 0 0 1 1 1 0 0 1 0 1 1 0 1 0 1 1 1 0 0 1 1 1; 
     0 0 0 1 0 0 1 1 1 1 1 1 1 0 1 0 0 1 0 1 0 0 1 0 0 1 0 0 1 1 0 0 1 0 1; 
     0 1 1 0 1 0 1 0 0 0 0 0 1 0 0 1 0 0 1 1 0 0 1 0 0 0 1 1 1 1 0 1 1 1 0; 
     0 1 0 0 0 1 0 0 0 1 1 1 0 1 0 1 1 0 0 1 1 0 0 1 0 0 0 1 1 0 0 1 0 1 0; 
     1 0 1 0 0 0 0 0 1 0 1 1 1 1 0 0 0 1 1 1 0 1 1 0 1 0 1 0 1 1 1 0 0 0 1; 
     1 1 0 1 0 1 1 0 0 1 0 0 0 0 0 0 0 1 1 0 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1; 
     1 1 0 1 1 0 1 1 1 0 0 0 0 1 0 1 1 0 1 0 1 0 0 0 1 0 0 0 0 0 0 1 0 1 1; 
     0 1 0 0 1 1 1 0 0 1 1 0 0 0 0 1 1 1 1 0 1 0 1 1 0 0 0 0 0 1 1 0 0 0 0; 
     0 0 1 0 1 0 0 1 1 0 0 1 1 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0 1 1 1; 
     0 0 0 0 0 1 1 1 1 0 1 0 1 1 0 0 1 0 0 0 1 0 1 1 0 1 0 1 0 0 1 0 0 1 0; 
     1 1 0 1 1 1 1 0 1 0 1 0 0 0 0 1 0 1 1 0 1 1 1 1 1 1 0 0 1 1 1 1 0 0 1; 
     0 1 0 0 0 0 1 0 0 1 0 1 0 1 1 1 1 1 1 0 1 0 1 0 0 0 0 1 0 0 0 1 1 1 1; 
     0 0 1 0 0 1 0 1 1 0 0 1 0 0 1 0 1 0 1 1 0 0 0 0 0 0 1 0 0 1 1 0 1 0 1; 
     1 0 1 0 0 1 1 1 1 0 0 0 1 1 1 0 0 1 0 1 0 1 1 1 0 1 0 1 0 1 0 0 0 0 1; 
     0 1 0 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 1 0 1 1 0 0 1 1 1 1 0 1 1 1 1 1 1; 
     1 0 1 1 1 1 1 0 1 1 0 0 1 0 0 1 1 1 0 0 1 1 0 1 0 1 0 0 0 1 1 0 0 1 1; 
     1 1 1 1 1 1 0 0 0 0 1 0 0 0 1 1 0 1 0 1 1 1 0 0 0 1 1 0 0 0 0 0 1 0 0; 
     0 0 1 1 1 1 0 0 1 0 0 1 0 0 0 1 0 1 1 0 0 1 1 1 1 1 0 1 0 0 1 1 0 0 0; 
     1 0 1 0 1 0 0 0 1 1 0 1 0 0 0 0 1 0 1 0 1 1 0 1 0 0 0 1 1 0 0 1 0 1 1; 
     0 1 1 1 1 1 1 1 0 1 1 0 0 1 0 1 0 1 1 1 1 1 0 0 1 0 0 0 1 0 1 0 1 0 1; 
     0 0 0 0 1 1 1 0 1 1 1 1 1 0 1 0 1 0 1 1 1 1 1 1 0 1 0 0 0 1 0 1 1 0 0; 
     1 0 1 1 1 1 0 0 1 0 1 0 1 1 0 0 0 0 0 0 1 0 1 0 1 0 1 0 1 1 0 1 1 0 1; 
     1 1 1 0 0 1 1 0 1 0 0 0 0 1 1 0 1 1 1 0 1 0 1 1 0 0 0 0 1 1 0 1 0 0 1];
%Pattern Finder
%Pattern is [1 1 0; 0 1 0; 0 0 1]
i = 0;
for m = 1:33 %row
    for n = 1:33 %column
        if (A(m,n) == 1 && A(m,n+1) == 1 && A(m,n+2) == 0 && ...
            A(m+1,n) == 0 && A(m+1,n+1) == 1 && A(m+1,n+2) == 0 && ...
            A(m+2,n) == 0 && A(m+2,n+1) == 0 && A(m+2,n+2) == 1)
            i = i + 1; %counts the amount of pattern
            fprintf('#%d(%d,%d)(%d,%d)(%d,%d)\n',i,m,n,m,n+1,m,n+2)
            fprintf('   (%d,%d)(%d,%d)(%d,%d)\n',m+1,n,m+1,n+1,m+1,n+2)
            fprintf('   (%d,%d)(%d,%d)(%d,%d)\n',m+2,n,m+2,n+1,m+2,n+2)
         end
    end
end