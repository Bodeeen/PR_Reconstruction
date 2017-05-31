function [ cropped_image ] = crop_image( image, cropping_data )
%Crop image according to cropping_data
%% Extract cropping parameters
X0 = cropping_data.X0;
Y0 = cropping_data.Y0;
Width = cropping_data.Width;
Height = cropping_data.Height;

%% Crop pattern according to data 
cropped_image = image(Y0:Y0+Height-1, X0+1:X0+Width-1);

end

