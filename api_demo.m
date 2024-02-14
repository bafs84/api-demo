% Define the API endpoint
endpoint = 'https://weather.home.sawicki.ch/getData';

% Specify parameters
start_date = '20230101';
end_date = '20230110';
station = 'ISANKTGA2';

% Create the full URL with query parameters
url = sprintf('%s?start_date=%s&end_date=%s&station=%s', endpoint, start_date, end_date, station);

% Specify the filename for the downloaded file
filename = sprintf('%s_%s-%s.parquet', station, start_date, end_date);

% Use webread or webwrite to call the API and download the file
% MATLAB doesn't directly support downloading binary files like this, so we use websave
websave(filename, url);

% Now, read the downloaded Parquet file
% MATLAB R2019a and later supports reading Parquet files directly
data = parquetread(filename);

% Display the first few rows of the table
head(data);

% Convert 'obsTimeLocal' from string to datetime format
data.obsTimeLocal = datetime(data.obsTimeLocal, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');

% Sort the data based on 'obsTimeLocal' to ensure chronological plotting
data = sortrows(data, 'obsTimeLocal');

% Calculate the mean of 'tempAvg'
meanTempAvg = mean(data.tempAvg);

% Plotting
figure; % Create a new figure window
hold on; % Hold on to plot multiple lines

% Plot each temperature metric
plot(data.obsTimeLocal, data.tempHigh, '-r', 'DisplayName', 'High Temp');
plot(data.obsTimeLocal, data.tempLow, '-b', 'DisplayName', 'Low Temp');
plot(data.obsTimeLocal, data.tempAvg, '-g', 'DisplayName', 'Avg Temp');
% Plot the mean of tempAvg as a dotted line
yline(meanTempAvg, '--k', 'DisplayName', 'Mean Avg Temp');

% Enhancing the plot
xlabel('Observation Time'); % X-axis label
ylabel('Temperature'); % Y-axis label
title('Temperature Profile'); % Title
legend('show'); % Show legend
datetick('x', 'yyyy-mm-dd HH:MM:SS', 'keepticks', 'keeplimits'); % Format the datetime ticks on the x-axis
hold off; % Release the plot hold
