function save_image(recon, bg_sub_fac, diff_limit, datafilepath, format, varargin)
        vargs = varargin;
        nargs = length(vargs)/2;
        names = vargs(1:2:2*nargs);
        values = vargs(2:2:2*nargs);
        
        split = strsplit(datafilepath, '\');
        LoadDataFileName = split{end};
        LoadDataPathName = strjoin(split(1:end-1), '\');
        savename = strsplit(LoadDataFileName,'.');
        savename = savename{1};
        dname = uigetdir(LoadDataPathName);
        fname = savename
        savepath = strcat(dname, '\', fname, sprintf('_Reconstruction_%.dnm_pin_%.2f_bg_sub_fac', diff_limit, bg_sub_fac));
        disp(strcat('Saving in :', savename))
        savepath_check = savepath;
        new_ver = 2;
        while exist(savepath_check) == 7
            savepath_check = strcat(savepath, '_', num2str(new_ver));
            new_ver = new_ver + 1;
        end
        savepath = savepath_check;
        mkdir(savepath)
        
        imsidey = size(recon, 1);
        imsidex = size(recon, 2);
        imsidez = size(recon, 3);
%         output = recon - min(recon(:));
%         output = uint16(2^16*output/max(output(:)));

%% Scale values appropriatly
        if max(recon(:)) < 2^16/500
            output = uint16(500*recon); % 500 arbitrarily chosen to fit normal data
        elseif max(recon(:)) < 2^16/50
            output = uint16(50*recon);
        elseif max(recon(:)) < 2^16/5
            output = uint16(5*recon);
        end
        
        
        if strcmp(format,'tif')
            imwrite(output, strcat(savepath, '\', fname, '_Reconstructed_Sthlm', '.tif')),
        elseif strcmp(format,'hdf5')
            h5create(strcat(savepath, '\', fname, '_Stack'),'/data', [imsidey imsidex imsidez])
            h5write(strcat(savepath, '\', fname, '_Stack'),'/data', recon);
        end
        if nargs == 1
            widefield = values{1};
            widefield = widefield - min(widefield(:));
            widefield = uint16(2^16*widefield/max(widefield(:)));
            imwrite(widefield, strcat(savepath, '\', fname, '_WF', '.tif'))
        end
end

