`include "uvm_pkg.sv"
`include "uvm_macros.svh"

`include "ifDut.sv"
`include "dut_top.v"
`include "apb_protocol_checker_top.sv"
`include "uart_protocol_checker_top.sv"

module testTop;
  import uvm_pkg::*;
  `include "cApbTransaction.sv"
  `include "cApbMasterDriver.sv"
  `include "cScoreboard.sv"
  `include "cApbMasterMonitor.sv"
  `include "uvm_env.sv"
  
    ifApbMaster vifApbMaster();
    
    //dut_top dut_top();
  
  initial begin
    uvm_config_db#(virtual interface ifApbMaster)::set(null,"uvm_test_top.coTest.*","vifApbMaster",vifApbMaster);
  end
  
  initial begin
    run_test();
    end
  
endmodule
