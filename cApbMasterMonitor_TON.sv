// Author : TonSinhNguyen
// 22-June-2019

`include "cApbTransaction.sv"
class cApbMasterMonitor extends uvm_monitor;
	uvm_analysis_port #(cApbTransaction) ap_toScoreboardWrite;
	cApbTransaction coApbTransaction;
	virtual ifApbMaster vifApbMaster;
	`uvm_component_utils(cApbMasterMonitor)
	
	function new (string name = "cApbMasterMonitor", uvm_component parent = null);
		super.new(name,parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		`uvm_info("cApbMasterMonitor build_phase","Entered ..", UVM_LOW);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual ifApbMaster)::get(this,"","vifApbMaster",vifApbMaster)) begin
			`uvm_fatal("NOVIF","Can't get vifApbMaster!!!")
		end
		ap_toScoreboardWrite = new("ap_toScoreboardWrite", this);
		`uvm_info("cApbMasterMonitor build_phase","Exit ...",UVM_LOW);
	endfunction
	virtual task run_phase(uvm_phase phase);
		forever begin
			wait (vifApbMaster.psel)
			do begin
				repeat(1) @(posedge vifApbMaster.pclk);
				coApbTransaction.paddr[31:0] = vifApbMaster.paddr[31:0];
				coApbTransaction.pstrb[3:0]  = vifApbMaster.pstrb[3:0];
				coApbTransaction.pwrite      = vifApbMaster.pwrite;
				if(vifApbMaster.penable == 1 && vifApbMaster.pready == 1) begin
					if(coApbTransaction.pwrite == 1) begin
						coApbTransaction.pwdata[31:0] = vifApbMaster.pwdata[31:0];
					end
					else begin
						coApbTransaction.prdata[31:0] = vifApbMaster.prdata[31:0];
					end
					
					if(coApbTransaction.paddr[31:0] == 32'h04 && coApbTransaction.pwdata[31:0] == 32'h01) begin 
					
					end
					
					if (coApbTransaction.paddr[31:0] == 32'h04 && coApbTransaction.pwdata[31:0] == 32'h00) begin
					
					end
				end
			end while(vifApbMaster.penable == 0 && vifApbMaster.pready == 0);
			
			$write("[IF_MON] paddr [31:0]  = 0x%8x\n",vifApbMaster.paddr[31:0]);
			$write("[IF_MON] pwdata  = 0x%8x\n",vifApbMaster.pwdata);
			$write("[IF_MON] prdata  = 0x%8x\n",vifApbMaster.prdata);
			$write("[IF_MON] pwrite  = %1b\n",vifApbMaster.pwrite);
			$write("[IF_MON] penable :: binary is %1b\n",vifApbMaster.penable);
			$write("[IF_MON] psel :: binary is %1b\n",vifApbMaster.psel);
			
			$write("[TRANS_MON] paddr[31:0] :: binary is 0x%8x\n",coApbTransaction.paddr[31:0]);
			$write("[TRANS_MON] pwdata = 0x%8x\n",coApbTransaction.pwdata);
			$write("[TRANS_MON] prdata = 0x%8x\n",coApbTransaction.prdata);
			$write("[TRANS_MON] pwrite = %1b\n",coApbTransaction.pwrite);
	end
	
endtask: run_phase