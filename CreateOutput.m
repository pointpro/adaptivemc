%%%Write to excel sheet
%Driver_AdaptiveMC;
close all
TAVec = t_f';
NonDim = Non_dim;
TL = length(TAVec);
numdf = 3;
numqoi = 1;
x_Mean = zeros(TL, N_d);
x_Mean_NonDim = zeros(TL, N_d);
Display_Mean = zeros(TL, numdf);
Display_Median = zeros(TL, numdf);
Display_Q1 = zeros(TL, numdf);
Display_Q3 = zeros(TL, numdf);
Display_iqr = zeros(TL, numdf);
Display_min = zeros(TL, numdf);
Display_max = zeros(TL, numdf);
Display_outlierss = struct();
QOI = zeros(TL, numqoi);
Error = zeros(TL, numqoi);
Simulation_Size = zeros(TL, 1);
iqrfactor = 1.3;
Display_outliers = [];
for i = 1:TL
    Csample = MCSAM(i).sam;
    Csample_ND = MCSAM(i).sam_ND;
    Display_Raw(:,1) = Csample_ND(:,1);
    Display_Raw(:,2) = Csample_ND(:,2);
    Display_Raw(:,3) = sqrt((Display_Raw(:,1).^2 + Display_Raw(:,2).^2)/2);
    QOI_Raw = sqrt((Csample_ND(:,1).^2 + Csample_ND(:,2).^2)/2);
    %%%Display function stats
    Display_Mean(i,:) = mean(Display_Raw);
    Display_Median(i,:) = median(Display_Raw);
    Display_Q1(i,:) = quantile(Display_Raw, 0.25);
    Display_Q3(i,:) = quantile(Display_Raw, 0.75);
    Display_iqr(i,:) = Display_Q3(i,:) - Display_Q1(i,:);
    outlength = 0;
    for j = 1:numdf
        %%%min and max
        minupperlimit = Display_Q1(i,j);
        minlowerlimit = minupperlimit - iqrfactor*Display_iqr(i,j);
        dfmincandidates = find(Display_Raw(:,j) < minupperlimit & Display_Raw(:,j) > minlowerlimit);        
        maxlowerlimit = Display_Q3(i,j);
        maxupperlimit = maxlowerlimit + iqrfactor*Display_iqr(i,j);
        dfmaxcandidates = find(Display_Raw(:,j) > maxlowerlimit & Display_Raw(:,j) < maxupperlimit);                
        Display_min(i,j) = min(Display_Raw(dfmincandidates, j));
        Display_max(i,j) = max(Display_Raw(dfmaxcandidates, j));
        %%%end: min and max
        
        %%%outliers
        dfoutliers_min = find(Display_Raw(:,j) < minlowerlimit);
        dfoutliers_max = find(Display_Raw(:,j) > maxupperlimit);
        dfoutliers = [dfoutliers_min; dfoutliers_max];
        Display_outlierss(i).dfmode(j).o = Display_Raw(dfoutliers, j);
        oll = length(dfoutliers);
        if oll > outlength
            outlength = oll;
        end
        %%%end:outliers
    end
    
    %%%arrange outliers in matrix format for each time instance
    %%%
    outlier_block = zeros(outlength, numdf+1);
    outlier_block(:,2:end) = inf;
    outlier_block(:,1) = TAVec(i);
    for j = 1:numdf
        numout  = length(Display_outlierss(i).dfmode(j).o);
        outlier_block(1:numout, j+1) = Display_outlierss(i).dfmode(j).o;        
    end
    if outlength > 0
        Display_outliers = [Display_outliers; outlier_block];   
    else
        Display_outliers = [Display_outliers; [TAVec(i), inf(1, numdf)]];
    end
    %%%
    
    QOI(i,1) = mean(QOI_Raw);
    Error(i,1) = MCSAM(i).Acc;
    x_Mean(i,:) = mean(Csample);
    x_Mean_NonDim(i,:) = mean(Csample_ND);
    Simulation_Size(i,1) = size(MCSAM(i).sam, 1);
    Display_Raw = [];    
end

Time = Display_outliers(:,1);
Display_Outliers = Display_outliers(:, 2:end);


%%%Create Table
DATAMAIN = table(TAVec, Display_Mean, Display_Median, Display_Q1, Display_Q3, Display_min, Display_max, QOI, Error, Simulation_Size, x_Mean, x_Mean_NonDim);
DATAOUTLIERS = table(Time, Display_Outliers);

%%%Write to File
filename = 'OUTPUT_VANDERPOL.xlsx';
writetable(DATAMAIN, filename, 'Sheet', 'Main');
writetable(DATAOUTLIERS, filename, 'Sheet', 'Outliers');


%%%Data-Dump: Write all sim data to sheets
for i = 1:TL
    x = MCSAM(i).sam;
    x_NonDim = MCSAM(i).sam_ND;
    Time = repmat(TAVec(i), Simulation_Size(i,1), 1);
    SAMTABLE = table(Time, x, x_NonDim);
    Sheetname = strcat('Ensemble-', num2str(i));
    writetable(SAMTABLE, filename, 'Sheet', Sheetname);
end

%%%
% Boxplot for display functions
%%%
Time = Display_outliers(:,1);
twid = 0.3*min(diff(TAVec));
findinf = isinf(Display_Outliers);
Display_Outliers(findinf) = nan;
for j = 1:numdf
    figure(j)    
    title(['Display Function ' num2str(j)]);
    hold on
    xlabel('Time, s');
    ylabel(['Display Function ' num2str(j)]);
    set(gca, 'fontsize', 14, 'fontweight', 'bold');    
    plot(TAVec, Display_Median(:,j), 'k');
    plot(TAVec, Display_Mean(:,j), 'ko', 'Markerfacecolor', 'k', 'Markersize', 2);
    for i = 1:TL
        xMed = TAVec(i);
        yMed = Display_Median(i,j);
        xleft = xMed - twid;
        xright = xMed + twid;
        ydown = Display_Q1(i,j);
        yup = Display_Q3(i,j);
        %%%box
        polg = polyshape([xleft, xright, xright, xleft], [ydown, ydown, yup, yup]);
        plot(polg, 'FaceColor', 'k', 'Edgecolor', 'k');
        %%%end: box
        %%%whisker: middle
        whiskm = [xleft yMed; xright yMed];
        plot(whiskm(:,1), whiskm(:,2), 'k', 'linewidth', 2);
        %%%
        %%%whisker: top
        whiskt_1 = [xMed yup; xMed Display_max(i,j)];
        whiskt_2 = [xleft Display_max(i,j); xright Display_max(i,j)];
        plot(whiskt_1(:,1), whiskt_1(:,2), 'k-.');
        plot(whiskt_2(:,1), whiskt_2(:,2), 'k');        
        %%%end: whisker: top
        %%%whisker: bottom
        whiskb_1 = [xMed ydown; xMed Display_min(i,j)];
        whiskb_2 = [xleft Display_min(i,j); xright Display_min(i,j)];
        plot(whiskb_1(:,1), whiskb_1(:,2), 'k-.');
        plot(whiskb_2(:,1), whiskb_2(:,2), 'k');        
        %%%end: whisker: bottom
    end
    %%%outliers
    plot(Time, Display_Outliers(:,j), 'bx', 'Markerfacecolor', 'b', 'Markersize', 4, 'Linewidth', 2);
    %%%end: outliers
end