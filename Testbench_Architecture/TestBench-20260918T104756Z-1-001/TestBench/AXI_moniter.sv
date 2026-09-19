`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2026 02:49:54 PM
// Design Name: 
// Module Name: AXI_moniter
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

module AXI_monitor #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64
)(
    axi_if axi
);

    always @(posedge axi.clk) begin

        // write address     

        if (axi.awvalid && axi.awready) begin

            $display("[AXI MONITOR] WRITE ADDR time=%0t addr=%h", $time, axi.awaddr);

        end

        // write data

        if (axi.wvalid && axi.wready) begin

            $display("[AXI MONITOR] WRITE DATA time=%0t data=%h", $time, axi.wdata);

        end

        // read request

        if (axi.arvalid && axi.arready) begin

            $display("[AXI MONITOR] READ ADDR time=%0t addr=%h", $time, axi.araddr);

        end

        // read response

        if (axi.rvalid && axi.rready) begin

            $display("[AXI MONITOR] READ DATA time=%0t data=%h", $time, axi.rdata
            );

        end

    end

endmodule