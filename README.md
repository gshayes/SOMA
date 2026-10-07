# Second Order Meta Analysis

This repository supports the `SOMA` package which contains functions that perform Second Order Meta Analysis (SOMA). This package accompanies *Methods for Second Order Meta-Analysis*, a paper currently under review and authored by Larry V. Hedges, Gracie Hayes, and Paul Witte. The `SOMA` package enables researchers to apply the proposed methods to their own data.

# `R` Package

Anyone interested in performing SOMA by using our functions may use the code found in the `functions.R` script in the `R` folder, or download and install the `SOMA` package by running `devtools::install_github("gshayes/SOMA")`. The package includes two functions: - `somaf` which performs fixed effects second order meta analysis - `somar` which performs random effects second order meta analysis Annotation in the `functions.R` script explains each function's steps and references specific equations in *Methods for Second Order Meta-Analysis*.

# Empirical Example

The `empirical-example` folder contains the code, workbook, and analysis needed to review or run the empirical example included in the manuscript. Please view the folder's [README](empirical-example/README.md) for more details.

# Status

The accompanying manuscript is currently under review for journal publication. Code and documentation may continue to evolve during the review process. Reach out to Gracie Hayes with any questions about this repository ([gshayes\@u.northwestern.edu](mailto:gshayes@u.northwestern.edu)).
