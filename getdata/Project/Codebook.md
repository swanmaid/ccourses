Codebook
========
See `README.md` or `README.html` for details on dataset creation.

Variable list and descriptions
------------------------------

Variable name    | Description
-----------------|------------
subject          | ID the subject who performed the activity for each window sample. Its range is from 1 to 30.
activity         | Activity name
featureDomain       | Feature: Time domain signal or frequency domain signal (Time or Frequency)
featureInstrument   | Feature: Measuring instrument (Accelerometer or Gyroscope)
featureAcceleration | Feature: Acceleration signal (Body or Gravity)
featureMeasure    | Feature: Measure (Mean or SD)
featureJerk         | Feature: Jerk signal
featureMagnitude    | Feature: Magnitude of the signals calculated using the Euclidean norm
featureAxis         | Feature: 3-axial signals in the X, Y and Z directions (X, Y, or Z)
count        | Feature: Count of data points used to compute `average`
average      | Feature: Average of each variable for each activity and each subject

Dataset structure
-----------------

```{r}
str(tidyset)
```

List the key variables in the data table
----------------------------------------

```{r}
key(tidyset)
```

Show a few rows of the dataset
------------------------------

```{r}
tidyset
```

Summary of variables
--------------------

```{r}
summary(tidyset)
```

List all possible combinations of features
------------------------------------------

```{r}
tidyset[, .N, by=c(names(tidyset)[grep("^feature", names(tidyset))])]
```

Save to file
------------

Save data table objects to a tab-delimited text file called `DatasetHumanActivityRecognitionUsingSmartphones.txt`.

```{r}
f <- file.path(path, "HumanActivityRecognitionUsingSmartphonesDataset.txt")
write.table(tidyset, f, quote=FALSE, sep="\t", row.names=FALSE)
```