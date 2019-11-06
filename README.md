# ClimateGNSS

ClimateGNSS.jl is meant to support the transformation of GNSS Troposphere data (mainly Zenith Wet Delay) into standardized NetCDF formatting, and also has the side benefit of performing some minor analysis and density distribution estimates when enough data is available.

ClimateGNSS.jl currently supports the following data resources:
* Earth Observatory of Singapore
    - Data is processed using GIPSY by EOS-SG internally.  Please approach Dr. Lujia Feng (lfeng@ntu.edu.sg) for data.
    - Resort and analysis available

The following resources are currently in development in ClimateGNSS.jl:
* Nevada Geodetic Laboratory (both downloading and analysis)
    - Data is available online.  ClimateGNSS.jl is able to download GNSS data for a specified region using ClimateEasy.jl region specifications.
    - Resort and analysis available

If you would like other publicly available data resources to be included, please get in touch!

Author(s):
* Nathanael Zhixin Wong: nathanaelwong@fas.harvard.edu
