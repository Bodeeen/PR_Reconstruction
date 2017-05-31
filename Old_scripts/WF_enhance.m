function [ enhancedWF ] = WF_enhance( WF_raw )
WF_raw = double(WF_raw);
kern = Gausskern(100,20);
kern = kern ./ sum(kern(:));
LPfiltered = conv2(WF_raw, kern,'same');
enhancedWF = WF_raw - 0.4*LPfiltered;
enhancedWF = mean(enhancedWF(:)) + enhancedWF;
% figure
% subplot(1,2,1)
% imshow(WF_raw, [])
% title('Raw widefield')
% subplot(1,2,2)
% imshow(enhancedWF, [])
% title('Enhanced widefield')

end

