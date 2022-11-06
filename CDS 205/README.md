#
**Spring 2022**

**Introduction to Agent-Based Modeling and Simulation**

**CDS205**

**Midterm Instructions**

**Posted March 12; Due Sunday March 27 end of day**

**Worth 20% of Grade, e.g., 4 Homeworks**

***Please submit your report on Blackboard as a Word document, with a file name as follows:*** 

**‘*your GMU username* CDS205 Spring 2022 Midterm.docx’*.***

Imagine you have been asked to prepare a short report on the expected effects of social distancing, masking, quarantining, and vaccination on a new pandemic. To assist you with preparing this report, you will use a new agent-based model that has just been created. The name of this model is ‘Vaccine\_Impact\_on\_Covid\_DSR’, which you should have downloaded along with this file. You have been asked to focus on the local area, with a time horizon of 1 year. Given the limitations of the model, you can ignore immigration to or emigration from the area, deaths from other causes, and births.

The current information you have is as follows:

- There are 10,000 people in the area.
- On average, each day people move around at a rate given as 75 out of 100 using a fancy measure of sociability.
- 10 persons are already infected with the disease.
- In the absence of vaccination or masking, the odds of an infected person transmitting the disease to a susceptible person when they meet, is, on average, 1 out of 4.
- A person can transmit the disease as soon as they are infected.
- Symptoms start to appear, on average, around 5 days, but no fewer than 2 days, after a person contracts the disease. At this point, if they are inclined to quarantine when sick, they will do so.
- The area has the capacity to treat up to 500 persons at a time.
- Once a person contracts the disease, the base case fatality rate for the disease is 1%. Any day when the number of people infected exceeds the treatment capacity, this actual fatality rate increases at an increasing rate as the number of people infected grows.
- The average length a person remains infected, and infectious, is, on average 14 days, but no fewer than 7 days.
- It is believed that persons have permanent immunity if they recover from the disease

**The first questions you have been asked to address, assuming no action is taken, are:**

- When can we expect the epidemic to reach a peak?
- What is the extent of the epidemic at its peak?

*(in presenting your results for the above two questions, be sure to be clear what indicator(s) you are using to define the peak of the infection)*

- How many people in our area can we expect to be infected over the course of the year?
- How many people in our area can we expect to die from the disease over the course of the year?

You have also been informed this about possible interventions:

- It is possible to influence individuals in terms of what share of the population social distances, wears masks, and quarantine if they do get infected.
  - An individual who social distances is effectively immune from getting the disease.
  - Masks reduce the odds of an infected person transmitting the disease to a susceptible person by 65%.
  - Infected persons who quarantine will not transmit the disease
- A vaccine is available, which will reduce the susceptibility of a non-infected person by 90%. It will take 30 days to reach whatever target share of the population you aim for, after which time you will not be able to get any more vaccine for another year.
- It is not possible, within a year to:
  - change any of the basic disease parameters
  - increase the treatment capacity in the area
  - reduce the sociability of those persons who do not social distance

**It is assumed that if you get everybody to distance, mask, quarantine if infected, and get a vaccination, the epidemic will burn out very quickly, with very few infections and deaths.**

- Does the model support this conclusion? Please explain.

**Of course, resources are not unlimited. Therefore, you also need to make recommendations about the different possible actions.**

- Assuming they are used individually, discuss how increasing the share of the population that distances, masks, quarantines if sick, or is vaccinated influences the effect of the epidemic.

*(In your discussion, be sure to use consistent measures to discuss the effects so that they are comparable across the interventions.)*

**The people who have requested this report are a bit risk-averse, and worry that some of the assumptions about the disease might be a bit optimistic. They realize that time is of the essence, though, so they realize a full sensitivity analysis is not possible at this time. They would, however, like you to explore the effect of altering at least one of the following assumptions – base-prob-of transmissibility, base-case-fatality-rate, base-recovery-time, or base-length-of-immunity.**

- Select one of these parameters to explore. Assume a value that is likely to make the epidemic worse, i.e., higher base-prob-of transmissibility, higher base-case-fatality-rate, longer base-recovery-time, or shorter base-length-of-immunity (if you choose base-length of immunity, do not select a value greater than 180). What does the model tell you is the effect of changing this parameter on the epidemic, both in the absence and presence of interventions?

**Report Guidelines**

In preparing your report:

- include your name and a date on the front page
- number all pages
- write approximately 1200 words of text outside of figures and tables
  - as much as possible, use full sentences rather than bullet points
- include appropriate figures and tables; make sure:
  - they are discussed/referred to somewhere in the text
  - they have captions and titles
  - table columns are clearly labeled and include units
  - figure axes are labeled and include units 
  - figure legends are included where necessary
- include a final page, with the heading “Details of Simulations Runs and Experiments”, identifying key parameter settings for individual simulations runs and/or BehaviorSpace experiments made; it should be possible to identify which runs were used in preparing your tables and figures
- no references or citations are needed

CDS205 Spring 2022 Midterm Instructions.docx		Page 3 of 3
