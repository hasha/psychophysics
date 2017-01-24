%experiment block
function [coherences,num_trials,quadrant_num_exp,number_active] = experimentBlock2(threshold)

%in order to make sure that all configurations are viewed here all trial
%coherence values for each stim are pregenerated

quadrants = 4; %duh!
%threshold = round(threshold,1);
%subthreshold_values = linspace(0,(threshold-(0.1*threshold)),6); %choose 6 equally spaced coherence values

active_stims = [1:4]; %all 5 stimuli can now be active within a quadrant
stim_configs = nchoosek(4,2) + nchoosek(4,3) + nchoosek(4,4) + nchoosek(4,4);
%there are two nchoosek(4,4)s because either 1,2,3,4 could be on or 2,3,4,5
num_trials = stim_configs*quadrants*6;

coherences = NaN(stim_configs,4);
count = 0;
for s = 2:4
    stimType{s} = nchoosek(active_stims,s);
    for t = 1:size(stimType{s},1)
        temp = ones(1,4); %use one for the rest 
        count = count+1;
        idx = stimType{s}(t,:);
        temp(idx) = threshold;
        coherences(count,:) = temp;
        coherences_type(count) = s;
        clear temp
    end
end

stimType{s+1} = stimType{s} + 1;
%this is so that 2,3,4,5 are active


%add the quadrant number to the end of each row so that when shuffled order
%is preserved
coherences_q1 = [coherences_q1, ones(1,length(coherences_q1))',repmat(coherences_type,1,6)'];
coherences_q2 = [coherences_q2, ones(1,length(coherences_q2))'.*2,repmat(coherences_type,1,6)'];
coherences_q3 = [coherences_q3, ones(1,length(coherences_q3))'.*3,repmat(coherences_type,1,6)'];
coherences_q4 = [coherences_q4, ones(1,length(coherences_q4))'.*4,repmat(coherences_type,1,6)'];

clear coherences

coherences = [coherences_q1;coherences_q2;coherences_q3;coherences_q4];

%now shuffle the rows
coherences = coherences(randperm(size(coherences,1)),:);
number_active = coherences(:,end);
quadrant_num_exp = coherences(:,(end-1));
coherences = coherences(:,1:(end-2));

end