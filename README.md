# Plot your Chrome history

## Detect your hist

### In MAC 

It should be in `~/Library/Application\ Support/Google/Chrome/Default/History` 

You can then change the name for sake of clarity.


## Extract the db in a csv

Script from [here](https://gist.github.com/TravelingTechGuy/7ac464f6cccde912a6ec7a1e2f8aa96a).

```
sqlite3 chrome_history.db < extract_hist.sql
```

## Plot by month and week-day

```
Rscript history_plot.R
```

and then a Rplots file will be generated. 
