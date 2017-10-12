####################################################################################################
#
#   Created by Jim Melanson, jmelanson1965@gmail.com
#   September, 2017
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, and distribute
# copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
# to the following conditions:
#
#  -The original author notice (above) shall remain intact.
#  
#  -The above author notice and this permission notice shall be included in all copies or
#   substantial portions of the Software.
#
#  -THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
#   BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
####################################################################################################
#
#   The purpose of this is to generate prime numbers.
#
#   There are two ways to use this module:
#
#   1.) Generate a list of prime numbers between two numbers:
#
#       my $obj = MongerPrime->new();
#       my @list_of_primes = $obj->range(10000, 12000);
#
#   2.) Step through prime numbers one at a time from a starting point
#
#       my $obj = MongerPrime->new();
#       $obj->seed(10000);
#       print "Next prime is: ", $obj->next;
#       print "Previous prime is: ", $obj->previous;
#
#       You can pass the seed with the constructor if you wish:
#
#       my $obj = MongerPrime->new(10000);
#       print "Next prime is: ", $obj->next;
#       print "Previous prime is: ", $obj->previous;
#
#       NOTE: I recommend you do a lot of testing if you are using the
#       range method, especially if you are using five or more digits.
#       The module can handle it, but once you hit five and six digit
#       prime numbers, it can be a slow response.
#
####################################################################################################

package MongerPrime;
use 5.00;

sub new {
    my ($class, $seed) = @_;
    my $self = {
        _seed => $seed, 
        _list => [],
    };
    bless $self, $class;
    return $self;
}

sub DESTROY {
    my $self = shift;
    foreach(keys %{$self}) {
        delete $self->{$_};
    }
    undef(%$self);
    undef $self;
}

sub seed { 
    if($_[1] > 2) {
        $_[0]->{_seed} = $_[1];
    } else {
        return $_[0]->{_seed};
    }
}

sub is_prime { 
    if($_[1] > 2) {
        $_[0]->{_seed} = $_[1];
    }
    return $_[0]->_is_prime($_[0]->{_seed});
}
 
sub range {
    #Return a list of primes between two numbers OR return
    #the number of primes in the list in scalar context.
    if($_[2] > $_[1]) {
        my @temp;
        if(($_[1] > 2) && ($_[2] > 2)) {
            for(my $c = $_[1]; $c <= $_[2]; $c++) {
                if($c % 2 > 0) {
                    #Not an even number, proceed.
                    if($_[0]->_is_prime($c)) {
                        push(@temp, $c);
                        $demo_limit_iterator++;
                    }
                }
            }
        }
        return wantarray ? @temp : $#temp + 1;
    }
}

sub previous {
    #The prime prior to the seed
    #The prime coming after the seed.
    #Is there a seed value greater than 1 because 2 is a prime number?
    if ($_[0]->{_seed} > 1) {
        #Declare a semaphore
        my $sem = 0;
        #Declare the iterator that will hold the value we are testing
        my $iterator;
        
        #SEED CHECK
        #Check to see if the seed is an even number. If it is, then we add one to it.
        #If the seed is even, we add one to get an odd number. We then iterate through
        #every second number. We don't need to test even numbers because other than "2", there
        #are no even prime numbers. If the seed is odd to begin with, then we don't need to add
        #anything to it as it is odd.
        
        if($_[0]->{_seed} % 2 == 0) {
            $iterator = $_[0]->{_seed} + 1;
        } else {
            $iterator = $_[0]->{_seed};
        }
        #The semaphore $sem will never evaluate as true.
        #We only want to exit this WHILE loop when we find a
        #prime number.
        while(!$sem) {
            #As the iterator is an odd number, subtract "2" to get
            #to the next odd number.
            $iterator -= 2;
            #Check to see if the new value for the iterator is
            #a prime number or not. If it is, then we can return it.
            if($_[0]->_is_prime($iterator) == 1) {
                $_[0]->{_seed} = $iterator;
                return $iterator;
            }
        }
    } else {
        #The seed value was too small.
        return -1;
    }
}

sub next {
    #The prime coming after the seed.
    #Is there a seed value greater than 2 (1 is prime, so is 2)?
    if ($_[0]->{_seed} > 1) {
        #Declare a semaphore
        my $sem = 0;
        #Declare the iterator that will hold the value we are testing
        my $iterator;
        
        #SEED CHECK
        #Check to see if the seed is an even number. If it is, then we subtract one from it.
        #If the seed is even, we take away one to get an odd number. We then iterate through
        #every second number. We don't need to test even numbers because other than "2", there
        #are no even prime numbers. If the seed is odd to begin with, then we don't need to
        #subtract anything from it as it is odd.
        if($_[0]->{_seed} % 2 == 0) {
            $iterator = $_[0]->{_seed} - 1;
        } else {
            $iterator = $_[0]->{_seed};
        }
        #The semaphore $sem will never evaluate as true.
        #We only want to exit this WHILE loop when we find a
        #prime number.
        while(!$sem) {
            #As the iterator is an odd number, add "2" to get
            #to the next odd number.
            $iterator += 2;
            #Check to see if the new value for the iterator is
            #a prime number or not. If it is, then we can return it.
            if($_[0]->_is_prime($iterator) == 1) {
                $_[0]->{_seed} = $iterator;
                return $iterator;
            }
        }
    } else {
        #The seed value was too small.
        return -1;
    }
}

sub _is_prime {
    if($_[1] > 1) {
        if($_[1] % 2 == 0) {
            return 0;
        } else {
            for(my $c = 2; $c < $_[1]; $c++) {
                if($_[1] % $c == 0) {
                    return 0;
                }
            }
            return 1;
        }
    } else {
        return 0;
    }
}

1;
