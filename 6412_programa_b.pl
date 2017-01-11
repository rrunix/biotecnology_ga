#!/usr/bin/perl

use AI::Genetic;

#Constants
my $pi = 3.14;
my $e =  2.718281828;
my $bsr = 140;
my $kcp = 0.0615;
my $ki = 0.14;

#Change this params to increase/decrease the iterations,crossover..
my $population = 130;
my $iterations = 50;
my $crossover = 0.9;
my $mutation = 0.1; 

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
#1, F
#2..9 :ξi
$ga->init([
          [0.40,0.60],
	  [-100,100],
	  [-100,100],
	  [-100,100],
	  [-100,100],
	  [-100,100],
	  [-100,100],
	  [-100,100],
	  [-100,100],
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

print "factor de eficiencia = $ptosMejor\n\n";

#print
sub printGen {
	my $genes = $_[0];
         my $f = $genes->[0];
	 my $sp1 = $genes->[1];
	 my $sp2 = $genes->[2];
	 my $sp3 = $genes->[3];
	 my $sp4 = $genes->[4];
	 my $sp5 = $genes->[5];
	 my $sp6 = $genes->[6];
	 my $sp7 = $genes->[7];
	 my $sp8 = $genes->[8];
	 
	 print ("values : \n");
	 print ("\tf  = $f\n");
	 print ("\tξ1 = $sp1\n");
	 print ("\tξ2 = $sp2\n");
	 print ("\tξ3 = $sp3\n");
	 print ("\tξ4 = $sp4\n");
	 print ("\tξ5 = $sp5\n");
	 print ("\tξ6 = $sp6\n");
	 print ("\tξ7 = $sp7\n");
	 print ("\tξ8 = $sp8\n");
}
	
#Aptitude method
sub funcionAptitud {
       	 my $genes = $_[0];
         # Get values
         my $f = $genes->[0];
	 my $sp1 = $genes->[1];
	 my $sp2 = $genes->[2];
	 my $sp3 = $genes->[3];
	 my $sp4 = $genes->[4];
	 my $sp5 = $genes->[5];
	 my $sp6 = $genes->[6];
	 my $sp7 = $genes->[7];
	 my $sp8 = $genes->[8];
	 
	 #Time
	 my $times=[10,20,30,60,90,120,150,180];
	 #cps(t)
	 my $cpst = [];
	 
	 #Doubt. Bi(t) or B(t) ??
	 #First release is bi(t), modified is b(t)
	 for(my $time = 0; $time < 8; $time++) {
	 	my $actualTime = $times->[$time];
	 	$cpst->[$time] = $bsr +$sp1*(100-(11/6)*$actualTime +(17/60)*($actualTime**2))
	 	+ $sp2*((195/2)-(4/3)*$actualTime+ (31/120)*($actualTime**2))
	 	+ $sp3*(-750 + (331/6)*$actualTime + (41/60)*($actualTime**2))
	 	+ $sp4*((24875/12)+(231/4)*$actualTime+(107/240)+($actaulTime**2))
	 	+ $sp5*((-5265/4) + (469/12)*$actualTime + (59/240)*($actaulTime**2))
	 	+ $sp6*((7695/4) + (395/12)*$actualTime + (37/240)*($actaulTime**2))
	 	+ $sp7*((-9695) + (875/6)*$actualTime + (8/15)*($actaulTime**2))
	 	+ $sp8*((10930) + (775/6)*$actualTime + (23/60)*($actaulTime**2));
	 }
	 
	 #cp(t) random values ( I don't understand how I can calculate it )
	 my $cpt = [3,3,3,3,3,3,3,3];
	 #it(t) random values ( I don't understand how I can calculate it )
	 my $it = [3,3,3,3,3,3,3,3];
	 #v exp random value ( I don't understand how I can calculate it )
	 my $vexp = 10;
	 
	 #Psi1 values
	 my $psi1 = [];
	 #Psi2 values
	 my $psi2 = [];
	 
	 #Calculate psi1,2
	 for(my $i = 0; $i < 8; $i++) {
	 	$psi1->[$i] = ($vepx * $cpst->[$i]) + ($kcp *$cpt->[$i]) - ($cpst->[$i]);
	 	$psi2->[$i] = ($vepx * $it->[$i]) + ($ki*$it->[$i]) - ($f* $cpst->[$i]);
	 }

	 #Do summatory
	 my $sumatory = 0;
	 for(my $i = 0; $i < 8; $i++) {
	 	$summatory = $sumatory +  $psi1->[$i]*$psi1->[$i] + $psi2->[$i]*$psi2->[$i];
	 }
	 
         return ((1/180) *( 10**14 - sqrt($summatory)));
}


#Finish method
sub funcionFinalizacion {
         my $ga = $_[0];
         return 0;
}

