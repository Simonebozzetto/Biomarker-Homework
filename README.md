# Homework BPMDD

Questa repository contiene materiali relativi all'homework di Biomarkers, Precision Medicine and Drug Development. 

Link per accedere ai dati e codici in caso di problemi (accessibile direttamente da visual abstract): https://github.com/Simonebozzetto/Biomarker-Homework.git 

I dati vengono analizzati in MATLAB, R e JASP. 

## Contenuto del repository
Nella repository, oltre ai PDF contenenti il Scientific Report, il Visual Abstract e alla consegna, sono presenti i seguenti file di supporto:
1) data_homework.mat
	contiene i dati forniti, opportunamente modificati per poter essere caricati in MATLAB e utilizzati nelle analisi.

2) codice_homework.m
	include tutte le analisi effettuate in MATLAB, nonché i grafici generati e successivamente inseriti nel report.

3) LI_code.m e swtest.m: 
	due funzioni MATLAB utilizzate, rispettivamente, per il calcolo dell’indice di lateralizzazione e per l’esecuzione del test di Shapiro-Wilk.

4) HomeworkBPMDD_LateralityTSPO.jasp
	file contenente le analisi preliminari condotte con il software JASP.
	Inoltre lo stesso file è presente in altri formati quali .csv e .xlsx 

5) Homework_R_part.R
	script R che documenta l’analisi effettuata tramite R. Per eseguire questo codice, è stato creato un nuovo file .mat (data_homework_R_part) con i dati già pronti per essere elaborati su R.

## Istruzioni

### MATLAB

1. Aprire `codice_homework.m` in MATLAB.
2. Assicurarsi che le funzioni swtest e LI_code siano nello stesso path/cartella.
3. Caricare i dati (`Data_Homework.mat`) 
4. Avviare l’analisi step by step anzichè eseguirla in un'unica volta.

### R

1. Aprire `Homework_R_part.R` con RStudio.
2. Caricare i dati da `Data_Homework_for_R.mat`.
3. Eseguire il codice per le analisi statistiche.

### JASP

1. Aprire `HomeworkBPMDD_LateralityTSPO.jasp` con JASP.
2. Esplorare le analisi già configurate e personalizzate.


## Autori

- [Rebecca Annovi, Simone Bozzetto, Chiara De Bon, Francesca Lazzarotto]
- Corso: [Biomarker Precision Medicine and Drug Development, Mattia Veronese]
- Università: [Università degli Studi di Padova]

---
