`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 12:38:26 PM
// Design Name: 
// Module Name: AXI_interface
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


interface axi_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64
)(
    input logic clk,
    input logic rst_n
);

    // channel for write address

    logic [ADDR_WIDTH-1:0] awaddr;
    logic                  awvalid;
    logic                  awready;

    // data for write

    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;

    // response to write

    logic [1:0] bresp;
    logic       bvalid;
    logic       bready;

    // channel for read address

    logic [ADDR_WIDTH-1:0] araddr;
    logic                  arvalid;
    logic                  arready;

    // data for read

    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rvalid;
    logic                  rready;


    modport master (

        input clk,
        input rst_n,

        output awaddr,
        output awvalid,
        input  awready,

        output wdata,
        output wstrb,
        output wvalid,
        input  wready,

        input  bresp,
        input  bvalid,
        output bready,

        output araddr,
        output arvalid,
        input  arready,

        input  rdata,
        input  rresp,
        input  rvalid,
        output rready
    );


    modport slave (

        input clk,
        input rst_n,

        input  awaddr,
        input  awvalid,
        output awready,

        input  wdata,
        input  wstrb,
        input  wvalid,
        output wready,

        output bresp,
        output bvalid,
        input  bready,

        input  araddr,
        input  arvalid,
        output arready,

        output rdata,
        output rresp,
        output rvalid,
        input  rready
    );

endinterface
