% Optimierung:

clear tabelle;
clear werte;

untere_grenze = 0;
genauigkeit = 0.01;
obere_grenze = 100;

anzahl_schritte = 10;

anzahl_durchgaenge = log((obere_grenze - untere_grenze)/anzahl_schritte/genauigkeit)/log(anzahl_schritte/2);
anzahl_durchgaenge = ceil(anzahl_durchgaenge);

prozent = 0;

for anzahl = 1:anzahl_durchgaenge
    
    intervall = (obere_grenze - untere_grenze)/anzahl_schritte;
    
    werte = untere_grenze:intervall:obere_grenze;
    
    for i = 1:anzahl_schritte+1
        korrekturfaktor = werte(i);
        sim('testbench_v01_1');
        tabelle(i) = min(abs(simout1(2000:end)));
        
        clc;
        prozent = prozent + 100/(anzahl_durchgaenge+1)/anzahl_schritte;
        fprintf('%f %%',prozent);
    end
    
    [C,I] = min(tabelle);
    obere_grenze = werte(I) + intervall;
    untere_grenze = werte(I) - intervall;
    
end

korrekturfaktor = werte(I)
