#!/usr/bin/python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys
import platform
import math
from climbs_lookup import *
import urllib2

#%matplotlib

# Useful pandas snippits: http://www.swegler.com/becky/blog/2014/08/06/useful-pandas-snippets/

# Some possible info on down-grading Gym times/difficulty, by recommended training times?
# http://www.rockandice.com/lates-news/rock-climbing-training-transitioning-from-the-gym-to-the-crag-1

# https://trinket.io/python as a possible way to do graphs online/mobile (only has matplotlib support, no pandas)

# TODO: Plot intensity^2 method from Ben

from os.path import expanduser
home = expanduser("~")
#filename='climbs_test.xls'
filename=home +'/Dropbox/climbs.xls'
xl = pd.ExcelFile(filename);

# TODO: Figure out how to download the xls file from a (dropbox) URL
#urlname = 'https://www.dropbox.com/s/g320po5p5xtce4y/climbs.xls?dl=0'
#socket = urllib2.urlopen(urlname)
#xl = pd.ExcelFile(socket);

sheetname='Log'
df_climbs = xl.parse(sheetname)
df_lut = xl.parse('Lookup_Tables')

df_injuries = xl.parse('Injuries')

#df= pd.read_excel(filename, sheetname)

#TODO: Use a different "grade" and adj_difficulty for bouldering problems.
#      Probably keep the "grade" at the current levels, and reduce the 
#      adj_difficulty lower, since it feeds into the "load" calculation.

#-----------------------------------------------
def print_full(x):
#-----------------------------------------------
    pd.set_option('display.max_rows', len(x))
    print(x)
    pd.reset_option('display.max_rows')

#-----------------------------------------------
def calc_adj_difficulty(row):
    """Create an adjusted difficulty, based on grade and belay type"""
#-----------------------------------------------
    adj = 1.0 # 'f' = follow, adj=1;  'l' = lead, adj=1
    belay = row['Belay'].lower()
    if belay == 'autobelay' or belay == 'ab' or belay == 'auto':
        adj = 0.70
    elif belay == 'toprope' or belay == 'tr' or belay == 'none':
        adj = 0.80
    elif belay == 'tr/l':
        adj = 0.90
    #elif belay == 'boulder' or belay == 'b':
    #    adj = 0.8
    adj_grade = row['Grade'] * adj
    #print('Length row = ' +str(len(row)) + '  belay = ' +str(belay) +'   grade = ' + str(row['Grade']) +'   adj_grade = ' +str(adj_grade) )
    return adj_grade

#TODO: figure out a way to do df.apply(mult_cols, axis=1), with column name arguments added
#-----------------------------------------------
def calc_adj_load(row):
    """Create an adjusted load, based on % sent, and adjusted difficulty(grade and belay type)"""
#-----------------------------------------------
    belay = row['Belay'].lower()
    if belay == 'boulder' or belay == 'b':
        return float(row['Send'] /100.0) * row['adj_difficulty'] * 0.75
    else:
        return float(row['Send'] /100.0) * row['adj_difficulty']

#-----------------------------------------------
#def calc_adj_endure(row, median = 0):
def calc_adj_endure(row):
    """Create an adjusted endurance, based on rest, % sent, and adjusted difficulty(grade and belay type)"""
#-----------------------------------------------
    # rest_mult curve based on the following Octave code:
    #x=[1:120]; y=2-min(2,log10((x.^2)/400)); plot(x,min(y,2)); grid on
    rest_mult = (math.pow(row['Rest (s)'],2.0))/400.0
    if rest_mult < 1:
        rest_mult = 1
    rest_mult = math.log10(rest_mult)
    rest_mult = min(rest_mult, 2)
    rest_mult = min(2-rest_mult, 2)
    belay = row['Belay'].lower()
    if belay == 'boulder' or belay == 'b':
        endure = float(row['Send'] /100.0) * row['adj_difficulty']  * rest_mult * 0.3
    else:
        endure = float(row['Send'] /100.0) * row['adj_difficulty']  * rest_mult
    #if median > 0:
    endure = endure * (row['Bolts'] / bolts_median)
    return endure

#------------------------------------------------------------
def get_fill_ewma(s_in, alpha = 0.4, N_window = 50):
#------------------------------------------------------------
    # Note alpha = [0, 1]

    s_fill_no_zero = s_in[s_in != 0]
    s_fill_no_zero_norm = (s_in[s_in != 0] / (N_window / 1 +0) ) +0
    if getattr(s_in, "rolling", None):
        s_rm = (s_in.rolling(window=N_window,center=False).mean() /1) / s_fill_no_zero_norm.mean()
    else:
        s_rm = (pd.rolling_mean(s_in, N_window) / 1) / s_fill_no_zero_norm.mean()

    if getattr(s_in, "ewm", None):
        s_ewma = s_in.ewm(ignore_na=False,span=N_window,min_periods=0,adjust=True).mean() / s_fill_no_zero_norm.mean()
    else:
        s_ewma = pd.ewma(s_in, span=N_window) / s_fill_no_zero_norm.mean()

    s_rm_ewma =  ( s_ewma* alpha  +  s_rm * (1.0 - alpha) )  /2
    #s_rm_ewma = s_rm_ewma.dropna()

    s_rm_ewma_norm = s_rm_ewma / s_rm_ewma.max()
    s_rm_ewma_scale = s_rm_ewma_norm * (s_fill_no_zero.max() - s_fill_no_zero.min())
    s_rm_ewma_scale += s_fill_no_zero.min()
    return s_fill_no_zero, s_fill_no_zero_norm, s_rm_ewma, s_rm_ewma_scale

#--------------------------------------------
def dates_fill (df, col):
    """
     Create a data frame with a top_mean of 0 on days with no climbs. 
      - First create df_tm_ts_zero with a 'top mean' of 0 for each day between the first and last 'Date's
      - Merge df_ts_zero with df
      - Do some cleanup
    """
#--------------------------------------------
    first_date = df.Date.iloc[0]
    last_date = df.Date.iloc[-1]
    dates_fill_ts = pd.date_range(first_date, last_date)

    df_dates_fill_z = pd.DataFrame(dates_fill_ts)
    df_dates_fill_z.columns = ['Date']
    df_dates_fill_z[col] = 0
    df_dates_fill_z = pd.merge(df_dates_fill_z, df, on='Date', how='outer') 

    #at this point, instead of a 'col' column, we have 'col_x' and 'col_y' columns
    col_y = col+'_y'
    col_x = col+'_x'
    df_dates_fill_z[col_y] = df_dates_fill_z[col_y].fillna(0)
    df_dates_fill_z[col] = df_dates_fill_z[col_x] + df_dates_fill_z[col_y]
    del df_dates_fill_z[col_x]
    del df_dates_fill_z[col_y]

    df_dates_fill_gb = df_dates_fill_z.groupby('Date')[col].sum()

    return df_dates_fill_gb

#--------------------------------------------------
def plot_inuries( df_injuries, max_y, ax):
#--------------------------------------------------
    N = len(df_injuries['Start Date'])
    for n in range(N):
        d = df_injuries['Start Date'][n]
        ax.plot([d,d], np.array([ 0, max_y]), 'r-')

#df_climbs.head()
# TODO: Only look at the last N days of data

#
# Save data frame as a json file
#
#json = df_climbs.to_json()
##print(json)
#with open("climbs.json", "w") as text_file:
#    text_file.write(json)

# Drop rows with NaN(NaT) for the date or grade
df_climbs = df_climbs.dropna(subset=['Date', 'Grade'])

# Delete unused columns
del df_climbs['Location']
del df_climbs['Notes']

# Fill in lengths
bolts_median = df_climbs.Bolts.median()
df_climbs['Bolts'].fillna(bolts_median, inplace=True)
for v in bouldering_lut.keys():
    #print 'Processing boulder lut -> bolts for ' +v
    df_climbs.loc[df_climbs['Grade'] == v,         'Bolts'] = bolts_median/2
    df_climbs.loc[df_climbs['Grade'] == v.upper(), 'Bolts'] = bolts_median/2
    df_climbs.loc[df_climbs['Grade'] == v,         'Belay'] = 'B'
    df_climbs.loc[df_climbs['Grade'] == v.upper(), 'Belay'] = 'B'
df_climbs_bolts = df_climbs
#del df_climbs_bolts['Rest (s)']
#del df_climbs_bolts['Duration (s)']

# Use difficult look-up table to replace Grade strings with numeric values
df_climbs['Belay'].fillna('none', inplace=True)
df_climbs['Rest (s)'].fillna('120', inplace=True)
df_climbs['Rest (s)'] = df_climbs['Rest (s)'].astype(float)
df_climbs['Grade'] = df_climbs['Grade'].astype(str).str.lower()
df_climbs = df_climbs.replace({'Grade': difficulty_lut})
df_climbs['Grade'] = df_climbs['Grade'].astype(str).str.lower()
df_climbs = df_climbs.replace({'Grade': bouldering_lut})
df_climbs['Grade'] = df_climbs['Grade'].astype(float)
#print df_climbs['Grade'].astype(float)
df_climbs['adj_difficulty'] = df_climbs.apply(calc_adj_difficulty, axis=1)


# Count empty (NaN) Sits as zero
df_climbs['Sits'].fillna(0, inplace=True)

#gb_date=df_climbs.groupby('Date')
#df_climbs.groupby('Date').sum().plot('Grade')
#df_climbs[['Date', 'Grade']].groupby('Date').sum().plot()
#load_by_date = df_climbs[['Date', 'Grade']].groupby('Date').sum()
# df_climbs.groupby('Date')['Grade'].count()
# df_climbs.groupby('Date')['Grade'].sum()
# df_climbs.groupby('Date')['Grade'].mean()

df_climbs['Send'].fillna(100, inplace=True)            # assume all empty entries are 100% complete
# DNF = Did Not Finish
# S = Sent
# OS = On Sight
# RP = Red Point
df_climbs = df_climbs.replace({'Send': {'DNF': 50, 'S':100, 'OS':100, 'RP':100 }  }) # assume all DNF entries are 50% complete

df_climbs['adj_load'] = df_climbs.apply(calc_adj_load, axis=1)
df_climbs['adj_endure'] = df_climbs.apply(calc_adj_endure, axis=1)


df_sent = df_climbs[(df_climbs['Send']==100) & (df_climbs['Sits']==0)]

#----------------------------------
fig1 =plt.figure(1)
fig1.clf()
ax1 = plt.subplot(4,1,1)
#ax1.hold(True);
#----------------------------------
#plt.plot(df_climbs['Date'], df_climbs['Grade'])
#df_climbs.plot(x='Date', y='Grade', marker='o', linestyle='none', markersize=1, ax=ax1, legend=False, color='darkred')
ax1.plot(df_climbs.Date, df_climbs.Grade, 'o', markersize=2, color='green')
#h4=df_sent.Grade.plot(style='co', ax=ax1, legend=False, markersize=1)

#plot_difficulty = 'Grade'
plot_difficulty = 'adj_difficulty'
s_mean=df_climbs.groupby('Date')[plot_difficulty].mean()
s_median=df_climbs.groupby('Date')[plot_difficulty].median()
s_min=df_climbs.groupby('Date')[plot_difficulty].min()
s_max=df_climbs.groupby('Date')[plot_difficulty].max()
h2=s_max.plot(style='g-', ax=ax1, legend=False)

s_max_sent=df_sent.groupby('Date')[plot_difficulty].max()
h3=s_max_sent.plot(style='c-', ax=ax1, legend=False)

plot_inuries( df_injuries, df_climbs.Grade.max(), ax1)

h2.set_ylabel("Max Difficulty")
ax1.set_xticklabels([])
h2.set_ylim(7.0, 13.0)
h2.set_yticks([7,8,9,10,11,12,13])
h2.grid(True)


#----------------------------------
ax2 = plt.subplot(4,1,2)
#----------------------------------
#s_adj_load_fill = dates_fill( df_climbs, 'adj_load')
#s_adj_load_fill_no_zero, s_rm_ewma = get_fill_ewma(s_adj_load_fill, alpha = 0.4, N_window = 50)

s_adj_endure_fill = dates_fill( df_climbs, 'adj_endure')
s_adj_endure_fill_no_zero, s_adj_endure_fill_no_zero_norm, s_rm_ewma_e, s_rm_ewma_es = get_fill_ewma(s_adj_endure_fill, 0.4, 50)
#h4 = s_adj_endure_fill_no_zero_norm.plot(style='co', ax=ax2, legend=False, markersize=3)
h4 = s_adj_endure_fill_no_zero.plot(style='go', ax=ax2, legend=False, markersize=3)
h6 = s_rm_ewma_es.plot(style='c-', ax=ax2, legend=False)

plot_inuries( df_injuries, s_rm_ewma_es.max(), ax2)

ax2.set_ylabel("Endurance")
ax2.grid(True)
ax2.set_xticklabels([])

#----------------------------------
ax3 = plt.subplot(4,1,3)
#----------------------------------
s_count = df_climbs.groupby('Date')[plot_difficulty].count()   #TODO: only count boulders as 25%-50% ???
h5=s_count.plot(style='o', ax=ax3, legend=False, markersize=3)
N_window=5
if getattr(s_count, "rolling", None):
    s_rm_count = s_count.rolling(window=N_window,center=False).mean()
else:
    s_rm_count = pd.rolling_mean(s_count, N_window)  
h7= s_rm_count.plot(style='g-', ax=ax3, legend=False)

plot_inuries( df_injuries, s_count.max(), ax3)


ax3.set_xticklabels([])
h5.set_ylabel("# climbs/\nday")
h5.grid(True)

#---------------------------------------------------------------------
gbd = df_sent.groupby(['Date'])
top_means = []
top_dates = []
for ge in gbd:
    top_dates.append( ge[0] )
    series = ge[1][plot_difficulty].sort_values(ascending=False)
    top_means.append( series[0:4].mean() )   # Note: this appears to work even when the series is shorter than 4 elements
s_top_dates = pd.Series(top_dates)
s_top_means = pd.Series(top_means)

#---
df_top_means = pd.DataFrame({ 'Date':s_top_dates, 'Top_Means':s_top_means})
s_top_means_fill = dates_fill(df_top_means, 'Top_Means')
s_top_means_fill_no_zero, s_top_fill_no_zero_norm, s_top_means_rm_ewma, s_top_means_rm_ewma_s = get_fill_ewma(s_top_means_fill, 0.5, 50)
#s_top_means_rm_ewma += s_top_means.min() -s_top_means_rm_ewma.min()
#----------------------------------
ax4 = plt.subplot(4,1,4)
#----------------------------------
#h8 = ax4.plot(s_top_dates, s_top_means, 'co', markersize=3) #, legend=False)
#h9= s_rm_ewma.plot(style='c-', ax=ax4, legend=False)
h8 = s_top_means_fill_no_zero.plot(style='go', ax=ax4, legend=False, markersize=3)
h9 = s_top_means_rm_ewma_s.plot(style='c-', ax=ax4, legend=False)

plot_inuries( df_injuries, s_top_means.max(), ax4)
#plot_inuries( df_injuries, 13.0, ax4)

ax4.set_ylabel("Top 4 Difficulty")
#ax4.set_ylim(6, np.round(s_top_means_fill_no_zero.max() +0.5))
ax4.set_ylim(7.0, 13.0)
ax4.set_yticks([7,8,9,10,11,12,13])
ax4.grid(True)


#---------------------------------------------------------------------

#mng = plt.get_current_fig_manager()
# mng.resize(*mng.window.maxsize())
#mng.window.state('zoomed') #works fine on Windows!
#mng.window.showMaximized()

if platform.system() != 'Darwin':
    fig1.set_size_inches(10,8,forward=True) # Works on ubuntu

plt.show()


#s_90p_sent = df_sent.groupby('Date')['Grade'].aggregate(lambda x: (np.percentile(x,90)) )
s_Date = df_sent.Date.values
s_Grade = df_sent.Grade.values

#NumUniqueDates = df_sent.Date.unique().shape[0] 
NumUniqueDates = pd.Series(s_Date).unique().shape[0] 
N = s_Date.shape[0]

#Append an extra bogus day, so the plot limits work out OK
s_Date = np.append(s_Date, s_Date[-1] +np.timedelta64(1, 'D'))
s_Grade= np.append(s_Grade, 0)

#NumGradeBins = 8
#gradeBins = np.zeros( NumGradeBins )

gMax = np.round(s_Grade.max() + 0.5)
gMin = 7
gradeBins = np.linspace(gMin, gMax, (gMax-gMin)*2+1)[::-1]
gradeHist = np.zeros( (NumUniqueDates,gradeBins.size) )

date = s_Date[0]
date_index=0
l_xDate = [date]
print("N = " +str(N))
for n in range(N):
    #print("s_Date[" +str(n) + "] = " +str(s_Date[n]) +"    date = " +str(date))
    if s_Date[n] != date:
        date = s_Date[n]
        l_xDate.append(date)
        date_index += 1
    g = s_Grade[n]

    addedThis_g = False
    for m in range(gradeBins.size):
        if ( g >= gradeBins[m] ):
            gradeHist[date_index,m] += 1
            #print str([date,g,date_index,m])
            addedThis_g = True
            break
    if not addedThis_g:
        # If we haven't found a bin yet, then add it to the lowest possible bin
        gradeHist[date_index,gradeBins.size-1] += 1
        #print str([date,g,date_index,gradeBins.size-1])

row_sums = gradeHist.sum(axis=1, keepdims=True)
gradeHistNorm = gradeHist / row_sums

# TODO: use 3d bars instead of pcolor(), example at:
# http://www.jon.hk/2010/03/3d-bar-histogram-in-python/
# https://toeholds.wordpress.com/2010/04/06/3d-histogram-in-python-2/
#----------------------------------
fig2 =plt.figure(2)
#----------------------------------
plt.clf()
#s_xDate = pd.TimeSeries(l_xDate)
s_xDate = pd.Series(l_xDate)
#p = plt.pcolormesh(            s_xDate, gradeBins, gradeHistNorm.T, cmap=plt.cm.copper)
#p = plt.pcolormesh(            s_xDate, gradeBins, gradeHist.T, cmap=plt.cm.copper)
p = plt.pcolormesh(range(len(l_xDate)), gradeBins, gradeHist.T, cmap=plt.cm.copper)
fig2.colorbar(p)
plt.ylabel('Grade- bin')
plt.xlabel('Date')
plt.title('Histogram of sent climbs\nBrighter color = more climbs at that grade bin')
axf2 = plt.gca()
axf2.set_xticklabels(s_xDate)
#axf2.xaxis.set_ticklabels(s_xDate.tolist())
axf2.xaxis.set_ticklabels(s_xDate.dt.strftime('%Y-%m-%d'))
#plt.gca().set_yticks(gradeBins)
#axf2.invert_yaxis()
#axf2.set_yticklabels(gradeBins +0.5)
yt = np.append(gradeBins[::-1], [gradeBins[0] +0.5, gradeBins[0] +1])
#axf2.set_yticks(yt)
#axf2.set_yticklabels(yt)
#axf2.set_xticklabels(s_xDate)
plt.axis('tight')
locs, labels = plt.xticks()
plt.setp(labels, rotation=45)
plt.show()
#TODO: Group by N days, or by weeks because we're really interested in the averages, rather than the daily results

sys.exit()
#exit()

"""
#----------------------------------
fig2 =plt.figure(2)
#----------------------------------
plt.clf()
ax1 = plt.subplot(4,1,1)
#TODO: Only used climbs with send = 100 and sits =0 for the 90 percentile
#df_sent = df_climbs[(df_climbs['Send']==100) & (df_climbs['Sits']==0)]
s_90p_sent = df_sent.groupby('Date')['Grade'].aggregate(lambda x: (np.percentile(x,90)) )
s_90p_all = df_climbs.groupby('Date')['Grade'].aggregate(lambda x: (np.percentile(x,90)) )
h1=s_max.plot(kind='area', color='0.85', ax=ax1, legend=True, label="Max All")
h2=s_90p_all.plot(style='bx-', ax=ax1, legend=True, label="All")
#h2=s_90p_all.plot(kind='area', color=(0.6, 0.6, 0.6), ax=ax1, legend=True, label="All")
h3=s_90p_sent.plot(style='ro-', ax=ax1, legend=True, label="Sent")
h4=s_mean.plot(style='g-', ax=ax1, legend=True, label="Mean All")
h5=s_min.plot(style='k', kind='area', ax=ax1, legend=True, label="Min All")
h1.set_ylabel("90th percentile\n per day")

#h,l = ax1.get_legend_handles_labesl()
ax1.legend( loc="lower left",prop={'size':6} )
ax1.set_xticklabels([])
#h1.set_label([])  # Doesn't work
#ax1.set_label([]) # Doesn't work
ax1.set_ylim( (6, 13) )




df_90p_avg_sent = pd.DataFrame(s_90p_sent)
df_90p_avg_sent['Date'] = df_90p_avg_sent.index
df_90p_avg_sent['p_div_mean'] = pd.Series(s_90p_sent / s_mean, index=df_90p_avg_sent.index)
df_90p_avg_sent['p_div_median'] = pd.Series(s_90p_sent / s_median, index=df_90p_avg_sent.index)
df_90p_avg_sent['p_div_count'] = pd.Series(s_90p_sent / s_count, index=df_90p_avg_sent.index)
df_90p_avg_sent['roll_p'] = pd.rolling_mean(s_90p_sent, 10)
df_90p_avg_sent['roll_p_div_mean'] = pd.Series(df_90p_avg_sent['roll_p'] / s_mean, index=df_90p_avg_sent.index)

df_90p_avg_all = pd.DataFrame(s_90p_all)
df_90p_avg_all['Date'] = df_90p_avg_all.index
df_90p_avg_all['p_div_mean'] = pd.Series(s_90p_all / s_mean, index=df_90p_avg_all.index)
df_90p_avg_all['p_div_median'] = pd.Series(s_90p_all / s_median, index=df_90p_avg_all.index)
df_90p_avg_all['p_div_median'] = pd.Series(s_90p_all / s_median, index=df_90p_avg_all.index)
df_90p_avg_all['p_div_count'] = pd.Series(s_90p_all / s_count, index=df_90p_avg_all.index)


ax2 = plt.subplot(4,1,2)
h4a = df_90p_avg_sent.plot(x='Date', y='p_div_mean', style='ro-', ax=ax2, legend=False)
h4b = df_90p_avg_sent.plot(x='Date', y='roll_p_div_mean', style='r--', ax=ax2, legend=False)
h4c = df_90p_avg_sent.plot(x='Date', y='p_div_median', style='m-', ax=ax2, legend=False)
h5 = df_90p_avg_all.plot(x='Date', y='p_div_mean', style='bx-', ax=ax2, legend=False)
h4a.set_ylabel("90th percentile/\nmean of sent\nper day")
ax2.set_xticklabels([])
#ax2.set_ylim( (0.5, 1.5) )

ax3 = plt.subplot(4,1,3)
h6 = df_90p_avg_sent.plot(x='Date', y='p_div_count', style='ro-', ax=ax3, legend=False)
h7 = df_90p_avg_all.plot(x='Date', y='p_div_count', style='bx-', ax=ax3, legend=False)
h6.set_ylabel("90th percentile/\ncount of all\nper day")
ax3.set_xticklabels([])

#fig2.subplots_adjust(hspace = 0.75)

ax4 = plt.subplot(4,1,4)
s_count_sent = df_sent.groupby('Date')['Grade'].count()
s_count_sent_div_all = pd.Series(s_count_sent / s_count, index=df_90p_avg_all.index)
h8=s_count_sent_div_all.plot(style='o-', ax=ax4, legend=False)
h8.set_ylabel("sent count/\nall count")
ax4.set_ylim( (0, 1) )

if platform.system() != 'Darwin':
    fig2.set_size_inches(10,8,forward=True) 
plt.show()
"""
sys.exit()

#----------------------------------
fig3 =plt.figure(3)
#----------------------------------
#ax1 = plt.subplot(5,1,6)
#h3=df_climbs.Grade.hist(bins=np.linspace(1,12,45))
#h3.set_xticks(np.linspace(1,12,12) )
h3=df_climbs.Grade.hist(bins=np.linspace(5,12,29))
h3.set_xticks(np.linspace(5,13,9) )
h3.set_ylabel("bin counts")
h3.set_xlabel("Difficulty")
plt.title("Difficulty Histogram")

#h3=plt.plot(df_climbs.Date, df_climbs.Grade, 'o')
#df_grades = df_climbs[['Date', 'Grade']]
plt.show()



df_named_climbs = df_climbs.dropna(subset=['Name'])
#----------------------------------
fig4 = plt.figure(4)
#----------------------------------
plt.clf()
ax1 = plt.subplot(1,1,1)
#h21=df_named_climbs.groupby('Name')['Name'].count().plot(style='o-')
# TODO: limit df_by_attempts to only climbs where at least one of the attempts was Send<100 or Sits>0
df_by_attempts = pd.DataFrame( df_named_climbs['Name'].value_counts() )
df_by_attempts['Name'] = df_by_attempts.index
df_by_attempts.columns = ['Attempts', 'Name']
df_by_attempts = df_by_attempts[df_by_attempts.Attempts > 1]
h2 = df_by_attempts.plot(x='Name', y='Attempts', kind='bar', ax=ax1, legend=False)
locs,labels = plt.xticks()
plt.setp(labels, rotation=90)
h2.set_ylabel("Number of Attempts")
plt.tight_layout()
plt.show()


#----------------------------------
fig5 = plt.figure(5)
#----------------------------------
plt.clf()
h31 = df_climbs['Belay'].value_counts().plot(kind='bar')
h31.set_ylabel("Number Climbs")
h31.set_xlabel("Belay Type")
#h31 = df_climbs['Belay'].value_counts().plot(kind='pie')


s_nc=df_named_climbs['Name'].value_counts()
s_sits=df_named_climbs.groupby('Name')['Sits'].mean().sort_index()
s_grades=df_named_climbs.groupby('Name')['Grade'].mean().sort_index()
df_attempts_sits = pd.concat( [s_nc, s_sits, s_grades], axis=1).reset_index()
df_attempts_sits.columns = ['Name', 'Attempts', 'Sits Mean', 'Grade']
plt.show()


#----------------------------------
fig6 = plt.figure(6)
#----------------------------------
plt.clf()
#plt.scatter(df_attempts_sits['Sits Mean'], df_attempts_sits['Attempts'])
#plt.grid('on')
#plt.xlabel('Sits Mean')
#plt.ylabel('Attempts')
#for label, x, y in zip(df_attempts_sits['Name'], df_attempts_sits['Sits Mean'], df_attempts_sits['Attempts']):
#    plt.annotate(
#        label, 
#        xy = (x, y), xytext = (-20, 20),
#        textcoords = 'offset points', ha = 'right', va = 'bottom',
#        bbox = dict(boxstyle = 'round,pad=0.5', fc = 'yellow', alpha = 0.5),
#        arrowprops = dict(arrowstyle = '->', connectionstyle = 'arc3,rad=0'))

#plt.hist(df_attempts_sits['Sits Mean'] / df_attempts_sits['Attempts'])
#plt.xlabel('Mean Sits / Attempts')
#plt.ylabel('Histogram')

plt.scatter(df_attempts_sits['Grade'], df_attempts_sits['Sits Mean'])
plt.grid('on')
plt.ylabel('Sits Mean')
plt.xlabel('Grade')
plt.show()

#----------------------------------
fig7 = plt.figure(7)
#----------------------------------
plt.clf()

s_sits_mean=df_climbs.groupby('Date')['Sits'].mean()
s_mean_div_sits = pd.Series(s_mean / (s_sits_mean +1), index=df_90p_avg_all.index)
h8=s_mean_div_sits.plot(style='o-', legend=False)
plt.grid('on')
plt.ylabel("Mean Grade/\nMean Sits+1")
plt.xlabel('Date')
plt.show()



df_dnf=df_climbs[df_climbs['Send']!=100]
df_dnf_grade_hist=pd.DataFrame(df_dnf['Grade'].value_counts())
df_dnf_grade_hist['Grade'] = df_dnf_grade_hist.index
df_dnf_grade_hist.columns = ['bin_sums', 'Grade']
#----------------------------------
fig8 = plt.figure(8)
#----------------------------------
plt.clf()
ax1 =plt.subplot(3,1,1)
#df_dnf.groupby('Name')['Grade'].mean().hist(width=0.05)
df_dnf_gbName_mean = pd.DataFrame(df_dnf.groupby('Name')['Grade'].mean())
df_dnf_gbName_mean['Name'] = df_dnf_gbName_mean.index
h5 = df_dnf_gbName_mean.plot(x='Name', y='Grade', kind='bar', ax=ax1)
#h5 = df_dnf_gbName_mean.hist(ax=ax1)
plt.title("DNF Climbs, group by name")
plt.xlabel("Name")
plt.ylabel("Grade")

ax3= plt.subplot(3,1,3)
#plt.bar(df_dnf_grade_hist.Grade, df_dnf_grade_hist.bin_sums, width=0.05, ax=ax3)
#plt.plot(x=df_dnf_grade_hist.Grade, y=df_dnf_grade_hist.bin_sums, kind='bar', ax=ax3)
h6 = df_dnf_grade_hist.plot(x='Grade', y='bin_sums', kind='bar', ax=ax3)
plt.title("DNF Climbs Histogram by Grade")
plt.xlabel("Grade")
plt.ylabel("Count")
plt.grid('on')
plt.show()

print( "DNF Climbs")
print( df_dnf.groupby('Name')['Grade'].mean() )


# TODO: For each climb with sits>0, plot the progression of number of sits over time (by attempt # = date?), label each series with name and grade?
#
#            ^  name1, 11+
#     # sits |  o         + Name2, 12-
#            |   o            + 
#            |       o            +
#            +----------------------->
#                  Date
