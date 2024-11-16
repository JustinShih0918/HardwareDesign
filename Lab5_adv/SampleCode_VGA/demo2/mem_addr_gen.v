module mem_addr_gen(
   input clk,
   input rst,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output [16:0] pixel_addr
   );
    
   reg [9:0] pos_x;
   reg [9:0] pos_y; 
   parameter IMG_W = 320;
   parameter IMG_H = 240;

   wire [9:0] center_x = IMG_W/2;
   wire [9:0] center_y = IMG_H/2;

   parameter ZOOM = 2;

   wire [9:0] xpos = center_x + ((h_cnt - 320) >> ZOOM);
   wire [9:0] ypos = center_y + ((v_cnt - 240) >> ZOOM);
  
   assign pixel_addr = ((xpos % IMG_W) + IMG_W * (ypos % IMG_H)) % 76800;  //640*480 --> 320*240 

   always @ (posedge clk or posedge rst) begin
      if(rst) begin
        pos_x <= 0;
          pos_y <= 0;
      end                                                                                                                
       else begin
          pos_x <= pos_x + 1;
          pos_y <= pos_y + 1;
          if(pos_x == 319) pos_x <= 0;
          else if(pos_y == 239) pos_y <= 0;
       end
   end
    
endmodule
