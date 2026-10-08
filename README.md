# Netflix Stock Analysis

Cleaning, feature engineering and exploratory/predictive analysis of Netflix (NFLX) historical stock data, with company profile information.

## Project Contents

| File | Type | Purpose |
|---|---|---|
| `Netflix_stock_File_cleaning.ipynb` | Notebook | Loads the raw files, cleans them, builds analysis variables, saves the `*_clean.csv` files |
| `Netflix_Stock_Main_Analysis_Guide_Exact_Variables.ipynb` | Notebook | Main analysis: descriptive statistics, returns, trends, correlations, ML price prediction |
| `Netflix_stock_history_clean.csv` | Data | Daily price history plus engineered features (main dataset) |
| `Netflix_stock_action_clean.csv` | Data | Corporate actions (dividends and splits) |
| `Netflix_stock_spilts_clean.csv` | Data | Stock split events (filename spelling is as-is) |
| `Netflix_stock_info_clean.csv` | Data | Company profile / market snapshot (key-value format) |

## Workflow

1. **Cleaning** (`Netflix_stock_File_cleaning.ipynb`)
   - Reads the raw files: action, dividends, history, splits, info.
   - Converts dates and numeric columns (`errors="coerce"`), drops duplicate dates, sorts chronologically.
   - Drops rows with missing OHLC/Volume (missing prices are not mean-imputed, since this is time-series data).
   - Validates data: no negative values, OHLC logic checks (High >= Low/Open/Close, Low <= Open/Close).
   - Creates analysis variables and flags return outliers (not deleted).
   - Saves the cleaned files.
2. **Analysis** (`Netflix_Stock_Main_Analysis_Guide_Exact_Variables.ipynb`)
   - Mean / median / mode of price and volume columns
   - Daily return analysis and plot
   - Closing price trend
   - Annual performance (avg/max/min close, avg volume, volatility, yearly return)
   - Correlation matrix and heatmap
   - Machine learning: Linear Regression and Random Forest predicting next-day Adj Close

## Data Dictionary

### `Netflix_stock_history_clean.csv` (6,010 rows, 13 columns; 2002-05-23 to 2026-04-13)

| Column | Description |
|---|---|
| `Date` | Trading date |
| `Open`, `High`, `Low`, `Close` | Daily prices (USD) |
| `Adj Close` | Adjusted close price |
| `Volume` | Shares traded |
| `Daily_Return` | % change in `Adj Close` vs. previous day (first row is NaN) |
| `Daily_Range` | `High - Low` (price units) |
| `Open_Close_Change` | `Close - Open` (price units) |
| `Year`, `Month` | Extracted from `Date` |
| `Return_Outlier` | True if `Daily_Return` falls outside the 1.5 x IQR fences (359 rows flagged) |

Note: prices and volumes appear split-adjusted (e.g. ~$0.12 close and ~1.05 billion shares volume on the first day).

### `Netflix_stock_action_clean.csv`
Columns: `Date`, `Dividends`, `Stock Splits`. Netflix pays no dividends, so `Dividends` is 0.

### `Netflix_stock_spilts_clean.csv`
Columns: `Date`, `Stock Splits`. Contains the 2004-02-12 split (ratio 2.0).

### `Netflix_stock_info_clean.csv`
Two-column key/value table (169 entries) with company details (address, sector/industry, business summary, employees, officers, governance risk scores) and a market snapshot (previous close, day range, volume, beta, trailing/forward P/E, etc.). Snapshot values reflect a single point in time.

## Requirements

Python 3 with `pandas`, `numpy`, `matplotlib`, `seaborn`, `scikit-learn`, plus Jupyter.

```bash
pip install pandas numpy matplotlib seaborn scikit-learn jupyter
```

## How to Run

1. Place all files in the same folder.
2. Run `Netflix_stock_File_cleaning.ipynb` first. It needs the raw files (`Netflix_stock_action.csv`, `Netflix_stock_dividends.csv`, `Netflix_stock_history.csv`, `Netflix_stock_spilts.csv`, `Netflix_stock_info.csv`), which are not included in this upload.
3. Run `Netflix_Stock_Main_Analysis_Guide_Exact_Variables.ipynb`.

## Known Issues / Things to Fix

- **Wrong file paths in the analysis notebook:** `Netflix_stock_spilts` and `Netflix_stock_info` are both loaded from `Netflix_stock_action_clean.csv`, and `Netflix_stock_action` is loaded from the raw (uncleaned) file. They should point to `Netflix_stock_spilts_clean.csv`, `Netflix_stock_info_clean.csv` and `Netflix_stock_action_clean.csv`.
- **Info file header:** `Netflix_stock_info_clean.csv` has no header row, so `pd.read_csv` treats the first entry (`address1`) as the column name. Load with `header=None` or transpose it.
- **Missing split date:** the action file has a second split row (ratio 7.0) with an empty `Date`, likely lost when parsing timezone-aware dates. The cleaned splits file keeps only the 2004 split, so the 7-for-1 split is missing there.
- **Data not cleaned/saved for info:** the cleaning notebook only inspects `Netflix_stock_info`; it does not write a cleaned version, and `Netflix_stock_dividends_clean.csv` is not among the uploaded files.
- **ML caveats:** `Volume` is used unscaled as a feature, and features like `Lag_1`/`MA_5` make next-day price prediction look strong (high R²) mostly because prices are autocorrelated. Treat results as a baseline, not as a trading signal.
- **Hardcoded results:** the notebook prints static text for the mean (0.1721%) and std (3.4372%) of daily returns; recompute these from the data rather than hardcoding.

## Disclaimer

For educational and analytical purposes only. This is not financial advice.
