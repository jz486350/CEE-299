# CEE-299

This repository contains the minimum required input files to run (1) the initial household income estimation given purchase time and date and (2) the adjusted household income from original time of purchase to current.

Edit only **input_bldg.xlsx** and populate columns 1 & 2 with transaction data. Column 3 can be ignored if census tract information is not available. Column 4 can be left as a ones vector if all units are single-family. **DO NOT EDIT ANY OTHER INPUT FILES.**

After formatting the **input_bldg.xlsx**, run **HH_mortgage.m** first, and then **HH_adjust.m** to get final adjusted household income vector.
