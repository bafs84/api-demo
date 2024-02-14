library(httr)
library(arrow)
library(ggplot2)

# Define the API endpoint and parameters
endpoint <- "https://weather.home.sawicki.ch/getData"
params <- list(
  start_date = '20230101',
  end_date = '20230110',
  station = 'ISANKTGA2'
)

# Specify the filename for the downloaded file
filename <- sprintf("%s_%s-%s.parquet", params$station, params$start_date, params$end_date)

# Use GET() from httr to call the API and download the file
response <- GET(url = endpoint, query = params)
writeBin(content(response, "raw"), filename)

# Now, read the downloaded Parquet file
data <- arrow::read_parquet(filename)

# Display the first few rows of the table
print(head(data))

# Convert 'obsTimeLocal' from string to datetime format
data$obsTimeLocal <- as.POSIXct(data$obsTimeLocal, format = "%Y-%m-%d %H:%M:%S")

# Sort the data based on 'obsTimeLocal' to ensure chronological plotting
data <- data[order(data$obsTimeLocal),]

# Calculate the mean of 'tempAvg'
meanTempAvg <- mean(data$tempAvg, na.rm = TRUE)

# Plotting with ggplot2
ggplot(data) + 
  geom_line(aes(x = obsTimeLocal, y = tempHigh, colour = "High Temp")) +
  geom_line(aes(x = obsTimeLocal, y = tempLow, colour = "Low Temp")) +
  geom_line(aes(x = obsTimeLocal, y = tempAvg, colour = "Avg Temp")) +
  geom_hline(yintercept = meanTempAvg, linetype = "dashed", colour = "black") +
  labs(title = "Temperature Profile", x = "Observation Time", y = "Temperature") +
  scale_colour_manual("", 
                      breaks = c("High Temp", "Low Temp", "Avg Temp"),
                      values = c("High Temp" = "red", "Low Temp" = "blue", "Avg Temp" = "green")) +
  theme_minimal()

# Note: Depending on your locale settings and version of R, you might need to adjust the datetime conversion format.

