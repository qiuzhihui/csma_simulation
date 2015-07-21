function [status, timer,comm,counter,flag,ack] = state_machine(pre_status_matrix, pre_next_status_timer,pre_comm_matrix,frame_size...
    ,back_off_counter,first_frame_flag,priority_matrix,max_DIFS,x_position,y_position,ack_matrix)

    global plot_flag;
    %Stacte table
    % 0: idle(nothing to send)
    % 1: waiting for the media available (have something to send)
    % 2: Free media and wait for DIFS (have something to send)
    % 3: Sending Data
    % 4: waiting for SIFS
    % 5: sending ACK
    % 6: wait for ACK
    % -1: Random back-off (Data collision)

    back_off_base=4;
    max_back_off=8;
    

    
    len=size(pre_status_matrix,1);
    status=zeros(len,1);
    timer=zeros(len,1);
    comm = zeros(len,1);
    counter=back_off_counter;
    flag=first_frame_flag;
    ack=ack_matrix;
    
    
    for i=1:len  % go through each nodes;
        count=0; % count the number of node sending data at the same time if >1 there is a collision
        busy_flag=0;
        switch pre_status_matrix(i,1)
            
            case 0 %pre state is idle
                
                    
                    
                    
                for j=1:len         %check if we receive message
                    if(pre_status_matrix(j,2)==3&&first_frame_flag(j)==1) 
                        frame_size(i)=frame_size(j);
                        count=count+1;
                        tmp=pre_comm_matrix(j);

                    end
                end
                if (count==1&&tmp==i)         % need to receive message
                    status(i)=7;    % go to ceceive state
                    timer(i)=frame_size(i);
                    comm(i)=pre_comm_matrix(i);    
                    
                    
              
                elseif(pre_comm_matrix(i)==0) % don need ack message check comm matrix  nothing to send stay idle
                    status(i)=0;
                    timer(i)=0;
                    comm(i)=pre_comm_matrix(i); 
                else  %have something to send check if channel is busy
                    comm(i)=pre_comm_matrix(i); 
                    for j=1:len
                        if(i~=j && pre_status_matrix(j,2)==3||pre_status_matrix(j,2)==5) %channel is busy
                            status(i)=1;
                            timer(i)=0;
                            busy_flag=1;
                        end
                    end
                    if(busy_flag==0)   % channel is not busy
                        status(i)=2;
                        timer(i)=randi([max_DIFS-priority_matrix(i) max_DIFS]);
                    end
                    
                    
                end
                
                
            case 1 %pre state is waiting for media vailiable
                comm(i)=pre_comm_matrix(i); 
                
                for j=1:len         %check if we receive message
                    if(pre_status_matrix(j,2)==3&&first_frame_flag(j)==1) 
                        frame_size(i)=frame_size(j);
                        count=count+1;
                        tmp=pre_comm_matrix(j);

                    end
                end
                if (count==1&&tmp==i)         % need to receive message
                    status(i)=7;              % go to ceceive state
                    timer(i)=frame_size(i);
                    comm(i)=pre_comm_matrix(i);  
                    
                    
                    
                    
                else                %then keep sensing the channel
                    for j=1:len
                        if(pre_status_matrix(j,2)==3||pre_status_matrix(j,2)==5) %channel is busy
                            status(i)=1;
                            timer(i)=0;
                        end
                    end
                    if(status(i)~=1)   % channel is not busy
                        status(i)=2;
                        timer(i)=randi([max_DIFS-priority_matrix(i) max_DIFS]);
                    end
                end

                
            case 2 %pre state is waiting DFS
                comm(i)=pre_comm_matrix(i); 
                if(pre_status_matrix(i,2)==3)  % already start sending data
                    status(i)=3;
                    timer(i)=frame_size(i);
%                     sx=x_position(i);
%                     sy=y_position(i);
%                     dx=x_position(comm(i));
%                     dy=y_position(comm(i));
%                     plot_line(sx,sy,dx,dy,'y')
                    plot_flag(i,1)=1;
                    plot_flag(i,2)=1;
                    plot_flag(i,3)=x_position(i);
                    plot_flag(i,4)=y_position(i);
                    plot_flag(i,5)=x_position(comm(i));
                    plot_flag(i,6)=y_position(comm(i));
                    
                    
                    
                    
                    
                    
                else
                    for j=1:len
                        if(i~=j && pre_status_matrix(j,2)==3 || pre_status_matrix(j,2)==5) %channel is busy
                            
                                status(i)=1;
                                timer(i)=0;
                                
                        end
                    end

                    if(status(i)~=1)   % channel is not busy
                        status(i)=2;
                        timer(i)=pre_next_status_timer(i)-1;
                    end

                    if(status(i)==2 && timer(i)==0) %finish DIFS start sending Data
                        status(i)=3;
                        timer(i)=frame_size(i);
                        flag(i)=1;
                        plot_flag(i,1)=1;
                        plot_flag(i,2)=1;
                        plot_flag(i,3)=x_position(i);
                        plot_flag(i,4)=y_position(i);
                        plot_flag(i,5)=x_position(comm(i));
                        plot_flag(i,6)=y_position(comm(i));
                    end
                    
                    
                    for k=1:len         %check if we receive message
                        if(pre_status_matrix(k,2)==3&&first_frame_flag(k)==1) 
                            frame_size(i)=frame_size(k);
                            count=count+1;
                            tmp=pre_comm_matrix(k);
                        end
                    end
                    if (count==1&&tmp==i)          % need to receive message
                        status(i)=7;               % go to ceceive state
                        timer(i)=frame_size(i);
                        comm(i)=pre_comm_matrix(i);
                    end
                    
                    
                    
                end
                
                
            case 3 %pre state is sending data
                comm(i)=pre_comm_matrix(i);    %keep sending and timer -1
                status(i)=3;
                timer(i)=pre_next_status_timer(i)-1;
                flag(i)=0;
                
                if(timer(i)==0)       %finished sending data, begin waite for ACK
                    status(i)=6;
                    timer(i)=4;
                end
                
                
                
                
            case 4 %pre state is waiting for SIFS
                comm(i)=pre_comm_matrix(i);
                status(i)=4;
                timer(i)=pre_next_status_timer(i)-1;
                
                
                if(timer(i)==0)   %finished waiting SIFS 
                    status(i)= 5;
                    timer(i)=2;
%                     sx=x_position(i);
%                     sy=y_position(i);
%                     dx=x_position(ack(i));
%                     dy=y_position(ack(i));
%                     plot_line(sx,sy,dx,dy,'g')
                    plot_flag(i,1)=1;
                    plot_flag(i,2)=2;
                    plot_flag(i,3)=x_position(i);
                    plot_flag(i,4)=y_position(i);
                    plot_flag(i,5)=x_position(ack(i));
                    plot_flag(i,6)=y_position(ack(i));
                    
                end
                
                
                
            case 5 %pre state is sending ACK
                comm(i)=pre_comm_matrix(i);
                status(i)=5;
                timer(i)=pre_next_status_timer(i)-1;
                
                
                if(timer(i)==0)   %finished sending ACK begin idle
                    status(i)= 0;
                    timer(i)=0;
                    comm(i)=pre_comm_matrix(i);
                end
                
                
            case 6 %pre state is waiting for ACK
                comm(i)=pre_comm_matrix(i);
                status(i)=6;
                timer(i)=pre_next_status_timer(i)-1;
                
                if(timer(i)==0) %finished waiting for ACK
                    
                    
                    
                           if(pre_status_matrix(comm(i),1)==5) % received ACK from the receiver end begin idle
                                status(i)=0;
                                timer(i)=0;
                                comm(i)=0;
                                counter(i)=0;   %flash counter when the data is successfully sended
                                
                                
                                
                            else %collision happend random exponential back-off
                                status(i)=-1;
                                counter(i) = counter(i)+1;
                                timer(i) = randi([1 (back_off_base^counter(i))]);  %random exponential back-off


                                if(counter> max_back_off) %back-off excceed max value give up sending data flash the counter
                                    status(i)=0;
                                    counter(i)=0;
                                    timer(i)=0;
                                    comm(i)=0;
                                end

                           end
                            
                           for k=1:len         %check if we receive message
                                if(pre_status_matrix(k,2)==3&&first_frame_flag(k)==1) 
                                    frame_size(i)=frame_size(k);
                                    count=count+1;
                                    tmp=pre_comm_matrix(k);
                                end
                            end
                            if (count==1&&tmp==i)          % need to receive message
                                status(i)=7;               % go to ceceive state
                                timer(i)=frame_size(i);
                                comm(i)=pre_comm_matrix(i);
                            end
                            
                           
                           
                    
                end
                
            case 7 %pre state is receiving message
                comm(i)=pre_comm_matrix(i);
                status(i)=7;
                timer(i)=pre_next_status_timer(i)-1;
                
                if(timer(i)==0)   %finished receiving begin SIFS and find out send ack back to who
                    status(i)= 4;
                    timer(i)=2;
                    for j=1:len
                        if pre_status_matrix(j)==3
                            ack(i)=j;
                        end
                    end
                end
                
                
                
                
                
            case -1 %pre state is Random back-off (Data collision)
                comm(i)=pre_comm_matrix(i);
                
                for k=1:len         %check if we receive message
                    if(pre_status_matrix(k,2)==3&&first_frame_flag(k)==1) 
                        frame_size(i)=frame_size(k);
                        count=count+1;
                        tmp=pre_comm_matrix(k);
                    end
                end
                if (count==1&&tmp==i)          % need to receive message
                    status(i)=7;               % go to ceceive state
                    timer(i)=frame_size(i);
                    comm(i)=pre_comm_matrix(i);
                
              
                
                else
                    for j=1:len % check if channel is busy
                        if(pre_status_matrix(j,2)==3||pre_status_matrix(j,2)==5) %channel is busy
                            status(i)=-1;
                            timer(i)=pre_next_status_timer(i);
                            busy_flag=1;
                        end
                    end

                    if(busy_flag==0)   % channel is not busy
                        status(i)=-1;
                        timer(i)=pre_next_status_timer(i)-1;
                    end

                    if(timer(i)==0) %finished random back-off
                        status(i)=0;
                        timer(i)=0;
                    end
                    
                end
                
                
        end
                
       
        
    end
    
    
   

end