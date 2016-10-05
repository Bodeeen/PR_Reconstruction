rand_coords = 1000+round(rand(20,2)*500)
figure
hold on
for i = 1:size(rand_coords, 1)
    plot(squeeze(gains(rand_coords(i,1), rand_coords(i,2),:)))
end
xlabel('Light intensity')
ylabel('Relative gain')