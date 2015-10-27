#!/usr/bin/perl
use strict;
use warnings;
use Net::Telnet::Netscreen;
use Net::Telnet::Cisco;
use Data::Dump qw(dump);
use POSIX qw(strftime);

my $network_prefix = '192.168.253';
my @network_range = (2..3);
my $backup_folder = "/backup/dena_nw_config";

# mkdir directory for update with (date)
my $date_local = strftime "%Y.%m.%d-%H%M%S", localtime;
my $nw_dir = "/$backup_folder/$date_local";
system("mkdir -p $nw_dir");

# Login to Juniper device
my $juniper_session = new Net::Telnet::Netscreen(host=> '192.168.253.2');
$juniper_session->login('punchadmin', '******');

my @output = $juniper_session->cmd("set console page 0\n" . "get config\n");
    splice @output, 0, 2;
        open my $output_handle, ">", "$nw_dir/han-ssg140fw-14f.txt"
            or warn "failed";
    print $output_handle @output;
    print "Backup config of device: 192.168.253.2 successfully!!!\n\n\n";
    $juniper_session->close();

# Login to Cisco device
print "Start backup config of device: 192.168.253.4\n";
my $cisco_session = Net::Telnet::Cisco->new(host => '192.168.253.4')
    or warn "  Can not connect!";
$cisco_session->login('backup','******')
    or warn "  login failed: $cisco_session->errmsg";
$cisco_session->enable("******")
    or warn "  enable failed: $cisco_session->errmsg";
my $cisco_cmd = "terminal length 0\n" . "show running-config\n";

# STDOUT network configuration to screen
my @cisco_output = $cisco_session->cmd("$cisco_cmd\n\n\n")
    or warn "cmd failed: $cisco_session->errmsg";
splice @cisco_output, 0, 3;
# Save network configuration to file
open my $cisco_output_handle, ">", "$nw_dir/han-router1841-14f.txt"
    or warn "failed";
print $cisco_output_handle @cisco_output;
print "Backup config of device: 192.168.253.4 successfully!!!\n";
$cisco_session->close();



