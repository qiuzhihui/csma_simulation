function plot_line(sx,sy,dx,dy,type)

h = animatedline('Color',type,'LineWidth',3);
xline = linspace(sx,dx,100);
yline = linspace(sy,dy,100);

for k = 1:length(xline)
    addpoints(h,xline(k),yline(k));
    drawnow
end
clearpoints(h)

end
