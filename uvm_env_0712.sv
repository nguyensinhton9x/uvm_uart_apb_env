//--------------------------------------
//Project: The UVM environemnt for UART (Universal Asynchronous Receiver Transmitter)
//Function: TOP UVM environment
// - cApbMasterDriver    - APB master model
// - cApbMasterMonitor   - APB master monitor
// - cApbMasterSequencer - APB master sequencer
// - 
//Author:  Pham Thanh Tram, Nguyen Sinh Ton, Doan Duc Hoang, Truong Cong Hoang Viet, Nguyen Hung Quan
//Page:    VLSI Technology
//--------------------------------------

typedef class cApbMasterAgent;

class cApbMasterSequencer extends uvm_sequencer#(cApbTransaction);
	
	cApbMasterAgent coApbMasterAgent;
	
	virtual ifInterrupt vifInterrupt;
	
	`uvm_component_utils(cApbMasterSequencer)
  
	function new (string name = "cApbMasterSequencer", uvm_component parent = null);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual interface ifInterrupt)::get(this,"","vifInterrupt",vifInterrupt)) begin
			`uvm_fatal("cVSequencer","Can't get vifInterrupt!!!")
		end
	endfunction
	
endclass

// Need to add other sequences (e.g. cApbMasterReadSeq)
class cApbMasterWriteSeq extends uvm_sequence#(cApbTransaction);
	`uvm_object_utils(cApbMasterWriteSeq)
	`uvm_declare_p_sequencer(cApbMasterSequencer)

	rand logic [31:0] addr;
	rand logic [31:0] data;
	rand logic [ 3:0] be;	

	function new (string name = "cApbMasterWriteSeq");
		super.new(name);
	endfunction

	virtual task body();
		cApbTransaction coApbTransaction;
		coApbTransaction = cApbTransaction::type_id::create("coApbTransaction");
		start_item(coApbTransaction);
		assert(coApbTransaction.randomize() with {
			coApbTransaction.paddr  == addr;
			coApbTransaction.pwdata == data;
			coApbTransaction.pstrb  == be;
			coApbTransaction.pwrite == 1;
		});
		finish_item(coApbTransaction);
	endtask
endclass

class cApbMasterAgent extends uvm_agent;
    cApbMasterDriver    coApbMasterDriver;
    cApbMasterSequencer coApbMasterSequencer;
    cApbMasterMonitor   coApbMasterMonitor;

    `uvm_component_utils(cApbMasterAgent)
	
    function new(string name = "cApbMasterAgent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        coApbMasterDriver    = cApbMasterDriver::type_id::create("coApbMasterDriver",this);
        coApbMasterSequencer = cApbMasterSequencer::type_id::create("coApbMasterSequencer",this);
        coApbMasterMonitor   = cApbMasterMonitor::type_id::create("coApbMasterMonitor",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        coApbMasterDriver.seq_item_port.connect(coApbMasterSequencer.seq_item_export);
    endfunction

endclass


class cVSequencer extends uvm_sequencer#(cApbTransaction);

	//cApbMasterSequencer coApbMasterSequencerTx;
	//cApbMasterSequencer coApbMasterSequencerRx;
	
	cApbMasterAgent coApbMasterAgentTx;
	cApbMasterAgent coApbMasterAgentRx;

	cScoreboard coScoreboard;
	
	`uvm_component_utils(cVSequencer)

   // TODO: component must have variable "parent"
   //       object must not have veriable "parent" (refer to class cVSequence) 
	function new (string name = "cVSequencer", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

endclass


class cVSequence extends uvm_sequence#(cApbTransaction);
	`uvm_object_utils(cVSequence)

	function new (string name = "cVSequence");
		super.new(name);
	endfunction

  task body();
    // Content of test pattern.
  endtask
endclass

class cEnv extends uvm_env;

	cApbMasterAgent coApbMasterAgentTx;
	cApbMasterAgent coApbMasterAgentRx;

	cScoreboard coScoreboard;

	cVSequencer coVSequencer;
	
	`uvm_component_utils(cEnv)
	
	function new (string name = "cEnv", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		coApbMasterAgentTx = cApbMasterAgent::type_id::create("coApbMasterAgentTx",this);
		coApbMasterAgentRx = cApbMasterAgent::type_id::create("coApbMasterAgentRx",this);
		coScoreboard = cScoreboard::type_id::create("coScoreboard",this);
		coVSequencer = cVSequencer::type_id::create("coVSequencer",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		$cast(coVSequencer.coApbMasterAgentTx, this.coApbMasterAgentTx);
		$cast(coVSequencer.coApbMasterAgentRx, this.coApbMasterAgentRx);
		
		$cast(coVSequencer.coScoreboard, this.coScoreboard);

		coApbMasterAgentTx.coApbMasterMonitor.ap_toScoreboardWrite.connect(coScoreboard.aimp_frmMonitorWrite);
		// Add more connection here
	endfunction
	
endclass

class cTest extends uvm_test;

	cEnv coEnv;
	cVSequence coVSequence; 
		
	`uvm_component_utils(cTest)

	function new (string name = "cTest", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		coEnv = cEnv::type_id::create("coEnv",this);
		coVSequence = cVSequence::type_id::create("coVSequence");
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info(get_full_name(), "run phase completed.", UVM_LOW)
		phase.raise_objection(this);
		fork
			coVSequence.start(coEnv.coVSequencer);
			begin
				#1ms;
				`uvm_error("TEST SEQUENCE", "TIMEOUT!!!")
			end
		join_any
		disable fork;
		phase.drop_objection(this);
	endtask

endclass


