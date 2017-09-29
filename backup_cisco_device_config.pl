#!/usr/bin/perl

use strict;
use warnings;
use Data::Dump qw(dump);
use POSIX qw(strftime);
use Net::Telnet::Cisco;

my $network_prefix = '172.21.148';
my @network_range = (11..17, 51..56, 254);
my $backup_folder = "/backup/path_dir";
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


# mkdir directory for update with (date)
my $date_local = strftime "%Y.%m.%d-%H%M%S", localtime;
my $nw_dir = "/$backup_folder/$date_local";
system("mkdir -p $nw_dir");

# Copy config
for (my $i=0; $i<=$#network_range; $i++) {
    my $network_device_ip = $network_prefix . "." . $network_range[$i];
    print "Start backup config of device: $network_device_ip\n";

    # Login to network device
    my $session = Net::Telnet::Cisco->new(host => $network_device_ip)
        or warn "  Can not connect!";
    $session->login('backup','******')
        or warn "  login failed: $session->errmsg";
    $session->enable("******")
        or warn "  enable failed: $session->errmsg";
    my $cmd = "terminal length 0\n" . "show running-config\n";

    # STDOUT network configuration to screen
    my @output = $session->cmd("$cmd\n\n\n")
       or warn "  cmd failed: $session->errmsg";
    splice @output, 0, 6;

    # Save network configuration to file
    while(my($k, $v) = each %nw_devices) {
        open my $output_handle, ">", "$nw_dir/$v.txt"
           or warn "failed";
    print $output_handle @output;
    }
    print "Backup config of device: $network_device_ip succefully!!!\n\n\n";
    $session->close();

}

