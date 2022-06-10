`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:20:31 12/03/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze #(parameter maze_width = 6)(
input 		          	  clk,
input [maze_width - 1:0]  starting_col, starting_row, 
input  			  			  maze_in, 			
output reg [maze_width - 1:0] row, col,	 		
output reg			  		  maze_oe,			
output reg		  			  maze_we, 			
output reg		  			  done);


reg [3:0] state, next_state;
reg [maze_width - 1:0] r_ant, c_ant;
reg [1:0] dir = 0;// directia default (sus)
reg [1:0] dir_aux;

`define start 0
`define directie 1
`define testare_directie 2
`define perete 3
`define testare_perete 4
`define verificare_blocaj 5
`define fundatura 6
`define stop 7



always @(posedge clk) begin
	if(done != 1)
		state <= next_state;
end

always @(*) begin
	maze_oe = 0;
	maze_we = 0;
	done = 0;
	
	case(state)
		`start: begin
				  row = starting_row;
				  col = starting_col;
				  r_ant = row;
				  c_ant = col;
				  
				  maze_we = 1;
				  next_state = `directie;
		end
		
		`directie: begin
					  case(dir)//asociez fiecarei directii un caz
							0: row = row - 1;//sus
							1: row = row + 1;//jos
							2: col = col - 1;//dreapta
							3: col = col + 1;//stanga
						endcase
							
						maze_oe = 1;
						next_state = `testare_directie;
		end
						
		`testare_directie: begin
								 if (maze_in == 0) begin
										r_ant = row;
										c_ant = col;
										
										maze_we = 1;
										next_state = `perete;
								 end
								 else begin
										row = r_ant;
										col = c_ant;//se intoarce la pozitia initiala
										
										dir = dir + 1;//cauta directia corecta
										next_state = `directie;
								 end		 
		end
		`perete: begin
					case(dir)
						0: col = col + 1;//fiecarei directii i se asociaza peretele drept
						1: col = col - 1;
						2: row = row - 1;
						3: row = row + 1;
					endcase
						
						maze_oe = 1;
						next_state = `testare_perete;
		end
					
		`testare_perete: begin
							  if (maze_in == 1) begin
									row = r_ant;
									col = c_ant;
									
									case(dir)//daca exista perete => incearca sa avanseze
										  0: row = row - 1;
									     1: row = row + 1;
										  2: col = col - 1;
										  3: col = col + 1;
									endcase
							
									maze_oe = 1;
									next_state = `verificare_blocaj;
							  end
							  else begin 
									r_ant = row;
									c_ant = col;
									
									maze_we = 1; //daca peretele drept e 0 se duce automat catre el 
									if (row == 0 || row == 63 || col == 0 || col == 63)
										 next_state = `stop;
									else begin
									
									if (dir > 1)//schimbarea directiei cu cea a peretelui 
										dir = dir - 2;
									else if (dir == 0)
										dir = 3;
									else if (dir == 1)
										dir = 2;
										
									next_state = `perete;
									end
							  end			  
		end
		
		`verificare_blocaj: begin
								  if (maze_in == 0) begin
										r_ant = row;
										c_ant = col;
										
										maze_we = 1;
										if (row == 0 || row == 63 || col == 0 || col == 63)
											 next_state = `stop;
										else
										next_state = `perete;	
								  end
								  else begin 
										row = r_ant;
										col = c_ant;
										dir_aux = dir;
										
										if (dir < 2) //schimba dierctia spre stanga
											 dir = dir + 2; 
										else if (dir == 2)
													dir = 1;
										else if (dir == 3)
													dir = 0;
										
										case(dir) //incearca sa mearga spre stanga
											0: row = row - 1;
											1: row = row + 1;
											2: col = col - 1;
											3: col = col + 1;
										endcase
										
										maze_oe = 1;
										next_state = `fundatura;
								  end						  
		end
		
		`fundatura: begin
						if (maze_in == 0) begin 
							 r_ant = row;
							 c_ant = col;
							 
							 maze_we = 1;
							 if (row == 0 || row == 63 || col == 0 || col == 63)
								  next_state = `stop;
							 else
							 next_state = `perete;
						end
						else begin 
							 dir = dir_aux;  
							 if (dir == 0) //isi schimba directia -> merge inapoi
								  dir = 1;
							 else if (dir == 1)
										 dir = 0;
							 else if (dir == 2)
										 dir = 3;
							 else if (dir == 3)
										 dir = 2;
							
							 row = r_ant;
							 col = c_ant;
							 
							 next_state = `perete;
						end			
		end
		
		`stop: done = 1;
		
		default: next_state = `start;
		
		endcase	
end

endmodule
