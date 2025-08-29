module mixing_packed_and_unpacked_array_tb();

	initial begin
    // Defining an array of 5 elemens, each element is a packed 4-bytes item
    bit [3:0] [7:0] mem[5];
    
    // A single 32 bit array (word)
    bit [31:0] single_word;

    // Defining an array of 8 elements each element 4 bit
    // This would be analogous to a packed array of nibbles (4 bit)
    bit [7:0] [3:0] nibbles;

    single_word = 32'hBABA_CAFE;
    // Set the first element of the array
      mem[0] = single_word;
    $displayh("mem[0] = %p", mem[0]);
      
    // Set the 3rd byte of the first element of the array
    mem[0][3] = 8'hFF;
    $displayh("mem[0][3] = %p", mem[0][3]);

    // Set the second nibble of the first byte of the 3rd element of the array
    mem[3][1][7:4] = 4'hA;
    $displayh("mem[3][1][7:4] = %p", mem[3][1][7:4]);
      
    // Copy a 4 bit value from mem to the first element of the nibbles array.
    nibbles[0] = mem[3][1][7:4];
    $displayh("nibbles[0] = %p", nibbles[0]);
      
  end

endmodule