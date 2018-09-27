classdef Scene < matlab.mixin.Copyable
    %Scene A scene of audiovisual objects
    
    properties
        height      % scene height in pixels
        width       % scene width in pixels
        color       % background color
        bg          % background image
        stimuli     % list of SensoryObjects
        image       % generated in renderScene
        audioImage  % generated in auditorySpatialSaliencyMap
        soundArray  % generated in generateSound
        duration    % duration of the scene in seconds
        inhibitedLocations
        inhibitionProfile
    end
    
    properties(Constant)
        fs = 8000    % audio sampling frequency
        nFilters = 50;
        receptiveFieldSize = 10; % determines blur of auditory image
    end
    
    methods
        function obj = Scene(varargin)
            % Scene object constructor
            if nargin == 2
                % bg, duration
                obj.bg = varargin{1};
                obj.duration = varargin{2};
                obj.height = size(obj.bg, 1);
                obj.width = size(obj.bg, 2);
            elseif  nargin == 4
                % height, width, duration, color
                obj.height = varargin{1};
                obj.width = varargin{2};
                obj.duration = varargin{3};
                obj.color = varargin{4};
                obj.stimuli = [];

                SensoryObject.setgetDuration(obj.duration);
            end
                        
            inhib_x = [1 50 200 500 1000];
            inhib_y = [1.2 1.2 .25 .75 1];
            obj.inhibitionProfile = interp1(inhib_x, inhib_y, 1:1:obj.duration*1000);
        end
        
        
        function addObject(obj, sensoryObject)
            % add a SensoryObject to the scene
            obj.stimuli = [obj.stimuli sensoryObject];
            
            % if the object appears at time zero, add it to the inhibition
            % map.
            
            if sensoryObject.appearTime == 0
                obj.inhibitedLocations = [obj.inhibitedLocations; sensoryObject.position];
            end
        end
            
        %%% Visual %%%
        
        function renderScene(obj)
            % Iterates through objects in the scene and renders them into
            % an image
            if isempty(obj.bg)
                img = 0*ones(obj.height, obj.width, 3); % .3
            else
                img = obj.bg;
            end
            
            for n = 1:length(obj.stimuli)
                % img = insertShape(img, obj.stimuli(n).shape, obj.stimuli(n).position, 'Linewidth', 3, 'Color', obj.stimuli(n).color);
                % workaround for the fact that insertshape requires the
                % computer vision toolbox, which I no longer have
                stimulus = obj.stimuli(n);
                if strcmp(stimulus.shape, 'circle')
                    img = drawCircle(img, stimulus.position(1:2), stimulus.position(3), stimulus.color);
                elseif strcmp(stimulus.shape, 'square')
                    img = drawRect(img, stimulus.position(1:2), stimulus.position(3), stimulus.position(3), 0, stimulus.color); % center, size
                elseif strcmp(stimulus.shape, 'rect')
                    %img = drawSquare(img, stimulus.position(1:2), stimulus.position(3), stimulus.color);
                    img = drawRect(img, stimulus.position(1:2), stimulus.position(3), stimulus.position(4), stimulus.position(5), stimulus.color); % center, height, width, theta
                elseif strcmp(stimulus.shape, 'text')
                    img = drawText(img, stimulus.position(1:2), stimulus.txt);
                end

            end
            obj.image = img;
        end

        function renderScenePTB(obj, window)
            % Render scene on to the screen using PTB. Meant for use in experiments 
            obj.renderScene()
            imageTexture = Screen('MakeTexture', window, obj.image);
            Screen('DrawTexture', window, imageTexture, [], [], 0);
        end
        
        function scaledImage = getScaledImage(obj, scale)
            % Iterates through objects in the scene and renders them into
            % an image
            if isempty(obj.bg)
                img = 0*ones(round(obj.height*scale), round(obj.width*scale), 3); % .3
            else
                img = imresize(obj.bg, scale);
            end
            
            for n = 1:length(obj.stimuli)
                % img = insertShape(img, obj.stimuli(n).shape, obj.stimuli(n).position, 'Linewidth', 3, 'Color', obj.stimuli(n).color);
                % workaround for the fact that insertshape requires the
                % computer vision toolbox, which I no longer have
                stimulus = obj.stimuli(n);
                if strcmp(stimulus.shape, 'circle')
                    img = drawCircle(img, round(stimulus.position(1:2)*scale), round(stimulus.position(3)*scale), stimulus.color);
                elseif strcmp(stimulus.shape, 'square')
                    img = drawRect(img, stimulus.position(1:2)*scale, stimulus.position(3)*scale, stimulus.position(3)*scale, 0, stimulus.color); % center, size     
                elseif strcmp(stimulus.shape, 'rect')
                    img = drawRect(img, stimulus.position(1:2)*scale, stimulus.position(3)*scale, stimulus.position(4)*scale, stimulus.position(5), stimulus.color); % center, height, width, theta
                elseif strcmp(stimulus.shape, 'text')
                    img = drawText(img, round(stimulus.position(1:2)*scale), stimulus.txt);
                end

            end
            scaledImage = img;
        end
        
        function inMap = renderInhibitionMap(obj, t)
            % render the scene's inhibition map at time t

            if isempty(obj.bg)
                aoe = 2; % area of effect multiplier
                inMap = ones(obj.height, obj.width);
                num_locs = size(obj.inhibitedLocations, 1);
                for loc_idx = 1:num_locs
                   cur_loc = obj.inhibitedLocations(loc_idx, :);
                   inMap = drawCircle(inMap, cur_loc(1:2), cur_loc(3)*aoe, obj.inhibitionProfile(t*1000));
                end
            else
                % inhibition map generation currently only works using the
                % itti algorithm
                img = initializeImage(obj.bg);
                params = defaultSaliencyParams(img.size,'dyadic');
                [salmap, salData] = makeSaliencyMap(img, params);
                wta = initializeWTA(salmap,params);

                winner = [-1, -1];
                while(winner(1) == -1)
                    [wta, winner] = evolveWTA(wta);
                end

                shapeData = estimateShape(salmap, salData, winner, params);
                inMap = shapeData.binaryMap.data .* obj.inhibitionProfile(t*1000);
                inMap(inMap==0) = 1;
            end
        
        end

        function [salmap, salData] = IttiVisualSaliencyMap(obj)
            % Compute saliency map for the scene
            obj.renderScene();
            img = initializeImage(obj.image);
            params = defaultSaliencyParams(img.size,'dyadic');
            [salmap,salData] = makeSaliencyMap(img,params);
        end
        
        function [salmap] = HFTVisualSaliencyMap(obj)
           obj.renderScene();
           salmap = HFTSaliencyMap(obj.image);
        end
        
      
        %%% Auditory %%%
        
        function generateSound(obj)
            % Generate the sound array for this scene by combining the
            % sound arrays from each individual object
            tempSoundArray = zeros(1, obj.duration*obj.stimuli(1).fs);
            for n = 1:length(obj.stimuli)
                obj.stimuli(n).generateSound()
                tempSoundArray = tempSoundArray + obj.stimuli(n).soundArray;
            end
            obj.soundArray = tempSoundArray;
        end
              
        
        function TFSmap = timeFrequencyToSpaceMap(obj)
            % create a map from time (in samples) and filter index to
            % location: [x, y] = map([num2str(t*fs) ' ' num2str(filterIdx)])
            cfArray = ERBSpace(0, obj.fs/2, obj.nFilters); % center frequency of each gammatone filter
            locationMap = containers.Map;
            for obj_idx = 1:length(obj.stimuli)
                for sound_idx = 1:size(obj.stimuli(obj_idx).soundParams, 1)
                    
                    start = obj.stimuli(obj_idx).soundParams(sound_idx, 1);
                    dur = obj.stimuli(obj_idx).soundParams(sound_idx, 2);
                    freq = obj.stimuli(obj_idx).soundParams(sound_idx, 3);
                    
                    for n = start*obj.fs : (start + dur)*obj.fs
                        [~, index] = min(abs(cfArray-freq));% find filter index corresponding to freq
                        locationMap([num2str(n) ' ' num2str(index)]) = obj.stimuli(obj_idx).position(1:2);
                    end
                    
                end
            end
            TFSmap = locationMap;
        end
        
        function salmap = auditoryTimeFreqSaliencyMap(obj)
            % generate time-frequency saliency map
            obj.generateSound()
            
            % treat cochleagram as time-frequency saliency map
            % change in the future           
            
            fcoefs = MakeERBFilters(obj.fs, obj.nFilters, 0);
            y = ERBFilterBank(obj.soundArray, fcoefs);
            
            for j=1:size(y,1)
                c=max(y(j,:),0);
                c=filter(1,[1 -.99],c);
                y(j,:)=c;
            end
            
            salmap = y;      
        end
        
        function [salmap, saldata] = auditorySpatialSaliencyMap(obj, t)
            % generate spatial auditory saliency map at time t
            TFSmap = obj.timeFrequencyToSpaceMap();
            
            timeFreqSalMap = obj.auditoryTimeFreqSaliencyMap();
            audioImage = zeros(obj.height, obj.width);
            timeSlice = timeFreqSalMap(:,obj.fs*t);
            
            % Using time-frequency to space mapping, create an auditory
            % image. Intensity at a pixel is the spectrotemporal saliency
            % of the sound coming from that location at that time.
            
            for filterIdx = 1:length(timeSlice)
                mapKey = [num2str(t*obj.fs) ' ' num2str(filterIdx)];
                if isKey(TFSmap, mapKey)
                    loc = TFSmap(mapKey);
                    audioImage(loc(1), loc(2)) = timeSlice(filterIdx);
                end
            end
            
            % Take the auditory image and compute center-surround saliency
            
            obj.audioImage = imgaussfilt(audioImage, obj.receptiveFieldSize);   % gaussian blur
            obj.audioImage = obj.audioImage / max(obj.audioImage(:));           % normalize
            img = initializeImage(cat(3, audioImage, audioImage, audioImage));  % create 3-channel image
            params = defaultSaliencyParams(img.size,'dyadic');
            params.features = {'Intensities'  'Orientations'};
            [salmap, saldata] = makeSaliencyMap(img,params);                       
        end 
        
        %%% Multisensory %%%
        
        function salmap = multisensorySaliencyMap(obj, t)
            % generate multisensory saliency map at time t, using the
            % divisive normalization algorithm proposed by Ohshiro,
            % Angelaki, DeAngelis
            
            [auditorySaliencyMap, ~] = obj.auditorySpatialSaliencyMap(t);
            [visualSaliencyMap, ~] = obj.visualSaliencyMap();
            
            % algorithm parameters
            audioWeight = .5;       % auditory dominance weight
            visualWeight = .5;      % visual dominance weight
            n = 2;                  % exponent of output nonlinearity
            a = 1;                  % semi-saturation constant
            
            % input nonlinearity: one of sqrt(x), log(x+1), x / (x+1)
            audIn = sqrt(auditorySaliencyMap.data);
            visIn = sqrt(visualSaliencyMap.data);
            
            % weighted sum
            multisensorySum = audioWeight*audIn + visualWeight*visIn;
            
            % output nonlinearity
            multisensoryOut = multisensorySum .^ n;
            
            % divisive normalization
            salmap = multisensoryOut ./ (a^n + mean2(multisensoryOut));          
        end
    end  
end

