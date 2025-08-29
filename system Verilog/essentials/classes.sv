class Statistics;
    time startT;
    static int ntrans = 0;               // Transaction count
    static time total_elapsed_time = 0;  // Total elapsed time

    function void start();
        startT = $time;
        $display("Start time: %0t", startT); // Display start time
    endfunction

    function void stop();
        time how_long = $time - startT;
        ntrans++;
        total_elapsed_time += how_long;
        $display("Stop time: %0t, Duration: %0t, Total Transactions: %0d, Total Elapsed Time: %0t", 
                 $time, how_long, ntrans, total_elapsed_time); // Display stop time and transaction info
    endfunction
endclass

class Transaction;
    bit [31:0] addr;
    bit [31:0] csm;
    bit [31:0] data[8];
    Statistics stats; // Statistics handle

    function new();
        stats = new(); // Make instance of Statistics
    endfunction

    task transmit_me();
        // Fill packet with data
        foreach (data[i]) begin
            data[i] = i; // Dummy data assignment for illustration
          $display("Transmitting Data[%0d] = %0h", i, data[i]);
        end

        stats.start();

        #100; // Simulate transmission delay
        stats.stop();
    endtask
endclass

program automatic using_classes_tb();
  Transaction t;
  
  initial begin
    t = new();
    t.transmit_me();
    // Optionally, wait for a moment and then display a final message
    #500; // Wait for some simulation time
    $display("Simulation completed.");
  end
endprogram