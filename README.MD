# Miscellaneous Utilities
The following utilities provide various helper functions to import, export, and print various file and data types.  A general description and usage is given for each of the functions below.

## `bode_plot.m`
### Usage
```MATLAB
  [H, w] = bode_plt( A, B, C, D, E, w0, wf, np, plt_opt);
```
### Description
Computes the Bode plot for the frequency response of a system

Inputs:
  * A,B,C,D,E - system matrices
  * w0 - log_10 of the starting frequency (default = -4)
  * wf - log_10 of the ending frequency (default = 4)
  * np - number of points to plot (default = 100)
  * plt_opt - plot options

Outputs:
  * H - value at plot point frequencies iw
  * w - plot point frequency values for iw


