module queue_methods_tb();
    int j = 1;
    int q2[$] = {3,4}; // Queue literals do not use '
    int q[$] = {0,2,3};

    initial begin
        $display("q = %p", q);
        q.insert(1, j); // {0, 1, 2, 3} Insert j before element #1
        $display("q = %p", q);

        q.delete(1); // {0, 2, 3} Delete element #1
        $display("q = %p", q); 

        q.push_front(6); // {6, 0 ,2, 3} Insert at front
        $display("q = %p", q); 
        
        j = q.pop_back; // {6, 0, 2} so j = 3
        $display("q = %p", q); 

        q.push_back(8);  // {6,0,2,8} Insert at back
        $display("q = %p", q); 

        j = q.pop_front; // {0,2,8} so j = 6
        $display("q = %p", q); 

        foreach(q[i])        // Print entire queue
            $display("q[%0d] = %0d", i, q[i]);

        q.delete();
        $display("q = %p", q); 
        
    end

endmodule