%experiment block
function [coherences,num_trials,quadrant_num_exp,number_active,active_stim_location] = experimentBlock(threshold)

%in order to make sure that all configurations are viewed here all trial
%coherence values for each stim are pregenerated

%here quadrant_num is a misnomer, we break up experiment into halves

%threshold = round(threshold,1);
subthreshold_values = linspace(0.19999,(threshold-(0.000001*threshold)),6); %choose 6 equally spaced coherence values
%this bit of code is VESTIGIAL, it refers to when I used lower coherence
%values for the noise quadrants/halves ... most of the operations that will
%follow are therefore pointless. I will optimize this when I find the time.
%-Alireza, Nov. 2016

%subthreshold_values = [0.1,0.3,0.5,0.7,0.9];

active_stims = 1:8; %all 8 stimuli can now be active within a half
stim_configs = nchoosek(8,2) + nchoosek(8,4) + nchoosek(8,6) + nchoosek(8,8);
num_trials = stim_configs*2*length(subthreshold_values); %2 because there are two halves

coherences = NaN(stim_configs,8);
count = 0;

for s = [2,4,6,8] %either 2, 4, 6 or 8 stim will be active
    stimType{s} = nchoosek(active_stims,s);
    for t = 1:size(stimType{s},1)
        temp = ones(1,8); %use one for the rest 
        count = count+1;
        idx = stimType{s}(t,:);
        temp(idx) = threshold;
        coherences(count,:) = temp;
        coherences_type(count) = s;
        clear temp
    end
end

clear idx

idx = find(coherences==1);
idx2 = find(coherences==threshold);
[r_noise,c_noise] = size(coherences); 

changing_stim = zeros(r_noise,c_noise); %the stim that change direction
changing_stim(idx2) = 1;


all_coherences = [];
all_noise_coherences = [];
for s = 1:6
    %s is the coherence values
    %this yields the coherence values for a signal quadrant
    % and a noise quadrant
    temp_coherences = coherences;
    temp_noise_coherences = ones(r_noise,c_noise) .* subthreshold_values(s);
    temp_coherences(idx) = subthreshold_values(s);
    all_coherences = [all_coherences;temp_coherences];
    all_noise_coherences = [all_noise_coherences;temp_noise_coherences];
    clear temp_coherences temp_noise_coherences
end

changing_stim = repmat(changing_stim,6,1);

%for all 4 quadrants and remaining stims
coherences_1 = horzcat(all_coherences,all_noise_coherences); %first half signal
coherences_2 = horzcat(all_noise_coherences,all_coherences); %second half signal

%add the quadrant number to the end of each row so that when shuffled order
%is preserved
coherences_1 = [coherences_1, ones(1,length(coherences_1))',repmat(coherences_type,1,6)',changing_stim];
coherences_2 = [coherences_2, ones(1,length(coherences_2))'.*2,repmat(coherences_type,1,6)',changing_stim];

clear coherences

coherences = [coherences_1;coherences_2];

%now shuffle the rows
coherences = coherences(randperm(size(coherences,1)),:);

active_stim_location = coherences(:,19:end);
number_active = coherences(:,18);
quadrant_num_exp = coherences(:,17); %here it's referred to as quadrant_num even though it's a half
coherences = coherences(:,1:16);

end




    
    
