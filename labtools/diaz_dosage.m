fid=fopen('diaz_dosage.txt', 'w')
fprintf(fid, '0.5 mg/ml diazepam')
fprintf(fid, '\nmass (g)\t0.5mg/kg\t1mg/kg\t5mg/kg')
for i=30:100
    fprintf(fid, '\n%d\t%.2f\t%.2f\t%.2f', i, i*1e-3, i*2e-3, i*10e-3)
end
fclose(fid)