# Real-Time Fluid Property Estimation Using Sensor Data

This repository provides an overview of a university engineering project investigating whether fluid properties can be estimated from sensor measurements using machine learning techniques.

The project involved collecting motion and environmental sensor data from a rotating laboratory system and using statistical feature extraction together with regression models to estimate properties of fluid mixtures during operation.

This repository contains selected code, results and sample data from my individual project. Components developed by my supervisor, together with material restricted by university data and intellectual property policies, have been omitted. The repository is intended as a technical portfolio demonstrating my own methodology and contributions rather than as a complete reproducible release.

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

The regression model predicts glycerol volume fraction from the extracted sensor features. The predicted fraction, together with the measured temperature, is then converted into an estimated dynamic viscosity using the Cheng correlation. Therefore, viscosity is obtained through a subsequent physics-based calculation rather than being predicted directly by the machine-learning model.

## Results

The trained model achieved a root mean square error of approximately 0.019 when predicting glycerol volume fraction from the extracted sensor features.

The approach demonstrated that sensor measurements from a compact laboratory system can be used to infer fluid properties during operation.

## Limitations

Although the model performed well during offline validation, the real-time predictions were less stable. This was attributed partly to the mismatch between the 180-second experiments used to generate the training data and the 4-second rolling window used for live inference. Future improvements could include training on deployment-matched time windows, collecting a larger and more varied dataset, and using a longer stabilisation period or temporal smoothing.


## Skills Demonstrated

- Python

- Machine learning (Gaussian Process Regression)

- signal processing

- feature engineering

- experimental data analysis

- embedded system integration
 
