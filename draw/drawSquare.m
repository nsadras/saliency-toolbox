% drawSquare - draws a solid disk into a 2d image.




function resultMap = drawSquare(bgMap,center,radius,value)

if isstruct(bgMap)
  bg = bgMap.data;
else
  bg = bgMap;
end

% need to clip the top?
tb = center(1) - radius; 
if (tb < 1)
  tb = 1;
end

% need to clip the bottom?
bb = center(1) + radius; 
if (bb > size(bg,1))
  bb = size(bg,1);
end

% need to clip left?
lb = center(2) - radius;
if (lb < 1)
  lb = 1;
end

% need to clip right?
rb = center(2) + radius; 
if (rb > size(bg,2))
  rb = size(bg,2);
end

% draw the disk into the result
result = bg;
if length(size(bgMap)) == 3
    cutResR = result(tb:bb,lb:rb, 1);
    cutResG = result(tb:bb,lb:rb, 2);
    cutResB = result(tb:bb,lb:rb, 3);


    cutResR(:) = value(1);
    cutResG(:) = value(2);
    cutResB(:) = value(3);

    result(tb:bb,lb:rb,1) = cutResR;
    result(tb:bb,lb:rb,2) = cutResG;
    result(tb:bb,lb:rb,3) = cutResB;
else
    cutRes = result(tb:bb,lb:rb, 1);
    cutRes(:) = value(1);
    result(tb:bb,lb:rb) = cutRes;
end

if isstruct(bgMap)
  resultMap = bgMap;
  resultMap.data = result;
  resultMap.label = [resultMap.label ' disk'];
else
  resultMap = result;
end

