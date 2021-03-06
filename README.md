# Climate Data Tools
Climate Data Tools (CDT) is a  set of utility functions for meteorological data quality control, homogenization and merging station data with satellite and others proxies, all functions are  available in the GUI mode.

## Installation

### Step 1: Download and Install `R`

`CDT` is based on [R programming language](https://www.r-project.org/) a very powerful and freely available software environment for statistical computing and graphics. You can download and install the current version of `R` at [https://cran.r-project.org](https://cran.r-project.org).

### Step 2: Installing `R` packages

Open an `R` console and type:

```R
packages <- c('stringr','tkrplot','gmt','fields','latticeExtra','sp','maptools','gstat','automap','rgeos','reshape2','ncdf4','rgdal','foreach','doParallel')
install.packages(packages)
```
You are asked which repository `R` should use. Select your nearest site from the list of CRAN Mirrors.

### Step 3: Download and Install `Tcl/Tk`

`CDT` needs `Tcl/Tk` to work properly for the GUI part. The easiest way to get `Tcl/Tk` installed is via ActiveState's free ActiveTcl distribution, which includes precompiled versions of not only the core `Tcl/Tk`, but dozens of libraries. You can download ActiveTcl from ActiveState's websites [https://www.activestate.com/activetcl/downloads](https://www.activestate.com/activetcl/downloads).

Linux and Mac OS X: If you installed `Tcl/Tk` from the system's software manager. You have to install separately this two libraries: `Tktable` and `BWidget`.
You can download `Tktable` at [https://sourceforge.net/projects/tktable/files/tktable/2.10/](https://sourceforge.net/projects/tktable/files/tktable/2.10/) and `BWidget` at [https://sourceforge.net/projects/tcllib/files/BWidget/](https://sourceforge.net/projects/tcllib/files/BWidget/). If you use ActiveTcl for `Tcl/Tk`, you only need to specify the `Tktable`  and `BWidget` installation path.

### Step 4: Getting `CDT` Code

You can use Git to clone `CDT` repository on your local machine. 

```bash
# cd to the directory you want to put CDT
git clone https://github.com/rijaf/CDT.git
```
This will create a new directory CDT, containing a clone of CDT's GitHub repository. 

If you cannot use git, download [CDT zip file](https://github.com/rijaf/CDT/archive/master.zip) directly from Github , then unzip it somewhere in a directory you want.

### Step 5: Run `CDT`

Open an `R` console and type:

```R
source("/path_to/CDT/CDT.R")
# <path_to> is the full path of the directory where you put CDT
```
## Windows installation

 You can find [here](https://drive.google.com/drive/folders/0B47a4XJ9R4b6cVVycVVWTzZIMlk) all the resources needed and instruction to install `CDT` on Windows.

