`timescale 1ns / 1ps

module tb_single_port_ram;

    // Testbench Signals
    reg        clk;
    reg        rst_n;
    reg        rd_en;
    reg        wr_en;
    reg        read_first_en;
    reg  [9:0] addr;
    reg  [7:0] d_in;
    wire [7:0] d_out;

    // Instantiate the Unit Under Test (UUT)
    single_port_ram uut (
        .clk          (clk),
        .rst_n        (rst_n),
        .rd_en        (rd_en),
        .wr_en        (wr_en),
        .read_first_en(read_first_en),
        .addr         (addr),
        .d_in         (d_in),
        .d_out        (d_out)
    );

    // 1. Clock Generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    // 2. Waveform Dump & Real-time Console Monitor
    initial begin
        // Generate VCD waveform file for GTKWave / ModelSim viewing
        $dumpfile("ram_waveform.vcd");
        $dumpvars(0, tb_single_port_ram);

        // Continuous print monitor for signal tracking
        $monitor("Time=%0t ns | rst_n=%b | rd=%b wr=%b mode=%s | addr=0x%0h | d_in=0x%0h | d_out=0x%0h",
                 $time, rst_n, rd_en, wr_en, 
                 (read_first_en ? "READ_FIRST " : "WRITE_FIRST"), 
                 addr, d_in, d_out);
    end

    // 3. Test Stimulus Sequence
    initial begin
        // Initialize signals
        clk           = 0;
        rst_n         = 0;
        rd_en         = 0;
        wr_en         = 0;
        read_first_en = 0;
        addr          = 10'd0;
        d_in          = 8'd0;

        // Apply Reset
        #10;
        rst_n = 1;
        #10;

        // --- STEP 1: Initial Write to Address 0x05 with value 0xAA ---
        $display("\n--- Step 1: Pre-loading address 0x05 with 0xAA ---");
        @(posedge clk);
        addr  <= 10'h05;
        d_in  <= 8'hAA;
        wr_en <= 1'b1;
        rd_en <= 1'b0;

        // --- STEP 2: Normal Read from Address 0x05 ---
        $display("\n--- Step 2: Normal Read from address 0x05 ---");
        @(posedge clk);
        wr_en <= 1'b0;
        rd_en <= 1'b1;

        // --- STEP 3: Simultaneous R/W in READ-FIRST Mode ---
        // Address 0x05 holds 0xAA. We write 0xBB and expect d_out = 0xAA (old data).
        $display("\n--- Step 3: READ-FIRST Mode Collision (Write 0xBB to 0x05) ---");
        @(posedge clk);
        wr_en         <= 1'b1;
        rd_en         <= 1'b1;
        read_first_en <= 1'b1; // READ_FIRST
        d_in          <= 8'hBB;

        // --- STEP 4: Simultaneous R/W in WRITE-FIRST Mode ---
        // Address 0x05 now holds 0xBB. We write 0xCC and expect d_out = 0xCC (new data).
        $display("\n--- Step 4: WRITE-FIRST Mode Collision (Write 0xCC to 0x05) ---");
        @(posedge clk);
        wr_en         <= 1'b1;
        rd_en         <= 1'b1;
        read_first_en <= 1'b0; // WRITE_FIRST
        d_in          <= 8'hCC;

        // --- STEP 5: Read back to verify memory contents ---
        $display("\n--- Step 5: Final Read from 0x05 (Should be 0xCC) ---");
        @(posedge clk);
        wr_en <= 1'b0;
        rd_en <= 1'b1;

        // Finish simulation
        #20;
        $display("\nSimulation Complete.");
        $finish;
    end

endmodule
