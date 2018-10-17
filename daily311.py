from urllib.request import urlopen
from sodapy import Socrata
import datetime
import pandas

# Constants
API_ENDPOINT = 'fhrw-4uyv'
API_URL = 'data.cityofnewyork.us'
API_APP_KEY = 'vHIZ8v0kxS6gg5c1DgqLDS5N5'
API_ROWS_LIMIT = 100000

# Date configuration
today = datetime.datetime.now()
yesterday = today + datetime.timedelta(days=-1)
yearAgo = today + datetime.timedelta(days=-365)

def getQueryBetweenDates(date1, date2):
  # date1 < date2
  whereClause = 'created_date >= \'{yyyy1}-{mm1}-{dd1}T00:00:00\' and created_date < \'{yyyy2}-{mm2}-{dd2}T00:00:00\''
  whereClause = whereClause.format(
    yyyy1=date1.year, mm1=date1.month, dd1=date1.day,
    yyyy2=date2.year, mm2=date2.month, dd2=date2.day
  )
  return whereClause

yearlyQuery = getQueryBetweenDates(yearAgo, today)
dailyQuery = getQueryBetweenDates(yesterday, today)

# API request using Socrata
socrataClient = Socrata(API_URL, API_APP_KEY)
yearlyData = socrataClient.get(
  API_ENDPOINT, where=yearlyQuery, limit=API_ROWS_LIMIT
)
dailyData = socrataClient.get(
  API_ENDPOINT, where=dailyQuery, limit=API_ROWS_LIMIT
)

# Convert JSON data to CSV
def saveToCSV(data, fileName):
  dicts = []
  for row in data:
    row.pop('location', None)
    dicts.append(row)
  df = pandas.DataFrame(dicts)
  df.to_csv(fileName)

saveToCSV(dailyData, 'data/data_daily.csv')
saveToCSV(yearlyData, 'data/data_yearly.csv')
