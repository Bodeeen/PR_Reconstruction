function [ output_stack ] = frame_correction( input_stack )
%% Correct for scanning acquiring one frame in beginning and one too few in the end
% and sometimes missing the first "real" frame. After rewriting some
% scanning code, this is rarely needed now.
%output_stack = input_stack(:,:,2:end);
if round(sqrt(size(output_stack, 3))) ~= sqrt(size(output_stack, 3))
    output_stack = cat(3, output_stack(:,:,1), output_stack);
end

%% For old scanning
if round(sqrt(size(output_stack, 3))) ~= sqrt(size(output_stack, 3))
    output_stack = cat(3, output_stack, output_stack(:,:,end));
end

output_stack = output_stack - 98; %Remove camera offset

end

