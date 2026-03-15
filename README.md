# Real-Time Fluid Property Estimation Using Sensor Data

This repository provides an overview of a university engineering project investigating whether fluid properties can be estimated from sensor measurements using machine learning techniques.

The project involved collecting motion and environmental sensor data from a rotating laboratory system and using statistical feature extraction together with regression models to estimate properties of fluid mixtures during operation.

Due to university data and intellectual property policies, the full source code and experimental datasets are not publicly available. The implementation is stored within the University of Warwick data storage system.

## Project Overview

The objective of the project was to explore whether sensor signals could be used to infer changes in fluid behaviour without relying on dedicated rheological instruments.

The system combined:

- multi-axis inertial sensor measurements

- statistical feature extraction

- machine learning regression models

- embedded data processing for live prediction

## Methods

Sensor measurements were processed using rolling time windows to extract statistical features such as mean, standard deviation and root mean square values. These features were used to train regression models capable of estimating the composition of glycerol–water mixtures.

Gaussian Process Regression was identified as the most suitable model for the dataset.

## Results

The trained model achieved a root mean square error of approximately 0.019 when predicting glycerol volume fraction from the extracted sensor features.

The approach demonstrated that sensor measurements from a compact laboratory system can be used to infer fluid properties during operation.

## Skills Demonstrated

- Python

- Machine learning (Gaussian Process Regression)

- signal processing

- feature engineering

- experimental data analysis

- embedded system integration

## Note

The implementation code and full dataset are stored internally within the University of Warwick storage system in accordance with university data management policies.
 
