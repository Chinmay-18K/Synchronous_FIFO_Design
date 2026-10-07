`timescale 1ns / 1ps

module fifo_sync
    //parameter declare
    #(parameter FIFO_DEPTH = 8,
      parameter DATA_WIDTH = 32)
    //input output port
     (input cs,
      input rst_n,
      input write_en,
      input read_en,
      input clk,
      input [DATA_WIDTH - 1 : 0] data_in,
      output reg [DATA_WIDTH - 1 : 0] data_out,
      output full,
      output empty);
      
      //localparameter used inside logic
      localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);  //for fifo of depth 8, fifo_depth_log = 3
      
      //bidirectional array declare
      reg [DATA_WIDTH-1 : 0] fifo [0: FIFO_DEPTH - 1];
      
      //declaring pointers
      reg [FIFO_DEPTH_LOG : 0] wr_p;  //4 bit
      reg [FIFO_DEPTH_LOG : 0] rd_p;  //4 bit
      
      //write operation
      always @(posedge clk or negedge rst_n)
        begin
            if(!rst_n) begin
                wr_p <= 0;
                end
            else if (cs && write_en && !full) begin
                fifo [wr_p [FIFO_DEPTH_LOG -1 : 0]] <= data_in;
                wr_p <= wr_p + 1'b1;
                end
        end
        
        //read operation
       always @(posedge clk or negedge rst_n)
           begin
               if(!rst_n) begin
                  rd_p <= 0;
                  end
               else if (cs && read_en && !empty) begin
                  data_out <= fifo [rd_p [FIFO_DEPTH_LOG - 1 : 0]];
                  rd_p <= rd_p + 1'b1;
                  end   
            end
        
       //full and empty logic
       assign empty = (rd_p == wr_p);
       assign full = (rd_p == {~wr_p[FIFO_DEPTH_LOG], wr_p[FIFO_DEPTH_LOG : 0]});
       
endmodule
