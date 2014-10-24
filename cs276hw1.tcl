# Create a simulator object
set ns [new Simulator]

# Open the nam trace file
set nf [open hw1.nam w]
$ns namtrace-all $nf

#Open the trace file (before you start the experiment!)
set tf [open my_experimental_output.tr w]
$ns trace-all $tf

# Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
	# Close the trace file
        close $nf
	# Execute nam on the trace file
        exec nam hw1.nam &
        exit 0
}

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

$ns color 1 Blue
$ns color 2 Red

# Create six nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

# Create a duplex link between the nodes - NOTE: Also need to try RED
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

# Function
proc attach-expoo-traffic { node sink size burst idle rate } {
	# Get an instance of the simulator
	set ns [Simulator instance]

	# Create a UDP agent and attach it to the node
	set source [new Agent/UDP]
	$ns attach-agent $node $source

	# Create an Expoo traffic agent and set its configuration parameters
	set traffic [new Application/Traffic/Exponential]
	$traffic set packetSize_ $size
	$traffic set burst_time_ $burst
	$traffic set idle_time_ $idle
	$traffic set rate_ $rate
        
    # Attach traffic source to the traffic generator
    $traffic attach-agent $source
	# Connect the source and the sink
	$ns connect $source $sink
	return $traffic
}

# Setup a TCP connection (n1 to n4)
set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n1 $tcp
set sink4 [new Agent/TCPSink]
$ns attach-agent $n4 $sink4
$ns connect $tcp $sink4
$tcp set fid_ 1

# Setup a CBR over TCP connection (n1 to n4)
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

# Setup a TCP connection 2 (n5 to n6)
set tcp2 [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n5 $tcp2
set sink6 [new Agent/TCPSink]
$ns attach-agent $n6 $sink6
$ns connect $tcp2 $sink6
$tcp set fid_ 1

# Setup a CBR over TCP connection 2 (n5 to n6)
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $tcp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1mb
$cbr2 set random_ false

# Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr start"
$ns at 0.1 "$cbr2 start"
$ns at 4.5 "$cbr2 stop"
$ns at 4.5 "$cbr stop"


####################################################################################
# Call the finish procedure after 5 seconds simulation time
$ns at 5.0 "finish"

# Run the simulation
$ns run

# Close the trace file (after you finish the experiment!)
close $tf


