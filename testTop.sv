//--------------------------------------
//Project: The UVM environemnt for UART (Universal Asynchronous Receiver Transmitter)
//Module:  DUT top connects 2 UART instances
//Function: Instance 2 uart_top
//Author:  Pham Thanh Tram, Nguyen Sinh Ton, Doan Duc Hoang, Truong Cong Hoang Viet, Nguyen Hung Quan
//Page:    VLSI Technology
//--------------------------------------
`include "uvm_pkg.sv"
`include "uvm_macros.svh"

`include "uart_define.h"
`include "ifDut.sv"
`include "dut_top.v"
`include "uart_top.v"
`include "uart_apb_if.v"
`include "uart_receiver.v"
`include "uart_transmitter.v"
`include "apb_protocol_checker.sv"
`include "apb_protocol_checker_top.sv"
`include "uart_protocol_checker.sv"
`include "uart_protocol_checker_top.sv"

module testTop;
  import uvm_pkg::*;
  `include "cApbTransaction.sv"
  `include "cApbMasterDriver.sv"
  `include "cScoreboard.sv"
  `include "cApbMasterMonitor.sv"
  `include "uvm_env.sv"
  
    wire ctrl_if_0, ctrl_if_1;
    wire uart_0to1, uart_1to0;
    wire ctrl_fif_0, ctrl_fif_1;
    wire ctrl_oif_0, ctrl_oif_1;
    wire ctrl_pif_0, ctrl_pif_1;
    wire ctrl_rif_0, ctrl_rif_1;
    wire ctrl_tif_0, ctrl_tif_1;
  
    apb_protocol_checker_top apb_protocol_checker_top();
    
    uart_protocol_checker_top uart_protocol_checker_top();
    
    ifApbMaster vifApbMaster_0();
    ifApbMaster vifApbMaster_1();
    
    dut_top dut_top(//UART 0
      .pclk_0(vifApbMaster_0.pclk),
      .preset_n_0(vifApbMaster_0.preset_n),
      .pwrite_0(vifApbMaster_0.pwrite),
      .psel_0(vifApbMaster_0.psel), 
      .penable_0(vifApbMaster_0.penable),
      .paddr_0(vifApbMaster_0.paddr),
      .pwdata_0(vifApbMaster_0.pwdata),
      .pstrb_0(vifApbMaster_0.pstrb), 
      .prdata_0(vifApbMaster_0.prdata),
      .pready_0(vifApbMaster_0.pready),
      .pslverr_0(vifApbMaster_0.pslverr),
   `ifdef INTERRUPT_COM
     .ctrl_if_0(ctrl_if_0),
   `else
     .ctrl_tif_0(ctrl_tif_0),
     .ctrl_rif_0(ctrl_rif_0),
     .ctrl_pif_0(ctrl_pif_0),
     .ctrl_oif_0(ctrl_oif_0),
     .ctrl_fif_0(ctrl_fif_0),
   `endif
   //UART 1
      .pclk_1(vifApbMaster_1.pclk),
      .preset_n_1(vifApbMaster_1.preset_n),
      .pwrite_1(vifApbMaster_1.pwrite),
      .psel_1(vifApbMaster_1.psel), 
      .penable_1(vifApbMaster_1.penable),
      .paddr_1(vifApbMaster_1.paddr),
      .pwdata_1(vifApbMaster_1.pwdata),
      .pstrb_1(vifApbMaster_1.pstrb), 
      .prdata_1(vifApbMaster_1.prdata),
      .pready_1(vifApbMaster_1.pready),
      .pslverr_1(vifApbMaster_1.pslverr),
   `ifdef INTERRUPT_COM
     .ctrl_if_1(ctrl_if_1),
   `else
     .ctrl_tif_1(ctrl_tif_1),
     .ctrl_rif_1(ctrl_rif_1),
     .ctrl_pif_1(ctrl_pif_1),
     .ctrl_oif_1(ctrl_oif_1),
     .ctrl_fif_1(ctrl_fif_1),
   `endif
   //For UART protocol checker
   .uart_0to1(uart_0to1),
   .uart_1to0(uart_1to0)
   );
  
  initial begin
    uvm_config_db#(virtual interface ifApbMaster)::set(null,"uvm_test_top.coTest.*","vifApbMaster_0",vifApbMaster_0);
    uvm_config_db#(virtual interface ifApbMaster)::set(null,"uvm_test_top.coTest.*","vifApbMaster_1",vifApbMaster_1);
  end
  
  initial begin
    run_test();
    end
  
endmodule
