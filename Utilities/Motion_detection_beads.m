function [ x_motions, y_motions ] = Motion_detection_beads(stack)
%Takes an input stack of a bead scan, localized the beads and calculated
%the motion  of all the different beads individually.
px_size = 65;
area_half_side_nm = 1500;
area_half_side_px = area_half_side_nm/px_size;

first = stack(:,:,1);
first = first - min(first(:));
first = first ./ max(first(:));

beads = FastPeakFind(first, 0.3, (fspecial('gaussian', 7,1)), 1, 2);
nr_b = length(beads)/2;
beads = reshape(beads, [2,nr_b]);

figure
imshow(first,[])
hold on
plot(beads(1,:), beads(2,:), 'x')
for i = 1:nr_b
    rectangle('Position',[beads(1,i) - area_half_side_px beads(2,i) - area_half_side_px 2*area_half_side_px 2*area_half_side_px], 'EdgeColor','w')
end

x_motions = [];
y_motions = [];

for i = 1:size(beads, 2)
    xs = floor(beads(1,i) - area_half_side_px);
    ys = floor(beads(2,i) - area_half_side_px);

    area = stack(ys:ys+2*area_half_side_px,xs:xs+2*area_half_side_px, :);
    [~, xm, ym] = Motion_detection_fun(area);
    x_motions = cat(1, x_motions, xm);
    y_motions = cat(1, y_motions, ym);
end

