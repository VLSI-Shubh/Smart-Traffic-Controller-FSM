module traffic_controller ( 
    input [3:0] Traffic,
    input clk, rst, 
    output reg [3:0]Red, Green, Yellow
    );  

    parameter [2:0] s_idle = 3'b000,
        s_13gg = 3'b001,
        s_13yy = 3'b010,
        s_24gg = 3'b011,
        s_24yy = 3'b100;
        reg [2:0] ps,ns;
        reg [16:0]max_timer; 
        reg done;
        
    // Now lets write the state transition diagram 
    always @(*) begin
        case (ps)
            s_idle: if (~|Traffic) begin
                ns = s_idle;
            end else begin
                if (Traffic[0] || Traffic[2]) begin
                    ns = s_13gg;
                end else begin
                    if (Traffic[1] || Traffic[3]) begin
                        ns = s_24gg;
                    end else begin
                        ns = s_idle;
                    end
                end
            end
            s_13gg: if (done) begin
                ns = s_13yy;
            end else begin
                ns = s_13gg;
            end
            s_13yy: if (done) begin
                ns = s_idle;
            end else begin
                ns = s_13yy;
            end
            s_24gg: if (done) begin
                ns =s_24yy;
            end else begin
                ns = s_24gg;
            end
            s_24yy: if (done) begin
                ns = s_idle;
            end else begin
                ns = s_24yy;
            end
            default: ns = s_idle;
        endcase
    end
    // Now we write the state memory 

    always @(posedge clk or posedge rst ) begin
        if (rst) begin
            ps <= s_idle;
        end else begin
            ps<=ns;
        end
    end
    // Memory of the state done

    //Now comes the counter, the main and the ped counter for that we declare the max times first 
    parameter GREEN_TIME  = 16'd55;
    parameter YELLOW_TIME = 16'd10;



    // Main timer block

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            max_timer <= 16'd0;
            done <= 0;
        end else begin
            case (ps)
                s_13gg: begin
                    if (max_timer == 0) begin
                        max_timer <= GREEN_TIME;
                    end else begin
                        if (max_timer > 0) begin
                            max_timer <= max_timer - 1;
                            done <= (max_timer-1 ==0);
                        end else begin
                            done <= 0;
                        end
                    end
                end
                s_13yy: begin
                    if (max_timer == 0) begin
                        max_timer <= YELLOW_TIME;
                    end else begin
                        if (max_timer > 0) begin
                            max_timer <= max_timer - 1;
                            done <= (max_timer-1 == 0);
                        end else begin
                            done <= 0;
                        end
                    end
                end
                s_24gg: begin
                    if (max_timer == 0) begin
                        max_timer <= GREEN_TIME;
                    end else begin
                        if (max_timer > 0) begin
                            max_timer <= max_timer - 1;
                            done <= (max_timer-1 ==0);
                        end else begin
                            done <= 0;
                        end
                    end
                end
                s_24yy: begin
                    if (max_timer == 0) begin
                        max_timer <= YELLOW_TIME;
                    end else begin
                        if (max_timer > 0) begin
                            max_timer <= max_timer - 1;
                            done <= (max_timer-1 ==0);
                        end else begin
                            done <= 0;
                        end
                    end
                end
                default : done <= 0; 
            endcase
        end
    end

    // Now comes the output logic
    always @(*) begin
        // Default values for all outputs
         Red = 4'b0000;
         Green = 4'b0000;
         Yellow = 4'b0000;

        case (ps)
            s_idle: begin
                Red = 4'b1111;
                Green = 4'b0000;
                Yellow = 4'b0000;
            end

            s_13gg: begin
                Red  = 4'b1010;
                Green = 4'b0101;
            end

            s_13yy: begin
                Red = 4'b1010;
                Yellow = 4'b0101;
                Green = 4'b0000;
            end

            s_24gg: begin
                Red  = 4'b0101;
                Green = 4'b1010;
            end

            s_24yy: begin
                Red = 4'b0101;
                Yellow = 4'b1010;
                Green = 4'b0000;
            end

            default: begin
                Red = 4'b1111; 
            end
        endcase
    end
endmodule