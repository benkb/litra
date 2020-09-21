use strict;
use warnings;

use Getopt::Long;


## % LITRA(1)
## % Ben Srctxt
## % 2020-09-21,17:01

## # NAME 

## Litra - write documentation in your sourcecode

## # SYNOPSIS

### Usage: litra.pl [OPTIONS] FILE 

## # DESCRIPTION

## Writing while exploring, testing new things and try to write down 
## the all notes in the process.


sub usage {
  my $thisfile = $0;
  open (my $tfh, '<', $thisfile) || die "Err: cannot open $thisfile\n";
  while(<$tfh>){ if(s/^###\s+//){ print STDERR $_ } }
  die;
}

### Options: 

my $help;
# delimiters
my ($usageline, $singleline, $multiline_start, $multiline_end) = ("","","", "");

GetOptions (
### -s regex --singleline=regex			

### : Regex for starting single line

	"singleline|s=s" => \$singleline,    

### -ss regex --second-singleline=regex			

### : Regex for starting single line

	"usageline|u=s" => \$usageline,    

### -ms regex --multiline-start=regex			

### : Regex for starting multi line

	"multiline-start|ms=s"   => \$multiline_start,

### -me regex --multiline-end=regex			

### : Regex for end multi line

	"multiline-end|me=s"   => \$multiline_end,

### -h --help

### : show help
	"help|h" => \$help)
	or die("Error in command line arguments\n");

usage if $help;

## ```
my $infile = $ARGV[0];
## ```

$infile || usage();

sub handle_singleline {
	my ($infile, $delim, $usage_delim) = @_;
	open (my $fh, '<' , $infile) || die "Err: cannot open $infile\n";

	my ($mdblock, $codeblock);

	while (<$fh>){
  	chomp;
  	if (/^$delim\s*\`\`\`/){    ##  // ``` Begin/End of Codeblock 
			print '```' . "\n";
    	$mdblock = 1;
			$codeblock = ($codeblock) ? undef : 1;
  	}elsif (/^$delim\s+(.*)/){  ## // # Markdown Text 
    	$mdblock = 1;
    	print $1 . "\n";
  	}elsif (/^\s*$/){    ##  // Empty line in Markdown Block Text
    	print "\n" if $mdblock;
			undef $mdblock;
  	}else{
			print $_ . "\n" if $codeblock;
		}

		if($usage_delim){
  		if (/^$usage_delim\s+[uU]sage:\s+(.*)/){  ## // # Markdown Text 
    		$mdblock = 1;
    		print "\t"  . $1 . "\n";
  		}elsif (/^$usage_delim\s+[oO]ptions:\s+$/){  ## // # Markdown Text 
    		$mdblock = 1;
    		print "# OPTIONS\n";
			} elsif (/^$usage_delim\s+(.*)/){  ## // # Markdown Text 
    		$mdblock = 1;
    		print $1 . "\n";
			}
		}
	}
}


if($singleline and $multiline_start and $multiline_end){
	die "Err: choose between <singleline> or <multiline>" 
}elsif($singleline){
	handle_singleline($infile, $singleline, $usageline)
}elsif($multiline_start and $multiline_end){
#	handle_multiline()
}else{
}

