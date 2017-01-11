#!/usr/bin/perl

use AI::Genetic;

$pi = 3.14;
$e =  2.718281828;

$population = 50;
$iterations = 5000;
$crossover = 0.9;
$mutation = 0.3; 

my $ga = new AI::Genetic(
        -fitness    => \&funcionAptitud,
        -type       => 'rangevector',
        -population => $population,
        -crossover  => $crossover,
        -mutation   => $mutation,
        -terminate  => \&funcionFinalizacion,
       );


#iniciamos el algoritmo genético
# Cromosomas : 
#1, CATALASA
#2, NADH
#3, L-Trp
#4, NaBr
#5, FAD
#6, FLR

$ga->init([
          [2000.0,4000.0],
	  [5000.0,10000.0],
	  [50.0, 200.0],
	  [30000.0, 60000.0],
	  [10.0, 50.0],
	  [120.0,200.0]
          ]);

print ("\nProgram args \n");
print ("\titerations = $iterations\n");
print ("\tpopulation = $population\n");
print ("\tcrossover  = $crossover\n");
print ("\tmutation   = $mutation\n");

print "\n";

#start
$ga->evolve('rouletteTwoPoint', $iterations);

#Get the best gen
$mejor = $ga->getFittest->genes;
#Get its score
$ptosMejor = $ga->getFittest->score;

#Print it
printGen ($mejor);

print "[5-Br-triptófano]  = $ptosMejor μM.\n\n";

#print a gen
sub printGen {
	my $genes = $_[0];
         # x es igual al valor del primer gen
         my $catalasa = $genes->[0];
	 my $nadh = $genes->[1];
	 my $ltrp = $genes->[2];
	 my $nabr = $genes->[3];
	 my $fad = $genes->[4];
	 my $flr = $genes->[5];
	 print ("values : \n");
	 print ("\tcatalasa  = $catalasa\n");
	 print ("\tnadh      = $nadh\n");
	 print ("\tltrp      = $ltrp\n");
	 print ("\tnabr      = $nabr\n");
	 print ("\tfad       = $fad\n");
	 print ("\tflr       = $flr\n\n");
}
	
#Aptitude method
sub funcionAptitud {
         #Gen to test
         my $genes = $_[0];

         my $catalasa = $genes->[0];
	 my $nadh = $genes->[1];
	 my $ltrp = $genes->[2];
	 my $nabr = $genes->[3];
	 my $fad = $genes->[4];
	 my $flr = $genes->[5];
         
         #Aptitude
         my $aptitud = ($catalasa * ($pi/2)) +
	(3*$nadh) / (1.48 * (sqrt(2))) * ($ltrp ** 3) +
	(11.234567/$nabr) * ( 2 / 48 ) * ( $e ** $fad ) +
	($flr ** (1/8));
         return $aptitud;
}


      #Finish method
sub funcionFinalizacion {
         my $ga = $_[0];
         return 0;
}

