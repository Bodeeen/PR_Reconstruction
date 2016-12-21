function [ cropping_data ] = get_cropping_data( hdf5path )
%Get cropping parameters from hdf5 file.
%Note the Y-X mismatch that comes from how Tempesta saves the hdf5 file
%(rotated, X0 and Y0 for Orcaflash is bottom left corner).

% NOTE that cropping parameters are zero-indexed and Matlab indexes from one.
% Thus the "+ 1" on X0 and Y0.
    X0 = h5readatt(hdf5path, '/data', 'Y0') + 1;
    Y0 = h5readatt(hdf5path, '/data', 'X0') + 1;
    Width = h5readatt(hdf5path, '/data', 'Height');
    Height = h5readatt(hdf5path, '/data', 'Width');
    
    cropping_data = struct('X0', X0, 'Width', Width, 'Y0', Y0, 'Height', Height);
end

