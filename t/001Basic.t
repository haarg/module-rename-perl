######################################################################
# Test suite for Module::Rename
# by Mike Schilli <cpan@perlmeister.com>
######################################################################

use warnings;
use strict;

use Test::More qw(no_plan);
use Sysadm::Install qw(:all);
use Log::Log4perl qw(:easy);
use File::Basename;
use File::Find;

#Log::Log4perl->easy_init($DEBUG);

BEGIN { use_ok('Module::Rename') };

my $sbx = "sandbox";
$sbx = "t/$sbx" unless -d $sbx;
$sbx = "../t/$sbx" unless -d $sbx;

cd $sbx;
rmf "tmp" if -d "tmp";
cp_r("Foo-Bar", "tmp");

my $ren = Module::Rename->new(
    name_old => "Foo::Bar",
    name_new => "Ka::Boom",
);

$ren->find_and_rename("tmp");

ok(! -f "tmp/Foo-Bar/lib/Foo/Bar.pm", "Old file deleted");
ok( -f "tmp/Foo-Bar/lib/Ka/Boom.pm", "File renamed");

my $data = slurp "tmp/Foo-Bar/lib/Ka/Boom.pm";
unlike($data, qr/Foo::Bar/, "Content renamed");
like($data, qr/Ka::Boom/, "Content renamed");

rmf "tmp";

######################################################################
sub cp_r {
######################################################################
    my($from, $to) = @_;

    my @files = ();

    find(sub {
        push @files, $File::Find::name if -f;
    }, $from);

    for my $file (@files) {
        my $newfile = "$to/$file";
        my $dir = dirname($newfile);
        mkd $dir unless -d $dir;
        cp $file, $newfile;
    }
}
