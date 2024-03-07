# DPMA
A model-averaging approach for dynamic prediction of an event using multiple longitudinal markers
Dynamic event  prediction, using joint modeling of survival time and longitudinal variables, is extremely useful in personalized medicine. However, the estimation of joint models including many longitudinal markers is still a computational challenge because of the high number of random effects and parameters to be estimated. We propose a model averaging strategy to combine predictions from several joint models for the event, including one longitudinal marker only or pairwise longitudinal markers. The prediction is computed as the weighted mean of the predictions from the one-marker or two-marker  models, with the time-dependent weights estimated by minimizing the time-dependent Brier score. This method enables us to combine a large number of predictions issued from joint models to achieve a reliable and accurate individual prediction.

### Installation

To obtain the latest development version of DPMA, you can use the following code snippet to install it directly from GitHub:

``` 

# install.packages("devtools") 

devtools::install_github("tbaghfalaki/DPMA")

```

This will effortlessly fetch and install the most up-to-date version of DPMA for your use.

## References: 
Reza Hashemi, Taban Baghfalaki, Viviane Philipps and Helene Jacqmin-Gadda (2024). Dynamic prediction of an event using multiple longitudinal markers: a model averaging approach, Statistics in Medicine.



