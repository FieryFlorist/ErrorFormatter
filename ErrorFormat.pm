#! /usr/bin/perl

use POSIX qw/ceil/;
use POSIX qw/floor/;
use Math::Round qw/round/;
use Exporter;

our @ISA= qw( Exporter );

# these CAN be exported.
our @EXPORT_OK = qw(  );

# these are exported by default.
our @EXPORT = qw( printErrFormat );

sub printErrFormat {
	# Check if a valid number of arguments has been passed
	my $numArgs = scalar(@_);
	if ($numArgs < 2) {
		return "";
	}
	
	# Value to print
	my $value = $_[0];
	# Error of value
	my $error = $_[1];
	# If there is no valid error, just return a generic string
	if ($error <= 0) {
		return sprintf('%f', $value);
	}
	
	# Lower limit to switch to scientific mode
	my $limLow = 0.01;
	# Upper limit to switch to scientific mode
	my $limHigh = 1000;
	# Check if non-standard limits have been given
	if ($numArgs == 4) {
		# Lower limit to switch to scientific mode
		$limLow = $_[2];
		# Upper limit to switch to scientific mode
		$limHigh = $_[3];
	}
	# Check limits and return the appropriate format
	if (($value < $limLow and $error < $limLow) or ($value > $limHigh or $error > $limHigh)) {
		return printErrSci($value, $error);
	} else {
		return printErrNml($value, $error);
	}
}

sub printErrSci {
	my $value = $_[0]; my $error = $_[1];
	# Get the number of digits off the ones place the leading error appears.
	my $sigDigs = floor(log($error)/log(10));
	# Get the leading digit of the error.
	my $errStr = sprintf('%1d', round($error/(10**$sigDigs)));
	# Get the leading digit position of the value
	my $valDigs = floor(log($value)/log(10));
	
	# Check if the value is actually larger than the error
	if ($valDigs <= $sigDigs) {
			my $nextVal = round($value/(10**$sigDigs));
			my $returnStr = sprintf('%1d', $nextVal);
			if ($sigDigs > -1) {
				return "$returnStr($errStr)E+" . sprintf('%02d', $sigDigs);
			} else {
				return "$returnStr($errStr)E-" . sprintf('%02d', -$sigDigs);
			}
	} else {
		# Grab all the digits to be printed
		my $nextVal = floor($value/(10**$valDigs));
		my @returnArray = ($nextVal);
		$value = $value - $nextVal * (10**$valDigs);
		for ($i = $valDigs-1; $i > $sigDigs; $i = $i-1) {
			$nextVal = floor($value/(10**$i));
			push(@returnArray, $nextVal);
			$value = $value - $nextVal * (10**$i);
		}
		$nextVal = round($value/(10**$sigDigs));
		push(@returnArray, $nextVal);
		$countBack = scalar(@returnArray)-1;
		# Carry any rounding
		while ($returnArray[$countBack] > 9) {
			$returnArray[$countBack] = $returnArray[$countBack] - 10;
			$countBack = $countBack - 1;
			$returnArray[$countBack] = $returnArray[$countBack] + 1;
		}
		# Build the return string
		my $returnStr = sprintf('%1d', $returnArray[0]) . ".";
		for($i=1; $i< scalar(@returnArray); $i = $i+1) {
			$returnStr = $returnStr . sprintf('%1d', $returnArray[$i]);
		}
		if ($valDigs > -1) {
			return "$returnStr($errStr)E+" . sprintf('%02d', $valDigs);
		} else {
			return "$returnStr($errStr)E-" . sprintf('%02d', -$valDigs);
		}
	}
}

sub printErrNml {
	my $value = $_[0]; my $error = $_[1];
	# Get the number of digits off the ones place the leading error appears.
	my $sigDigs = floor(log($error)/log(10));
	# Get the leading digit of the error.
	my $errStr = sprintf('%1d', round($error/(10**$sigDigs)));
	# Get the leading digit position of the value
	my $valDigs = floor(log($value)/log(10));
	# Check if the value is actually larger than the error
	if ($valDigs < $sigDigs) {
		if ($sigDigs >= 0) {
			my $nextVal = round($value/(10**$sigDigs));
			my $returnStr = $returnStr . sprintf('%1d', $nextVal);
			for (my $i=0; $i < $sigDigs; $i=$i+1) {
				if ($nextVal > 0) {
					$returnStr = $returnStr . "0";
				}
				$errStr = $errStr . "0";
			}
			return "$returnStr($errStr)";
		} else {
			my $returnStr = "0.";
			for (my $i=-1; $i>=$sigDigs; $i=$i-1) {
				$returnStr = $returnStr . "0";
			}
			my $nextVal = round($value/(10**$sigDigs));
			my $returnStr = $returnStr . sprintf('%1d', $nextVal);
			return $returnStr . "($errStr)";
		}
	}
	# If the value is larger than the error, loop through all the digits and return them.
	# First, create the digit list
	my $nextVal = floor($value/(10**$valDigs));
	my @returnArray = ($nextVal);
	$value = $value - $nextVal * (10**$valDigs);
	for ($i = $valDigs-1; $i > $sigDigs; $i = $i-1) {
		$nextVal = floor($value/(10**$i));
		push(@returnArray, $nextVal);
		$value = $value - $nextVal * (10**$i);
	}
	$nextVal = round($value/(10**$sigDigs));
	push(@returnArray, $nextVal);
	$countBack = scalar(@returnArray)-1;
	# Second, carry any rounding
	while ($returnArray[$countBack] > 9) {
		$returnArray[$countBack] = $returnArray[$countBack] - 10;
		$countBack = $countBack - 1;
		$returnArray[$countBack] = $returnArray[$countBack] + 1;
	}
	# Prepare the output string
	my $returnStr = "";
	# Third, add any leading zeros.
	if ($valDigs < 0) {
		$returnStr = "0.";
		for (my $i = -1; $i > $valDigs; $i = $i - 1) {
			$returnStr = $returnStr . "0";
		}
	}
	# Fourth, insert digits (and decimal if necessary)
	for (my $i=$valDigs; $i>=$sigDigs; $i=$i-1) {
		$returnStr = $returnStr . $returnArray[$valDigs-$i];
		if ($i == 0 and $i>$sigDigs) {
			$returnStr = $returnStr . ".";
		}
	}
	# Fifth, add any trailing zeros (to value and error!)
	for (my $i=0; $i < $sigDigs; $i=$i+1) {
		$returnStr = $returnStr . "0";
		$errStr = $errStr . "0";
	}
	return $returnStr . "($errStr)";
}
