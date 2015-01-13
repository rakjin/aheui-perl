#/usr/bin/env perl
use utf8;
use Encode qw/encode decode/;
use Acme::Aheui::Machine;
use File::Slurp;

my ($filename) = @ARGV;

die "Usage:\n\taheui source.aheui\n" unless $filename;
die "'$filename' not found.\n" unless -e $filename;

open(FH, $filename) or die "cannot open $filename.\n";
my $source = join '', <FH>;
close(FH);
$source = decode('utf-8', $source);

my $machine = Acme::Aheui::Machine->new( source => $source );
$machine->execute();