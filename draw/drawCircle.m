% drawDisk - draws a solid disk into a 2d image.
%
% resultMap = drawDisk(bgMap,center,radius,value)
%    Draws a solid disk with radius 'radius' around 'center'
%    into the background map 'bgMap' and fills it
%    with 'value' (an rgb tuple).
%    Returns a map structure if bgMap is given as a map structure.
%    Returns a 2d array if bgMap is given as a 2d array.



function resultMap = drawCircle(bgMap,center,radius,value)

if isstruct(bgMap)
  bg = bgMap.data;
else
  bg = bgMap;
end

% create the disk
[xx,yy] = meshgrid(-radius:radius);
disk = (xx.^2 + yy.^2 <= radius^2);

% need to clip the top?
tb = center(1) - radius; td = 1;
if (tb < 1)
  td = 2 - tb;
  tb = 1;
end

% need to clip the bottom?
bb = center(1) + radius; bd = size(disk,2);
if (bb > size(bg,1))
  bd = bd - (bb - size(bg,1));
  bb = size(bg,1);
end

% need to clip left?
lb = center(2) - radius; ld = 1;
if (lb < 1)
  ld = 2 - lb;
  lb = 1;
end

% need to clip right?
rb = center(2) + radius; rd = size(disk,2);
if (rb > size(bg,2))
  rd = rd - (rb - size(bg,2));
  rb = size(bg,2);
end

% draw the disk into the result
result = bg;

if length(size(bgMap)) == 3
    cutResR = result(tb:bb,lb:rb, 1);
    cutResG = result(tb:bb,lb:rb, 2);
    cutResB = result(tb:bb,lb:rb, 3);

    cutDisk = disk(td:bd,ld:rd);

    cutResR(cutDisk) = value(1);
    cutResG(cutDisk) = value(2);
    cutResB(cutDisk) = value(3);

    result(tb:bb,lb:rb,1) = cutResR;
    result(tb:bb,lb:rb,2) = cutResG;
    result(tb:bb,lb:rb,3) = cutResB;
else
    cutRes = result(tb:bb,lb:rb, 1);
    cutDisk = disk(td:bd,ld:rd);
    cutRes(cutDisk) = value(1);
    result(tb:bb,lb:rb) = cutRes;
end

if isstruct(bgMap)
  resultMap = bgMap;
  resultMap.data = result;
  resultMap.label = [resultMap.label ' disk'];
else
  resultMap = result;
end
