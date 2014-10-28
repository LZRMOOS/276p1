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

proc finish {} {
        global f0 f1 f2
        #Close the output files
        close $f0
        close $f1
        close $f2
        #Call xgraph to display the results
        exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 &
        exit 0
}

proc record {} {
        global sink3 sink4 sink6 f0 f1 f2
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 0.5
        #How many bytes have been received by the traffic sinks?
        set bw0 [$sink3 set bytes_]
        set bw1 [$sink4 set bytes_]
        set bw2 [$sink6 set bytes_]
        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        puts $f2 "$now [expr $bw2/$time*8/1000000]"
        #Reset the bytes_ values on the traffic sinks
        $sink3 set bytes_ 0
        $sink4 set bytes_ 0
        $sink6 set bytes_ 0
        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

set sink3 [new Agent/LossMonitor]
set sink4 [new Agent/LossMonitor]
set sink6 [new Agent/LossMonitor]

$ns attach-agent $n3 $sink3
$ns attach-agent $n4 $sink4
$ns attach-agent $n6 $sink6

set source1 [attach-expoo-traffic $n1 $sink4 200 2s 1s 100k]
set source5 [attach-expoo-traffic $n5 $sink6 200 2s 1s 200k]

set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]


####################################################################################
# Call the finish procedure after 5 seconds simulation time
$ns at 0.0 "record"
$ns at 10.0 "$source1 start"
$ns at 10.0 "$source5 start"
$ns at 50.0 "$source1 stop"
$ns at 50.0 "$source5 stop"
$ns at 60.0 "finish"

# Run the simulation
$ns run

close $tf