[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
im = imread(strcat(LoadPathName, LoadFileName));
corr = chessboard_correction_LS(im, 32);
