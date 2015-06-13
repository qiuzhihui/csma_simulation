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
%    frame_size=10;
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
 frame_size=5;
 simulation_time=100;
 back_off_base=4;



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
back_off_counter=zeros(n+1,1);
first_frame_flag=zeros(n+1,1);

% set simple case;
comm_matrix(2,1)=1;
comm_matrix(3,1)=1;

first_frame_flag(2,1)=1;
first_frame_flag(3,1)=1;








for clock= 2: simulation_time

    %comm_table is not 0 means have something to send;
    %first fill the current status matrix with sending status;
    [status,timer,flag] = working_node(status_matrix(:,clock-1),next_status_timer(:,clock-1),frame_size,first_frame_flag);
    status_matrix(:,clock) = status;
    next_status_timer(:,clock) = timer;
    first_frame_flag = flag;

    
    %now update current status and timer based on previous status and timer
    %update comm_matrix also;
    [status,timer,comm,counter,flag] = state_machine(status_matrix(:,clock-1:clock),next_status_timer(:,clock-1),comm_matrix(:,clock-1)...
        ,frame_size,back_off_counter,first_frame_flag);
    status_matrix(:,clock) = status;
    next_status_timer(:,clock) = timer;
    comm_matrix(:,clock) = comm;
    back_off_counter = counter;
    first_frame_flag = flag;

    ss=1;

end

status_matrix
next_status_timer

sss=1;






























