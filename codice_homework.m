close all
clear all
clc
%%
load Data_Homework.mat;
%% PREPARAZIONE DEI DATI PER L'ANALISI STATISTICA
% Verifica della presenza di eventuali soggetti che presentano valori NaN,
% Inf e/o NON FISIOLOGICI. Questi soggetti verranno rimossi in quanto non
% ammissibili per un analisi statistica corretta.

% FARE UNA DISTINZIONE TRA I DIVERSI TIPI DI VALORI ANOMALI?

flag_sex = ~(Sex == "male" | Sex == "female") | ismissing(Sex);
flag_geno = ~(Genotype == "HAB" | Genotype == "MAB") | ismissing(Genotype);
flag_age = any(isnan(Age) | isinf(Age) | (Age<0),2);
flag_delete_Vt = any(isnan(Vt_ROI) | isinf(Vt_ROI) | (Vt_ROI<0) | (Vt_ROI>10),2);
flag_delete_Vol = any(isnan(Vol_ROI) | isinf(Vol_ROI) | (Vol_ROI<0),2);
flag_delete_VolB = any(isnan(Vol_Brain) | isinf(Vol_Brain) | (Vol_Brain<0),2);
flag_sum = any(sum(Vol_ROI,2) > Vol_Brain,2);
flag_delete = flag_sex | flag_geno | flag_age | flag_delete_Vt | flag_delete_Vol | flag_delete_VolB | flag_sum;
clear flag_sex
clear flag_geno
clear flag_age
clear flag_delete_Vt
clear flag_delete_Vol
clear flag_delete_VolB
clear flag_sum

fprintf('Soggetti con dati problematici:\n');
disp(find(flag_delete));
%% GRAFICI - BOXPLOT PER VERIFICARE OUTLIERS
figure
subplot(2,2,1)
boxplot(Age)
title('Boxplot Età')
ylabel('Età (anni)')
subplot(2,2,2)
boxplot(Vol_Brain)
title('Boxplot Volume Totale Cervello')
ylabel('Volume (cm^3)')
subplot(2,2,3)
boxplot(Vt_ROI)
title('Boxplot Vt per ROI')
ylabel('Vt')
subplot(2,2,4)
boxplot(Vol_ROI)
title('Boxplot Volumi ROI')
ylabel('Volume ROI (cm^3)')
%% RIMOZIONE DEI SOGGETTI CON DATI PROBLEMATICI
Vt_ROI(flag_delete,:) = [];
Vol_ROI(flag_delete,:) = [];
Vol_Brain(flag_delete,:) = [];
Age(flag_delete,:) = [];
Sex(flag_delete,:) = [];
Genotype(flag_delete,:) = [];
%% CALCOLO INDICE DI LATERALIZZAZIONE 
n_subj = size(Vt_ROI, 1);
n_ROI = size(Vt_ROI, 2) / 2; 
LI_Vt = LI_code(Vt_ROI); 
LI_vol = LI_code(Vol_ROI);
LI_labels = ["LI_Thalamus","LI_Putamen","LI_Cerebellum","LI_Occipital_Lobe","LI_Temporal_Lobe","LI_Frontal_Lobe","LI_Parietal_Lobe"];
%% GRAFICO MEDIE DELL'INDICE DI LATERALIZZAZIONE
LI_Vt_mean = mean(LI_Vt);
LI_vol_mean = mean(LI_vol);

regions = {'Thalamus','Putamen','Cerebellum','Occipital Lobe','Temporal Lobe','Frontal Lobe','Parietal Lobe'};
regions_cat = categorical(regions);
regions_cat = reordercats(regions_cat, regions);

lateralization = [LI_Vt_mean; LI_vol_mean];
lateralization = lateralization';

colors = [0.3010, 0.7450, 0.9330; 0.8500, 0.3250, 0.0980]; 

figure
barh(regions_cat, lateralization, 'grouped')
set(gca, 'YDir','reverse')

b = gca;
b.Children(2).FaceColor = colori(1,:);
b.Children(1).FaceColor = colori(2,:);

xline(0, '--', 'Color', [0.5 0.5 0.5]);

xlabel('Asymmetry index')
ylabel('Brain region')
legend({'LI Vt','LI Vol'}, 'Location','best')
title('Lateralization index for Vt and Vol')
xlim([-0.04 0.04])
grid on

clear b
clear lateralization
clear colori
clear regions
clear regions_cat
clear LI_Vt_mean
clear LI_vol_mean
%% TEST STATISTICI SULL'INDICE DI LATERALIZZAZIONE DI Vt
% test di gaussianità con lillietest
% anche se lillietest è meno robusto, è stato svolto per confrontare poi i
% risultati con il test Shapiro-Wilk
[h_lillie_thalamus,p_lillie_thalamus] = lillietest(LI_Vt(:,1)); % distribuzione non gaussiana
[h_lillie_putamen, p_lillie_putamen] = lillietest(LI_Vt(:,2)); % distribuzione non gaussiana
[h_lillie_cerebellum, p_lillie_cerebellum] = lillietest(LI_Vt(:,3)); % distribuzione non gaussiana
[h_lillie_occipital, p_lillie_occipital] = lillietest(LI_Vt(:,4)); % distribuzione gaussiana
[h_lillie_temporal, p_lillie_temporal] = lillietest(LI_Vt(:,5)); % distribuzione non gaussiana 
[h_lillie_frontal, p_lillie_frontal] = lillietest(LI_Vt(:,6)); % distribuzione non gaussiana
[h_lillie_parietal, p_lillie_parietal] = lillietest(LI_Vt(:,7)); % distribuzione gaussiana

% test di gaussianità con Shapiro-Wilk
% il test Shapiro-Wilk non è implementato su MatLab ma è stato ottenuto da
% MathWorks File Exchange al link:
% https://it.mathworks.com/matlabcentral/fileexchange/13964-shapiro-wilk-and-shapiro-francia-normality-tests
[h_sw_thalamus,p_sw_thalamus] = swtest(LI_Vt(:,1)); % distribuzione non gaussiana
[h_sw_putamen, p_sw_putamen] = swtest(LI_Vt(:,2)); % distribuzione non gaussiana
[h_sw_cerebellum, p_sw_cerebellum] = swtest(LI_Vt(:,3)); % distribuzione non gaussiana
[h_sw_occipital, p_sw_occipital] = swtest(LI_Vt(:,4)); % distribuzione non gaussiana
[h_sw_temporal, p_sw_temporal] = swtest(LI_Vt(:,5)); % distribuzione gaussiana
[h_sw_frontal, p_sw_frontal] = swtest(LI_Vt(:,6)); % distribuzione non gaussiana
[h_sw_parietal, p_sw_parietal] = swtest(LI_Vt(:,7)); % distribuzione gaussiana
% ci sono delle differenze tra i risultati ottenuti con lillietest e
% shapiro-wilk. Per confermare i risultati sono confrontati con i test di 
% normalità eseguiti con JASP 
% -> JASP ha ottenuto gli stessi risultati del Shapiro Wilk test di matlab
%    quindi sono stati assunti con distribuzione gaussiana solamente gli
%    indici di lateralizzazione del lobo pariatale e temporale 

% independent t-test tra gruppi distinti, assumendo la gaussianità dei dati
% Sex
[h_indp_sex_temporal, p_indep_sex_temporal] = ttest2(LI_Vt(Sex=="male",5), LI_Vt(Sex=="female",5));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_sex_parietal, p_indp_sex_parietal] = ttest2(LI_Vt(Sex=="male",7), LI_Vt(Sex=="female",7));
% media dei due gruppi (male & female) significativamente uguale

% Genotype
[h_indp_geno_temporal, p_indp_geno_temporal] = ttest2(LI_Vt(Genotype=="HAB",5), LI_Vt(Genotype=="MAB",5));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_parietal, p_indp_geno_parietal] = ttest2(LI_Vt(Genotype=="HAB",7), LI_Vt(Genotype=="MAB",7));
% media dei due gruppi (male & female) significativamente uguale

% Mann-Whitney U test tra gruppi distinti, assumendo la non gaussianità 
% dei dati
% Sex
[p_mwu_sex_thalamus,h_mwu_sex_thalamus] = ranksum(LI_Vt(Sex=="male",1),LI_Vt(Sex=="female",1)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_sex_putamen, h_mwu_sex_putamen] = ranksum(LI_Vt(Sex=="male",2),LI_Vt(Sex=="female",2));  
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_sex_cerebellum, h_mwu_sex_cerebellum] = ranksum(LI_Vt(Sex=="male",3),LI_Vt(Sex=="female",3)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_sex_occipital, h_mwu_sex_occipitial] = ranksum(LI_Vt(Sex=="male",4),LI_Vt(Sex=="female",4)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_sex_frontal, h_mwu_sex_frontal] = ranksum(LI_Vt(Sex=="male",6),LI_Vt(Sex=="female",6)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana

% Genotype
[p_mwu_geno_thalamus,h_mwu_geno_thalamus] = ranksum(LI_Vt(Genotype=="HAB",1),LI_Vt(Genotype=="MAB",1)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_geno_putamen, h_mwu_geno_putamen] = ranksum(LI_Vt(Genotype=="HAB",2),LI_Vt(Genotype=="MAB",2));  
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_geno_cerebellum, h_mwu_geno_cerebellum] = ranksum(LI_Vt(Genotype=="HAB",3),LI_Vt(Genotype=="MAB",3)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_geno_occipital, h_mwu_geno_occipitial] = ranksum(LI_Vt(Genotype=="HAB",4),LI_Vt(Genotype=="MAB",4)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_geno_frontal, h_mwu_geno_frontal] = ranksum(LI_Vt(Genotype=="HAB",6),LI_Vt(Genotype=="MAB",6)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana

% prima di proseguire oltre, andiamo ad eseguire gli stessi test statistici
% anche a livello dei Vt destro e sinistro delle varie regioni cerebrali
% per accertarsi se vi sono delle differenze statisticamente significative
% a livello di valori di Vt tra i due emisferi cerebrali e tra i gruppi già
% visti sopra: sesso e genotipo
%% TEST STATISTICI SUI VALORI Vt 
% test di gaussianità con Shapiro-Wilk
% data la conformità con JASP, si è scelto di eseguire solamente il test
% Shapiro-Wilk
[h_sw_thalamus_sx,p_sw_thalamus_sx] = swtest(Vt_ROI(:,1)); % distribuzione NON normale
[h_sw_thalamus_dx,p_sw_thalamus_dx] = swtest(Vt_ROI(:,2)); % distribuzione NON normale
[h_sw_putamen_sx, p_sw_putamen_sx] = swtest(Vt_ROI(:,3)); % distribuzione NON normale
[h_sw_putamen_dx, p_sw_putamen_dx] = swtest(Vt_ROI(:,4)); % distribuzione NON normale
[h_sw_cerebellum_sx, p_sw_cerebellum_sx] = swtest(Vt_ROI(:,5)); % distribuzione NON normale
[h_sw_cerebellum_dx, p_sw_cerebellum_dx] = swtest(Vt_ROI(:,6)); % distribuzione normale
[h_sw_occipital_sx, p_sw_occipital_sx] = swtest(Vt_ROI(:,7)); % distribuzione NON normale
[h_sw_occipital_dx, p_sw_occipital_dx] = swtest(Vt_ROI(:,8)); % distribuzione NON normale
[h_sw_temporal_sx, p_sw_temporal_sx] = swtest(Vt_ROI(:,9)); % distribuzione NON normale
[h_sw_temporal_dx, p_sw_temporal_dx] = swtest(Vt_ROI(:,10)); % distribuzione normale
[h_sw_frontal_sx, p_sw_frontal_sx] = swtest(Vt_ROI(:,11)); % distribuzione NON normale
[h_sw_frontal_dx, p_sw_frontal_dx] = swtest(Vt_ROI(:,12)); % distribuzione NON normale
[h_sw_parietal_sx, p_sw_parietal_sx] = swtest(Vt_ROI(:,13)); % distribuzione NON normale
[h_sw_parietal_dx, p_sw_parietal_dx] = swtest(Vt_ROI(:,14)); % distribuzione normale
% in accordo con i risultati ottenuti su JASP

% independent t-test tra gruppi distinti, assumendo la gaussianità dei dati
% Sex
[h_indp_sex_cerebellum_dx, p_indep_sex_cerebellum_dx] = ttest2(Vt_ROI(Sex=="male",6), Vt_ROI(Sex=="female",6));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_temporal_dx, p_indp_sex_temporal_dx] = ttest2(Vt_ROI(Sex=="male",10), Vt_ROI(Sex=="female",10));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_parietal_dx, p_indp_sex_parietal_dx] = ttest2(Vt_ROI(Sex=="male",14), Vt_ROI(Sex=="female",14));
% media dei due gruppi (male & female) significativamente diversa

% Genotype
[h_indp_geno_cerebellum_dx, p_indep_geno_cerebellum_dx] = ttest2(Vt_ROI(Genotype=="HAB",6), Vt_ROI(Genotype=="MAB",6));
% media dei due gruppi (HAB & MAB) significativamente diversa
[h_indp_geno_temporal_dx, p_indp_geno_temporal_dx] = ttest2(Vt_ROI(Genotype=="HAB",10), Vt_ROI(Genotype=="MAB",10));
% media dei due gruppi (HAB & MAB) significativamente diversa
[h_indp_geno_parietal_dx, p_indp_geno_parietal_dx] = ttest2(Vt_ROI(Genotype=="HAB",14), Vt_ROI(Genotype=="MAB",14));
% media dei due gruppi (HAB & MAB) significativamente diversa

% Mann-Whitney U test tra gruppi distinti, assumendo la non gaussianità 
% dei dati
% Sex
[p_mwu_sex_thalamus_sx,h_mwu_sex_thalamus_sx] = ranksum(Vt_ROI(Sex=="male",1),Vt_ROI(Sex=="female",1)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_thalamus_dx,h_mwu_sex_thalamus_dx] = ranksum(Vt_ROI(Sex=="male",2),Vt_ROI(Sex=="female",2)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_sex_putamen_sx, h_mwu_sex_putamen_sx] = ranksum(Vt_ROI(Sex=="male",3),Vt_ROI(Sex=="female",3));  
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_sex_putamen_dx, h_mwu_sex_putamen_dx] = ranksum(Vt_ROI(Sex=="male",4),Vt_ROI(Sex=="female",4));  
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana
[p_mwu_sex_cerebellum_sx, h_mwu_sex_cerebellum_sx] = ranksum(Vt_ROI(Sex=="male",5),Vt_ROI(Sex=="female",5)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_occipital_sx, h_mwu_sex_occipitial_sx] = ranksum(Vt_ROI(Sex=="male",7),Vt_ROI(Sex=="female",7)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_occipital_dx, h_mwu_sex_occipitial_dx] = ranksum(Vt_ROI(Sex=="male",8),Vt_ROI(Sex=="female",8)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_temporal_sx, h_mwu_sex_temporal_sx] = ranksum(Vt_ROI(Sex=="male",9),Vt_ROI(Sex=="female",9)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_frontal_sx, h_mwu_sex_frontal_sx] = ranksum(Vt_ROI(Sex=="male",11),Vt_ROI(Sex=="female",11)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_frontal_dx, h_mwu_sex_frontal_dx] = ranksum(Vt_ROI(Sex=="male",12),Vt_ROI(Sex=="female",12)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_parietal_sx, h_mwu_sex_parietal_sx] = ranksum(Vt_ROI(Sex=="male",13),Vt_ROI(Sex=="female",13)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana

% Genotype
[p_mwu_geno_thalamus_sx,h_mwu_geno_thalamus_sx] = ranksum(Vt_ROI(Genotype=="HAB",1),Vt_ROI(Genotype=="MAB",1)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_thalamus_dx,h_mwu_geno_thalamus_dx] = ranksum(Vt_ROI(Genotype=="HAB",2),Vt_ROI(Genotype=="MAB",2)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_putamen_sx, h_mwu_geno_putamen_sx] = ranksum(Vt_ROI(Genotype=="HAB",3),Vt_ROI(Genotype=="MAB",3));  
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_putamen_dx, h_mwu_geno_putamen_dx] = ranksum(Vt_ROI(Genotype=="HAB",4),Vt_ROI(Genotype=="MAB",4));  
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_cerebellum_sx, h_mwu_geno_cerebellum_sx] = ranksum(Vt_ROI(Genotype=="HAB",5),Vt_ROI(Genotype=="MAB",5)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_occipital_sx, h_mwu_geno_occipitial_sx] = ranksum(Vt_ROI(Genotype=="HAB",7),Vt_ROI(Genotype=="MAB",7)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_occipital_dx, h_mwu_geno_occipitial_dx] = ranksum(Vt_ROI(Genotype=="HAB",8),Vt_ROI(Genotype=="MAB",8)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_temporal_sx, h_mwu_geno_temporal_sx] = ranksum(Vt_ROI(Genotype=="HAB",9),Vt_ROI(Genotype=="MAB",9)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_frontal_sx, h_mwu_geno_frontal_sx] = ranksum(Vt_ROI(Genotype=="HAB",11),Vt_ROI(Genotype=="MAB",11)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_frontal_dx, h_mwu_geno_frontal_dx] = ranksum(Vt_ROI(Genotype=="HAB",12),Vt_ROI(Genotype=="MAB",12)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_geno_parietal_sx, h_mwu_geno_parietal_sx] = ranksum(Vt_ROI(Genotype=="HAB",13),Vt_ROI(Genotype=="MAB",13)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa

% in accordo con i risultati ottenuti su JASP

% test di gaussianità con Shapiro-Wilk della differenza tra le coppie di
% dati per decidere se eseguire un paired t-test oppure un Wilcoxon 
% Signed-Rank test
[h_sw_thalamus_diff,p_sw_thalamus_diff] = swtest(Vt_ROI(:,1)-Vt_ROI(:,2)); % distribuzione NON gaussiana della differenza
[h_sw_putamen_diff, p_sw_putamen_diff] = swtest(Vt_ROI(:,3)-Vt_ROI(:,4)); % distribuzione NON gaussiana della differenza
[h_sw_cerebellum_diff, p_sw_cerebellum_diff] = swtest(Vt_ROI(:,5)-Vt_ROI(:,6)); % distribuzione NON gaussiana della differenza
[h_sw_occipital_diff, p_sw_occipital_diff] = swtest(Vt_ROI(:,7)-Vt_ROI(:,8)); % distribuzione NON gaussiana della differenza
[h_sw_temporal_diff, p_sw_temporal_diff] = swtest(Vt_ROI(:,9)-Vt_ROI(:,10)); % distribuzione NON gaussiana della differenza
[h_sw_frontal_diff, p_sw_frontal_diff] = swtest(Vt_ROI(:,11)-Vt_ROI(:,12)); % distribuzione NON gaussiana della differenza
[h_sw_parietal_diff, p_sw_parietal_diff] = swtest(Vt_ROI(:,13)-Vt_ROI(:,14)); % distribuzione gaussiana della differenza

% paired t-test tra Vt degli stessi soggetti dell'emisfero destro e 
% dell'emisfero sinistro, assuemendo la gaussianità dei dati
[h_paired_parietal,p_paired_parietal] = ttest(Vt_ROI(:,13),Vt_ROI(:,14)); % no differenze significative
[h_paired_temporal,p_paired_temporal] = ttest(Vt_ROI(:,9),Vt_ROI(:,10)); % no differenze significative

% Wilcoxon Signed-Rank test tra Vt degli stessi soggetti dell'emisfero destro e 
% dell'emisfero sinistro, assuemendo la non gaussianità dei dati
[p_wsr_thalamus, h_wsr_thalamus] = signrank(Vt_ROI(:,1),Vt_ROI(:,2)); % no differenze significative
[p_wsr_putamen, h_wsr_putamen] = signrank(Vt_ROI(:,3),Vt_ROI(:,4)); % no differenze significative
[p_wsr_cerebellum, h_wsr_cerebellum] = signrank(Vt_ROI(:,5),Vt_ROI(:,6)); % no differenze significative
[p_wsr_occipital, h_wsr_occipital] = signrank(Vt_ROI(:,7),Vt_ROI(:,8)); % no differenze significative
[p_wsr_temporal, h_wsr_temporal] = signrank(Vt_ROI(:,9),Vt_ROI(:,10)); % DIFFERENZE SIGNIFICATIVE
[p_wsr_frontal, h_wsr_frontal] = signrank(Vt_ROI(:,11),Vt_ROI(:,12)); % no differenze significative
%% TEST STATISTICI SULL'INDICE DI LATERALIZZAZIONE DEI VOLUMI DELLE ROI
% test di gaussianità con Shapiro-Wilk
[h_sw_ROI_thalamus,p_sw_ROI_thalamus] = swtest(LI_vol(:,1)); % distribuzione gaussiana
[h_sw_ROI_putamen, p_sw_ROI_putamen] = swtest(LI_vol(:,2)); % distribuzione gaussiana
[h_sw_ROI_cerebellum, p_sw_ROI_cerebellum] = swtest(LI_vol(:,3)); % distribuzione NON gaussiana
[h_sw_ROI_occipital, p_sw_ROI_occipital] = swtest(LI_vol(:,4)); % distribuzione gaussiana
[h_sw_ROI_temporal, p_sw_ROI_temporal] = swtest(LI_vol(:,5)); % distribuzione gaussiana
[h_sw_ROI_frontal, p_sw_ROI_frontal] = swtest(LI_vol(:,6)); % distribuzione gaussiana
[h_sw_ROI_parietal, p_sw_ROI_parietal] = swtest(LI_vol(:,7)); % distribuzione gaussiana

% independent t-test tra gruppi distinti, assumendo la gaussianità dei dati
% Sex
[h_indp_sex_thalamus_ROI, p_indep_sex_thalamus_ROI] = ttest2(LI_vol(Sex=="male",1), LI_vol(Sex=="female",1));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_sex_putamen_ROI, p_indp_sex_putamen_ROI] = ttest2(LI_vol(Sex=="male",2), LI_vol(Sex=="female",2));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_sex_occipital_ROI, p_indep_sex_occipital_ROI] = ttest2(LI_vol(Sex=="male",4), LI_vol(Sex=="female",4));
% media dei due gruppi (male & female) significativamente DIVERSA
[h_indp_sex_temporal_ROI, p_indep_sex_temporal_ROI] = ttest2(LI_vol(Sex=="male",5), LI_vol(Sex=="female",5));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_sex_frontal_ROI, p_indp_sex_frontal_ROI] = ttest2(LI_vol(Sex=="male",6), LI_vol(Sex=="female",6));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_sex_parietal_ROI, p_indp_sex_parietal_ROI] = ttest2(LI_vol(Sex=="male",7), LI_vol(Sex=="female",7));
% media dei due gruppi (male & female) significativamente uguale

% Genotype
[h_indp_geno_thalamus_ROI, p_indep_geno_thalamus_ROI] = ttest2(LI_vol(Genotype=="HAB",1), LI_vol(Genotype=="MAB",1));
% media dei due gruppi (HAB & MAB) significativamente DIVERSA
[h_indp_geno_putamen_ROI, p_indp_geno_putamen_ROI] = ttest2(LI_vol(Genotype=="HAB",2), LI_vol(Genotype=="MAB",2));
% media dei due gruppi (HAB & MAB) significativamente uguale
[h_indp_geno_occipital_ROI, p_indep_geno_occipital_ROI] = ttest2(LI_vol(Genotype=="HAB",4), LI_vol(Genotype=="MAB",4));
% media dei due gruppi (HAB & MAB) significativamente DIVERSA
[h_indp_geno_temporal_ROI, p_indep_geno_temporal_ROI] = ttest2(LI_vol(Genotype=="HAB",5), LI_vol(Genotype=="MAB",5));
% media dei due gruppi (HAB & MAB) significativamente uguale
[h_indp_geno_frontal_ROI, p_indp_geno_frontal_ROI] = ttest2(LI_vol(Genotype=="HAB",6), LI_vol(Genotype=="MAB",6));
% media dei due gruppi (HAB & MAB) significativamente uguale
[h_indp_geno_parietal_ROI, p_indp_geno_parietal_ROI] = ttest2(LI_vol(Genotype=="HAB",7), LI_vol(Genotype=="MAB",7));
% media dei due gruppi (HAB & MAB) significativamente uguale

% Mann-Whitney U test tra gruppi distinti, assumendo la non gaussianità 
% dei dati
% Sex
[p_mwu_sex_cerebellum_ROI, h_mwu_sex_cerebellum_ROI] = ranksum(LI_vol(Sex=="male",3),LI_vol(Sex=="female",3)); 
% i due gruppi hanno statisticamente distribuzione diversa
% -> diversa mediana

% Genotype
[p_mwu_geno_cerebellum_ROI, h_mwu_geno_cerebellum_ROI] = ranksum(LI_vol(Genotype=="HAB",3),LI_vol(Genotype=="MAB",3)); 
% i due gruppi hanno statisticamente la stessa distribuzione 
% -> stessa mediana

% analogamente a prima si sono visti gli stessi test statistici per quanto
% riguarda i volumi delle regioni di interese
%% TEST STATISTICI SUI VALORI VOL 
% test di gaussianità con Shapiro-Wilk
[h_sw_thalamus_sx_ROI,p_sw_thalamus_sx_ROI] = swtest(Vol_ROI(:,1)); % distribuzione NON normale
[h_sw_thalamus_dx_ROI,p_sw_thalamus_dx_ROI] = swtest(Vol_ROI(:,2)); % distribuzione NON normale
[h_sw_putamen_sx_ROI, p_sw_putamen_sx_ROI] = swtest(Vol_ROI(:,3)); % distribuzione normale
[h_sw_putamen_dx_ROI, p_sw_putamen_dx_ROI] = swtest(Vol_ROI(:,4)); % distribuzione normale
[h_sw_cerebellum_sx_ROI, p_sw_cerebellum_sx_ROI] = swtest(Vol_ROI(:,5)); % distribuzione NON normale
[h_sw_cerebellum_dx_ROI, p_sw_cerebellum_dx_ROI] = swtest(Vol_ROI(:,6)); % distribuzione NON normale
[h_sw_occipital_sx_ROI, p_sw_occipital_sx_ROI] = swtest(Vol_ROI(:,7)); % distribuzione normale
[h_sw_occipital_dx_ROI, p_sw_occipital_dx_ROI] = swtest(Vol_ROI(:,8)); % distribuzione normale
[h_sw_temporal_sx_ROI, p_sw_temporal_sx_ROI] = swtest(Vol_ROI(:,9)); % distribuzione normale
[h_sw_temporal_dx_ROI, p_sw_temporal_dx_ROI] = swtest(Vol_ROI(:,10)); % distribuzione normale
[h_sw_frontal_sx_ROI, p_sw_frontal_sx_ROI] = swtest(Vol_ROI(:,11)); % distribuzione normale
[h_sw_frontal_dx_ROI, p_sw_frontal_dx_ROI] = swtest(Vol_ROI(:,12)); % distribuzione normale
[h_sw_parietal_sx_ROI, p_sw_parietal_sx_ROI] = swtest(Vol_ROI(:,13)); % distribuzione normale
[h_sw_parietal_dx_ROI, p_sw_parietal_dx_ROI] = swtest(Vol_ROI(:,14)); % distribuzione normale

% independent t-test tra gruppi distinti, assumendo la gaussianità dei dati
% Sex
[h_indp_sex_putamen_sx_ROI, p_indp_sex_putamen_sx_ROI] = ttest2(Vol_ROI(Sex=="male",3), Vol_ROI(Sex=="female",3));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_putamen_dx_ROI, p_indp_sex_putamen_dx_ROI] = ttest2(Vol_ROI(Sex=="male",4), Vol_ROI(Sex=="female",4));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_occipital_sx_ROI, p_indp_sex_occipital_sx_ROI] = ttest2(Vol_ROI(Sex=="male",7), Vol_ROI(Sex=="female",7));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_occipital_dx_ROI, p_indp_sex_occipital_dx_ROI] = ttest2(Vol_ROI(Sex=="male",8), Vol_ROI(Sex=="female",8));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_temporal_sx_ROI, p_indp_sex_temporal_sx_ROI] = ttest2(Vol_ROI(Sex=="male",9), Vol_ROI(Sex=="female",9));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_temporal_dx_ROI, p_indp_sex_temporal_dx_ROI] = ttest2(Vol_ROI(Sex=="male",10), Vol_ROI(Sex=="female",10));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_frontal_sx_ROI, p_indp_sex_frontal_sx_ROI] = ttest2(Vol_ROI(Sex=="male",11), Vol_ROI(Sex=="female",11));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_frontal_dx_ROI, p_indp_sex_frontal_dx_ROI] = ttest2(Vol_ROI(Sex=="male",12), Vol_ROI(Sex=="female",12));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_parietal_sx_ROI, p_indp_sex_parietal_sx_ROI] = ttest2(Vol_ROI(Sex=="male",13), Vol_ROI(Sex=="female",13));
% media dei due gruppi (male & female) significativamente diversa
[h_indp_sex_parietal_dx_ROI, p_indp_sex_parietal_dx_ROI] = ttest2(Vol_ROI(Sex=="male",14), Vol_ROI(Sex=="female",14));
% media dei due gruppi (male & female) significativamente diversa

% Genotype
[h_indp_geno_putamen_sx_ROI, p_indp_geno_putamen_sx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",3), Vol_ROI(Genotype=="MAB",3));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_putamen_dx_ROI, p_indp_geno_putamen_dx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",4), Vol_ROI(Genotype=="MAB",4));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_occipital_sx_ROI, p_indp_geno_occipital_sx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",7), Vol_ROI(Genotype=="MAB",7));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_occipital_dx_ROI, p_indp_geno_occipital_dx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",8), Vol_ROI(Genotype=="MAB",8));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_temporal_sx_ROI, p_indp_geno_temporal_sx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",9), Vol_ROI(Genotype=="MAB",9));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_temporal_dx_ROI, p_indp_geno_temporal_dx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",10), Vol_ROI(Genotype=="MAB",10));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_frontal_sx_ROI, p_indp_geno_frontal_sx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",11), Vol_ROI(Genotype=="MAB",11));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_frontal_dx_ROI, p_indp_geno_frontal_dx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",12), Vol_ROI(Genotype=="MAB",12));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_parietal_sx_ROI, p_indp_geno_parietal_sx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",13), Vol_ROI(Genotype=="MAB",13));
% media dei due gruppi (male & female) significativamente uguale
[h_indp_geno_parietal_dx_ROI, p_indp_geno_parietal_dx_ROI] = ttest2(Vol_ROI(Genotype=="HAB",14), Vol_ROI(Genotype=="MAB",14));
% media dei due gruppi (male & female) significativamente uguale

% Mann-Whitney U test tra gruppi distinti, assumendo la non gaussianità 
% dei dati
% Sex
[p_mwu_sex_thalamus_sx_ROI,h_mwu_sex_thalamus_sx_ROI] = ranksum(Vol_ROI(Sex=="male",1),Vol_ROI(Sex=="female",1)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_thalamus_dx_ROI,h_mwu_sex_thalamus_dx_ROI] = ranksum(Vol_ROI(Sex=="male",2),Vol_ROI(Sex=="female",2)); 
% i due gruppi hanno statisticamente la distribuzione diversa
% -> mediana diversa
[p_mwu_sex_cerebellum_sx_ROI, h_mwu_sex_cerebellum_sx_ROI] = ranksum(Vol_ROI(Sex=="male",5),Vol_ROI(Sex=="female",5)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa
[p_mwu_sex_cerebellum_dx_ROI, h_mwu_sex_cerebellum_dx_ROI] = ranksum(Vol_ROI(Sex=="male",6),Vol_ROI(Sex=="female",6)); 
% i due gruppi hanno statisticamente la distribuzione diversa 
% -> mediana diversa

% Genotype
[p_mwu_geno_thalamus_sx_ROI,h_mwu_geno_thalamus_sx_ROI] = ranksum(Vol_ROI(Genotype=="HAB",1),Vol_ROI(Genotype=="MAB",1)); 
% i due gruppi hanno statisticamente la distribuzione uguale 
% -> stessa mediana 
[p_mwu_geno_thalamus_dx_ROI,h_mwu_geno_thalamus_dx_ROI] = ranksum(Vol_ROI(Genotype=="HAB",2),Vol_ROI(Genotype=="MAB",2)); 
% i due gruppi hanno statisticamente la distribuzione uguale
% -> stessa mediana 
[p_mwu_geno_cerebellum_sx_ROI, h_mwu_geno_cerebellum_sx_ROI] = ranksum(Vol_ROI(Genotype=="HAB",5),Vol_ROI(Genotype=="MAB",5)); 
% i due gruppi hanno statisticamente la distribuzione uguale 
% -> stessa mediana 
[p_mwu_geno_cerebellum_dx_ROI, h_mwu_geno_cerebellum_dx_ROI] = ranksum(Vol_ROI(Genotype=="HAB",6),Vol_ROI(Genotype=="MAB",6)); 
% i due gruppi hanno statisticamente la distribuzione uguale 
% -> stessa mediana 


% test di gaussianità con Shapiro-Wilk della differenza tra le coppie di
% dati per decidere se eseguire un paired t-test oppure un Wilcoxon 
% Signed-Rank test
[h_sw_thalamus_ROI_diff,p_sw_thalamus_ROI_diff] = swtest(Vol_ROI(:,1)-Vol_ROI(:,2)); % distribuzione NON gaussiana della differenza
[h_sw_putamen_ROI_diff, p_sw_putamen_ROI_diff] = swtest(Vol_ROI(:,3)-Vol_ROI(:,4)); % distribuzione gaussiana della differenza
[h_sw_cerebellum_ROI_diff, p_sw_cerebellum_ROI_diff] = swtest(Vol_ROI(:,5)-Vol_ROI(:,6)); % distribuzione NON gaussiana della differenza
[h_sw_occipital_ROI_diff, p_sw_occipital_ROI_diff] = swtest(Vol_ROI(:,7)-Vol_ROI(:,8)); % distribuzione gaussiana della differenza
[h_sw_temporal_ROI_diff, p_sw_temporal_ROI_diff] = swtest(Vol_ROI(:,9)-Vol_ROI(:,10)); % distribuzione gaussiana della differenza
[h_sw_frontal_ROI_diff, p_sw_frontal_ROI_diff] = swtest(Vol_ROI(:,11)-Vol_ROI(:,12)); % distribuzione NON gaussiana della differenza
[h_sw_parietal_ROI_diff, p_sw_parietal_ROI_diff] = swtest(Vol_ROI(:,13)-Vol_ROI(:,14)); % distribuzione gaussiana della differenza

% paired t-test tra Vol degli stessi soggetti dell'emisfero destro e 
% dell'emisfero sinistro, assuemendo la gaussianità dei dati
[h_paired_putamen_ROI,p_paired_putamen_ROI] = ttest(Vol_ROI(:,3),Vol_ROI(:,4)); % differenze significative
[h_paired_occipital_ROI,p_paired_occipital_ROI] = ttest(Vol_ROI(:,7),Vol_ROI(:,8)); % differenze significative
[h_paired_parietal_ROI,p_paired_parietal_ROI] = ttest(Vol_ROI(:,13),Vol_ROI(:,14)); % differenze significative
[h_paired_temporal_ROI,p_paired_temporal_ROI] = ttest(Vol_ROI(:,9),Vol_ROI(:,10)); % differenze significative

% Wilcoxon Signed-Rank test tra Vol degli stessi soggetti dell'emisfero destro e 
% dell'emisfero sinistro, assuemendo la non gaussianità dei dati
[p_wsr_thalamus_ROI, h_wsr_thalamus_ROI] = signrank(Vol_ROI(:,1),Vol_ROI(:,2)); % differenze significative
[p_wsr_cerebellum_ROI, h_wsr_cerebellum_ROI] = signrank(Vol_ROI(:,5),Vol_ROI(:,6)); % differenze significative
[p_wsr_frontal_ROI, h_wsr_frontal_ROI] = signrank(Vol_ROI(:,11),Vol_ROI(:,12)); % no differenze significative
%% REGRESSIONE LINEARE
% PREPARAZIONE DATI
% dato che i vettori Genotype e Sex sono delle stringhe, per eseguire
% la regressione lineare, è necessario eseguire una codifica numerica dei
% valori che possono assumere queste due variabili.
% Dato che i valori che possono assumere sono binari in questo caso:
% Genotype: HAB o MAB
% Sex: male o female
% allora è sufficiente creare una stringa di double composta da 0 e 1 nel
% seguente modo:
Genotype_bin = double(Genotype == 'HAB');
% VALORI DELLA NUOVA VARIABILE:     HAB -> 1        MAB -> 0
Sex_bin = double(Sex == 'male');
% VALORI DELLA NUOVA VARIABILE:     male -> 1        female -> 0
%%
% GRAFICI PRE-REGRESSIONE LINEARE
% istogramma della distribuzione di LI_Vt del Thalamus L
figure;
histogram(LI_Vt(:,1), 20);
title('Distribuzione di LI del Vt');
xlabel('LI Vt'); 
ylabel('Frequenza');
% boxplot di LI_Vt del Thalamus L per sesso
figure;
boxplot(LI_Vt(:,1), Sex);
title('LI Vt per sesso');
ylabel('LI Vt');
% boxplot di LI_Vt del Thalamus L per genotipo
figure;
boxplot(LI_Vt(:,1), Genotype);
title('LI Vt per sesso');
ylabel('LI Vt');
% scatter plot tra LI_Vt del Thalamus L e età
figure;
scatter(Age, LI_Vt(:,1), 'filled');
lsline; 
title('LI Vt vs Età');
xlabel('Età'); 
ylabel('LI Vt');
% scatter plot tra LI_Vt del Thalamus L e volume cerebrale
figure;
scatter(Vol_Brain, LI_Vt(:,1), 'filled');
lsline; 
title('LI Vt vs volume cerebrale');
xlabel('Vol Brain'); 
ylabel('LI Vt');
% correlazione tra LI_Vt del Thalamus L e LI_vol delle varie ROI
figure;
for i = 1:7
    subplot(2,4,i)
    scatter(LI_vol(:,i), LI_Vt(:,1), 'filled');
    lsline;
    title(['LI Vol ROI ' num2str(i)]);
    xlabel('LI Volume'); ylabel('LI Vt');
end
clear i
sgtitle('Correlazione tra LI Vt e LI Volumi delle ROI');
% matrice di correlazione con heatmap del LI_Vt del Thalamus L
X_numeric = [LI_Vt(:,1), Age, Vol_Brain, LI_vol(:,1)];
labels = {'LI Vt','Age', 'Vol Brain', 'LI ROI 1'};
R = corr(X_numeric, 'Rows', 'complete');
figure;
heatmap(labels, labels, R, 'Colormap', parula);
title('Matrice di correlazione tra predittori del talamo');
clear X_numeric
clear labels
clear R
%%
% REGRESSIONE LINEARE CON TUTTE LE VARIABILI INDIPENDENTI
% Creazione della matrice beta che conterrà tutti i coefficienti delle
% regressioni lineari
% Le variabili indipendenti che verranno utilizzate nella regressione
% lineare sono 6. Si considera influente solamente la LI_vol della stessa
% ROI di cui si vuole fare la regressione lineare. Questo perché si è
% interessati a trovare quali variabili indipendenti sono
% significativamente influenti sul LI_Vt e non se esiste quale correlazione
% tra le varie ROI a livello di indice di assimmetria
n_indp_var = 6;
beta = zeros(n_indp_var,n_ROI);
y_pred = zeros(n_subj,n_ROI);
residuals = zeros(n_subj,n_ROI);
R2 = zeros(n_ROI,1);
sigma_hat_2 = zeros(n_ROI,1);
SE = zeros(n_indp_var,n_ROI);
CV = zeros(n_indp_var,n_ROI);
t_values = zeros(n_indp_var,n_ROI);
p_values = zeros(n_indp_var,n_ROI);
for ii = 1 : n_ROI
    % Creazione di Y e X per ogni ROI, in X è inclusa anche l'intercetta
    % Non si inserisce Vt in quanto non ha senso perché LI è derivato proprio
    % dai valori di Vt nelle due emisferi cerebrali
    Y = LI_Vt(:, ii); 
    X = [Age, Sex_bin, Genotype_bin, Vol_Brain, LI_vol(:,ii), ones(n_subj,1)];
    % Calcolo dei coefficienti
    b = (X' * X)\(X' * Y);
    beta(:,ii) = b;
    % Ca lcolo dei residui
    y_pred(:,ii) = X * b;
    residuals(:,ii) = Y - y_pred(:,ii);
    % Calcolo della bontà del fit: quanta varianza il modello spiega i dati iniziali?
    SST = sum((Y - mean(Y)).^2); 
    SSE = sum((Y - y_pred(:,ii)).^2);
    R2(ii) = 1 - (SSE / SST); 
    disp('Indice di determinazione R2')
    disp(R2(ii))
    % Varianza dell'errore di misura
    sigma_hat_2(ii) = (residuals(:,ii)'*residuals(:,ii))/(n_subj-n_indp_var);
    disp('Stima della varianza dell''errore di misura')
    disp(sigma_hat_2(ii))
    % Standard error delle stime
    SE(:,ii) = sqrt((sigma_hat_2(ii))*diag(inv(X'*X)));
    disp('Standard Error delle misure')
    disp(SE(:,ii))
    % Coefficiente di variazione
    CV(:,ii) = SE(:,ii)./abs(beta(:,ii))*100;
    disp('Coefficienti di variazione percentuali dei beta')
    disp(CV(:,ii))
    % t-statistic per ogni coefficiente e calcolo del p-value 
    t_values(:,ii) = b ./ SE(:,ii);
    p_values(:,ii) = 2 * (1 - tcdf(abs(t_values(:,ii)), n_subj-n_indp_var));
    % Visualizzazione mediante scatter plot  
    % figure 
    % scatter(Y, y_pred(:,ii),'*')
    % grid on 
    % xlabel('Y') 
    % ylabel('Y pred') 
    % title(['Scatterplot ' 'Y' '-' 'Y pred'])
    % Visualizzazione nella stessa figura: dati e predizione, residui 
    % figure
    % plot(residuals(:,ii))
    % title('Residui (Y - Y pred)')
end
clear ii
clear X
clear Y
clear b
clear SST
clear SSE
%% ELASTIC-NET REGRESSION GENERALIZZATA
n_pred = 5;
B_all = zeros(n_pred, n_ROI);        
Intercept_all = zeros(n_ROI, 1);
Lambda_all = zeros(n_ROI, 1);

for i = 1:n_ROI
    Y_en = LI_Vt(:, i);
    X_en = [Age, Sex_bin, Genotype_bin, Vol_Brain, LI_vol(:,i)];

    [B, FitInfo] = lasso(X_en, Y_en, 'Alpha', 0.5);

    [~, idxMinMSE] = min(FitInfo.MSE);

    B_all(:, i) = B(:, idxMinMSE);                     
    Intercept_all(i) = FitInfo.Intercept(idxMinMSE);  
    Lambda_all(i) = FitInfo.Lambda(idxMinMSE);        
end
clear Y_en
clear X_en
clear B
clear FitInfo
clear idxMinMSE
%% PLOT DELLA REGRESSIONE LINEARE TRA LI_Vt E LI_Vol
figure
for i = 1:n_ROI
    subplot(2, ceil(n_ROI/2), i)
    x = LI_vol(:, i);         
    y = LI_Vt(:, i);          
    b = beta(:, i);           
    scatter(x, y, 25, 'filled', 'MarkerFaceAlpha', 0.6); hold on;
    x_grid = linspace(min(x), max(x), 100)';
    X_grid = [mean(Age)*ones(size(x_grid)),mean(Sex_bin)*ones(size(x_grid)),mean(Genotype_bin)*ones(size(x_grid)),mean(Vol_Brain)*ones(size(x_grid)),x_grid,ones(size(x_grid))];
    y_grid = X_grid * b;
    plot(x_grid, y_grid, 'r-', 'LineWidth', 2);
    xlabel('LI_{Vol}');
    ylabel('LI_{Vt}');
    title(['ROI ', num2str(i)]);
    beta_vol = beta(5, i);
    R2_val = R2(i);
    text(min(x), max(y), sprintf('\\beta_{LI_{Vol}} = %.2f\nR^2 = %.2f', beta_vol, R2_val),'VerticalAlignment', 'top', 'BackgroundColor', 'w', 'EdgeColor', 'k');
end
sgtitle('Relazione lineare tra LI_{Vol} e LI_{Vt} per ciascuna ROI')
clear i
clear x
clear y
clear b
clear x_grid
clear X_grid
clear y_grid
clear beta_vol
clear R2_val
%% PLOT DELLA REGRESSIONE LINEARE DA INSERIRE NEL REPORT 
x = LI_vol(:, 1);         
y = LI_Vt(:, 1);          
b = beta(:, 1);           
scatter(x, y, 25, 'filled', 'MarkerFaceAlpha', 0.6)
hold on
x_grid = linspace(min(x), max(x), 100)';
X_grid = [mean(Age)*ones(size(x_grid)),mean(Sex_bin)*ones(size(x_grid)),mean(Genotype_bin)*ones(size(x_grid)),mean(Vol_Brain)*ones(size(x_grid)),x_grid,ones(size(x_grid))];
y_grid = X_grid * b;
plot(x_grid, y_grid, 'r-', 'LineWidth', 2)
xlabel('LI_{Vol}')
ylabel('LI_{Vt}')
beta_vol = beta(5, 1);
R2_val = R2(1);
text(-0.065, -0.1, sprintf('\\beta_{LI_{Vol}} = %.2f\nR^2 = %.2f', beta_vol, R2_val),'VerticalAlignment', 'top', 'BackgroundColor', 'w', 'EdgeColor', 'k');
xlim([-0.07,-0.006])
ylim([-0.16,0.1])
sgtitle('Linear regression between LI Vt and LI Vol of the Thalamus')
clear i
clear x
clear y
clear b
clear x_grid
clear X_grid
clear y_grid
clear beta_vol
clear R2_val
%% PLOT DELLA REGRESSIONE LINEARE USANDO FUNZIONE lm() 
% plottato per comparazione ma non utilizzato!
figure
for i = 1:n_ROI
    subplot(2, ceil(n_ROI/2), i);
    x = LI_vol(:,i);
    y = LI_Vt(:,i);
    lm = fitlm(x, y);
    scatter(x, y, 25, 'filled', 'MarkerFaceAlpha', 0.6)
    hold on
    plot(x, lm.Fitted, 'r-', 'LineWidth', 1.5)
    title(['ROI ', num2str(i)])
    xlabel('LI_{Vol}')
    ylabel('LI_{Vt}')
    coeff = lm.Coefficients.Estimate(2); 
    R2_lm = lm.Rsquared.Ordinary;
    text(min(x), max(y), sprintf('\\beta = %.2f\nR^2 = %.2f', coeff, R2_lm),'VerticalAlignment', 'top', 'BackgroundColor', 'w', 'EdgeColor', 'k')
end
sgtitle('Relazione lineare tra LI_{Vol} e LI_{Vt} per ciascuna ROI')
clear x
clear y
clear lm
clear coeff
clear R2_lm
%% PLOT DELLA "DIMENSIONE/SIGNIFICATIVITA'" DEI COEFFICIENTI DELLA REGRESSIONE LINEARE
predictor_labels = {'Age', 'Sex', 'Genotype', 'VolBrain', 'LI_{Vol}', 'Intercept'};
figure
for i = 1:n_ROI
    subplot(2, ceil(n_ROI/2), i)
    b = beta(:, i);
    bar(b, 'FaceColor', [0.7 0.7 0.7])
    hold on
    bar(5, b(5), 'FaceColor', [0.2 0.4 0.9])
    xticks(1:n_indp_var)
    xticklabels(predictor_labels)
    xtickangle(45)
    ylabel('\beta')
    title(['ROI ', num2str(i)])
    ylim padded
end
sgtitle('Coefficienti \beta della regressione lineare per ciascuna ROI (LI_{Vol} evidenziato)')
clear i
clear b
%% PLOT DEI COEFFICIENTI DA INSERIRE NEL REPORT 
figure
b = beta(:, 1);
bar(b, 'FaceColor', [0.7 0.7 0.7])
hold on
bar(5, b(5), 'FaceColor', [0.2 0.4 0.9])
xticks(1:n_indp_var)
xticklabels(predictor_labels)
xtickangle(45)
ylabel('\beta')
ylim([-0.6,0.2])
sgtitle('Linear regression \beta for the Thalamus')
clear i
clear b
%% ANOVA A 2 VIE
sex = categorical(Sex);
genotype = categorical(Genotype);

p_05_sex = vartestn(LI_Vt(:,5), sex, 'TestType', 'LeveneAbsolute'); % varianze dei gruppi possono essere considerate uguali
p_05_geno = vartestn(LI_Vt(:,5), genotype, 'TestType', 'LeveneAbsolute'); % varianze dei gruppi possono essere considerate uguali

p_07_sex = vartestn(LI_Vt(:,7), sex, 'TestType', 'LeveneAbsolute'); % varianze dei gruppi possono essere considerate uguali
p_07_geno = vartestn(LI_Vt(:,7), genotype, 'TestType', 'LeveneAbsolute'); % varianze dei gruppi possono essere considerate uguali

% dato che anova richiede la normalità e l'uguaglianza delle varianze, sono
% state prese solamente le 2 LI_Vt gaussiani su cui è stata testata la
% uguaglianza delle varianze. quindi abbiamo schernito da 7 test di anova a
% 2 vie a solamente 2! 

[p_twa_LI_Vt_temporal, tbl_twa_LI_Vt_temporal, stats_twa_LI_Vt_temporal] = anovan(LI_Vt(:,5), {sex, genotype},'model', 'interaction','varnames', {'Sex', 'Genotype'});
[p_twa_LI_Vt_parietal, tbl_twa_LI_Vt_parietal, stats_twa_LI_Vt_parietal] = anovan(LI_Vt(:,7), {sex, genotype},'model', 'interaction','varnames', {'Sex', 'Genotype'});
%% ANCOVA
% % % % % Variabili indipendenti: Age, Vol_Brain, LI_vol
% % % % % Variabili che separano in gruppi: sex, genotype
% % % % x_Temporal = {sex, genotype, Age, Vol_Brain, LI_vol(:,5)};
% % % % x_Parietal = {sex, genotype, Age, Vol_Brain, LI_vol(:,7)};
% % % % continuous_x = [3, 4, 5];
% % % % [p_anc_LI_Vt_Temporal, tbl_anc_LI_Vt_Temporal, stats_anc_LI_Vt_Temporal, terms_anc_LI_Vt_Temporal] = anovan(LI_Vt(:,5), x_Temporal, 'model', 'interaction', 'continuous', continuous_x, 'varnames', {'Sex', 'Genotype', 'Age', 'Vol_Brain', 'LI_vol'});
% % % % [p_anc_LI_Vt_Parietal, tbl_anc_LI_Vt_Parietal, stats_anc_LI_Vt_Parietal, terms_anc_LI_Vt_Parietal] = anovan(LI_Vt(:,7), x_Parietal, 'model', 'interaction', 'continuous', continuous_x, 'varnames', {'Sex', 'Genotype', 'Age', 'Vol_Brain', 'LI_vol'});
%% PER SPOSTARE I DATI SU R ESEGUIRE TUTTO IL SEGUENTE CODICE:
% LOAD DEI DATI
load Data_Homework.mat;
% CHECK DATI PROBLEMATICI 
flag_sex = ~(Sex == "male" | Sex == "female") | ismissing(Sex);
flag_geno = ~(Genotype == "HAB" | Genotype == "MAB") | ismissing(Genotype);
flag_age = any(isnan(Age) | isinf(Age) | (Age<0),2);
flag_delete_Vt = any(isnan(Vt_ROI) | isinf(Vt_ROI) | (Vt_ROI<0) | (Vt_ROI>10),2);
flag_delete_Vol = any(isnan(Vol_ROI) | isinf(Vol_ROI) | (Vol_ROI<0),2);
flag_delete_VolB = any(isnan(Vol_Brain) | isinf(Vol_Brain) | (Vol_Brain<0),2);
flag_sum = any(sum(Vol_ROI,2) > Vol_Brain,2);
flag_delete = flag_sex | flag_geno | flag_age | flag_delete_Vt | flag_delete_Vol | flag_delete_VolB | flag_sum;
clear flag_sex
clear flag_geno
clear flag_age
clear flag_delete_Vt
clear flag_delete_Vol
clear flag_delete_VolB
clear flag_sum
% RIMOZIONE DEI SOGGETTI CON DATI PROBLEMATICI
Vt_ROI(flag_delete,:) = [];
Vol_ROI(flag_delete,:) = [];
Vol_Brain(flag_delete,:) = [];
Age(flag_delete,:) = [];
Sex(flag_delete,:) = [];
Genotype(flag_delete,:) = [];
% CALCOLO INDICE DI LATERALIZZAZIONE 
n_subj = size(Vt_ROI, 1);
n_ROI = size(Vt_ROI, 2) / 2; 
LI_Vt = LI_code(Vt_ROI); 
LI_vol = LI_code(Vol_ROI);
LI_labels = ["LI_Thalamus","LI_Putamen","LI_Cerebellum","LI_Occipital_Lobe","LI_Temporal_Lobe","LI_Frontal_Lobe","LI_Parietal_Lobe"];
% PREPARAZIONE DEI DATI SU R
clear flag_delete
sex = categorical(Sex);
sex = double(sex);
genotype = categorical(Genotype);
genotype = double(genotype);
Vt_labels_cell = cellstr(Vt_labels);
Vol_label_cell = cellstr(Vol_label);
LI_labels_cell = cellstr(LI_labels);
clear Genotype
clear Sex
clear Vt_labels
clear Vol_label
clear LI_labels
save('Data_Homework_for_R.mat', '-v7')