 

clear all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   User Set Display Params   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%report width and height in cm
 
num_stim = 20 ; % shouldn't really be greater than 16 
if rem(num_stim,4) > 0 || num_stim>20 
    display('Wrong number of stimuli. Experiment aborted!')
    return
end
quadrants = ceil((1:num_stim)./(num_stim/4));
 
clear display

%    width           Width of screen (cm)
%    dist            Distance from screen (cm) q

display.width = 48;
display.height = 30;
display.dist = 100;
display.skipChecks = 1; %avoid Screen's timing checks and verbosity
display.screenNum = 0  ;
%display.bkColor = [128,128,128];
tmp = Screen('Resolution',display.screenNum);
display.resolution = [tmp.width, tmp.height];
clear tmp   c 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Default Display Parameters     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[window_ptr,screen_dimensions]= Screen(1,'OpenWindow',[128,128,128]);
%Screen('BlendFunction', window_ptr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%opens a grey screen

%%%%%%%%%%%%%%%%%%%%%%%
%    Set locations    % 
%%%%%%%%%%%%%%%%%%%%%%%

radius = 7.5;

k = [0:1:num_stim-1];
locations = [radius*cos((k.*2*pi)./num_stim);radius*sin((k.*2*pi)./num_stim)];
%locations(1,:) is the x position and locations(2,:) the y position

locations = [locations(:,1),locations(:,4:11),locations(:,14:20)];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Stim Params       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theta = 360/num_stim;
orientations = [90:theta:360,theta:theta:(90-theta)];
orientations2 = [270:theta:360,theta:theta:(270-theta)];
orientations = [orientations(1:2),orientations(5:12),orientations(15:20)];
orientations2 = [orientations2(1:2),orientations2(5:12),orientations2(15:20)];
%motion changes on opposite axis of orientation, orientations2 gives
%opposite values

orientations_circular = [360,theta:theta:(360-theta)];
orientations2_circular = [180:theta:360,theta:theta:(180-theta)];
%the previous ones gave radial orientations, this one gives circular
%orientations
orientations_circular = [orientations_circular(1:2),orientations_circular(5:12),orientations_circular(15:20)];
orientations2_circular = [orientations2_circular(1:2),orientations2_circular(5:12),orientations2_circular(15:20)];

% 
orientations_spiral = ones(1,20)*360;
orientations2_spiral = ones(1,20)*180;
orientations_spiral = [orientations_spiral(1:2),orientations_spiral(5:12),orientations_spiral(15:20)];
orientations2_spiral  = [orientations2_spiral(1:2),orientations2_spiral(5:12),orientations2_spiral(15:20)];



fixed_stim_vals = [90 180 270 360]; %do we want thes e to stay at zero coherence?
active_stim = find(~ismember(orientations,fixed_stim_vals));
temp = [1:num_stim];
unactive_stim = temp(~ismember(temp,active_stim));
clear temp  
 
%fixed parameters
n_dots = 120;
speed = 5; 
lifetime = 12;
apertureSize = [1.5 1.5]; 
color = [0,0,0];
size = 4; %size of dots in pixels
pulse_length = 0.6; %seconds  
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PRE-ALLOCATE COHERENCE  VALUES  % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

threshold_repeats = num_stim; %number of repeats for each coherence level
%each stim should have at least 2 presentations of each coherence value
threshold_coherence_list = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8]; %coherence levels chosen
threshold_trials = (threshold_repeats * length(threshold_coherence_list) + 20); %# of trials to determine threshold
%include 10 practice runs

for t = 1:threshold_trials
    
if t < 20
     
    rnd_stim_num = active_stim(randi(length(active_stim))); 
    quadrant_num_threshold(1,t) = quadrants(rnd_stim_num);
    coh_num = 0.9; %20 practice trials with c oherence of 0.9
    temp = zeros(1,num_stim);
    temp(rnd_stim_num) = 1;
    coherences_threshold(t,:) = temp .* coh_num;
    active_idx(1,t) = rnd_stim_num;
    
elseif t > 20
    
    rnd_stim_num = active_stim(randi(length(active_stim))); 
    quadrant_num_threshold(1,t) = quadrants(rnd_stim_num);
    
    rnd_coh_num = threshold_coherence_list(randi(length(threshold_coherence_list)));
    temp = zeros(1,num_stim);
    temp(rnd_stim_num) = 1;
    coherences_threshold(t,:) = temp .* rnd_coh_num;
    active_idx(1,t) = rnd_stim_num;
    
    clear tmp rnd_stim _num rnd_coh_num
end

end 


try
    display = OpenWindow(display);

    drawText(display,[0,6],'Press the Key Corresponding to the Quadrant in Which a Coherent Motion Pulse Occured.',[0,0,0]);
    drawText(display,[0,5],'Press the Appropriate Key After the Animation Ends.',[255,0,0]);
    drawText(display,[0,3],'Press Any Key to Begin the Experiment.',[0,0,0]);

    display = drawFixation(display);

    while KbCheck; end
    KbWait;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    DETERMINE THRESHOLD   % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
  for trialNum = 1:2
      %threshold_trials
      
    dots = generate_dots_struct(n_dots,speed,orientations,orientations2,lifetime,apertureSize,locations,color,size,coherences_threshold(trialNum,:));
    Screen('BlendFunction', display.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    movingDots(display,dots,pulse_length,active_idx(trialNum));
         
         keys = waitTill(1);
              
         %Interpret the response provide feedback
        if isempty(keys)  %No key was pressed, yellow fixation
            correct = NaN;
            display.fixation.color{1} = [255,255,0]; 
        else
            %Correct response, green fixation
            if (keys{end}(1)=='w' && quadrant_num_threshold(trialNum) == 4) || (keys{end}(1)=='s' && quadrant_num_threshold(trialNum) == 1) || (keys{end}(1)=='a' && quadrant_num_threshold(trialNum) == 2) || (keys{end}(1)=='q' && quadrant_num_threshold(trialNum) == 3)
                results.response(trialNum) = 1;
                display.fixation.color{1} = [0,255,0];
                %Incorrect response, red fixation 
            elseif (keys{end}(1)=='w' &&  quadrant_num_threshold(trialNum) ~= 4) || (keys{end}(1)=='s' && quadrant_num_threshold(trialNum) ~= 1) || (keys{end}(1)=='a' && quadrant_num_threshold(trialNum) ~= 2) || (keys{end}(1)=='q' && quadrant_num_threshold(trialNum) ~= 3)
                results.response(trialNum) = 0;
                display.fixation.color{1} = [255,0,0];
                %Wrong key was pressed, blue fixation
            else
                results.response(trialNum) = NaN;
                display.fixation.color{1} = [0,0,255];   
            end 
        end
 %Flash the fixation with color
        drawFixation(display);
        waitTill(.15);
        display.fixation.color{1} = [0,0,0];
        drawFixation(display);
        results.coherence(trialNum) = sum([dots.coherence]);
        results.quadrant(trialNum) = quadrant_num_threshold(trialNum);
  end
 
  %calculate threshold 
%    results = psychometric(results); %uses a logistic function
%    threshold = results.threshold;
%     load('alirezaThreshold.mat');
%     results = psychometric(results);
%     threshold = results.threshold;
threshold = 1;

  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  MAIN EXPERIMENT - RADIAL MOTION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear active_idx
    [coherences,num_trials,quadrant_num_exp,number_active,active_stim_location] = experimentBlock(threshold);
     
    %NOTE: For now   this is only con figured for 16 stims! Generalize this
    %later!
  
    drawText(display,[0,6],'Take a Short Break!',[0,0,0]);
    drawText(display,[0,4],'Press Any Key to Resume the Experiment.',[255,0,0]); 
    display = drawFixation(display); 
    
    while KbCheck; end
    KbWait;
    
 for trialNum = 1:40
     %num_trials
      
    dots = generate_dots_struct(n_dots,speed,orientations,orientations2,lifetime,apertureSize,locations,color,size,coherences(trialNum,:));
    Screen('BlendFunction', display.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
      
    if quadrant_num_exp(trialNum) == 2
        active_idx = find(active_stim_location(trialNum,:)) + 1;
    elseif quadrant_num_exp(trialNum) == 1
        active_idx = find(active_stim_location(trialNum,:)) + 9;
    end    
    
    active_idx(active_idx==17) = 1;
    
    movingDots(display,dots,pulse_length,active_idx);
         
         keys = waitTill(1);
              
         %Interpret the response provide feedback
        if isempty(keys)  %No key was pressed, yellow fixation 
            correct = NaN;
            display.fixation.color{1} = [255,255,0];
        else
            %Correct response, green fixation
             if (keys{end}(1)=='q' && quadrant_num_exp(trialNum) == 1) || (keys{end}(1)=='a' && quadrant_num_exp(trialNum) == 2) 
                results2.response(trialNum) = 1;
                display.fixation.color{1} = [0,255,0];
                %Incorrect response, red fixation
            elseif (keys{end}(1)=='q' && quadrant_num_exp(trialNum) ~= 1) || (keys{end}(1)=='a' && quadrant_num_exp(trialNum) ~= 2)
                results2.response(trialNum) = 0; 
                display.fixation.color{1} = [255,0,0];
                %Wrong key was pressed, blue fixation
            else
                results2.response(trialNum) = NaN;
                display.fixation.color{1} = [0,0,255];
            end
        end
 %Flash the fixation with color
        drawFixation(display);
        waitTill(.15);
        display.fixation.color{1} = [255,255,255];
        drawFixation(display);
        
        
        
        liana_results22.coherence(trialNum,:) = coherences(trialNum,:);
         liana_results22.sub_coherence(trialNum) = mode(coherences(trialNum,:));
         liana_results22.quadrant(trialNum) = quadrant_num_exp(trialNum);
         liana_results22.number(trialNum) = number_active(trialNum);
        
if trialNum == ceil(num_trials/2)
    drawText(display,[0,6],'Take a Short Break!',[255,255,255]);
    drawText(display,[0,5],'You Are Almost Done!',[255,255,255]);
    drawText(display,[0,4],'Press Any Key to Resume the Experiment.',[255,0,0]);
    display = drawFixation(display); 
    while KbCheck; end
    KbWait;
end

 end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  MAIN EXPERIMENT - CIRCULAR MOTION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    drawText(display,[0,6],'Take a Short Break!',[0,0,0]);
    drawText(display,[0,4],'Press Any Key to Resume the Experiment.',[255,0,0]);
    display = drawFixation(display); 
    
    while KbCheck; end
    KbWait;
 
        [coherences,num_trials,quadrant_num_exp,number_active,active_stim_location] = experimentBlock(threshold);
 
    
 for trialNum = 1:40
     %num_trials
       
    dots = generate_dots_struct(n_dots,speed,orientations_circular,orientations2_circular,lifetime,apertureSize,locations,color,size,coherences(trialNum,:));
    
    Screen('BlendFunction', display.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    
    if quadrant_num_exp(trialNum) == 2
        active_idx = find(active_stim_location(trialNum,:)) + 1;
    elseif quadrant_num_exp(trialNum) == 1
        active_idx = find(active_stim_location(trialNum,:)) + 9;
    end    
    
    active_idx(active_idx==17) = 1;
    
    movingDots(display,dots,pulse_length,active_idx);
        
         keys = waitTill(2);
              
         %Interpret the response provide feedback
        if isempty(keys)  %No key was pressed, yellow fixation 
            correct = NaN;
            display.fixation.color{1} = [255,255,0];
        else
            %Correct response, green fixation
             if (keys{end}(1)=='q' && quadrant_num_exp(trialNum) == 1) || (keys{end}(1)=='a' && quadrant_num_exp(trialNum) == 2) 
                results2.response(trialNum) = 1;
                display.fixation.color{1} = [0,255,0];
                %Incorrect response, red fixation
            elseif (keys{end}(1)=='q' && quadrant_num_exp(trialNum) ~= 1) || (keys{end}(1)=='a' && quadrant_num_exp(trialNum) ~= 2)
                results2.response(trialNum) = 0;
                display.fixation.color{1} = [255,0,0];
                %Wrong key was pressed, blue fixation
            else
                results2.response(trialNum) = NaN;
                display.fixation.color{1} = [0,0,255];
            end
        end
 %Flash the fixation with color
        drawFixation(display);
        waitTill(.15);
        display.fixation.color{1} = [255,255,255];
        drawFixation(display);
        
         liana_results2.coherence(trialNum,:) = coherences(trialNum,:);
         liana_results2.sub_coherence(trialNum) = mode(coherences(trialNum,:));
         liana_results2.quadrant(trialNum) = quadrant_num_exp(trialNum);
         liana_results2.number(trialNum) = number_active(trialNum);
        
if trialNum == ceil(num_trials/2)
    drawText(display,[0,6],'Take a Short Break!',[255,255,255]);
    drawText(display,[0,5],'You Are Almost Done!',[255,255,255]);
    drawText(display,[0,4],'Press Any Key to Resume the Experiment.',[255,0,0]);
    display = drawFixation(display); 
    while KbCheck; end
    KbWait;
end

 end   
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    MAIN EXPERIMENT - COMBINATION   % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    drawText(display,[0,6],'Take a Short Break!',[0,0,0]);
    drawText(display,[0,4],'Press Any Key to Resume the Experiment.',[255,0,0]);
    display = drawFixation(display); 
    
     while KbCheck; end
    KbWait;
    
         [coherences,num_trials,quadrant_num_exp,number_active,active_stim_location] = experimentBlock(threshold);

 
  for trialNum = 1:40
     %num_trials
       
    dots = generate_dots_struct(n_dots,speed,orientations_spiral,orientations2_spiral,lifetime,apertureSize,locations,color,size,coherences(trialNum,:));
    
    Screen('BlendFunction', display.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    if quadrant_num_exp(trialNum) == 2
        active_idx = find(active_stim_location(trialNum,:)) + 1;
    elseif quadrant_num_exp(trialNum) == 1
        active_idx = find(active_stim_location(trialNum,:)) + 9;
    end    
    
    active_idx(active_idx==17) = 1;
    
    movingDots(display,dots,pulse_length,active_idx);
        
         keys = waitTill(2);
              
         %Interpret the response provide feedback
        if isempty(keys)  %No key was pressed, yellow fixation 
            correct = NaN;
            display.fixation.color{1} = [255,255,0];
        else
            %Correct response, green fixation
             if (keys{end}(1)=='q' && quadrant_num_exp(trialNum) == 1) || (keys{end}(1)=='a' && quadrant_num_exp(trialNum) == 2) 
                results2.response(trialNum) = 1;
                display.fixation.color{1} = [0,255,0];
                %Incorrect response, red fixation
            elseif (keys{end}(1)=='q' && quadrant_num_exp(trialNum) ~= 1) || (keys{end}(1)=='a' && quadrant_num_exp(trialNum) ~= 2)
                results2.response(trialNum) = 0;
                display.fixation.color{1} = [255,0,0];
                %Wrong key was pressed, blue fixation
            else
                results2.response(trialNum) = NaN;
                display.fixation.color{1} = [0,0,255];
            end
        end
 %Flash the fixation with color
        drawFixation(display);
        waitTill(.15);
        display.fixation.color{1} = [255,255,255];
        drawFixation(display);
         liana_results23.coherence(trialNum,:) = coherences(trialNum,:);
         liana_results23.sub_coherence(trialNum) = mode(coherences(trialNum,:));
         liana_results23.quadrant(trialNum) = quadrant_num_exp(trialNum);
         liana_results23.number(trialNum) = number_active(trialNum);
       
if trialNum == ceil(num_trials/2)
    drawText(display,[0,6],'Take a Short Break!',[255,255,255]);
    drawText(display,[0,5],'You Are Almost Done!',[255,255,255]);
    drawText(display,[0,4],'Press Any Key to Resume the Experiment.',[255,0,0]);
    display = drawFixation(display); 
    while KbCheck; end
    KbWait;
end

 end   
    
 
    while KbCheck; end
    KbWait;
      
catch ME
    Screen('CloseAll');
    rethrow(ME)
end

Screen('CloseAll');


