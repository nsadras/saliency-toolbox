classdef SensoryObject < matlab.mixin.Copyable
    %SensoryObject An audiovisual object
    %    An object with a visual features (shape, color, location) and
    %    auditory features (a waveform consisting of pure tones of varying 
    %    frequency, amplitude, and duration)
  
    properties
        appearTime  % time at which this object appears, in seconds     
        shape       % shape name - Rectangle, FilledRectangle, Line, Polygon, FilledPolygon, Circle, FilledCircle
        color       % [R G B] vector or string - 'blue', 'green', 'red', 'cyan', 'magenta', 'black', and 'white'
        position    % position parameters required for the chosen shape - see insertShape() documentation
        soundParams % nx4 array where each row is a 4-tuple [ start duration freq amp ] in units of [ sec sec Hz - ] specifying a tone 
        soundArray  % array representing this object's audio output, generated from soundParams in generateSound()
        txt         % string containing text
    end
    
    properties(Constant)
        fs = 8000    % audio sampling frequency          
    end
    
    methods
        function obj = SensoryObject(varargin) % shape, color, position, soundParams
            if length(varargin) == 5
                obj.shape = varargin{1};
                obj.color = varargin{2};
                obj.position = varargin{3};
                obj.appearTime = varargin{4};
                obj.soundParams = varargin{5};
            elseif length(varargin) == 6
                obj.shape = varargin{1};
                obj.color = varargin{2};
                obj.position = varargin{3};
                obj.appearTime = varargin{4};
                obj.soundParams = varargin{5};
                obj.txt = varargin{6};
            end
        end
        
        function generateSound(obj)
            % generate audio based on soundParams
            tempSoundArray = zeros(1, SensoryObject.setgetDuration()*obj.fs);
            totalDuration = SensoryObject.setgetDuration();
            
            for soundParamIdx = 1:size(obj.soundParams, 1)
                cur_params = obj.soundParams(soundParamIdx,:);
                
                start = cur_params(1);
                toneDuration = cur_params(2);
                freq = cur_params(3);
                amp = cur_params(4);
                
                t = (start):(1/obj.fs):(start+toneDuration);
                prePad = start*obj.fs -1;
                postPad = (totalDuration - start - toneDuration)*obj.fs;
                
                tone = amp*sin(2*pi*freq*t);
                paddedTone = [zeros(1, prePad) tone zeros(1, postPad)];
                
                tempSoundArray = tempSoundArray + paddedTone;
            end
            
            obj.soundArray = tempSoundArray;
        end
    end
    
    methods(Static)
        function out = setgetDuration(in)
            % access and modify the duration of the sound file (static variable)
            persistent duration;
            if nargin
                duration = in;
            end
            out = duration;
        end
    end
end

