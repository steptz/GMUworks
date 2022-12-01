# Lesson 8 Part I - Colaboratory Assignment

**Instructions**. Below you will find several text cells with programming (short) problems. You will create how many code cells you need to answer them. Make sure that you and your programming partner contribute to the code.

**BEFORE YOU START**

Complete the cell below with your names. 



*   



## 1. Counting Triangles Inefficiently

In the slides, you could see several ways to count triangles. There are some ways that make the count faster, which becomes extremely important when the number of nodes grows.

We will try to make a count using a function defined in the videos. 

1. Modify the function `triangle_present` to return 1 when the triangle is present, and 0 otherwise.
2. Use this modified function to obtain the number of global triangles in the `foodweb-baydry-links.txt` network.


```python

```

## 2. Improving Efficiency

The reason for the method used in the previous problem is so slow is the 3 level `for` loop. We have to pass through every node in the network several times. 

We should always be careful on the computational time it takes to count triangles for a network, or at least identify which method is more efficient. 

We could try counting triangles using the adjacency matrix. To do this, repeat the count for the local and global triangles in ne `foodweb-baydry-links` network using the adjacency matrix.


```python

```

## 3. Analyzing a local triangle histogram

Using any of the methods found in the slides, import the `EnronHt.txt` that contains the local triangle histogram for the Enron Network.

Also from the slides, obtain from $H(t)$:

- $n$
- $\min t$
- $\max t$
- $T$
- $\langle t \rangle$


```python

```

## 4. Plotting the local triangles histogram

We will use a dataset introduced in the previous lesson: `dolphins.txt`.

Using only the dataset, plot the histogram of local triangles with the appropriate scaling in both axes.


```python

```
