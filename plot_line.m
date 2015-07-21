function plot_line

global plot_flag;
n=size(plot_flag,1);
xline=zeros(n,100);
yline=zeros(n,100);



for i=1:n
    if plot_flag(i,1)==1
        if plot_flag(i,2)==1
            type='y';
        else
            type='g';
        end
        h(i) = animatedline('Color',type,'LineWidth',3);
        xline(i,:) = linspace(plot_flag(i,3),plot_flag(i,5),100);
        yline(i,:) = linspace(plot_flag(i,4),plot_flag(i,6),100);        
    end

end


for k = 1:100
    for i=1:n
        if plot_flag(i,1)==1
            addpoints(h(i),xline(i,k),yline(i,k));
            drawnow
        end
    end
end

for i=1:n
    if plot_flag(i,1)==1
        clearpoints(h(i))
    end
end





plot_flag=zeros(n+1,6);


end








