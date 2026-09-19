`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 05:51:07 PM
// Design Name: 
// Module Name: DFI_monitor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DFI_monitor (
    dfi_if dfi
);

    always @(posedge dfi.clk) begin

        // Command activity
        if (!dfi.cs_n) begin

            $display("[DFI MONITOR] time=%0t addr=%h bank=%h RAS=%b CAS=%b WE=%b", $time, dfi.address, dfi.bank, dfi.ras_n, dfi.cas_n, dfi.we_n);

        end


        // Write data
        if (dfi.wrdata_en) begin

            $display("[DFI MONITOR] WRITE DATA time=%0t data=%h", $time, dfi.wrdata);

        end


        // Read data
        if (dfi.rddata_valid) begin

            $display("[DFI MONITOR] READ DATA time=%0t data=%h", $time, dfi.rddata);

        end

    end

endmodule
