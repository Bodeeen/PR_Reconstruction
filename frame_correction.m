function [ output_stack ] = frame_correction( input_stack )
%% Correct for scanning acquiring one frame in beginning and one too few in the end
% and sometimes missing the first "real" frame.
if round(sqrt(size(input_stack, 3))) ~= sqrt(size(input_stack, 3))
    output_stack = input_stack(:,:,2:end);
else
    output_stack = input_stack;
end

output_stack = output_stack - 98; %Remove camera offset

end

