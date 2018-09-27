function resultMap = drawText( bgMap, pos, txt )
%DRAWTEXT Draw text onto an image
x = round( pos(2) / 2 );
y = round( (size(bgMap, 1) - pos(1)) / 2 );

fig = figure('position', [0 0 200 200], 'visible', 'off');
t = text('units', 'pixels', 'position', [x y],'FontSize',15,'FontWeight','bold', 'string', txt);
set(gca,'xtick',[],'ytick',[])
ax = gca;
ax.Units = 'pixels';
F = getframe(ax,[0 0 100 100]);
close(fig)

c = F.cdata(:,:,:);
[i,j,~] = find(c==0);
ind = sub2ind(size(bgMap),i,j);
bgMap(ind) = uint8(255);

resultMap = bgMap;
end

