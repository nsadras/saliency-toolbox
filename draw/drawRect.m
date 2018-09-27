function resultMap = drawRect(bgMap,center,h,w,theta,value)
% drawRect - draws a solid rectangle into a 2d image.
%   bgMap - background image to draw on
%   center - coordinates of rectangle center
%   h - rectangle height
%   w - rectangle width
%   theta - angle to rotate rectangle
%   value - rgb tuple that indicates rectangle color

if isstruct(bgMap)
  bg = bgMap.data;
else
  bg = bgMap;
end

recw = round( abs(h*sin(theta)) + abs(w*cos(theta)) );
rech = round( abs(h*cos(theta)) + abs(w*sin(theta)) );

x = -round(recw/2) : round(recw/2);
y = -round(rech/2) : round(rech/2);

% create the rectangle
[X, Y] = meshgrid(x, y);
xinv = X*cos(-theta) - Y*sin(-theta);
yinv = X*sin(-theta) + Y*cos(-theta);
rect = (xinv < w/2) & (xinv > -w/2) & (yinv < h/2) & (yinv > -h/2);

% need to clip the top?
tb = center(1) - round(rech/2); td = 1;
if (tb < 1)
  td = 2 - tb;
  tb = 1;
end

% need to clip the bottom?
bb = center(1) + round(rech/2); bd = size(rect,1);
if (bb > size(bg,1))
  bd = bd - (bb - size(bg,1));
  bb = size(bg,1);
end

% need to clip left?
lb = center(2) - round(recw/2); ld = 1;
if (lb < 1)
  ld = 2 - lb;
  lb = 1;
end

% need to clip right?
rb = center(2) + round(recw/2); rd = size(rect,2);
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

    cutDisk = rect(td:bd,ld:rd);

    cutResR(cutDisk) = value(1);
    cutResG(cutDisk) = value(2);
    cutResB(cutDisk) = value(3);

    result(tb:bb,lb:rb,1) = cutResR;
    result(tb:bb,lb:rb,2) = cutResG;
    result(tb:bb,lb:rb,3) = cutResB;
else
    cutRes = result(tb:bb,lb:rb, 1);
    cutDisk = rect(td:bd,ld:rd);
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
