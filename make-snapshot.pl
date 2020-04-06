#!/usr/bin/perl
use File::Copy;
use Cwd;

# Configure system commands
@RSYNC = ('rsync','--archive','--delete', '--itemize-changes');
@MKDIR = ('mkdir','--parents');
@LN = ('ln','--symbolic', '--force', '--no-dereference');
@MV = ('mv','--force');

# Get the current date / time information
$t0 = time;
($sec, $min, $hour, $monthday, $month, $year, $weekday, $yesterday, $isdaylight) = gmtime $t0;
@date = ($year+1900, $month+1, $monthday);

# Cycle through the command line arguments for paths and flags. Flags go to rsync
@paths = ();
@flags = ();
$timestamp = sprintf('%d%02d%02d%02d%02d%02dZ', $date[0], $date[1], $date[2], $hour, $min, $sec);
$manualTimestamp = 0;
for ($i=0; $i<=$#ARGV; $i++) {
	if ($ARGV[$i] =~ /^--timestamp=([A-Za-z0-9]+)/) {
		$timestamp = $1;
		$manualTimestamp = 1;
	} elsif ($ARGV[$i] =~ /^--?[A-Za-z0-9]/) {
		@flags = (@flags, $ARGV[$i]);
	} else {
		@paths = (@paths, $ARGV[$i]);
	}
}

# Do we have a source?
if ($#paths >= 0) { $source = $paths[0] . '/'; } else { $source = $ENV{'HOME'} . '/'; }

# Do we have a destination?
if ($#paths >= 1) { $destination = $paths[1] . '/'; } else { $destination = '/recover/' . $ENV{'USER'} . '/' . lc($ENV{'HOSTNAME'}) . '/'; }

# Is the destination remote?
if ($destination =~ /^((\S+):)(.*)$/) {
	$host = $1;
	$destination = $3;
	@RSH = ('ssh', '-n', $2);
} else {
	$host = '';
	@RSH = ();
	$destination = Cwd::abs_path($destination) . "/";
}

$suffix = $timestamp;
$destination_partialpath = $destination.$suffix.'.partial/';
$destination_finalpath = $destination.$suffix;

$destination_freshest = $destination.'freshest';
$destination_verified = $destination.'verified';

@RSYNC = (@RSYNC, "--link-dest=${destination_freshest}", "--link-dest=${destination_verified}");

$errno = system (@RSH, @MKDIR, $destination_partialpath);
if (!$errno) { # success
	$errno = system (@RSYNC, @flags, $source, $host.$destination_partialpath);
	
	if (!$errno) {
		system (@RSH, @MV, $destination_partialpath, $destination_finalpath);
	} else {
		$destination_finalpath = $destination_partialpath;
	}
	if (!$manualTimestamp) {
		system (@RSH, @LN, $destination_finalpath, $destination_freshest);
	}
	if (!$errno) {
		if (!$manualTimestamp) {
			$errno = system (@RSH, @LN, $destination_finalpath, $destination_verified);
		}
		if ($errno) {
			print STDERR "REMOTE SYMLINK ERROR: terminated with code $errno\n";
		}
	} else {
		print STDERR "REMOTE SYNC ERROR: terminated with code $errno\n" ;
	}
} else { # failure
	print STDERR "REMOTE MKDIR ERROR: terminated with code $errno\n";
} # if

exit $errno;
