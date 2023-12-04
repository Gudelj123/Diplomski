close all;
clear all;
%Loading of the data
% Downloading the CSV file
%fileURL = 'https://drive.google.com/uc?export=download&id=1HA3BhcgkFfX9SqkrFAA9-drMF9npyyK3';
filename = 'air_particles.csv';
%websave(filename, fileURL);
% Loading the CSV data
data = readtable(filename);
% Checking for NaN and null values in dataset
nullValues = ismissing(data);
anyNull = any(nullValues(:));
disp(['Are there any NaN or null values in the dataset? ', num2str(anyNull)]);
%*********************************************************
% Convert the first column to MATLAB datetime format
timeColumn = datetime(data{:, 1}, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');

% Define the date ranges to be removed
dateRangesToRemove = [
    datenum([0 1 1]), datenum([0 1 3]);
    datenum([2020 3 26]), datenum([2020 3 30])
];

% Convert the date ranges to MATLAB datetime format
dateRangesToRemove = datetime(dateRangesToRemove, 'ConvertFrom', 'datenum');

% Loop through each date range and remove the corresponding observations
for i = 1:size(dateRangesToRemove, 1)
    startDateTime = dateRangesToRemove(i, 1);
    endDateTime = dateRangesToRemove(i, 2);
    
    % Identify the indices of observations within the date range
    indicesToRemove = month(timeColumn) == month(startDateTime) & ...
                       day(timeColumn) >= day(startDateTime) & ...
                       day(timeColumn) <= day(endDateTime);
    
    % Remove the observations from the data table
    data(indicesToRemove, :) = [];
end

%*********************************************************
% Dividing the data into groups by Variable name
timeData = data(:,1);               %Vremenska varijabla
julianTag = data(:,2);              %Julianski Tag
lagedData = data(:,3:19);           %Lag-Prethodni podaci (2 dana)
weatherData = data(:,20:38);           %Mjerenja prirodnih veli?ina
unkown_data = data(:,39:56);        %Nepoznati podaci
assistingVariables = data(:,39:56); %Pomo?ne varijable (blagdan,sat,mjesec,dan u tjednu i doba)
prophetData = data(:,83:107);       %Nepoznati podaci
particlesData= data(:,108:end);     %Podaci o štetnim ?esticama u zraku
allData_withoutDateAndJulian = data(:,3:end);

%Compute and plot correlations between variables and show heatmap of
%                   Correlation Matrix
correlationVariables = allData_withoutDateAndJulian.Properties.VariableNames;
corrMatrix = corrcoef(table2array(allData_withoutDateAndJulian));
figure;
heatmap(correlationVariables, correlationVariables, corrMatrix);
title('Correlation Heatmap');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Reviewing particle data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Showing descriptive statistics on variables
summaryStats = summary(particlesData);
variableNames = particlesData.Properties.VariableNames;
% Defining the number of columns and rows for the subplots
numColumns = size(particlesData, 2);
numRows = ceil(sqrt(numColumns));

% %BoxPlots
% outputFolder = 'OutputDataBoxplots'; 
% if ~exist(outputFolder, 'dir')
%     mkdir(outputFolder);
% end
% figure;
% for i = 1:numColumns
%     figure(i);
% %     subplot(numRows, numRows, i);
%     boxplot(particlesData{:, i});
%     title(variableNames{i});
%     filename = fullfile(outputFolder, sprintf('boxplot_%d.png', i));
%     saveas(gcf, filename, 'png');
%     close(gcf);
% end
% 
% %Histograms
% outputFolder = 'OutputDataHistograms'; 
% if ~exist(outputFolder, 'dir')
%     mkdir(outputFolder);
% end
% figure;
% for j = 18:numColumns*2
%     figure(j);
% %     subplot(numRows, numRows, i);
%     histogram(particlesData{:, j-17});
%     title(variableNames{j-17});
%     filename = fullfile(outputFolder, sprintf('histogram_%d.png', j));
%     saveas(gcf, filename, 'png');
%     close(gcf);
% end

%Plots
% figure;
% for i = 1:numColumns
%     subplot(numRows, numRows, i);
%     plot(particlesData{:, i});
%     title(variableNames{i});
% end
% for i = 1:numColumns
%     subplot(numRows, 4, i);
%     plot(particlesData{:, i});
%     title(variableNames{i});
%     
%     % Identify and mark outliers
%     data = particlesData{:, i};
%     lowerBound = prctile(data, 15) - 1.5 * iqr(data);
%     upperBound = prctile(data, 85) + 1.5 * iqr(data);
%     outliers = data(data < lowerBound | data > upperBound);
%     
%     hold on;
%     scatter(find(data < lowerBound | data > upperBound), outliers, 'ro');
%     hold off;
%     
%     % Optional: Adjust any other plot settings (e.g., axis labels, titles, etc.)
% end

% Adjust the subplot spacing
% set(gcf, 'Position', [100, 100, 1200, 800]);  % Set the figure size as needed
% set(gcf, 'Units', 'Normalized');
% set(gca, 'LooseInset', get(gca, 'TightInset') * 1.5);  % Adjust the spacing around subplots