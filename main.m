% master - nodes communication prototype with CSMA/CA algorithm;
% Zach - June 11, 20115


clear all
close all
clc



% %---------------------Input Parameters---------------------------{
% n=input('Number of nodes [5]? ');
% 
% if length(n)==0
% 
%    n=5;
% 
% end
% 
% frame_size=input('Average Transmission Time (packet size) [5]? ');
% 
% if length(frame_size)==0
% 
%    frame_size=zeros(n+1,1)+10;
% 
% end
% 
% 
% 
% simulation_time=input('Simulation Time in ms (SlotTime=2) [600]? ');%ms
% 
% if length(simulation_time)==0
% 
%    simulation_time=600;
% 
% 
% end
% 
% %---------------------Input Parameters---------------------------}

 n=5;
 simulation_time=100;
 back_off_base=4;
 frame_size=zeros(n+1,1)+10;
 max_DIFS=4;
 visualize=1;
 r=3;
 random_prob=0.05;
 movepara=5;


global plot_flag;
plot_flag=zeros(n+1,6);  %col1:flag  col2:send/ack col3:sendingx col4 sendingy col5:revx col6 revy



% Simulation parameter
% All the status are measured by slot
% SIFS: 2 slots;
% DIFS: 2 slots + SIFS;
% PIFS: 1 slots + SIFS;
% Frame size(each): 2 slot;
% ACK: 2 slot;


%State table
% 0: idle(nothing to send)
% 1: waiting for the media available (have something to send)
% 2: Free media and wait for DIFS (have something to send)
% 3: Sending Data
% 4: waiting for SIFS
% 5: sending ACK
% 6: wait for ACK
% 7: recieving Data
% -1: Random back-off,  not receiving ACK (Data collision)


% In the simulation all the nodes only talk to master, master can talk to 
% each nodes; frames size are fixed


% rows represent which node columes represent time
status_matrix =  zeros(n+1,simulation_time);  %status of each node, the first row is master's status
next_status_timer = zeros(n+1,simulation_time); %count the time left for current status
comm_matrix = zeros(n+1,simulation_time);     %which node has something to send at the time
ack_matrix = zeros(n+1,simulation_time);
back_off_counter=zeros(n+1,1);
first_frame_flag=zeros(n+1,1);
priority_matrix=zeros(n+1,1);   %now we only support 2 priorities high and low their DIFS is 3 and 4 slots


%comm_matrix(2,1)=1;
%comm_matrix(3,1)=1;


if visualize==1
    masterx=0;
    mastery=0;
    figure
    %plot master and slave nodes
    x_position=zeros(1,n);
    y_position=zeros(1,n);
    for i=1:360/n:360
        x_position(floor(i*n/360)+1)=r*sin(i/360*2*pi);
        y_position(floor(i*n/360)+1)=r*cos(i/360*2*pi);

    end 
    x_position=[masterx x_position];
    y_position=[mastery y_position];
    h(1)=plot(x_position(1),y_position(1),'or','MarkerSize',16,'MarkerEdgeColor','k','Marker','o');
    hold on;
    for i=2:n+1
        h(i)=plot(x_position(i),y_position(i),'or','MarkerSize',10,'MarkerEdgeColor','b','Marker','o');
    end
    axis([-5 5 -5 5]);
    position=[x_position;y_position];
    
end
    



for clock= 2: simulation_time
    
   %random location generator 
   if visualize==1
       random = (rand(2,n+1)-0.5)/movepara;
       position=position+random;
       x_position=position(1,:);
       y_position=position(2,:);
       for i=1:n+1
           set(h(i),'XData',position(1,i),'YData',position(2,i))
           pause(0.015);
       end
   end
    
    
    
    
   % random frame generator 
   for i=1:n+1
        if(comm_matrix(i,clock-1)==0&&status_matrix(i,clock-1)~=7)
            if(rand(1)<random_prob)
                random=randi(n);
                if(random>=i) 
                    random=random+1;
                end
                comm_matrix(i,clock-1)=random;
                first_frame_flag(i)=1;
            end
        end

    end    
    
    %comm_table is not 0 means have something to send;
    %first fill the current status matrix with sending status;
    [status,timer,flag] = working_node(status_matrix(:,clock-1),next_status_timer(:,clock-1),frame_size,first_frame_flag);
    status_matrix(:,clock) = status;
    next_status_timer(:,clock) = timer;
    first_frame_flag = flag;
    
    
    

    
    %now update current status and timer based on previous status and timer
    %update comm_matrix also;
    [status,timer,comm,counter,flag,ack] = state_machine(status_matrix(:,clock-1:clock),next_status_timer(:,clock-1),comm_matrix(:,clock-1)...
        ,frame_size,back_off_counter,first_frame_flag,priority_matrix,max_DIFS,x_position,y_position,ack_matrix(:,clock-1));
    status_matrix(:,clock) = status;
    next_status_timer(:,clock) = timer;
    comm_matrix(:,clock) = comm;
    back_off_counter = counter;
    first_frame_flag = flag;
    ack_matrix(:,clock)=ack;
    
    
    
    
    
    %plot the sending/Ack signal

    if visualize==1
        if(sum(plot_flag(:,1))>=1)
            plot_line;
        end
    end
    

    ss=1;

end

status_matrix
next_status_timer






figure
%Visualize states Matrix 
imagesc(status_matrix);            %# Create a colored plot of the matrix values
%colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)
                         
textStrings = num2str(status_matrix(:),'%i');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:size(status_matrix,2),1:size(status_matrix,1));   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:)...      %# Plot the strings
                );      
            

set(gca,'YTick',1:n+1,...                       %# Change the axes tick marks
'YTickLabel',{'Master','Slave1','Slave2','Slave3','Slave4','Slave5'},...
'TickLength',[0 0]);

title('CSMA/CA Simulation result')

sss=1;






























