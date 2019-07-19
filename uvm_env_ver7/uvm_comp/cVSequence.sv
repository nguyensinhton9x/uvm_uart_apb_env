//--------------------------------------
//Project: The UVM environemnt for UART (Universal Asynchronous Receiver Transmitter)
//Function: User UVM Sequence - This is the TEST PATTERN created by user
//  - User modifty this class to create the expected transactions for the test purpose
//Author:  Pham Thanh Tram, Nguyen Sinh Ton, Doan Duc Hoang, Truong Cong Hoang Viet, Nguyen Hung Quan
//Page:    VLSI Technology
//--------------------------------------
class cVSequence extends uvm_sequence#(cApbTransaction);
  //Register to Factory
	`uvm_object_utils(cVSequence)
  
  cApbMasterWriteSeq WriteSeq;
  // Object must not have veriable "parent" (refer to class cVSequencer)
	function new (string name = "cVSequence");
		super.new(name);
    WriteSeq = cApbMasterWriteSeq::type_id::create("WriteSeq");
	endfunction
  //TEST PATTERN is written at here
  task body();
    // Content of test pattern.
    `uvm_do(WriteSeq)
    $display("cVSequence: %h", req);
  endtask
endclass