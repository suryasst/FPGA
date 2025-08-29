`timescale 1ps/1ps

module data_types_tb();
    // -------------------------------------------------------------------------
    // Declaring TB's internal signals
    // -------------------------------------------------------------------------

    bit b;                      // 2-state, single-bit
    bit [31:0] b32;             // 2-state, 32-bit unsigned integer
    int unsigned ui;            // 2-state, 32-bit unsigned integer
    int i;                      // 2-state, 32-bit signed integer
    byte b8;                    // 2-state, 8-bit signed integer
    shortint s;                 // 2-state, 16-bit signed integer
    longint li;                 // 4-state, 64-bit signed integer
    time t_curr, t_initial;     // 4-state, 64-bit unsigned integer
    real r;                     // 2-state, double precision floating

    // -------------------------------------------------------------------------
    // Initial block of the TB 2.2
    // -------------------------------------------------------------------------

    initial begin

        // Procedural assignments
        b = 1;
        b32 = 32'hFFFFFFFF; // Maximum value in an unsigned 32-bit integer
        ui = 32'hFFFFFFFF;  // Maximum value in an unsigned 32-bit integer
        i = -2**31;         // Correct minimum value for a 32-bit signed integer
        b8 = 127;           // Maximum value for a signed 8-bit integer
        s = -2**15;         // Correct minimum value for a 16-bit signed integer
        li = 2**63 - 1;     // Maximum value for a 64-bit signed integer
        t_initial = $time;  // Capturing the initial time of simulation
        t_curr = t_initial; // Store the initial time in another signal
        r = 3.14159265;     // Corrected value for Pi approximation

        // Following procedural statements remain unchanged
        b = ~b;  // negation
        assert (b == 0) 
            $display("[Pass] Test case 1 successful."); 
        else 
            $error("[Fail] Test case 1 failed. Expected: 0, Actual: %b", b);

        b32 = b32 + 1;  // wraps around
        assert (b32 == 0) 
            $display("[Pass] Test case 2 successful.");
        else 
            $error("[Fail] Test case 2 failed. Expected: 0, Actual: %u", b32);

        ui = ui + 1;  // wraps around
        assert (ui == 0) 
            $display("[Pass] Test case 3 successful.", $time);
        else 
            $error("[Fail] Test case 3 failed. Expected: 0, Actual: %u", ui);

        i = i + 2147483648;  // corrects to 0
        assert (i == 0) 
            $display("[Pass] Test case 4 successful."); 
        else 
            $error("[Fail] Test case 4 failed. Expected: 0, Actual: %d", i);

        b8 = b8 + 1;  // wraps to -128
        assert (b8 == -128) 
            $display("[Pass] Test case 5 successful."); 
        else 
            $error("[Fail] Test case 5 failed. Expected: -128, Actual: %d", b8);

        s = s - 1;  // wraps to 32767
        assert (s == 32767) 
            $display("[Pass] Test case 6 successful."); 
        else 
            $error("[Fail] Test case 6 failed. Expected: 32767, Actual: %d", s);

        li = li + 1; // wraps to -2^63
        assert(li == -2**63) 
            $display("[Pass] Test case 7 successful."); 
        else 
            $error("[Fail] Test case 7 failed. Expected: %d, Actual: %d",-2**63, li);
        
        t_curr = t_curr + 10;
        assert(t_curr == t_initial + 10)
            $display("[Pass] Test case 8 successful."); 
        else 
            $error("[Fail] Test case 8 failed. Expected: %t, Actual: %t", t_initial + 10, t_curr);

        r = r * 2;
        assert(r == 6.2831853)
            $display("[Pass] Test case 9 successful."); 
        else 
            $error("[Fail] Test case 9 failed. Expected: 6.2831853, Actual: %f", r);

    end
endmodule