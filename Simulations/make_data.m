rec = Make_simulated_data(true, 320);
Save_simul_data(rec,[10 50 100 300 600 1000 5000], 100, 'WF_D320_32p5nm_px')
rec = Make_simulated_data(false, 250);
Save_simul_data(rec,[10 50 100 300 600 1000 5000], 100, 'MF_D250_32p5nm_px')
