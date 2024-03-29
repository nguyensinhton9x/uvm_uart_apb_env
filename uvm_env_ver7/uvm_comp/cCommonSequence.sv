//--------------------------------------
//Project: The UVM environemnt for UART (Universal Asynchronous Receiver Transmitter)
//Function: Common sequences help create the user sequences easily
//  - User adds more the common sequences in this file
//Author:  Pham Thanh Tram, Nguyen Sinh Ton, Doan Duc Hoang, Truong Cong Hoang Viet, Nguyen Hung Quan
//Page:    VLSI Technology
//--------------------------------------

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