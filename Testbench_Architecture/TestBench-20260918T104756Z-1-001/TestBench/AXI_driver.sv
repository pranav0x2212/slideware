`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 05:56:29 PM
// Design Name: 
// Module Name: AXI_driver
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


module AXI_driver #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64
)(
    axi_if.master axi
);


    task automatic write(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );

        // Send address
        @(posedge axi.clk);

        axi.awaddr  <= addr;
        axi.awvalid <= 1'b1;

        // Wait until DUT accepts address
        do begin
            @(posedge axi.clk);
        end while (!axi.awready);

        axi.awvalid <= 1'b0;


        // Send data
        @(posedge axi.clk);

        axi.wdata  <= data;
        axi.wstrb  <= '1;
        axi.wvalid <= 1'b1;

        // Wait until DUT accepts data
        do begin
            @(posedge axi.clk);
        end while (!axi.wready);

        axi.wvalid <= 1'b0;


        // Wait for write response
        axi.bready <= 1'b1;

        do begin
            @(posedge axi.clk);
        end while (!axi.bvalid);

        $display(
            "[AXI DRIVER] WRITE COMPLETE addr=%h data=%h",
            addr,
            data
        );

        @(posedge axi.clk);

        axi.bready <= 1'b0;

    endtask


    task automatic read(
        input  logic [ADDR_WIDTH-1:0] addr,
        output logic [DATA_WIDTH-1:0] data
    );

        @(posedge axi.clk);

        axi.araddr  <= addr;
        axi.arvalid <= 1'b1;

        // Wait for address acceptance
        do begin
            @(posedge axi.clk);
        end while (!axi.arready);

        axi.arvalid <= 1'b0;


        // Wait for read response
        axi.rready <= 1'b1;

        do begin
            @(posedge axi.clk);
        end while (!axi.rvalid);

        data = axi.rdata;

        $display(
            "[AXI DRIVER] READ COMPLETE addr=%h data=%h",
            addr,
            data
        );

        @(posedge axi.clk);

        axi.rready <= 1'b0;

    endtask

    initial begin

        axi.awaddr  = '0;
        axi.awvalid = 1'b0;

        axi.wdata   = '0;
        axi.wstrb   = '0;
        axi.wvalid  = 1'b0;

        axi.bready  = 1'b0;

        axi.araddr  = '0;
        axi.arvalid = 1'b0;

        axi.rready  = 1'b0;

    end

endmodule
