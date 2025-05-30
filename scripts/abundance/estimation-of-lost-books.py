import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import sys
import argparse
from datetime import datetime
import copia.stats as stats
from copia.plot import abundance_barplot
from copia.plot import abundance_histogram
from copia.plot import minsample_diagnostic_plot
from copia.plot import accumulation_curve
from copia.plot import density_plot
from copia.plot import abundance_barplot
from copia.plot import multi_kde_plot
from copia.plot import survival_errorbar
from copia.plot import evenness_plot
from copia.stats import species_accumulation
from copia.stats import survival_ratio
from copia.estimators import *
from copia.estimators import diversity
from copia.estimators import diversity
from copia.estimators import diversity
from copia.estimators import diversity
from copia.diversity import evenness
from copia.diversity import hill_numbers

def Hill_Shannon(list_ids):
    series_ids=pd.Series(list_ids)
    df_counts = series_ids.value_counts().reset_index()
    df_counts.columns = ['id', 'occurrences']

    # Calculate total number of records
    total_records = df_counts['occurrences'].sum()

    # Calculate proportion for each ID
    df_counts['proportion'] = df_counts['occurrences'] / total_records 
    df_counts['ln']=np.log(df_counts['proportion'])
    exponent=(df_counts['ln']*df_counts['proportion']).sum()
    return np.exp(-exponent)

def Hill_Simpson(list_ids):
    series_ids=pd.Series(list_ids)
    df_counts = series_ids.value_counts().reset_index()
    df_counts.columns = ['id', 'occurrences']

    # Calculate total number of records
    total_records = df_counts['occurrences'].sum()

    # Calculate proportion for each ID
    df_counts['proportion'] = df_counts['occurrences'] / total_records 
    df_counts['square']= df_counts['proportion']* df_counts['proportion']
    return 1/(df_counts['square'].sum())

parser = argparse.ArgumentParser(description="Estimate lost books")
parser.add_argument("file", help="A CSV file to read.")
parser.add_argument('--name', dest='name', default='', help='Name for the report directory')
args = parser.parse_args()

if not os.path.exists(args.file):
    print('%s is not an existing file' % (args.file))

data, method = args.name.split('_', 1)

# sys.exit()

# import ast

output_dir = 'outputs4/{0}'.format(args.name) if args.name != '' else 'outputs'
if not os.path.exists(output_dir):
    os.makedirs(output_dir, exist_ok=True)

report_file = "{0}/report.txt".format(output_dir)
if os.path.exists(report_file):
    os.remove(report_file)

year = "2025"  # 1971
df = pd.read_csv(args.file)
#     "/home/pkiraly/git/pkiraly/mi-veszett-el/data_raw/v02/abundance-" + year + ".csv"
# )
# df.columns = 'work', 'signature'
# df.head()
report = open(report_file, "w")

abundance = np.array(df["count"])

report.write("[basic_stats] " + datetime.now().strftime("%H:%M:%S") + "\n")
stat = stats.basic_stats(abundance)
stat_str = str(stat)

with open("{0}/overview.csv".format(output_dir), "w") as overview:
  h1 = Hill_Shannon(abundance)
  h2 = Hill_Simpson(abundance)
  overview.write('data,method,f1,f2,f3,f4,S,n,Hill_Shannon,Hill_Simpson\n')
  overview.write('%s,%s,%d,%d,%d,%d,%d,%d,%.2f,%.2f\n' % 
    (data, method, stat['f1'], stat['f2'], stat['f3'], stat['f4'], stat['S'], stat['n'],
        h1, h2))

# f1..4 - works in 1..4 examples
# S: number of works (species)
# n: number of examples (population)


# abundance_barplot(abundance)
report.write("[abundance_barplot] " + datetime.now().strftime("%H:%M:%S") + "\n")
abundance_barplot(abundance, trendline=True)
plt.savefig("{0}/abundance_cnt.png".format(output_dir), format="png")


# abundance_histogram(abundance)
report.write("[abundance_histogram] " + datetime.now().strftime("%H:%M:%S") + "\n")
abundance_histogram(
    abundance,
    trendline=True,
    title="Fennmaradt példányszámok eloszlása (" + year + ")",
    cat_label="RMNY tételek",
    obs_label="példányok",
    xlabel="fennmaradt példányszámok",
    # ylabel="Fisher logaritmikus sorozata",
    # ylabel="Valószínűségi tömegfüggvény",
    # obs_label='total copies'
    # title = 'Survival histogram (' + year + ')',
    # xlabel = 'survived copies'
)
plt.savefig("{0}/abundance_hist.png".format(output_dir), format="png")

# Basic species richness
# Estimate unbiased diversity using one of the estimators in copia.richness.
# All of the estimators are available from a single entry point, diversity()
# (or they can be accessed directly):
report.write("[diversity (chao1)] " + datetime.now().strftime("%H:%M:%S") + "\n")

report.write("diversity (chao1): {0}\n".format(diversity(abundance, method="chao1")))  # or chao1(abundance)

# By default, the estimators only return a single number, i.e. the estimate.
# Some estimators accept additional arguments that can be passed as
# **kwargs to diversity(), in which case a dict with the relevant fields will be returned:
report.write("[diversity (jackknife)] " + datetime.now().strftime("%H:%M:%S") + "\n")
report.write("diversity (jackknife): {0}\n".format(
    diversity(abundance, method="jackknife", return_order=True)
))  # or jackknife(abundance, return_order=True)

report.write("[Diversity measurement] " + datetime.now().strftime("%H:%M:%S") + "\n")
report.write("Diversity measurement\n")
for m in ("chao1", "ichao1", "ace", "jackknife", "egghe_proot"):
    report.write("{0}: {1}\n".format(m, "%.2f" % diversity(abundance, method=m)))

report.write("species richness: {0}\n".format(diversity(abundance, method="empirical")))
report.write("population size: {0}\n".format(diversity(abundance, method="empirical", species=False)))

# Bootstrapped estimation
# To obtain a lower and upper bound for the confidence interval on an estimate,
# it is common to apply a bootstrapped procedure. Set CI=True for this,
# so that a dict with the relevant keys (including the actual bootstrap values)
# is returned:
report.write("[Diversity measurement with confidence intervals] " + datetime.now().strftime("%H:%M:%S") + "\n")
report.write("Diversity measurement with confidence intervals\n")

with open("{0}/estimation.csv".format(output_dir), "w") as estimation_result:
    estimation_result.write('data,method,estimation,richness,min,max\n')
    for m in ("chao1", "ichao1", "ace", "jackknife", "egghe_proot"):
        div = diversity(abundance, method=m, CI=True, n_iter=10)
        estimation_result.write(
            "%s,%s,%s,%.2f,%.2f,%.2f\n" % (data, method, m, div["richness"], div["lci"], div["uci"])
        )  # div['std']

# Minimum additional sampling

# The minsample approach is a less conventional unbiased estimator for obtaining
# a lower bound on the true population size. It is available through a similar
# interface as the traditional species richness estimators:
report.write("[Diversity measurement with Empirical] " + datetime.now().strftime("%H:%M:%S") + "\n")
report.write("Empirical size: {0}\n".format(diversity(abundance, method="empirical", species=False)))
report.write("Unbiased estimate: {0}\n".format("%.2f" % diversity(abundance, method="minsample")))
# of population (=manuscripts)

# Like with the other estimators, a bootstrap procedure is available:
diversity(abundance, method="minsample", CI=True, n_iter=10)

# This method relies on an optimization procedure, which can be brittle
# and doesn't always converge. Two solvers are available: "fsolve"
# (optimization via scipy) and "grid" (a hardcore grid search).
# (The former will back off to the latter if it fails. Appropriate warning
# messages will be displayed.)
report.write("[Diversity measurement with minsample] " + datetime.now().strftime("%H:%M:%S") + "\n")
report.write("minsample/fsolve: {0}\n".format(diversity(abundance, method="minsample", solver="fsolve")))
report.write("minsample/grid: {0}\n".format(diversity(abundance, method="minsample", solver="grid")))

report.write("[diagn] " + datetime.now().strftime("%H:%M:%S") + "\n")
diagn = diversity(
    abundance,
    method="minsample",
    solver="grid",
    CI=False,  # CI must be False for this use!
    diagnostics=True,
)
report.write(str(diagn) + "\n")

assert np.isclose(
    diagn["richness"], diagn["n"] + (diagn["x*"] * diagn["n"]), atol=0.001
)

report.write("[minsample_diagnostic_plot] " + datetime.now().strftime("%H:%M:%S") + "\n")
minsample_diagnostic_plot(abundance, diagn)
plt.savefig("{0}/optimization.png".format(output_dir), format="png")


report.write("[species_accumulation] " + datetime.now().strftime("%H:%M:%S") + "\n")
print("species_accumulation")
accumulation = species_accumulation(abundance, max_steps=40000, n_iter=10)
accumulation

accumulation_curve(
    abundance,
    accumulation,
    xlabel="példányok",
    ylabel="kiadványok",
    title="RMNY akkumulált görbe",
)
plt.savefig("{0}/accumul.png".format(output_dir), format="png")


report.write("[minsample estimation] " + datetime.now().strftime("%H:%M:%S") + "\n")
print("minsample estimation")
minsample_est = diversity(abundance, method="minsample", solver="fsolve", CI=True)
accumulation_curve(
    abundance,
    accumulation,
    title="RMNY akkumulált görbe (minsample módszerrel)",
    xlabel="példányok",
    ylabel="kiadványok",
    minsample=minsample_est,
    xlim=(0, 40000),
)
plt.savefig("{0}/accumul2.png".format(output_dir), format="png")

report.write("[density_plot (iChao1)] " + datetime.now().strftime("%H:%M:%S") + "\n")
print("density_plot (iChao1)")
estimate = diversity(abundance, method="iChao1", CI=True)
density_plot(estimate)
plt.savefig("{0}/dens1.png".format(output_dir), format="png")


report.write("[density_plot (empirical)] " + datetime.now().strftime("%H:%M:%S") + "\n")
print("density_plot (empirical)")
empirical = diversity(abundance, method="empirical")
density_plot(estimate, empirical)
plt.savefig("{0}/dens2.png".format(output_dir), format="png")


report.write("[survival_ratio] " + datetime.now().strftime("%H:%M:%S") + "\n")
print("survival_ratio")
survival = survival_ratio(abundance, method="chao1")
density_plot(survival, xlim=(0, 1))
plt.savefig("{0}/surv.png".format(output_dir), format="png")

report.close()
sys.exit()

# suffix = "lang"
# df_lang = pd.read_csv(
#     "/home/pkiraly/git/pkiraly/mi-veszett-el/data_raw/v02/abundance-by-language-"
#     + year
#     + ".csv",
#     sep=",",
# )  # header=True
# df.columns = 'work', 'signature'
# df_lang.head()
# df_lang.groupby("nyelv").mean()
# keys = df_lang.groupby("nyelv").mean().index.values
# assemblages = {}
# for key in keys:
#     print(key)
#     assemblages[key] = df_lang[df_lang["nyelv"] == key]["count"].values
# assemblages = {}
# assemblages['latin'] = df_lang[df_lang["nyelv"] == 'latin']['count'].values
# assemblages['magyar'] = df_lang[df_lang["nyelv"] == 'magyar']['count'].values
# assemblages['német'] = df_lang[df_lang["nyelv"] == 'német']['count'].values

# report.write(str(assemblages) + "\n")

# stats.basic_stats(assemblages)
report.write("[stats.basic_stats(assemblages)] " + datetime.now().strftime("%H:%M:%S") + "\n")

all = []
all.append("method,language,S,richness,lci,uci")
for key, abundance in assemblages.items():
    st = stats.basic_stats(abundance)
    print(st["S"])
    for m in ("chao1", "ichao1", "ace", "jackknife", "egghe_proot"):
        div = diversity(abundance, method=m, CI=True, n_iter=10)
        all.append(
            '"%s","%s",%d,%.2f,%.2f,%.2f,'
            % (m, key, st["S"], div["richness"], div["lci"], div["uci"])
        )  # div['std']
report.write("\n".join(all))

for m in ("chao1", "ichao1", "ace", "jackknife", "egghe_proot"):
    for val in assemblages:
        div = diversity(abundance, method=m, CI=True, n_iter=10)
        report.write(
            "%s, %s: %.2f (%.2f-%.2f)\n"
            % (val, m, div["richness"], div["lci"], div["uci"])
        )  # div['std']


# abundance_barplot(abundance)
# abundance_barplot(assemblages["latin"], trendline=True)
# abundance_barplot(assemblages["magyar"], trendline=True)
# abundance_barplot(assemblages["német"], trendline=True)
# plt.savefig('outputs/abundance_cnt.png', format='png')

# suffix = "genre"
# df_genre = pd.read_csv(
#     "/home/pkiraly/git/pkiraly/mi-veszett-el/data_raw/abundance-by-genre.csv", sep=","
# )  # header=True
# df.columns = 'work', 'signature'
# df_lang.head()
# df_genre.groupby("genre").mean()
# assemblages = {}
# assemblages["alkalmi"] = df_genre[df_genre["genre"] == "alkalmi kiadvány"][
#     "count"
# ].values
# assemblages["egyházi-vallási"] = df_genre[
#     df_genre["genre"] == "egyházi-vallási kiadvány"
# ]["count"].values
# assemblages["iskolai"] = df_genre[df_genre["genre"] == "iskolai kiadvány"][
#     "count"
# ].values
# assemblages["nem besorolt"] = df_genre[df_genre["genre"] == "nem besorolt"][
#     "count"
# ].values
# assemblages["szórakoztató"] = df_genre[df_genre["genre"] == "szórakoztató kiadvány"][
#     "count"
# ].values
# assemblages["tudományos"] = df_genre[df_genre["genre"] == "tudományos kiadvány"][
#     "count"
# ].values
# assemblages["állami működéshez kapcsolódó"] = df_genre[
#     df_genre["genre"] == "állami működéshez kapcsolódó kiadvány"
# ]["count"].values

all = []
for key, abundance in assemblages.items():
    st = stats.basic_stats(abundance)
    # report.write(st["S"])
    for m in ("chao1", "ichao1", "ace", "jackknife", "egghe_proot"):
        div = diversity(abundance, method=m, CI=True, n_iter=10)
        all.append(
            '"%s","%s",%d,%.2f,%.2f,%.2f,'
            % (m, key, st["S"], div["richness"], div["lci"], div["uci"])
        )  # div['std']
report.write("\n".join(all))

# suffix = "format"
# df_format = pd.read_csv(
#     "/home/pkiraly/git/pkiraly/mi-veszett-el/data_raw/abundance-by-format.csv", sep=","
# )  # header=True
# df.columns = 'work', 'signature'
# df_lang.head()
# keys = df_format.groupby("format").mean().index.values
# assemblages = {}
# for key in keys:
#     report.write(key + "\n")
#     assemblages[key] = df_format[df_format["format"] == key]["count"].values
# assemblages['alkalmi'] = df_genre[df_genre["genre"] == 'alkalmi kiadvány']['count'].values
# assemblages['egyházi-vallási'] = df_genre[df_genre["genre"] == 'egyházi-vallási kiadvány']['count'].values
# assemblages['iskolai'] = df_genre[df_genre["genre"] == 'iskolai kiadvány']['count'].values
# assemblages['nem besorolt'] = df_genre[df_genre["genre"] == 'nem besorolt']['count'].values
# assemblages['szórakoztató'] = df_genre[df_genre["genre"] == 'szórakoztató kiadvány']['count'].values
# assemblages['tudományos'] = df_genre[df_genre["genre"] == 'tudományos kiadvány']['count'].values
# assemblages['állami működéshez kapcsolódó'] = df_genre[df_genre["genre"] == 'állami működéshez kapcsolódó kiadvány']['count'].values

report.write("[diversity(abundance)] " + datetime.now().strftime("%H:%M:%S") + "\n")
all = []
for key, abundance in assemblages.items():
    st = stats.basic_stats(abundance)
    # report.write(st["S"])
    for m in ("chao1", "ichao1", "ace", "jackknife", "egghe_proot"):
        div = diversity(abundance, method=m, CI=True, n_iter=10)
        all.append(
            '"%s","%s",%d,%.2f,%.2f,%.2f,'
            % (m, key, st["S"], div["richness"], div["lci"], div["uci"])
        )  # div['std']
report.write("\n".join(all))

report.write("[survival_ratio] " + datetime.now().strftime("%H:%M:%S") + "\n")
survival = {}
for category, assemblage in assemblages.items():
    survival[category] = survival_ratio(assemblage, method="chao1")
survival

multi_kde_plot(survival)
plt.savefig("{0}/multi_kde-{1}.png".format(output_dir, suffix), format="png")


survival_errorbar(survival)
plt.savefig("{0}/survival_error_bar-{1}.png".format(output_dir, suffix), format="png")


report.write("[hill_numbers] " + datetime.now().strftime("%H:%M:%S") + "\n")
hill_est = {}
for lang, assemblage in assemblages.items():
    _, est = hill_numbers(assemblage, n_iter=10)
    hill_est[lang] = est

evennesses = {l: evenness(hill_est[l]) for l in hill_est}


evenness_plot(evennesses)
plt.savefig("{0}/evenness-{1}.png".format(output_dir, suffix), format="png")

report.close()
