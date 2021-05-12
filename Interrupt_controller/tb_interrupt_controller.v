module tb;
parameter NUM_INTR=16;
reg pclk_i,prst_i,penable_i,pwrite_i;
reg [7:0] paddr_i;
reg [7:0] pwdata_i;
wire [7:0] prdata_o;
wire pready_o;
wire pslverr_o;
wire [3:0] intr_to_service_o;
wire intr_valid_o;
reg intr_serviced_i;
reg [NUM_INTR-1:0] intr_active_i;
integer i;

interrupt_controller dut (

//processor

pclk_i, prst_i, paddr_i, pwdata_i, prdata_o, pwrite_i, penable_i, pready_o, pslverr_o, 

intr_to_service_o, intr_valid_o, intr_serviced_i,

//peripheral intr_valid_o is use to say that whatever data processor receive untill this bit is given data is fake, else 
its interrupt
intr_active_i);

initial begin
	pclk_i = 0;
	forever #5 pclk_i = ~pclk_i;
end

initial begin
	prst_i = 1;
	paddr_i = 0;
	pwdata_i = 0;
	pwrite_i = 0;
	penable_i = 0;
	repeat (2) @(posedge pclk_i);
	prst_i = 0;
	//program registers
	/* for (i=0; i<NUM_INTR; i=i+1) begin
	//priority_reg (i,i) this call task function
	@(posedge pclk_i);
	paddr_i = i;//1 to 2 to 3 so on
	pwdata_i = i; // priority value same as i, NUM_INTR-i is reverse priorty
	pwrite_i= 1;
	penable_i = 1;
	wait (pready_o ==1);
	end */
	
	reg_write (0,10);
	reg_write (1,7);
	reg_write (2,5);
	reg_write (3,15);
	reg_write (4,6);
	reg_write (5,3);
	reg_write (6,8);
	reg_write (7,4);
	reg_write (8,0);
	reg_write (9,1);
	reg_write (10,11);
	reg_write (11,2);
	reg_write (12,13);
	reg_write (13,9);
	reg_write (14,14);
	reg_write (15,12);
	//generate interrrupt
	
	intr_active_i = $random;
	#20;
	intr_active_i = intr_active_i | $random; //while handling previous interrupt new interrup are genrated so bitwise oring done to add new with previous left
	#1000;
	intr_active_i = intr_active_i | $random; //new fresh interrupt generated after all previous are serviced
	#1000;
#1000;
$finish;	
	
end
task reg_write(input [7:0] addr, input [7:0] data);
	begin
		@(posedge pclk_i);
			paddr_i = addr;//1 to 2 to 3 so on
			pwdata_i = data; // priority value same as i, 15-i is reverse priorty
			pwrite_i= 1;
			penable_i = 1;
			wait (pready_o ==1);
		@(posedge pclk_i);
			paddr_i = 0;//1 to 2 to 3 so on
			pwdata_i = 0; // priority value same as i, 15-i is reverse priorty
			pwrite_i= 0;
			penable_i = 0;
	end
endtask
initial begin
	forever begin
		@(posedge pclk_i);
			if (intr_valid_o == 1) begin
				//take some time to service interrrupt
				#20;
				intr_active_i[intr_to_service_o] = 0; //dropping interrupt
				intr_serviced_i = 1;
				#10;
				intr_serviced_i = 0;
			end
	end
end	
endmodule
