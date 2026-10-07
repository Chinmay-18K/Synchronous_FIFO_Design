`timescale 1ns / 1ps

module tb_fifo_sync;
    
    parameter FIFO_DEPTH = 8;
    parameter DATA_WIDTH = 32;
    
    reg cs;
    reg clk = 0;
    reg wr_en;
    reg rd_en;
    reg rst_n;
    reg [DATA_WIDTH - 1 : 0] data_in;
    wire full;
    wire empty;
    wire [DATA_WIDTH - 1 : 0] data_out;
    
    integer i;
    
    fifo_sync #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    )
    dut(
        .cs(cs),
        .clk(clk),
        .write_en(wr_en),
        .read_en(rd_en),
        .rst_n(rst_n),
        .data_in(data_in),
        .full(full),
        .empty(empty),
        .data_out(data_out)
    );
    
    always #5 clk = ~clk;
    
    task write_data (input [DATA_WIDTH - 1 : 0] d_in);
        begin
            @(posedge clk);
            cs = 1; wr_en = 1;
            data_in = d_in;
            $display($time, "data_in = %0d", data_in);
            @(posedge clk);
            cs = 1; wr_en = 0;
        end
    endtask
    
    task read_data ();
        begin
           @(posedge clk);
           cs = 1; rd_en = 1;
           @(posedge clk);
           //#1;
           $display($time, "read_data data_out = %0d",data_out);
           cs = 1; rd_en = 0; 
        end
    endtask
    
    initial begin
        #1;
        rst_n = 0;
        rd_en = 0;
        wr_en = 0;
        
        @(posedge clk)
        rst_n = 1;
        
        $display($time,"\n Scenario 1");
        write_data(1);
        write_data(10);
        write_data(100);
        read_data();
        read_data();
        read_data();
        //read_data();
        
        $display($time,"\n Scenario 2");
        for(i = 0; i < FIFO_DEPTH; i = i+1)begin
            write_data(2**i);
            read_data();
        end
        
        $display($time,"\n Scenario 3");
        for(i = 0; i < FIFO_DEPTH; i = i+1)begin
            write_data(2**i);
        end 
        for(i = 0; i < FIFO_DEPTH; i = i+1)begin
            read_data();
        end
        
        #60 $finish;      
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
endmodule
