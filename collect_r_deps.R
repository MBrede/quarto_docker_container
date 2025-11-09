#!/usr/bin/env Rscript

collect_r_packages <- function() {
    if (!requireNamespace("stringr", quietly = TRUE)) {
        install.packages("stringr", Ncpus = 6)
    }
    
    candidates <- list.files(recursive = TRUE, pattern = "\\.(qmd|R|r|Rmd|rmd)$", full.names = TRUE)
    
    extract_packages <- function(file_name){
        tryCatch({
            readLines(file_name, warn = FALSE) |>
                paste0(collapse = "\n") |>
                stringr::str_extract_all("([[:alnum:]._]+(?=::))|((?<=library\\()[[:alnum:]._]+)|((?<=require\\()[[:alnum:]._]+)") |>
                unlist()
        }, error = function(e) {
            message("Warning: Could not read ", file_name)
            character(0)
        })
    }
    
    pkgs <- lapply(candidates, extract_packages) |>
        unlist()
    
    if (file.exists("DESCRIPTION")) {
        desc <- read.dcf("DESCRIPTION")
        if ("Imports" %in% colnames(desc)) {
            desc_pkgs <- unlist(strsplit(desc[1, "Imports"], "\n"))
            pkgs <- c(pkgs, desc_pkgs)
        }
    }
    
    pkgs <- trimws(pkgs) |>
        unique() |>
        setdiff(c("", "base", "stats", "graphics", "grDevices", "utils", "datasets", "methods"))
    
    message("Found R packages: ", paste(sort(pkgs), collapse = ", "))
    
    for (pkg in pkgs) {
        if (!requireNamespace(pkg, quietly = TRUE)) {
            message("Installing: ", pkg)
            install.packages(pkg, Ncpus = 6)
        }
    }
}

collect_r_packages()
