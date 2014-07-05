#!/usr/bin/perl -w
use strict;
use 5.12.1;
use File::Path qw(mkpath);
use JSON qw(decode_json);
use File::chdir;
mkpath ['villages'];
{
    local $CWD = 'villages';
    system("git init");
}
for my $file (<out/*.json>) {
    warn $file;
    open my $fh, '<', $file or die;
    my ($date) = $file =~ m/(\d\d\d\d-\d\d-\d\d)/;
    local $/;
    my $villages = decode_json <$fh>;
    open my $out, '>:encoding(utf-8)', "villages/villages.csv" or die;
    my $columns = [qw(ivid id name town county vid icid itid)];
    print $out join(',', @$columns)."\n";
    for (sort keys %$villages) {
        no warnings 'uninitialized';
        print $out join(',', @{$villages->{$_}}{@$columns})."\n";
    }

    {
        local $CWD = 'villages';
        my $dateopt = $date ? "--date ${date}T00:00:00" : '';
        local $ENV{GIT_AUTHOR_DATE} = $date ? "${date}T00:00:00" : '';
        local $ENV{GIT_COMMITTER_DATE} = $date ? "${date}T00:00:00" : '';
        system("git add villages.csv; git commit $dateopt -m 'changes for @{[$date || '']}'");
        if ($date) {
            system("git tag $date");
        }
    }
}
