# Create a simulator object
set ns [new Simulator]

# Open the nam trace file
set nf [open hw1.nam w]
$ns namtrace-all $nf

#Open the trace file (before you start the experiment!)
set tf [open p22trace.tr w]
$ns trace-all $tf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam hw1.nam &
        exit 0
}

# Agent/TCP - a ``tahoe'' TCP sender
# Agent/TCP/Reno - a ``Reno'' TCP sender
# Agent/TCP/Newreno - Reno with a modification
# Agent/TCP/Sack1 - TCP with selective repeat (follows RFC2018)
# Agent/TCP/Vegas - TCP Vegas
# Agent/TCP/Fack - Reno TCP with ``forward acknowledgment''
# Agent/TCP/Linux - a TCP sender with SACK support that runs TCP congestion control modules from Linux kernel
# The one-way TCP receiving agents currently supported are:
# Agent/TCPSink - TCP sink with one ACK per packet
# Agent/TCPSink/DelAck - TCP sink with configurable delay per ACK
# Agent/TCPSink/Sack1 - selective ACK sink (follows RFC2018)
# Agent/TCPSink/Sack1/DelAck - Sack1 with DelAck
# The two-way experimental sender currently supports only a Reno form of TCP:
# Agent/TCP/FullTcp

# Insert your own code for topology creation
# and agent definitions, etc. here
####################################################################################
#                         N1                      N4                     
#                           \                    /
#                            \                  /
#                             N2--------------N3
#                            /                  \
#                           /                    \
#                         N5                      N6

$ns color 23 Blue
$ns color 14 Green
$ns color 56 Red

# Create six nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

# Create a duplex link between the nodes 
$ns duplex-link $n1 $n2 10Mb 10ms DropTail    
$ns duplex-link $n2 $n5 10Mb 10ms DropTail 
$ns duplex-link $n2 $n3 10Mb 10ms DropTail 
$ns duplex-link $n3 $n4 10Mb 10ms DropTail 
$ns duplex-link $n3 $n6 10Mb 10ms DropTail 

# Topology
$ns duplex-link-op $n1 $n2 orient right-down 
$ns duplex-link-op $n2 $n5 orient left-down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n6 orient right-down

#Setup a UDP connection N2-N3
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 23

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 8mb
$cbr set random_ false

# Setup a TCP connection N1-N4
set tcp14 [new Agent/TCP/Reno]
$tcp14 set class_ 2
$ns attach-agent $n1 $tcp14
set sink4 [new Agent/TCPSink]
$ns attach-agent $n4 $sink4
$ns connect $tcp14 $sink4
$tcp14 set fid_ 14

# Setup a UDP connection N5-N6
set udp56 [new Agent/UDP]
$ns attach-agent $n5 $udp56
set sink6 [new Agent/Null]
$ns attach-agent $n6 $sink6
$ns connect $udp56 $sink6
$udp56 set fid_ 56

# Setup a CBR over TCP connection
set cbr14 [new Application/Traffic/CBR]
$cbr14 attach-agent $tcp14
$cbr14 set type_ CBR
$cbr14 set packet_size_ 1000
$cbr14 set rate_ 2mb
$cbr14 set random_ false

# Setup a CBR over UDP connection
set cbr56 [new Application/Traffic/CBR]
$cbr56 attach-agent $udp56
$cbr56 set type_ CBR
$cbr56 set packet_size_ 500
$cbr56 set rate_ 2mb
$cbr56 set random_ false


####################################################################################
# Call the finish procedure after 5 seconds simulation time

$ns at 1.0 "$cbr start"
$ns at 0.2 "$cbr14 start"
$ns at 1.3 "$cbr56 start"
$ns at 9.5 "$cbr14 stop"
$ns at 9.5 "$cbr56 stop"
$ns at 9.5 "$cbr stop"
$ns at 10.0 "finish"

# Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

# Run the simulation
$ns run

close $tf