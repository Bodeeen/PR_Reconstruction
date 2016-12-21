function save_image(widefield, recon, bg_sub_fac, diff_limit, datafilepath)
        
        split = strsplit(datafilepath, '\');
        LoadDataFileName = split{end}
        LoadDataPathName = strjoin(split(1:end-1), '\');
        savename = strsplit(LoadDataFileName,'.');
        savename = savename{1};
        dname = uigetdir(LoadDataPathName);
        fname = inputdlg('Chose name', 'Name',1,{savename});
        fname = fname{1};
        savepath = strcat(dname, '\', fname, sprintf('_Reconstruction_%.dnm_pin_%.2f_bg_sub_fac', 1000*diff_limit, bg_sub_fac));
        disp(strcat('Saving in :', savename))
        savepath_check = savepath;
        new_ver = 2;
        while exist(savepath_check) == 7
            savepath_check = strcat(savepath, '_', num2str(new_ver))
            new_ver = new_ver + 1;
        end
        savepath = savepath_check;
        mkdir(savepath)
        output = recon - min(recon(:));
        output = uint16(2^16*output/max(output(:)));
        imwrite(output, strcat(savepath, '\', fname, '_Reconstructed_Sthlm', '.tif'))
        widefield = widefield - min(widefield(:));
        widefield = uint16(2^16*widefield/max(widefield(:)));
        imwrite(widefield, strcat(savepath, '\', fname, '_WF', '.tif'))
end

