function takeScreenShot(timeSense)
    
    % to expand rectangular frame(in pixels) to include title and x-y axes.
    ax = gca;
    ax.Units = 'pixels';
    pos = ax.Position;
    ti = ax.TightInset;
    rect = [-ti(1), -ti(2), pos(3)+ti(1)+ti(3), pos(4)+ti(2)+ti(4)];
    
    % to get a movie frame
    F = getframe(ax, rect);
    
    Image = frame2im(F);
    imwrite(Image, strcat('Figure',num2str(timeSense),'.png'));
end