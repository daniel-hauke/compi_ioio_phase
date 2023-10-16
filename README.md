Aberrant perception of environmental volatility in emerging psychosis
===============
Code pertaining to the computational modelling analysis for the paper: 

"Aberrant perception of environmental volatility in emerging psychosis"

Hauke, Wobmann, Andreou, Mackintosh, de Bock, Karvelis, Adams, Sterzer, Borgwardt, Roth, & Diaconescu (2022)


Members of the project
---------------
- Supervision: Andreea O. Diaconescu, Daniel J. Hauke
- Sponsor: Andreea O. Diaconescu
- Contributors: Michelle Wobmann, Christina Andreou, Amatya Mackintosh, Renate de Bock, Povilas Karvelis, Rick A. Adams, Philipp Sterzer, Stefan Borgwardt, Volker Roth
- Tester for Reproducible Research: Povilas Karvelis


Project description
---------------
Behavior of 56 participants (3 Groups: Healthy controls, Individuals at clinical high risk for psychosis, and first-episode psychosis patients) was assessed during a social learning task and modelled to investigate the computational mechanisms underlying paranoid delusions in early psychosis.



Getting Started (General)
---------------
1.  Please, clone this repository. You can do so using the following command:
```
git clone https://github.com/daniel-hauke/compi_ioio_phase.git
```

Downloading the data
---------------
1.  Please, download the data from: https://osf.io/6rdjc/
2.  Copy the data into the compi_ioio_phase folder using the following structure:
```
compi_ioio_phase
   |-- code
   |-- data   
      |-- clinical    
         |-- clinical.xlsx         
      |-- ioio      
         |-- COMPI_0001_data.mat        
         |-- COMPI_0002_data.mat        
         |-- ...
```

Running modelling pipeline in MATLAB
---------------
The models were implemented in Matlab (version: 2017a; https://mathworks.com) using the HGF toolbox (version: 3.0), which is made available as open-source code as part of the TAPAS (Frässle et al., 2021) software collection (https://github.com/translationalneuromodeling/tapas/releases/tag/v3.0.0) and the VBA toolbox (Daunizeau et al., 2014) (https://mbb-team.github.io/VBA-toolbox/). To ensure future reproducibility TAPAS and VBA functions are included in this repository.

Please, make sure that you have Matlab 2017a up and running. 

1. Open Matlab and navigate to the compi_ioio_phase folder.
2. Run the `'compi_ioio_phase'` script from inside(!) this folder.
3. Results figures shown in the paper will be saved in the compi_ioio_phase/results/figures_paper subfolder.


Running statistics in R (requires running modelling first)
---------------
The statistics were run in R (version: 4.04; https://www.r-project.org/) using R-Studio (version: 1.4.1106; https:
//www.rstudio.com/). Please, make sure that you have R up and running.

1. Open R and navigate to the compi_ioio_phase folder.
2. In all 4 statistic scripts located in the compi_ioio_phase/code/statistics subfolder set ```root_project = "path to project on your computer"```.
3. Run statistic scripts.
4. Results figures shown in the paper will be saved in the compi_ioio_phase/results/figures_paper subfolder.

Acknowledgements
------------
We thank the participants for volunteering their energy and valuable time despite all the challenges they faced allowing us to pursue this research and the Schizophrenia International Research Society for honoring this work with the best poster price at the 2022 Congress of the Schizophrenia International Research Society. Furthermore, we thank Povilas Karvelis for volunteering his time to test this code.

