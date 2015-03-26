##ParseAscFile
ParseAscFile return all parsed parameters as a named list

For example, accessing to posix object in date.time is like: $date.time[['posix']]


##$date.time
Date and time of analysis (*named list*)
- **date**: date (e.g. )
- **time**: time with (e.g. 01:31 PM)
- **posix**: posix object (e.g. 1400234234)

##$file.names
s file and condition file names (*named list*)
- **acquisition**: .ais file (binary file)
- **condition**: .dis file

##$description
comment for the analysis spot (*string*)

##$position
x-y coordinates of SIMS stage (*named list*)
- **x**: x coordinates
- **y**: y coordinates

##$params
Various parameters for the analysis (*named list*)
Parameters from the sections 'ANALYTICAL PARAMETERS', 'CORRECTION FACTORS FOR RATIOS COMPUTATION' and 'ACQUISITION CONTROL PARAMETERS' in .asc file

- ** SAMPLE NAME ** : sample name
- ** SAMPLE HV (v) ** : applied high voltage to the sample
- ** Field _App. (um) ** : size of field aperture
- ** Entr._Slit (um) ** : entrance slit width
- ** Exit_Slit (um) ** : exit slit width for axial detectors
- ** Energ._Slit (eV) ** : energy slit width
- ** Raster_Size (um) ** : raster size
- ** Cont. Aperture (um) ** : contrast aperture size
- ** ESA inner (V) ** : inner ESA voltage
- ** ESA outter V) ** : outer ESA voltage ('V)' is correct)
- ** Max Area (optical gate coef= 100%) (um) ** : max area size (zooming factor)
- ** MRP(mono) ** : mass resolution power (MRP) for axial detectors
- ** Sec.Anal.pressure (mb) ** : pressure of Analysis chamber
- ** Gate DTOS ** : Gate DTOS
- ** Ip Sampling Gate(%) ** : Ip sampling gate parcent
- ** Egate ON/OFF ** : Egate (OFF = 0)
- ** Egate(%) ** : Egate parcent
- ** PRIMARY Ion Specie ** : species of primary beam (O|Cs)
- ** Primary HV (kV) ** : applied high voltage for primary beam
- ** PBMF Aperture (um) ** : mass aperture size
- ** Duo. pressure (mbar) ** : pressure of duo source
- ** L4 Aperture (um) ** : beam aperture size
- ** Yield ** : yield correction (APPLYED/NOT APPLYED)
- ** Background ** : background correction (APPLYED/NOT APPLYED)
- ** Dead Time (gate coef=1.0000) ** :dead time correction (APPLYED/NOT APPLYED)
- ** Linear Drift ** : linear drift correction (APPLYED/NOT APPLYED)
- ** Ems Drift ** : electron multiplier drift correction (APPLYED/NOT APPLYED)
- ** Ip Normalize ** : normalization by primary beam intensity (APPLYED/NOT APPLYED)
- ** Pre-sputtering ** : pre-sputtering (SELECTED/NOT SELECTED)
- ** Reference Signal ** : reference signal (SELECTED/NOT SELECTED)
- ** Mass Calibration Contro ** : (SELECTED/NOT SELECTED)
- ** Energy Control ** : (SELECTED/NOT SELECTED)
- ** Overlapping Crater ** : (SELECTED/NOT SELECTED)
- ** Ems Drift Control ** : (SELECTED/NOT SELECTED)
- ** Beam Centering ** : secondary beam cetering (SELECTED/NOT SELECTED)
- ** Ip control ** :  (SELECTED/NOT SELECTED)
- ** Sputter Time (s) ** : pre-sputtering time
- ** Raster size start (um) ** : raster size at start
- ** Raster size end (um) ** : raster size at end
- ** Ip preset start ** : used primary beam preset at start (Current)
- ** Ip preset end ** : used primary beam preset at end (Current)


##$detector.params
Detector paramers (*data frame*)

|         |Yield|Bkg(c/s)|DT(ns)|Slit Size(um)|EM HV|Threshold|Quad multi|ESA out|ESA in|Rep a|Rep b|
|---------|-----|--------|------|-------------|-----|---------|----------|-------|------|-----|-----|
| **L'2** |[1, 1]|[1, 2]|[1, 3]|[1, 4]|[1, 5]|[1, 6]|[1, 7]|[1, 8]|[1, 9]|[1, 10]|[1, 11]|
| **L2**  |[2, 1]|[2, 2]|[2, 3]|[2, 4]|[2, 5]|[2, 6]|[2, 7]|[2, 8]|[2, 9]|[2, 10]|[2, 11]|
| **L1**  |[3, 1]|[3, 2]|[3, 3]|[3, 4]|[3, 5]|[3, 6]|[3, 7]|[3, 8]|[3, 9]|[3, 10]|[3, 11]|
| **C**   |[4, 1]|[4, 2]|[4, 3]|[4, 4]|[4, 5]|[4, 6]|[4, 7]|[4, 8]|[4, 9]|[4, 10]|[4, 11]|
| **H1**  |[5, 1]|[5, 2]|[5, 3]|[5, 4]|[5, 5]|[5, 6]|[5, 7]|[5, 8]|[5, 9]|[5, 10]|[5, 11]|
| **H2**  |[6, 1]|[6, 2]|[6, 3]|[6, 4]|[6, 5]|[6, 6]|[6, 7]|[6, 8]|[6, 9]|[6, 10]|[6, 11]|
| **H'2** |[6, 1]|[6, 2]|[6, 3]|[6, 4]|[6, 5]|[6, 6]|[6, 7]|[6, 8]|[6, 9]|[6, 10]|[6, 11]|
| **FC1** |[7, 1]|[7, 2]|[7, 3]|[7, 4]|[7, 5]|[7, 6]|[7, 7]|[7, 8]|[7, 9]|[7, 10]|[7, 11]|
| **EM**  |[8, 1]|[8, 2]|[8, 3]|[8, 4]|[8, 5]|[8, 6]|[8, 7]|[8, 8]|[8, 9]|[8, 10]|[8, 11]|
| **FC2** |[9, 1]|[9, 2]|[9, 3]|[9, 4]|[9, 5]|[9, 6]|[9, 7]|[9, 8]|[9, 9]|[9, 10]|[9, 11]|


##$cumurated.result
Statistics of the analysis (*data frame*)

|        |Mean value|Std. dev. (STDE)|Std Err. mean(%)|Poisson (%)|Rejected #|Integrated mean|Delta Value(permil)|QSA corrected Mean|
|---------------------------------------------------------------------------------------------------------------------------|
| **R0** |[1, 1]|	[1, 2]|	[1, 3]|	[1, 4]|	[1, 5]|	[1, 6]|	[1, 7]|	[1, 8]|
| **R1** |[2, 1]|	[2, 2]|	[2, 3]|	[2, 4]|	[2, 5]|	[2, 6]|	[2, 7]|	[2, 8]|
| **R2** |[3, 1]|	[3, 2]|	[3, 3]|	[3, 4]|	[3, 5]|	[3, 6]|	[3, 7]|	[3, 8]|
| **Rx** |[x+1, 1]|	[x+1, 2]|	[x+1, 3]|	[x+1, 4]|	[x+1, 5]|	[x+1, 6]|	[x+1, 7]|	[x+1, 8]|

##$beam.centering
Beam centering parameters (*named list*)

If beam centering wasn't carried out, return FALSE

|                        |Selected|Scan-Range|resultX|resultY|
|------------------------|--------|----------|-------|-------|
| **Field App (DT1)**    |[1, 1]|[1, 2]|[1, 3]|[1, 4]|
| **Entrance Slits**     |[2, 1]|[2, 2]|[2, 3]|[2, 4]|
| **Contrast Apperture** |[3, 1]|[3, 2]|[3, 3]|[3, 4]|

##$isotopic.ratio
Definitions of isotope ratios (*named list*)
- **R0**: ratio definition for R0
- **R1**: ratio definition for R1
- **R2**: ratio definition for R2
* …
- **Rx**: ratio definition for Rx

##$primary.beam
Primary beam intensities (*named list*)
- **start**: primary beam intensity at the beginning of analysis
- **end**: primary beam intensity at the end of analysis
- **average**: average of start and end primary beam intensities
- **diff**: difference from beginning to end of analyses in permil

##$block.number
Block number of analysis (*numeric*)

##$cycle.number
Total cycle number (*numeric*)

##$cps
Count par second data for each cycle with time (s) from beginning (*data frame*)

(e.g. oxygen 2 isotope analysis with OH)

||N.Block|N.Cycle|16O|16O 1H|18O|Time|
|--------|
|1|[1, 1]|[1, 2]|[1, 3]|[1, 4]|[1, 5]|[1, 6]|
|2|[2, 1]|[2, 2]|[2, 3]|[2, 4]|[2, 5]|[2, 6]|
|3|[3, 1]|[3, 2]|[3, 3]|[3, 4]|[3, 5]|[3, 6]|
|4|[4, 1]|[4, 2]|[4, 3]|[4, 4]|[4, 5]|[4, 6]|
|5|[5, 1]|[5, 2]|[5, 3]|[5, 4]|[5, 5]|[5, 6]|
|x|[x, 1]|[x, 2]|[x, 3]|[x, 4]|[x, 5]|[x, 6]|
