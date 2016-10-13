/* This is an example HY-PHY Batch File.   It reads a '#' nucleotide dataset data/actin2.flt, parititions   the data into two blocks - each third nucleotide position   and the rest. We then apply HKY85 to the 1st partition and   F81 to the 2nd.         Output is printed out as a Newick Style tree with branch lengths   representing the number of expected substitutions per branch (which   is the default setting for nucleotide models w/o rate variation).   Also, the likelihood ratio statistic is evaluated and the P-value   for the test is reported.      Sergei L. Kosakovsky Pond and Spencer V. Muse    December 1999. *//* 1. Read in the data and store the result in  DataSet variables.	  The variable nuclotideSequence.sites holds the number of sites	  in the data set. */DataSet 		nucleotideSequence = ReadDataFile ("data/actin2.flt");   /* 2. Filter the data. 	  "<001>" defines a comb of size 3, choosing the 3rd element of each triplet	  "<110>" defines a comb of size 3, choosing the 1st and 2nd elements of each triplet */	    DataSetFilter	filteredData1 	= CreateFilter (nucleotideSequence,1,"<001>");DataSetFilter	filteredData2 	= CreateFilter (nucleotideSequence,1,"<110>");/* 3. Collect observed nucleotide frequencies from the filtered data. observedFreqs will	  store the vector of frequencies. */HarvestFrequencies (observedFreqs1, filteredData1, 1, 1, 1);HarvestFrequencies (observedFreqs2, filteredData2, 1, 1, 1);/* 4. Define the HKY85 substitution matrix. '*' is defined to be -(sum of off-diag row elements) */HKY85RateMatrix = 		{{*,trvs,trst,trvs}		 {trvs,*,trvs,trst}		 {trst,trvs,*,trvs}		 {trvs,trst,trvs,*}};		 		 F81RateMatrix = 		{{*,mu,mu,mu}		 {mu,*,mu,mu}		 {mu,mu,*,mu}		 {mu,mu,mu,*}};/*5.  Define the models.*/Model 	HKY85 = (HKY85RateMatrix, observedFreqs1);Model 	F81 =   (F81RateMatrix, observedFreqs2);/*6.  Define 2 trees, one for each block. Even though the topology is the same,	  the trees will have separate branch parameters for each partition.*/UseModel (HKY85);Tree	actinTree1 = (ZMU60513,ZMU60514,((((((ZMU60511,ZMU60510),OSRAC2),(OSRAC1,SVSOAC1)),((OSRAC3,ZMU60507),ZMU60509)),(MZEACT1G,OSRAC7)),ZMU60508));UseModel (F81);Tree	actinTree2 = (ZMU60513,ZMU60514,((((((ZMU60511,ZMU60510),OSRAC2),(OSRAC1,SVSOAC1)),((OSRAC3,ZMU60507),ZMU60509)),(MZEACT1G,OSRAC7)),ZMU60508));/*7. 	Set up the likelihood function, maximize, print results */LikelihoodFunction  theLnLik = (filteredData1, actinTree1,                                  filteredData2, actinTree2);Optimize (paramValues, theLnLik);fprintf  (stdout, "\n ----- RESULTS ----- \n", theLnLik);