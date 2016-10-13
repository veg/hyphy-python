/* This is an example HY-PHY Batch File.   It reads a 13 taxa dataset "data/hiv.nuc", performs   an HKY85 with gamma rate heterogeneity ML analysis on the data using the tree from the file.   Having finished that, the code simulates a data set with rate heterogeneity and   demonstrates how to access simulated rate distribution at sites.   Sergei L. Kosakovsky Pond and Spencer V. Muse    May 2002. *//* 1. Read in the data and store the result in a DataSet variable.*/DataSet 		nucleotideSequences = ReadDataFile ("data/hiv.nuc");   /* 2. Filter the data, specifying that all of the data is to be used	  and that it is to be treated as nucleotides.*/DataSetFilter	filteredData = CreateFilter (nucleotideSequences,1);/* 3. Collect observed nucleotide frequencies from the filtered data. observedFreqs will	  store the vector of frequencies. */HarvestFrequencies (observedFreqs, filteredData, 1, 1, 1);/* 4. Define the HKY+Gamma substitution matrix. '*' is defined to be -(sum of off-diag row elements).*/global alpha = .5;alpha:>0.01;alpha:<100;category c = (4, EQUAL, MEAN, 				GammaDist(_x_,alpha,alpha), 				CGammaDist(_x_,alpha,alpha), 				0 , 		  	    1e25,		  	    CGammaDist(_x_,alpha+1,alpha)		  	 );		  	 global		kappa = 1; /* transversion/transition ratio */HKY85RateMatrix = 		{{*,c*t*kappa,c*t,c*t*kappa}		 {c*t*kappa,*,c*t*kappa,c*t}		 {c*t,c*t*kappa,*,c*t*kappa}		 {c*t*kappa,c*t,c*t*kappa,*}};		 /*5.  Define the HKY85 model, by combining the substitution matrix with the vector of observed (equilibrium)	  frequencies. */Model HKY85	 = (HKY85RateMatrix, observedFreqs);/*6.  Now we can define the tree variable, using the tree string read from the data file,	  and, by default, assigning the last defined model (HKY85) to all tree branches. */	  Tree	givenTree = DATAFILE_TREE;/*7.  Since all the likelihood function ingredients (data, tree, equilibrium frequencies)	  have been defined we are ready to construct the likelihood function. */	  LikelihoodFunction  theLnLik = (filteredData, givenTree);/*8.  Maximize the likelihood function, storing parameter values in the matrix paramValues */Optimize (paramValues, theLnLik);/*9.  Print the tree with optimal branch lengths to the console. */fprintf  (stdout, "\n----ORIGINAL DATA----\n",theLnLik);		 /*10. Now we set up the simulation loop.	  First, we create another copy of the tree which will	  serve as the tree for simulated data sets */	  Tree	simulatedTree = DATAFILE_TREE;/*12. By default, the random generator is reset every time the program is run.	  The value of the seed is stored in RANDOM_SEED.	  If you wish to use a particular seed, say the repeat a simulation,	  call the function SetParameter (RANDOM_SEED,value,0).*//*SetParameter (RANDOM_SEED,12345,0);*/fprintf (stdout, "\nUsing the seed:\n", Format(RANDOM_SEED,10,0));/*12. Simulating the dataset and storing category (c) variable	  values in the row vector ratesAtSites, and the name of the category	  variable in the column vector namesOfRateVars. This is useful	  if several category variables are present so that we know which 	  row of ratesAtSites the values of a particular variable go.*/DataSet		simulatedData = SimulateDataSet (theLnLik,"",ratesAtSites,namesOfRateVars);/*13. We are just going to print out the rates and report their meanwhich should be close to 1 and the variance, which should be close to 1/alpha */fprintf (stdout, "\nCategory variable name: ", namesOfRateVars[0],                 "\n      Site       Rate\n");                 sum  = 0;sum2 = 0;for (k=0; k<Columns (ratesAtSites); k=k+1){	term = ratesAtSites[k];	fprintf (stdout, Format (k,10,0), " ", Format (term,10,5),"\n");	sum = sum+term;	sum2 = sum2+term*term;}	fprintf (stdout, "\nMean = ", sum/Columns (ratesAtSites),				 "\nVar  = ",(sum2-sum^2/Columns (ratesAtSites))/(Columns(ratesAtSites)-1)," (1/alpha) = ", 1/alpha, "\n");   