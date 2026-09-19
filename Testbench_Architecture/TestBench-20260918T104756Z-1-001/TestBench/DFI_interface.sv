`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 12:39:54 PM
// Design Name: 
// Module Name: DFI_interface
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

interface DFI_interface #(
    parameter ADDR_WIDTH = 18,
    parameter BANK_WIDTH = 4,
    parameter DATA_WIDTH = 64
)(
    input logic clk,
    input logic rst_n
);


    logic [ADDR_WIDTH-1:0] address;
    logic [BANK_WIDTH-1:0] bank;

    logic                  cs_n;
    logic                  ras_n;
    logic                  cas_n;
    logic                  we_n;


    // write the data

    logic [DATA_WIDTH-1:0] wrdata;
    logic                  wrdata_en;


    // reads data

    logic [DATA_WIDTH-1:0] rddata;
    logic                  rddata_valid;
    
    logic init_start;
    logic init_complete;

    // controller end ports

    modport controller (

        input  clk,
        input  rst_n,

        output address,
        output bank,

        output cs_n,
        output ras_n,
        output cas_n,
        output we_n,

        output wrdata,
        output wrdata_en,

        input  rddata,
        input  rddata_valid,

        output init_start,
        input  init_complete
    );

    // PHY end ports
    
    modport phy (

        input clk,
        input rst_n,

        input address,
        input bank,

        input cs_n,
        input ras_n,
        input cas_n,
        input we_n,

        input wrdata,
        input wrdata_en,

        output rddata,
        output rddata_valid,

        input init_start,
        output init_complete
    );

endinterface
