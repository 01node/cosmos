#!/bin/sh

IPT="/sbin/iptables"
#define your authorized hosts
IP_BASTION="x.x.x.x"
IP_OTHERHOST="x.x.x.1"



# Flush old rules, old custom tables
$IPT --flush
$IPT --delete-chain

# Set default policies for all three default chains
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

# Enable free use of loopback interfaces
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# All TCP sessions should begin with SYN
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -s $IPB -j DROP
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -s $IPH -j DROP

# Accept SSH connections from authorized hosts
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -p tcp --dport 22 -m state --state NEW -s $IP_BASTION -j ACCEPT
$IPT -A INPUT -p tcp --dport 2233 -m state --state NEW -s $IP_OTHERHOST -j ACCEPT

# Rest Server/SSL 
$IPT -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT


# Gaia 26656/26657 - accept all connections on 26656 and from specific location on 26657
$IPT -A INPUT -p tcp --dport 26656 -m state --state NEW  -j ACCEPT

$IPT -A INPUT -p tcp --dport 26657 -m state --state NEW -s $IP_BASTION -j ACCEPT
$IPT -A INPUT -p tcp --dport 26657 -m state --state NEW -s $IP_OTHERHOST -j ACCEPT

echo "Done"
