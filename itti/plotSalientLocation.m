% plotSalientLocation - plots the attended location into an existing figure.
%
% plotSalientLocation(winner,lastWinner,salParams,shapeData)
%    Plots the winning location into the current figure. 
%    Depending on the settings in salParams, the contour of the 
%    attended region or a circle centered at the attended location 
%    is drawn in yellow. If there is a valid lastWinner, 
%    a red line connects lastWinner with winner.
%       winner: the attended location in image coordinates.
%       lastWinner: the previously attended location (-1 for none).
%       salParams: structure with saliency parameters.
%       shapeData: structure array with information on the attended 
%          region from estimateShape.
%
% plotSalientLocation(winner,lastWinner,salParams)
%    If no shapeData are passed, a circle is drawn at the attended
%    location.
%
% See also estimateShape, winnerToImgCoords, runSaliency, drawDisk, 
%          contrastModulate, emptyMap, defaultSaliencyParams.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function plotSalientLocation(winner,lastWinner,img,params,varargin)

% first some logic to figure out what we have to draw
switch params.shapeMode
  case {'shapeSM','shapeCM','shapeFM','shapePyr'}
    if isempty(varargin)
      shape = 'Circle';
    elseif isempty(varargin{1})
      shape = 'Circle';
    elseif (max(varargin{1}.binaryMap.data(:)) == 0)
      shape = 'Circle';
    else
      shape = 'Outline';
    end
  case {'None','none'}
    shape = 'Circle';
  otherwise
    error(['Unknown shapeMode: ' params.shapeMode]);
end

% now draw everything that we need 
switch params.visualizationStyle
  % drawing contours
  case 'Contour'
    hold on;
    switch shape
      case {'Circle','circle'}
        modMap = drawDisk(emptyMap(img.size(1:2)),winner,round(params.foaSize/2),1);
        %plot(winner(2),winner(1),'yo','MarkerSize',params.foaSize);
      case {'Outline','outline'}
        %contour(varargin{1}.shapeMap.data,[0.5 0.5],'y-');
        modMap = varargin{1}.shapeMap;
      otherwise
        error(['Unknown shape: ' shape]);
    end
    contour(modMap.data,[0.5 0.5],'c-','LineWidth',5);
    doLine = (lastWinner(1) ~= -1);
    if (doLine) 
      plot([lastWinner(2),winner(2)],[lastWinner(1),winner(1)],'r-','LineWidth',3);
    end
    hold off;
    
  % using contrast modulation
  case 'ContrastModulate'
    switch shape
      case {'Circle','circle'}
        modMap = drawDisk(emptyMap(img.size(1:2)),winner,round(params.foaSize/2),1);
      case {'Outline','outline'}
        modMap = varargin{1}.shapeMap;
      otherwise
        error(['Unknown shape: ' shape]);
    end
    baseColor = [0.9 0.9 0.9]; % light grey
    baseContrast = 0.1;
    modImg = contrastModulate(img,modMap,baseContrast,baseColor);
    hold off;
    displayImage(modImg);

  case {'None','none'}
    displayImage(img);
    
  otherwise
    error(['Unknown visualizationMode: ' params.visualizationMode]);
end


