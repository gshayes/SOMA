# Reproduce the SOMA empirical example

This folder reproduces the empirical application in *Methods for Second Order Meta Analysis*: Tables 3–5 and Supplementary Appendices S2–S3.

## The four files

- **analysis.Rmd** — the complete executable analysis, including the statistical functions and 20 validation checks.
- **workbook_original.xlsx** — the original input workbook, unchanged.
- **analysis.html** — the rendered report, including the expected results and full session information at the end. Download and open it in a browser to read it without running R.
- **README.md** — these instructions.

Keep all four files together in one folder. The analysis uses only the workbook as data input; it does not read results from the HTML. No separate scripts or installation of the SOMA package are needed.

## Run the example

1. Download and **extract** the files. Use R with RStudio.
2. Install these packages once by running this command in the R console:

   ```r
   install.packages(c(
     "dplyr", "tidyr", "purrr", "stringr", "readr", "readxl",
     "tibble", "knitr", "rmarkdown", "metafor", "stringi"
   ))
   ```

3. Open **analysis.Rmd** in RStudio and click **Knit**.

Alternatively, set the R working directory to the folder containing the files and run:

```r
rmarkdown::render("analysis.Rmd")
```

Pandoc is required for rendering and is normally supplied with RStudio. Outside RStudio, set `RSTUDIO_PANDOC` to the directory containing your Pandoc executable if it is not detected.

Successful execution regenerates **analysis.html** and ends with **“All validation checks passed.”** It also creates an `outputs` folder containing CSV tables and session records. These are generated results, not additional files you need to download or upload. Re-running replaces the generated report and outputs, not the workbook.

## Verification and scope

Prepared on 6 October 2026 and tested in fresh R processes on Windows 11 with R 4.5.2 and Pandoc 3.10. The full R/package session record is included in the supplied HTML. Package installation on a newly provisioned computer and other operating systems were not tested.

All 20 embedded checks passed. All 34 substantive tables matched the previously submitted HTML, including 2,587 displayed cells (headers, labels and numeric entries). The 16 regenerated CSV tables also matched the previously verified unrounded results. The four-file ZIP was extracted into a new folder and tested without the larger preparation bundle's supporting files.

The workbook, study-reconciliation decisions, estimation functions and numerical results are unchanged. Reproducibility adjustments make paths local to this folder, preserve accented names and study-ID ordering, and correct a Table 5 validation condition so it checks both missingness and numeric values. These adjustments change the checks and portability, not the estimates.

This deposit covers the empirical example. It does not include the simulation study or test the current implementation of the separate SOMA R package. Exact reproduction is not an independent scientific validation of the input data or statistical assumptions.
