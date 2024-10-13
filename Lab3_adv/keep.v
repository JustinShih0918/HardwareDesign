if(pb_out_right) begin
    if (cor_pos_index == cor_A && head == RIGHT) begin
        next_head <= DOWN;
        next_pos_index <= cor_B;
    end
    else if(cor_pos_index == cor_B && head == DOWN) begin
        next_head <= LEFT;
        next_pos_index <= cor_G;
    end
    else if(cor_pos_index == cor_C && head == DOWN) begin
        next_head <= LEFT;
        next_pos_index <= cor_D;
    end
    else if(cor_pos_index == cor_D && head == LEFT) begin
        next_head <= UP;
        next_pos_index <= cor_E;
    end
    else if(cor_pos_index == cor_E && head == UP) begin
        next_head <= RIGHT;
        next_pos_index <= cor_G;
    end
    else if(cor_pos_index == cor_F && head == UP) begin
        next_head <= RIGHT;
        next_pos_index <= cor_A;
    end
    else if(cor_pos_index == cor_G && head == RIGHT) begin
        next_head <= DOWN;
        next_pos_index <= cor_C;
    end
    else if(cor_pos_index == cor_G && head == LEFT) begin
        next_head <= UP;
        next_pos_index <= cor_F;
    end
    else invalid_move <= 1;
end
else if(pb_out_left) begin
    if(cor_pos_index == cor_A && head == LEFT) begin
        next_head = DOWN;
        next_pos_index = cor_F;
    end
    else if(cor_pos_index == cor_B && head == UP) begin
        next_head = LEFT;
        next_pos_index = cor_A;
    end
    else if(cor_pos_index == cor_C && head == UP) begin
        next_head = LEFT;
        next_pos_index = cor_G;
    end
    else if(display == cor_D && head == RIGHT) begin
        next_head = UP;
        next_pos_index = cor_C;
    end
    else if(cor_pos_index == cor_E && head == DOWN) begin
        next_head = RIGHT;
        next_pos_index = cor_D;
    end
    else if(cor_pos_index == cor_F && head == DOWN) begin
        next_head = RIGHT;
        next_pos_index = cor_G;
    end
    else if(cor_pos_index == cor_G && head == LEFT) begin
        next_head = DOWN;
        next_pos_index = cor_E;
    end
    else if(cor_pos_index == cor_G && head == RIGHT) begin
        next_head = UP;
        next_pos_index = cor_B;
    end
    else invalid_move <= 1;
end
else if(pb_out_up) begin
    if(cor_pos_index == cor_B && head == DOWN) begin
        next_head = DOWN;
        next_pos_index = cor_C;
    end
    else if(cor_pos_index == cor_C && head == UP) begin
        next_display = B;
        next_head = UP;
        next_pos_index = cor_B;
    end
    else if(cor_pos_index == cor_E && head == UP) begin
        next_head = UP;
        next_pos_index = cor_F;
    end
    else if(cor_pos_index == cor_F && head == DOWN) begin
        next_display = E;
        next_head = DOWN;
        next_pos_index = cor_E;
    end
    else invalid_move <= 1;
end
next_record[next_pos_index] = 0;