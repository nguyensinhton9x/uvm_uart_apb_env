//--------------------------------------
//Project: The UVM environemnt for UART (Universal Asynchronous Receiver Transmitter)
//Function:  The most top of UVM env connected all components (DUT, UVM components and checkers)
//   by the interface
//Author:  Pham Thanh Tram, Nguyen Sinh Ton, Doan Duc Hoang, Truong Cong Hoang Viet, Nguyen Hung Quan
//Page:    VLSI Technology
//--------------------------------------
`timescale 1ns/1ns
`define UART0_CLOCK_CYCLE 10
`define UART1_CLOCK_CYCLE 14
//Include the UVM library
`include "uvm_pkg.sv"
`include "uvm_macros.svh"
//Include all parameter, define and source code files
//Note: Only include the files which are not included in any file before.
`include "uart_define.h" //defines
`include "ifDut.sv"      //Interface define
`include "dut_top.v"     //Top DUT connects 2 UART instances
`include "uart_top.v"    //Top module of UART IP
`include "uart_apb_if.v" //APB interface module of UART IP
`include "uart_receiver.v"  //Receiver module of UART IP
`include "uart_transmitter.v" //Transmitter module of UART IP
`include "apb_protocol_checker.sv" //APB checker module
`include "apb_protocol_checker_top.sv" //Connection of APB checker
`include "uart_protocol_checker.sv" //UART checker module
`include "uart_protocol_checker_top.sv" //Connection of UART checker

module testTop;
  import uvm_pkg::*;
  //include all used classes
  `include "cApbTransaction.sv"
  `include "cApbMasterDriver.sv"
  `include "cScoreboard.sv"
  `include "cApbMasterMonitor.sv"
  `include "uvm_env.sv"
  //Internal signals
  wire uart_0to1, uart_1to0;
  //Interface declaration
  ifApbMaster vifApbMaster_Tx();
  ifApbMaster vifApbMaster_Rx();
  ifInterrupt vifInterrupt_Tx();
  ifInterrupt vifInterrupt_Rx();
  //Clock generator
  //Create 2 asynchronous clock to test
  reg uart0_clk = 1'b0;
  reg uart1_clk = 1'b0;
  always #(`UART0_CLOCK_CYCLE/2) uart0_clk = ~uart0_clk;
  always #(`UART1_CLOCK_CYCLE/2) uart1_clk = ~uart1_clk;
  assign vifApbMaster_Tx.pclk = uart0_clk;
  assign vifApbMaster_Rx.pclk = uart1_clk;
  //Reset generator
  //Only reset one time when starting the simulation
  reg reset_n;
  initial begin
    reset_n = 1'b0;
    #(`UART0_CLOCK_CYCLE + `UART1_CLOCK_CYCLE)
    reset_n = 1'b1;
  end
  assign vifApbMaster_Tx.preset_n = reset_n;
  assign vifApbMaster_Rx.preset_n = reset_n;
  //Instances 
  apb_protocol_checker_top apb_protocol_checker_top();
  uart_protocol_checker_top uart_protocol_checker_top();
  //TOP DUT instance
  dut_top dut_top(
     //UART 0 connection
    .pclk_0(vifApbMaster_Tx.pclk),
    .preset_n_0(vifApbMaster_Tx.preset_n),
    .pwrite_0(vifApbMaster_Tx.pwrite),
    .psel_0(vifApbMaster_Tx.psel), 
    .penable_0(vifApbMaster_Tx.penable),
    .paddr_0(vifApbMaster_Tx.paddr),
    .pwdata_0(vifApbMaster_Tx.pwdata),
    .pstrb_0(vifApbMaster_Tx.pstrb), 
    .prdata_0(vifApbMaster_Tx.prdata),
    .pready_0(vifApbMaster_Tx.pready),
    .pslverr_0(vifApbMaster_Tx.pslverr),
    `ifdef INTERRUPT_COM
      .ctrl_if_0(vifInterrupt_Tx.ctrl_if),
    `else
      .ctrl_tif_0(vifInterrupt_Tx.ctrl_tif),
      .ctrl_rif_0(vifInterrupt_Tx.ctrl_rif),
      .ctrl_pif_0(vifInterrupt_Tx.ctrl_pif),
      .ctrl_oif_0(vifInterrupt_Tx.ctrl_oif),
      .ctrl_fif_0(vifInterrupt_Tx.ctrl_fif),
    `endif
    //UART 1 connection
    .pclk_1(vifApbMaster_Rx.pclk),
    .preset_n_1(vifApbMaster_Rx.preset_n),
    .pwrite_1(vifApbMaster_Rx.pwrite),
    .psel_1(vifApbMaster_Rx.psel), 
    .penable_1(vifApbMaster_Rx.penable),
    .paddr_1(vifApbMaster_Rx.paddr),
    .pwdata_1(vifApbMaster_Rx.pwdata),
    .pstrb_1(vifApbMaster_Rx.pstrb), 
    .prdata_1(vifApbMaster_Rx.prdata),
    .pready_1(vifApbMaster_Rx.pready),
    .pslverr_1(vifApbMaster_Rx.pslverr),
    `ifdef INTERRUPT_COM
       .ctrl_if_1(vifInterrupt_Rx.ctrl_if),
    `else
       .ctrl_tif_1(vifInterrupt_Rx.ctrl_tif),
       .ctrl_rif_1(vifInterrupt_Rx.ctrl_rif),
       .ctrl_pif_1(vifInterrupt_Rx.ctrl_pif),
       .ctrl_oif_1(vifInterrupt_Rx.ctrl_oif),
       .ctrl_fif_1(vifInterrupt_Rx.ctrl_fif),
    `endif
    //To UART protocol checker
    .uart_0to1(uart_0to1),
    .uart_1to0(uart_1to0)
  );
  //Interface connection
  //Connect TOP DUT to UVM components
  initial begin
    //Connect APB interface
    uvm_config_db#(virtual interface ifApbMaster)::set(null,"uvm_test_top.coEnv.coApbMasterAgentTx*","vifApbMaster",vifApbMaster_Tx);
    uvm_config_db#(virtual interface ifApbMaster)::set(null,"uvm_test_top.coEnv.coApbMasterAgentRx*","vifApbMaster",vifApbMaster_Rx);
    //Connect Interrupt interface
    uvm_config_db#(virtual interface ifInterrupt)::set(null,"uvm_test_top.coEnv.coApbMasterAgentTx*","vifInterrupt",vifInterrupt_Tx);
    uvm_config_db#(virtual interface ifInterrupt)::set(null,"uvm_test_top.coEnv.coApbMasterAgentRx*","vifInterrupt",vifInterrupt_Rx);
  end
  //Run the test pattern
  initial begin
    //This method will get thes test name from UVM_TESTNAME
    //which is assigned in the RUN command
    run_test();
  end
  
endmodule
