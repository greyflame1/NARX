# NARX

Nonlinear ARX Project

This project is an attempt to implement a **nonlinear ARX (AutoRegressive with eXogenous inputs)** model in **MATLAB**.  
The code works, but the number of regressors is currently smaller than expected.  
The derived formula is incorrect because it does not generate combinations between the `y` (output) and `u` (input) terms.

To use the project, load the dataset **dateNARX.mat** in MATLAB.  
After running the script, an error plot will be displayed.  
The model corresponding to the **minimum validation error** should be selected.

---

## Usage


# 1. Clone the repository
```bash
git clone https://github.com/greyflame1/NARX.git
cd NARX
```
# 2. Open MATLAB, load the dataset, and run the main script
```bash
load('dateNARX.mat')
run('ProiectNARX.m')
