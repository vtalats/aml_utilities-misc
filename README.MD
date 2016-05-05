# Miscellaneous Utilities

The following utilities provide various helper functions to import, export, and print various file and data types.  A general description and usage is given for each of the functions below.

***

## `bode_plot.m`
### Usage
```MATLAB
  [H, w] = bode_plt( A, B, C, D, E, w0, wf, np, plt_opt);
```
### Description
Computes the Bode plot for the frequency response of a system

### Inputs:
* A,B,C,D,E - system matrices
* w0 - log_10 of the starting frequency (default = -4)
* wf - log_10 of the ending frequency (default = 4)
* np - number of points to plot (default = 100)
* plt_opt - plot options

### Outputs:
* H - value at plot point frequencies iw
* w - plot point frequency values for iw
  
***

## `cplot.m`
### Usage
```MATLAB
[ plt ] = cplot( c, opts, fig );
```

### Description
Given a vector of complex numbers, `c`, this function will plot them on
the complex plane.  You may specify the point type and color in the
options.

### Inputs:
* c - vector of complex number.  Matrices are vectorized prior to plotting
* opts - optional plot color and style options.  If not given, then the plot
         is colorized according to eigenvalue stability for an ODE, i.e. stable -
         blue circles, unstable - red asterisks
* fig - optional figure to plot to

### Outputs:
  * plt - figure number for the plot

***

## `export_tex_tbl.m`
### Usage
```MATLAB
export_tex_tbl( data, data_fmt, tex_file, hdr_labels, caption, tbl_name, tstyle )
```
**Example Usage**
Let A be a 3x20 matrix of floats where the first 2 columns are output
data and the third column is the error.  Suppose we would like to
output the first 2 columns as decimals and the last column in an
exponential notation.  Next we want the headers to be **Output 1**,
**Output 2** and **Rel Error**.  We would like to save this to the file
`outdata.tex` in the subdirectory `tex_files`. (This directory needs to
exist prior to calling this function.)  

```MATLAB
data_fmt = {'%6.2f', '%6.2f', '%5.3e'};
tex_file_name = './tex_files/outdata.tex';
hdr_labels = {'Output 1', 'Output 2', 'Rel Error'};
tbl_caption = 'This is a table that was created in Matlab.'
tbl_name = 'out_mat'
export_tex_tbl(A, data_fmt, tex_file_name, hdr_labels, tbl_caption, tbl_name, 'std' )
```

### Description
This function takes a matrix and outputs the data into a tex file that
can be imported or sourced into another Latex file.

### Inputs:
* data       : data to be output to a table
* data_fmt   : Cell array of data formats or a string to use for all the data (defualt => '%f')
* tex_file   : file name of where to store data (default => 'data.tex')
* hdr_labels : Cell array of column header labels (defualt => no labels)
* caption    : Table caption (default => 'Matlab Data')
* tbl_name   : Table label (default => 'data').  Labels are formed as
*              'tab:tbl_name'
* tstyle     : Use 'std' or 'booktab' style (default => 'std')

### Outputs:
* None

***

## `import_big_fluent.m`
### Usage
```MATLAB
[ x, e_conn, u, v, w, timesteps ] = import_fluent( data_prefix, mesh_file, get_mesh, loglevel )
```

### Description
Imports mesh and velocity data from multiple tecplot360 files where the mesh and data files are separate.
These tecplot360 files contain data generated from fluent.  
Assumes ONE ZONE and finite element data types:
* FETriangle 
* FETetrahedron
* FEQuadrilateral
   
### Inputs:
* data_prefix - file name prefix for data files being imported - e.g. data_name_ would import the files `data_name_*.dat`
* mesh_file - file name for the data file containing the mesh
* get_mesh - flag to indicate whether to import mesh data:
  * 0 - data only
  * 1 - mesh only
  * 2 - mesh and data (default)
* loglevel - default is 2, set to 99 for maximum logging

### Outputs:
* x         - node points
* e_conn    - node connection matrix
* u,v,w     - velocity
* timesteps - array containing solution times

### Dependencies
* `@Msgcls`
* `read_tecplot360data.m`
* `read_tecplot360mesh.m`

***

## `read_tecplot360.m`
### Usage
```MATLAB
[x,e_conn,data,variables,soln_time] = read_tecplot(tecplot_file)
```

### Description
A MATLAB function that reads in a TecPlot file and extracts nodes, connectivity as well as data variables.
Assumes ONE ZONE and finite element data types:
* FETriangle 
* FETetrahedron
* FEQuadrilateral

### Inputs:
* tecplot_file - name of the input file

### Outputs:
* x - points in the domain
* e_conn - connectivity matrix
* data - a n_nodes x n_variables array containing the finite element data
* variables - names of the variables
* soln_time - array containing solution times

***

## `read_tecplot360data.m`
### Usage
```MATLAB
[x,e_conn] = read_tecplot360mesh(tecplot_file,lf)
```

### Description
A MATLAB function that reads a TecPlot file and extracts the mesh information (nodes and connectivity).

### Inputs:
* tecplot_file - name of the input TecPlot file
* lf - logfile instance 

### Outputs:
* x - points in the domain
* e_conn - connectivity matrix

### Dependencies
* @Msgcls

***

## `read_tecplot360mesh.m`
### Usage
```MATLAB
[data,variables,soln_time] = read_tecplot360data(tecplot_file,lf)
```

### Description
A MATLAB function that reads a TecPlot file and extracts the data information.

### Inputs:
* tecplot_file - name of the input TecPlot file
* lf - logfile instance 

### Outputs:
* data - a n_nodes x n_variables array containing the finite element data
* variables - names of the variables
* soln_time - array containing solution times

### Dependencies
* @Msgcls

***

## `setpltdef.m`
### Usage
```MATLAB
setpltdef
```

### Description
Sets the MATLAB plot font and line sizes to more readable sizes.

### Inputs:
  * None

### Outputs:
  * None

***

## `zplot.m`
### Usage
```MATLAB
zplot( z, opts )
```

### Description
Plots the complex numbers given by the matrix `z` on a complex plane with the unit circle.

### Inputs:
  * z - complex numbers to plot
  * opts - plot options for color and style.  If blank then the complex numbers are plotted as blue circles inside
           the unit disk and red asterisks otherwise.  This correlates to stable/unstable eigenvalues
           for a discrete time dynamical system.

### Outputs:
  * None

***

