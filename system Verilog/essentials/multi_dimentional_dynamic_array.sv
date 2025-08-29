module multi_dimentional_dynamic_array_tb();

    bit [7:0] mask[]; // Using dynamic array for an uncoounted list;
    int d[][]; // A dynamic array of dynamic arrays

    initial begin
        mask = '{8'b0000_0000, 8'b0000_0001, 8'b0000_0011, 8'b0000_0111};
      $display("mask size = %0d, mask = %p", $size(mask), mask);

        d = new[4]; // Construct the first or left-most dimension

       //  Construct the 2nd dimension, each array a different size!
      foreach(d[i]) begin
            d[i] = new[i+1];
        $display("size of d[%0d] is %0d", i, $size(d[i]));
      end
        
        // Initialize the elemens.
        foreach(d[i,j])
            d[i][j] = i * 10 + j;
	
      // Cannot omit loop variable while iterating over a dynamic array.
      for (int i=0; i < $size(d); i++) begin
        $write("%2d: ", i);
        for (int j=0; j < $size(d[i]); j++) begin
      		$write("%3d", d[i][j]);
        end
        $display;
      end

      foreach(d[i,j]) begin
        $write("[%0d, %0d] = %3d  ", i, j, d[i][j]);
        if ($size(d[i]) == j+1)
            $display;
      end
      
    end

endmodule