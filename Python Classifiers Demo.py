#Sample Demonstration using IRIS dataset
#Feature Scaling, K-Nearest Neighbors (K-NN), Decision Tree, Random Forest
#Confusion Matrix, Classification Report & Accuracy Score
#Don't execute all Classifiers at a time
#Last_Update_Date: Apr/07/2020

#Importing the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

#Importing the dataset
dataset = sns.load_dataset('iris')
dataset.head(10)
X = dataset.iloc[:, [2,3]].values
y = dataset.iloc[:, 4].values

#Displaying data set stored in array
X
y 

#Splitting the dataset into the Training set and Test set
#from sklearn.cross_validation import train_test_split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.25, random_state = 0)
#X_train - My actual data set
#X_test  - My test data set

len(X)
len(X_train) #Should be 25% of X
len(X_test)  #Should be 75% of X
len(y)

#Feature Scaling using StandardScaler Technique
#Standardize features by removing the mean and scaling to unit variance
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)

#Output after Feature Scaling
X_train 
X_test

#Fitting K-NN to the Training set
from sklearn.neighbors import KNeighborsClassifier
classifier = KNeighborsClassifier(n_neighbors = 4, metric = 'minkowski', p = 2) #Passing hyper paremeters
classifier.fit(X_train, y_train)


#Fitting Decision Tree to the Training set
from sklearn.tree import DecisionTreeClassifier
classifier = DecisionTreeClassifier() #No hyper paremeters are needed
classifier.fit(X_train, y_train)


#Fitting Random Forest to the Training set
from sklearn.ensemble import RandomForestClassifier
classifier = RandomForestClassifier(n_estimators = 500) #Passing hyper paremeters are needed
classifier.fit(X_train, y_train)


#Predicting the Test set
y_pred = classifier.predict(X_test)

#Testing part
#Comparing y_pred which is generated from X_test data_set vs actual data_set i.e. y_test
from sklearn.metrics import confusion_matrix, classification_report, accuracy_score
cm_result = confusion_matrix(y_test, y_pred)
print('Confusion Matrix')
print(cm_result)

cr_result = classification_report(y_test, y_pred)
print('Classification Report')
print(cr_result)

as_result = accuracy_score(y_test, y_pred)
print('Accuracy: ', as_result)