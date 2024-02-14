#requirements: pip install requests pandas matplotlib pyarrow fastparquet

import requests
import pandas as pd
import matplotlib.pyplot as plt

# Define the API endpoint
endpoint = 'https://weather.home.sawicki.ch/getData'

# Specify parameters
params = {
    'start_date': '20230101',
    'end_date': '20230110',
    'station': 'ISANKTGA2'
}

# Specify the filename for the downloaded file
filename = f"{params['station']}_{params['start_date']}-{params['end_date']}.parquet"

# Call the API and download the file
response = requests.get(endpoint, params=params)
with open(filename, 'wb') as file:
    file.write(response.content)

# Now, read the downloaded Parquet file
data = pd.read_parquet(filename)

# Display the first few rows of the table
print(data.head())

# Convert 'obsTimeLocal' from string to datetime format
data['obsTimeLocal'] = pd.to_datetime(data['obsTimeLocal'])

# Sort the data based on 'obsTimeLocal' to ensure chronological plotting
data = data.sort_values('obsTimeLocal')

# Calculate the mean of 'tempAvg'
mean_temp_avg = data['tempAvg'].mean()

# Plotting
plt.figure()
plt.plot(data['obsTimeLocal'], data['tempHigh'], '-r', label='High Temp')
plt.plot(data['obsTimeLocal'], data['tempLow'], '-b', label='Low Temp')
plt.plot(data['obsTimeLocal'], data['tempAvg'], '-g', label='Avg Temp')
plt.axhline(y=mean_temp_avg, color='k', linestyle='--', label='Mean Avg Temp')

# Enhancing the plot
plt.xlabel('Observation Time')
plt.ylabel('Temperature')
plt.title('Temperature Profile')
plt.legend()
plt.xticks(rotation=45)
plt.tight_layout()  # Adjust the layout to make room for the rotated x-axis labels
plt.show()
