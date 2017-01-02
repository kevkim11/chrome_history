# Plot your Chrome history


## In macOS

The history should be in `~/Library/Application\ Support/Google/Chrome/Default/History`

You can then change the name for sake of clarity.

```
cp ~/Library/Application\ Support/Google/Chrome/Default/History chrome_history.db
```

With the file you should be able to reproduce the plot.

```
Rscript history_plot.R -f chrome_history.db
```

For the monthly plot use:

```
Rscript history_plot.R -f chrome_history.db -m
```
