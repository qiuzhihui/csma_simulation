function [status, timer,flag] = working_node(pre_status_matrix, pre_next_status_timer,frame_size,first_frame_flag)
    

    len=size(pre_status_matrix,1);
    status=zeros(len,1);
    timer=zeros(len,1);
    flag=first_frame_flag;
    
    for i=1:len
        if(pre_status_matrix(i)==4 && pre_next_status_timer(i)==1) %SIFS sending ack next time slot;
            status(i)=5;
            timer(i)=2;
            
        end
        
        
        if(pre_status_matrix(i)==3 && pre_next_status_timer(i)>1) %SIFS sending ack next time slot;
            status(i)=3;
            timer(i)= pre_next_status_timer(i)-1;
            
        end
        
        
        if(pre_status_matrix(i)==5 && pre_next_status_timer(i)>1) %SIFS sending ack next time slot;
            status(i)=5;
            timer(i)= pre_next_status_timer(i)-1;
            
        end
        
        if(pre_status_matrix(i)==2 && pre_next_status_timer(i)==1) %DIFS end start sending data;
            status(i)=3;
             timer(i) = frame_size;
             flag(i)=1;
        end
        
    end
    
    

end