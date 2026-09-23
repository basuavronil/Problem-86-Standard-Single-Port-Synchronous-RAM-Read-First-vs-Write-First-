module single_port_ram (
    input  wire       clk,
    input  wire       rst_n,           // Active-low asynchronous reset
    
    // Control Signals
    input  wire       rd_en,           // Read Enable
    input  wire       wr_en,           // Write Enable
    input  wire       read_first_en,   // 1 = Read-First Mode, 0 = Write-First Mode
    
    // Address & Data Buses
    input  wire [9:0] addr,            // 10-bit Address Bus (1024 depth)
    input  wire [7:0] d_in,            // 8-bit Data Input
    output reg  [7:0] d_out            // 8-bit Data Output
);

    // Memory array: 1024 locations x 8-bit width
    reg [7:0] mem [0:1023];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d_out <= 8'd0;
        end 
        else begin
            // CASE 1: SIMULTANEOUS READ & WRITE ON THE SAME ADDRESS
            if (wr_en && rd_en) begin
                if (read_first_en) begin
                    // READ-FIRST: Output the OLD stored data, then overwrite RAM
                    d_out     <= mem[addr];
                    mem[addr] <= d_in;
                end 
                else begin
                    // WRITE-FIRST: Overwrite RAM and route NEW data straight to d_out
                    mem[addr] <= d_in;
                    d_out     <= d_in;
                end
            end 
            // CASE 2: WRITE-ONLY OPERATION
            else if (wr_en) begin
                mem[addr] <= d_in; // Write data to RAM (d_out holds previous value)
            end 
            // CASE 3: READ-ONLY OPERATION
            else if (rd_en) begin
                d_out <= mem[addr]; // Output stored data from RAM
            end
        end
    end

endmodule
