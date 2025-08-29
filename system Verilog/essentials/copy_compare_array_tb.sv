module copy_compare_array_tb();
    initial begin
        // ---------------------------------------------------------------------
        // Declare signals
        // ---------------------------------------------------------------------
        bit [31:0] src[5];
        bit [31:0] dst[5]; 

        // ---------------------------------------------------------------------
        // Initialize signals
        // ---------------------------------------------------------------------
        src = '{0, 1, 2, 3, 4};
        dst = '{5, 4, 3, 2, 1};


      $display("src = %p", src);
      $display("dst = %p", dst);
        // ---------------------------------------------------------------------
        // Array operation examples (Does not work on Icarus, Works in Mentor)
        // ---------------------------------------------------------------------
        // Compare two arrays
        if (src == dst)
            $display("src == dst");
        else
            $display("src != dst");

        // Copy array
        dst = src;
        $display("src %s dst", (src == dst) ? "==" : "!=");
        
        $display("Change element at index 0 of the src");
        src[0] = 100;
        $display("src %s dst", (src == dst) ? "==" : "!=");
        
        // Compare element 1 to 4 of src and dst array
        $display("src[1:4] %s dst[1:4]", 
                (src[1:4] == dst[1:4]) ? "==" : "!=");
    end

endmodule