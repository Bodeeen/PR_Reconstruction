function [ corrected ] = bleaching_correction( data, mode )

switch mode
    case 'Proportional'
        corrected = bleaching_correction_prop(data);
    case 'Additive'
        corrected = bleaching_correction_add(data);
end

end

