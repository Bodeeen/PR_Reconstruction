[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
im = double(load_image(strcat(LoadPathName, LoadFileName)));
corr_im = chessboard_correction_LS(im, 32);