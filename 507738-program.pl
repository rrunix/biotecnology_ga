#!/usr/bin/perl

use AI::Genetic;
use Scalar::Util qw(looks_like_number);

#Letters
my $mapTo=[ 'A', 'C', 'T', 'G' ];
#module
my $mod = 4;
#iterations
my $iterations = 50;
#population
my $population = 50;

# c(t) matrix
my $c=[];
# c(t+1) matrix
my $c1=[];
# c(t) matrix with letters
my $craw=[];
# c(t+1) matrix with letters
my $c1raw=[];

#Extract program args
if( ($#ARGV + 1) == 2 || ($#ARGV + 1) == 3) {

	#If the program has three args, this one is the iterations
	if( ($#ARGV + 1) == 3) {
		my $pop = $ARGV[2];
		#Check that the third arg is a number
		if(looks_like_number($pop)) {
			#Check that is higher tan 0
			if($pop > 0) {
				$iterations = $pop;
			} else {
				die "The iterations must be positive: $pop isn't valid \n";
			}
		}else {
			die "The iterations must be a number: $pop isn't valid \n";
		}
	}
	
	my $crawstring = $ARGV[0];
	my $c1rawstring = $ARGV[1];
	my $c1matrix = [];
	my $cmatrix = [];
	
	#If the length of the two words isn't the same throw a exception
	#We can't use TGT as c, and AAAA as c(t+1)
	if(length($crawstring) != length($c1rawstring)) {
		my $lengthcraw = length($crawstring);
		my $lengthc1raw = length($c1rawstring);
		die "The length of c(t) and c(t+1) must be the same : c(t) = $lengthcraw c(t+1) = $lengthc1raw \n";
	}
	
	#Convert a word into a letter sequence, example TGTG -> [T,G,T,G]
	my @chars = map substr( $crawstring, $_, 1), 0 .. length($crawstring) -1;
	
	#Store in craw array
	for(my $i = 0; $i <= $#chars; $i++) {
		$craw ->[$i] = $chars[$i];
	}
	#Convert a word into a letter sequence, example TGTG -> [T,G,T,G]
	@chars = map substr( $c1rawstring, $_, 1), 0 .. length($c1rawstring) -1;
	#Store in c1raw array
	for(my $i = 0; $i <= $#chars; $i++) {
		$c1raw ->[$i] = $chars[$i];
	}

} else {
	#If the args isn't 2,3 or -1 ( program without args ) show the help
	if($#ARGV != -1) {
		print("Error, wrong argument number. The number of arguments must be 0 (for default args)
		or 2 ( c(t) c(t+1) : example, AAAAA AAAAB . Additionally you can specify the iterations with a third
		argument, example : AAAAA AAAAB 1000\n");
	}
	#Using default args
	print("\nUsing default args \n");
	$craw = ['A','A','A','A','C','G','G','G','G','G','A','A','A','T','T','T','A','G','C','A'];
	$c1raw = ['A','C','G','A','C','G','G','G','G','G','G','T','T','T','A','A','A','A','C','A'];
}

print("Program args : \n");

#Print iterations
print("\tIterations      : $iterations \n");
my $crawlength = veclen($craw);

#Print c(t)
print("\tC(t) sequence   : ");
for(my $i = 0; $i < $crawlength; $i++) {
	print("$craw->[$i] ");
}
print("\n");

#Print c(t+1)
print("\tC(t+1) sequence : ");
for(my $i = 0; $i < $crawlength; $i++) {
	print("$c1raw->[$i] ");
}
print("\n");

#Print letter matching
print("\tLetter matching : ");
my $mapToLength = veclen($mapTo);
for(my $i = 0; $i < $mapToLength; $i++) {
	print("$mapTo->[$i] = $i ");
}
print("\n");
#Convert letters into numbers	
$c = lettersToNumbers($craw);
$c1 = lettersToNumbers($c1raw);

print("\nComputing m... \n\n");
#Get c(t+1) dimensions(The same as c(t))
my ($crows,$ccols) = matdim($c1);

#Calc the max score, the numbers are in the range [0..3] ( mod 4)
#So, the max score is the numbers of possible values multiplied by the number of rows
$maxScore = $crows * $mod;

#Initialice
my $ga = new AI::Genetic(
        -fitness    => \&aptitud,
        -type       => 'rangevector',
        -population => $population,
        -crossover  => 0.9,
        -mutation   => 0.1,
        -terminate  => \&funcionFinalizacion,
);

#Create init matrix, it contains the gene's ranges [ 1, crows - 2] and the number of gens (crows)
#For example, for crows=4
#[1,2]
#[1,2]
#[1,2]
#[1,2]
$matrixC = [];
for(my $i = 0; $i < $crows; $i++) {
	$matrixC->[$i][0] = 1;
	$matrixC->[$i][1] = $crows - 2;
}

#Initialize
$ga->init($matrixC);

#Start with $iterations iterations
$ga->evolve('rouletteTwoPoint', $iterations);

#Get the best
$best = $ga->getFittest->genes;
$score = $ga->getFittest->score;

#Calculate the precession
$precision = ($score / $maxScore) * 100;
print "Done. \n";

#Print output message
if($score == $maxScore) {
	print "A valid M has been found. Percentage of validity = $precision \% \n\n";
} else {
	print "A valid M hasn't been found. Percentage of validity = $precision \% \n\n";
}

#Print the matrix
print "M matrix : \n\n";
printResult($best);
print "\n";

#METHODS


#Genetic methods

#Finalization method, it allows stopping before achieve the maximun number of iterations
#in our case, the algorithm stop if the maximun score is reached
sub funcionFinalizacion {
	my $ga = shift;
	return 1 if $ga->getFittest->score == $maxScore;
	return 0;
}

#Aptitude method
sub aptitud {
	my $gen = $_[0];
        #Assume square matrix
        #Get the gene vector's length
	my $length = veclen($gen);
	#Get the c vector's length
	$clength = veclen($c);
	#Check if the length of both vectors are the same
	#If the length isn't the same, we can't multiply 
	#the matrix, so, we throw a exception
	unless ($length == $clength) {  # raise exception
        	die "Error, bad matrix: $length , $clength ";
   	}
   	
   	#M matrix, it's formed using gene vector. The dimensions
   	#of the M matrix are [ gene length, gene length ].
	my $matrix = [];
	#Counter for gene matrix
	my $count = 0;
	#Convert gene matrix to M matrix
	for(my $i = 0; $i < $length; $i++) {
		for(my $j = 0; $j < $length; $j++) {
			if( $gen->[$i] == 0 || $gen->[$i] == ($length)) {
				die "Bad formed, args can only be in the range [0 - $length] \n";
			}
			my $rest = $gen->[$i] - $j;
			#Example of convert a gen to a matrix row
			#gen : 3
			#M   : 0 0 1 1 1 0 0 0 ...
			#Other example
			#gen : 1
			#M   : 1 1 1 0 0 0 0 ...
			#The gene's number represent the second 1 in the row.
			#So, if the gene's number is 1, there is a 1 in 0,1,2 position.
			
			#The gene's number i, represents the 1's in the
			#row i and has 1's in the cols ( gene's number - 1, gene's number, gene's number + 1)
			if($rest == -1 || $rest == 0 || $rest == 1) {
				$matrix->[$i][$j] = 1;
			} else {
				$matrix->[$i][$j] = 0;
			}
		}
	}
	#Multiply M * C	
	$ctest = mmult($matrix, $c);
	#Apply mod $mod ( in our case 4 )
	$ctest = mmod($ctest, $mod);
	#Substract $c1 - M
	$diff = mrest($c1, $ctest);
	#Apply mod $mod ( in our case 4 )
	$diff =  mmod($diff, $mod);
	#Sum all matrix elemens
	$sumelems = msumelems($diff);
	#Return the score, high score is better, so we need
	#to substract maxScore - sumelems because the matrix
	#is better if its sumelems is lower.
	return $maxScore - $sumelems;
}

#Print the result
sub printResult {
	my $genes = $_[0];
	#Get the length
	$length = veclen($genes);
	for(my $i = 0; $i < $length; $i++) {
		for(my $j = 0; $j < $length; $j++) {
			my $rest = $genes->[$i] - $j;
			#the gene's number i, represents the 1's in the
			#row i and has 1's in the cols ( gene's number - 1, gene's number, gene's number + 1)
			if($rest == -1 || $rest == 0 || $rest == 1) {
				print("1 ");
			} else {
				print("0 ");
			}
		}
		print ("\n");
	}
}




#Number to Letters
sub numberToLetters {
	my $genes = $_[0];
	#Vector's length
	$length = veclen($genes);
	#Result
	$result = [];
	for(my $i = 0; $i < $length; $i++) {
		#The letter that represents genes[i] number is in mapTo [ genes[i] ]
		$result->[$i] = $mapTo->[$genes->[$i][0]];
	}
	#Return the result
	return result;
}

# Letters to numbers
sub lettersToNumbers {
	my $genes = $_[0];
	#Vector's length
	$length = veclen($genes);
	#Letters' length
	$lettersLength = veclen($mapTo);
	#Result
	$result = [];
	for(my $i = 0; $i < $length; $i++) {
		my $set = 0;
		for(my $j = 0; $j < $lettersLength; $j++) {
			#If genes[i] == mapTo[x], the letter number is x
			if($genes->[$i] eq $mapTo->[$j]) {
				$result->[$i][0] = $j;
				$set = 1;
			}
		}
		#If the number isn't set, throw a exception
		if($set == 0 ){
			die "Error, unacknowledged letter : $genes->[$i] \n";
		}
	}
	#Return the result
	return $result;
}

#Matrix methods

#Sum all matrix elements
sub msumelems {
    my ($m1) = @_;
    #Get the dimension
    my ($m1rows,$m1cols) = matdim($m1);
    #The result
    my $result = 0;
    #Sum 
    for(my $i = 0; $i < $m1rows; $i++) {
    	for(my $j = 0; $j < $m1cols; $j++) {
    		$result = $result + $m1->[$i][$j];
    	}
    }
    #Return the result
    return $result;
}

#Substract two matrix
sub mrest {
    my ($m1,$m2) = @_;
    #Get the dimensions1
    my ($m1rows,$m1cols) = matdim($m1);
    #Get the dimensions
    my ($m2rows,$m2cols) = matdim($m2);
    #If the matrix dimension doesn't match, throw a exception
    unless ($m1rows == $m2rows && $m1cols == $m2cols) {
    	die "IndexError: matrices don't match";
    }
    
    #The result
    my $result = [];
    #Substract the elements
    for(my $i = 0; $i < $m1rows; $i++) {
    	for(my $j = 0; $j < $m1cols; $j++) {
    		$result->[$i][$j] = $m1->[$i][$j] - $m2->[$i][$j];
    	}
    }
    #Return the result
    return $result;
}

#Multiply two matrix
sub mmult {
    my ($m1,$m2) = @_;
    my ($m1rows,$m1cols) = matdim($m1);
    my ($m2rows,$m2cols) = matdim($m2);

    #If the dimensions aren't valid, throw a exception
    unless ($m1cols == $m2rows) {  # raise exception
        die "IndexError: matrices don't match: $m1cols != $m2rows";
    }

    my $result = [];
    my ($i, $j, $k);

    for $i (range($m1rows)) {
        for $j (range($m2cols)) {
            for $k (range($m1cols)) {
                $result->[$i][$j] += $m1->[$i][$k] * $m2->[$k][$j];
            }
        }
    }
    return $result;
}

#Matrix module
sub mmod {
    #Method's args
    my ($m1,$mod) = @_;
    #Get the dimensions
    my ($m1rows,$m1cols) = matdim($m1);
    #Apply module
    for(my $i = 0; $i < $m1rows; $i++) {
    	for(my $j = 0; $j < $m1cols; $j++) {
    		$m1->[$i][$j] = $m1->[$i][$j] % $mod;
    	}
    }
    #return the result
    return $m1;
}

#Print a matrix
sub printMatrix {
    my ($m1) = @_;
    #Get the dimensions
    my ($m1rows,$m1cols) = matdim($m1);
    for(my $i = 0; $i < $m1rows; $i++) {
    	for(my $j = 0; $j < $m1cols; $j++) {
    		#print m[i][j] value
    		print("$m1->[$i][$j] ");
    	}
    	print("\n");
    }
}

#Range between 0 and the firts arg. 
#Example, range(5) returns [0,1,2,3,4]
sub range { 0 .. ($_[0] - 1) }

#Vector length
sub veclen {
    my $ary_ref = $_[0];
    my $type = ref $ary_ref;
    if ($type ne "ARRAY") { die "$type is bad array ref for $ary_ref" }
    return scalar(@$ary_ref);
}

#Matrix dimension
sub matdim {
    my $matrix = $_[0];
    my $rows = veclen($matrix);
    my $cols = veclen($matrix->[0]);
    return ($rows, $cols);
}

