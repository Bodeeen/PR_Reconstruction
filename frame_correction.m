function [ output_stack ] = frame_correction( input_stack )
%% Correct for scanning acquiring one frame in beginning and one too few in the end
% and sometimes missing the first "real" frame.
corr_stack = input_stack(:,:,2:end);
corr_stack(:,:,end+1) = corr_stack(:,:,end);
if round(sqrt(size(corr_stack, 3))) ~= sqrt(size(corr_stack, 3))
    output_stack = cat(3, corr_stack(:,:,1), corr_stack);
else
    output_stack = corr_stack;
end

output_stack = output_stack - 98; %Remove camera offset

end

