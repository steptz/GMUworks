**CDS 303: Scientific Data Mining** 

Sprring Term 2021 

Assignment 1: Classification 

Assignment is due: Monday March 8, 11:59pm (End of Day) (Please upload the solution as PDF-file in Blackboard) 

hw1data



||**person**|**time**|**gender**|**area**|**risk**|
| :- | - | - | - | - | - |
|**1**|1|1-2|m|u|l|
|**2**|2|2-7|m|r|h|
|**3**|3|>7|f|r|l|
|**4**|4|1-2|f|r|h|
|**5**|5|2-7|m|r|h|
|**6**|6|1-2|m|r|h|
|**7**|7|2-7|f|u|l|
|**8**|8|2-7|m|u|h|
**Exercise 1.1: Decision Tree Classification** 

Predict the risk class of a car driver based on the following attributes: 

- Time since getting the driving license (1 - 2 years, 2 - 7 years, > 7 years) 
- Gender (male, female) 
- Residential area (urban, rural) 

The training set is given below:  

1) Building the classifier: Construct a decision tree based on this training data. For splitting, use **information gain** as measure for impurity. Build a separate branch for each attribute value. The decision tree shall stop when all instances in the branch have the same class or no further attribute for splitting is available. 
1) Classification: Apply the decision tree to the following drivers and report the predicted class label:  

Person A: 1-2, f, rural Person B: 2-7, m , urban Person C: 1-2, f, urban
