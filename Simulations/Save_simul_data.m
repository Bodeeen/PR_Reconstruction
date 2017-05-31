function Save_simul_data( rec, sig_strength_vec, name )
%Save recording of simulated data with signal strength according to
%sig_strength_vec and in folder by name

dname = strcat(uigetdir(), '\', name);
mkdir(dname)
h = waitbar(0, 'Saving...')
i = 0;
for ss = sig_strength_vec
    waitbar(i/length(sig_strength_vec))
    rec_adj = rec * ss;
    noisy_rec = poissrnd(rec_adj); %Adding poissonian noise
    savepath = strcat(dname, '\', name, 'ss_', num2str(ss), '.h5');
    h5create(savepath, '/data', size(noisy_rec))
    h5write(savepath, '/data', noisy_rec)
    i = i+1;
end
close(h)
end

