xc = 1000;
yc = 1000;

pix_v = 40;
start_cal = illumination_stack(yc, yc, 1);
i = 0;

for k = 1:100000000
    while pix_v > illumination_stack(xc,yc,i+1);
        i = i+1;
    end
    lower = illumination_stack(xc, yc, i);
    upper = illumination_stack(xc, yc, i+1);
    interval = upper - lower;
    interp_v = (pix_v - lower)/interval * gains(yc,yc,i+1) + (upper - pix_v)/interval * gains(yc,yc,i);
end


