#!/Users/hieu.du/perl5/perlbrew/perls/perl-5.18.0/bin/perl

use strict;
use warnings;
use Data::Dump qw(dump);
use POSIX qw(strftime);
use Net::Telnet::Cisco;

my $network_prefix = '172.21.148';
my @network_range = (51..56, 254);
my $backup_folder = "/backup/dena_nw_config";
my %nw_devices = (
    '172.21.148.11' => 'han-ap-14f-01',
    '172.21.148.12' => 'han-ap-14f-02',
    '172.21.148.13' => 'han-ap-14f-03',
    '172.21.148.14' => 'han-ap-14f-04',
    '172.21.148.15' => 'han-ap-14f-05',
    '172.21.148.16' => 'han-ap-14f-06',
    '172.21.148.17' => 'han-ap-14f-07',
    '172.21.148.51' => 'han-cat29edg-14f-01',
    '172.21.148.52' => 'han-cat29edg-14f-02',
    '172.21.148.53' => 'han-cat29edg-14f-03',
    '172.21.148.54' => 'han-cat29edg-14f-04',
    '172.21.148.55' => 'han-cat29edg-14f-05',
    '172.21.148.56' => 'han-cat29edg-14f-06',
    '172.21.148.254' => 'han-cat37cor-14f-01',
);

# Filter config cisco
for (my $i=0; $i<=$#network_range; $i++) {
    my $network_device_ip = $network_prefix . "." . $network_range[$i];

    # Login to network device
    my $session = Net::Telnet::Cisco->new(host => $network_device_ip)
        or warn "  Can not connect!";
    $session->login('backup','backup')
        or warn "  login failed: $session->errmsg";
    $session->enable("Punch1123!")
        or warn "  enable failed: $session->errmsg";
    my $cmd = "terminal length 0\n" . "show ip int brief | i Port-channel\n";

    # STDOUT network configuration to screen
    my @output = $session->cmd("$cmd\n\n\n")
       or warn "  cmd failed: $session->errmsg";
        print @output;
    $session->close();
}

