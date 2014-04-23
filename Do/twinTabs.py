# twinTabs.py v 0.0.0            damiancclarke             yyyy-mm-dd:2014-03-29
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#

from sys import argv
import re
import os
import locale
locale.setlocale(locale.LC_ALL, 'en_US')

script, ftype = argv
print('\n\nHey DCC. The script %s is making %s files \n' %(script, ftype))

#==============================================================================
#== (1a) File names (comes from Twin_Regressions.do)
#==============================================================================
Results  = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/IV/"
Results1 = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/OLS"
Results2 = "/home/damiancclarke/investigacion/Activa/Twins/Results/Outreg/"
Tables   = "/home/damiancclarke/investigacion/Activa/Twins/Tables/"

base = 'Base_IV_none.xls'
bord = 'Base_IV_bord.xls'
lowi = 'Income_IV_low_none.xls'
midi = 'Income_IV_mid_none.xls'
thre = 'Desire_IV_all_none.xls'
twIV = 'Base_IV_twins_none.xls'
tbIV = 'Base_IV_twins_bord.xls'
gend = ['Gender_IV_F_none.xls','Gender_IV_M_none.xls']

firs = 'Base_IV_firststage_none.xls'
fbor = 'Base_IV_firststage_bord.xls'
flow = 'Income_IV_firststage_low_none.xls'
fmid = 'Income_IV_firststage_mid_none.xls'
ftwi = 'Base_IV_twins_firststage_none.xls'

ols  = "QQ_ols.txt"
bala = "Balance_mother.tex"
twin = "Twin_Predict_none.xls"
summ = "Summary.txt"
coun = "Count.txt"
dhss = "Countries.txt"

conl = "ConleyResults.txt"
imrt = "PreTwinTest_none.xls"

os.chdir(Results)

#==============================================================================
#== (1b) Options (tex or csv out)
#==============================================================================
if ftype=='tex':
    dd   = "&"
    dd1  = "&\\begin{footnotesize}"
    dd2  = "\\end{footnotesize}&\\begin{footnotesize}"
    dd3  = "\\end{footnotesize}"
    end  = "tex"
    foot = "$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01"
    ls   = "\\\\"
    mr   = '\\midrule'
    hr   = '\\hline'
    tr   = '\\toprule'
    br   = '\\bottomrule'
    mc1  = '\\multicolumn{'
    mcsc = '}{l}{\\textsc{'
    mcbf = '}{l}{\\textbf{'    
    mc2  = '}}'
    twid = ['5','6','4','5','9','7','4','5','6']
    tcm  = ['}{p{10cm}}','}{p{14.1cm}}','}{p{10.4cm}}','}{p{11.6cm}}',
            '}{p{13.3cm}}','}{p{11.5cm}}','}{p{7cm}}','}{p{11.5cm}}',
            '}{p{12.5cm}}']
    mc3  = '{\\begin{footnotesize}\\textsc{Notes:} '
    lname = "Fertility$\\times$desire"
    tsc  = '\\textsc{' 
    ebr  = '}'
    R2   = 'R$^2$'
    mi   = '$\\'
    mo   = '$'
    lineadd = '\\begin{footnotesize}\\end{footnotesize}&'*6+ls
    hs   = '\\hspace{5mm}'

elif ftype=='csv':
    dd   = ";"
    dd1  = ";"
    dd2  = ";"
    dd3  = ";"
    end  = "csv"
    foot = "* p<0.1, ** p<0.05, *** p<0.01"
    ls   = ""
    mr   = ""
    hr   = ""
    br   = ""
    tr   = ""
    mc1  = ''
    mcsc = ''
    mcbf = ''   
    mc2  = ''
    twid = ['','','','','','','','','']
    tcm  = ['','','','','','','','','']
    mc3  = 'NOTES: '
    lname = "Fertility*desire"
    tsc  = '' 
    ebr  = ''
    R2   = 'R-squared'
    mi   = ''
    mo   = ''
    lineadd = ''
    hs   = ''

#==============================================================================
#== (2) Function to return fertilility beta and SE for IV tables
#==============================================================================
def plustable(ffile,n1,n2,searchterm):
    beta = []
    se   = []
    N    = []

    f = open(ffile, 'r').readlines()

    for i, line in enumerate(f):
        if re.match(searchterm, line):
            beta.append(i)
            se.append(i+1)
        if re.match("N", line):
            N.append(i)
    
    TB = []
    TS = []
    TN = []
    for n in beta:
        TB.append(f[n].split()[n1:n2])
    for n in se:
        TS.append(f[n].split()[n1-1:n2-1])
    for n in N:
        TN.append(f[n].split()[n1:n2])

    return TB, TS, TN


#==============================================================================
#== (3) Call functions, print table for plus groups
#==============================================================================
for i in ['Two', 'Three', 'Four', 'Five']:
    if i=="Two":
        num1=1
        num2=4
        t='two'
        des='first-born children' 
        IVf   = open(Tables+'TwoPlusIV.'+end, 'w')
    elif i=="Three":
        num1=4
        num2=7
        t='three'
        des='first- and second-born children' 
        IVf = open(Tables+'ThreePlusIV.'+end, 'w')
    elif i=="Four":
        num1=7
        num2=10
        t='four'
        des='first- to third-born children' 
        IVf = open(Tables+'FourPlusIV.'+end, 'w')
    elif i=="Five":
        num1=10
        num2=13
        t='five'
        des='first- to fourth-born children' 
        IVf = open(Tables+'FivePlusIV.'+end, 'w')

    TB1, TS1, TN1 = plustable(base, num1, num2,"fert")
    TB2, TS2, TN2 = plustable(bord, num1, num2,"fert")
    TB3, TS3, TN3 = plustable(lowi, num1, num2,"fert")
    TB4, TS4, TN4 = plustable(midi, num1, num2,"fert")
    TB5, TS5, TN5 = plustable(thre, num1, num2,"fert")
    
    TB6, TS6, TN6 = plustable(twIV, num1, num2,"fert")
    TB7, TS7, TN7 = plustable(tbIV, num1, num2,"fert")

    FB, FS, FN    = plustable(firs, 1, 4,'twin\_'+t+'\_fam')

    print "Table for " + i + " Plus:"
    print ""

    if ftype=='tex':
        IVf.write("\\begin{table}[!htbp] \\centering \n"
        "\\caption{Instrumental Variables Estimates: "+i+" Plus} \\vspace{4mm} \n"
        "\\label{TWINtab:IV"+i+"plus} \n"
        "\\begin{tabular}{lcccc} \\toprule \\toprule \n")

    IVf.write(dd+"Base" + dd + dd + dd+ ls + "\n"
    +dd+"Controls"+dd+"Socioec"+dd+"Health"+dd+"Obs."+ls+mr+"\n"
    +mc1+twid[0]+mcsc+"Pre-Twins"+mc2+ls+" \n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families"+mc2+ls+" \n"
    "Fertility"+dd+TB1[0][0]+dd+TB1[0][1]+dd+TB1[0][2]+
    dd+format(float(TN1[0][2]), "n")+ls+"\n"
    "         "+dd+TS1[0][0]+dd+TS1[0][1]+dd+TS1[0][2]+dd+ls+ "\n"
    +dd+dd+dd+dd+ls+"\n" 
    +mc1+twid[0]+mcbf+"All Families (bord dummies)"+mc2+ls+" \n"
    "Fertility"+dd+TB2[0][0]+dd+TB2[0][1]+dd+TB2[0][2]+
    dd+format(float(TN1[0][2]), "n")+ls+"\n"
    "         "+dd+TS2[0][0]+dd+TS2[0][1]+dd+TS2[0][2]+dd+ls+ "\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"Low-Income Countries"+mc2+ls+" \n"
    "Fertility"+dd+TB3[0][0]+dd+TB3[0][1]+dd+TB3[0][2]+
    dd+format(float(TN3[0][2]), "n")+ls+"\n"
    "         "+dd+TS3[0][0]+dd+TS3[0][1]+dd+TS3[0][2]+dd+ls+"\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"Middle-Income Countries"+mc2+ls+" \n"
    "Fertility"+dd+TB4[0][0]+dd+TB4[0][1]+dd+TB4[0][2]+
    dd+format(float(TN4[0][2]), "n")+ls+"\n"
    "         "+dd+TS4[0][0]+dd+TS4[0][1]+dd+TS4[0][2]+dd+ls+"\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"Desired-Threshold"+mc2+ls+" \n"
    "Fertility"+dd+TB5[0][0]+dd+TB5[0][1]+dd+TB5[0][2]+
    dd+format(float(TN5[0][2]), "n")+ls+"\n"
    "         "+dd+TS5[0][0]+dd+TS5[0][1]+dd+TS5[0][2]+dd+ls+ "\n"
    +lname+dd+TB5[1][0]+dd+TB5[1][1]+dd+TB5[1][2]+dd+ls+"\n"
    "         "+dd+TS5[1][0]+dd+TS5[1][1]+dd+TS5[1][2]+dd+ls+"\n"+mr
    +mc1+twid[0]+mcsc+"Twins and Pre-Twins"+mc2+ls+" \n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families"+mc2+ls+" \n"
    "Fertility"+dd+TB6[0][0]+dd+TB6[0][1]+dd+TB6[0][2]+
    dd+format(float(TN6[0][2]), "n")+ls+"\n"
    "         "+dd+TS6[0][0]+dd+TS6[0][1]+dd+TS6[0][2]+dd+ls+ "\n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families (bord dummies)"+mc2+ls+" \n"
    "Fertility"+dd+TB7[0][0]+dd+TB7[0][1]+dd+TB7[0][2]+
    dd+format(float(TN6[0][2]), "n")+ls+"\n"
    "         "+dd+TS7[0][0]+dd+TS7[0][1]+dd+TS7[0][2]+dd+ls+ "\n"+mr
    +mc1+twid[0]+mcsc+"First Stage (Pre-Twins)"+mc2+ls+" \n"
    +dd+dd+dd+dd+ls+"\n"
    +mc1+twid[0]+mcbf+"All Families"+mc2+ls+" \n"
    "Twins"+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+
    dd+format(float(TN1[0][2]), "n")+ls+"\n"
    "         "+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd+ls+ "\n"
    +hr+
    mc1+twid[0]+tcm[0]+mc3
    +i+"-plus refers to all "+des+ " in families with "+t+" or "
    "more children.  Each cell presents the coefficient of a 2SLS "
    "regression where fertility is instrumented by twinning at birth order "
    +t+".  Base controls include age, mother's age, and mother's age at "
    "birth fixed effects plus country and year-of-birth FEs.  Standard "
    "errors are clustered by mother. \n"
    +foot)
    if ftype=='tex':
        IVf.write("\\end{footnotesize}}\n"+ls+br+
        "\\normalsize\\end{tabular}\\end{table} \n")

    IVf.close()

#==============================================================================
#== (4) Function to return fertilility beta and SE for OLS tables
#==============================================================================
os.chdir(Results1)

def olstable(ffile,n1,n2):
    beta = []
    se   = []
    N    = []
    R    = []

    f = open(ffile, 'r').readlines()

    for i, line in enumerate(f):
        if re.match("fert", line):
            beta.append(i)
            se.append(i+1)
        if re.match("Observations", line):
            N.append(i)
        if re.match("R-squared", line):
            R.append(i)

    TB = []
    TS = []
    TN = []
    TR = []
    for n in beta:
        TB = f[n].split()[n1:n2]
    for n in se:
        TS = f[n].split()[n1-1:n2-1]
    for n in N:
        TN = f[n].split()[n1:n2]
    for n in R:
        TR = f[n].split()[n1:n2]

    A1 = float(re.search("-\d*\.\d*", TB[0]).group(0))
    A2 = float(re.search("-\d*\.\d*", TB[1]).group(0))
    A3 = float(re.search("-\d*\.\d*", TB[2]).group(0))
    AR1 = str(round(A2/(A1-A2), 3))
    AR2 = str(round(A3/(A1-A3), 3))

    return TB, TS, TN, TR, AR1, AR2


TBa, TSa, TNa, TRa, A1a, A2a = olstable(ols, 1, 4)
TBl, TSl, TNl, TRl, A1l, A2l = olstable(ols, 4, 7)
TBm, TSm, TNm, TRm, A1m, A2m = olstable(ols, 7, 10)


#==============================================================================
#== (5) Write OLS table
#==============================================================================
OLSf = open(Tables+'OLS.'+end, 'w')

if ftype=='tex':
    OLSf.write("\\begin{table}[!htbp] \\centering \n"
    "\\caption{OLS Estimates of the Q-Q Trade-off} \n \\vspace{4mm}"
    "\\label{TWINtab:OLS} \n"
    "\\begin{tabular}{lccccc} \\toprule \\toprule \n")

OLSf.write(dd+"Base"+dd+"+"+dd+"+"+dd+"Altonji"+dd+"Altonji"+ls+"\n"
+dd+"Controls"+dd+"Socioec"+dd+"Health"+dd+"Ratio 1"+dd+"Ratio 2"+ls+mr+"\n"
+tsc+"Panel A: All Countries"+ebr+dd+dd+dd+dd+dd+ls+"\n"
"Fertility "+dd+TBa[0]+dd+TBa[1]+dd+TBa[2]+dd+A1a+dd+A2a+ls+"\n"
+            dd+TSa[0]+dd+TSa[1]+dd+TSa[2]+dd+dd+ls+  "\n"
+dd+dd+dd+dd+dd+ls+"\n"
"Observations "+dd+str(TNa[0])+dd+str(TNa[1])+dd+str(TNa[2])+dd+dd+ls+"\n"
+R2+dd+str(TRa[0])+dd+ str(TRa[1])+dd+str(TRa[2])+dd+dd+ls
+mr+"\n"
+tsc+"Panel B: Low Income"+ebr+dd+dd+dd+dd+dd+ls+"\n"
"Fertility "+dd+TBl[0]+dd+TBl[1]+dd+TBl[2]+dd+A1l+dd+A2l+ls+"\n"
+            dd+TSl[0]+dd+TSl[1]+dd+TSl[2]+dd+dd+ls+"\n"
+dd+dd+dd+dd+dd+ls+"\n"
"Observations "+dd+str(TNl[0])+dd+str(TNl[1])+dd+str(TNl[2])+dd+dd+ls+"\n"
+R2+dd+str(TRl[0])+dd+ str(TRl[1])+dd+str(TRl[2])+dd+dd+ls
+mr+"\n"
+tsc+"Panel C: Middle Income"+ebr+dd+dd+dd+dd+dd+ls+"\n"
"Fertility "+dd+TBm[0]+dd+TBm[1]+dd+TBm[2]+dd+A1m+dd+A2m+ls+ "\n"
+            dd+TSm[0]+dd+TSm[1]+dd+TSm[2]+dd+dd+ls+  "\n"
+dd+dd+dd+dd+dd+ls+"\n"
"Observations "+dd+str(TNm[0])+dd+str(TNm[1])+dd+str(TNm[2])+dd+dd+ls+ "\n"
+R2+dd+str(TRm[0])+dd+str(TRm[1])+dd+str(TRm[2])+dd+dd+ls
+hr+hr+ls+"\n"
+mc1+twid[1]+tcm[1]+mc3+
"Base controls consist of child gender, mother's age and age squared "
"mother's age at first birth, child age, country, and year of birth "
"dummies.  Socioeconomic augments `Base' to include mother's education "
"and quadratic, and Health includes mother's height and BMI.  Standard "
"errors are clustered at the level of the mother.\n" + foot)

if ftype=='tex':
    OLSf.write("\\end{footnotesize}}  \n"
    "\\\\ \\bottomrule \\normalsize\\end{tabular}\\end{table} \n")

OLSf.close()


#==============================================================================
#== (6) Read in balance table, fix formatting
#==============================================================================
bali = open(Results2+bala, 'r').readlines()
balo = open(Tables+"Balance_mother."+end, 'w')

for i,line in enumerate(bali):
    if ftype=='tex' or i>6:
        line = line.replace("&", dd)
        line = line.replace("\\\\", ls)
        line = line.replace("\\begin{tabular}", "\\vspace{5mm}\\begin{tabular}")
        line = line.replace("\\toprule", "\\toprule\\toprule & Non-Twin & Twin & Diff.\\\\")
        line = line.replace("mu\_1", "Family")
        line = line.replace("mu\_2", "Family")
        line = line.replace("d/d\\_se", "(Diff. SE)")
        line = line.replace("\\end{tabular}", "")    
        line = line.replace("\\end{table}", "")    
        line = line.replace("\\bottomrule", mr+mr)    
        if ftype=='csv':
            line = line.replace('\\sym{','')
            line = line.replace('}','')
            line = line.replace('$','')
        balo.write(line)

balo.write(mc1+twid[2]+tcm[2]+mc3+
"Education measured in years, mother's height in centimetres, and BMI is "
"weight in kilograms over height in metres squared.  Diff. SE is calculated "
"using a two-tailed t-test. "
+foot)
if ftype=='tex':
    balo.write("\\end{footnotesize}}\n"+ls+br+
    "\\normalsize\\end{tabular}\\end{table} \n")

balo.close()

#==============================================================================
#== (7) Read in twin predict table, LaTeX format
#==============================================================================
twini = open(Results2+"Twin/"+twin, 'r')
twino = open(Tables+"TwinReg."+end, 'w')

if ftype=='tex':
    twino.write("\\begin{landscape}\\begin{table}[htpb!] \n"
    "\\caption{Probability of Giving Birth to Twins} \\label{TWINtab:twinreg1} \n"
    "\\begin{center}\\begin{tabular}{lcccccc} \\toprule \\toprule \n"
    +dd+"(1)"+dd+"(2)"+dd+"(3)"+dd+"(4)"+dd+"(5)"+dd+"(6)"+ls+"\n"
    "Twin*100"+dd+"All"+dd+"\\multicolumn{2}{c}{Income}"+dd+
    "\\multicolumn{2}{c}{Time}"+dd+"Prenatal"+ls+"\n "
    "\\cmidrule(r){3-4} \\cmidrule(r){5-6} \n"
    +dd+dd+"Low inc"+dd+"Middle inc"+dd+"1990-2013"+dd+"1972-1989"+dd+ls+mr+ "\n"
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+dd+
   "\\begin{footnotesize}\\end{footnotesize}"+ls+"\n")
elif ftype=='csv':
    twino.write(dd+"(1)"+dd+"(2)"+dd+"(3)"+dd+"(4)"+dd+"(5)"+dd+"(6)"+ls+"\n"
    "Twin*100"+dd+"All"+dd+"Income"+''+dd+dd+"Time"+''+dd+dd+"Prenatal"+ls+"\n"
    +dd+dd+"Low inc"+dd+"Middle inc"+dd+"1990-2013"+dd+"1972-1989"+dd+ls+mr+"\n\n")

for i,line in enumerate(twini):
    if i>2:
        line = line.replace("\t",dd)
        line = line.replace("\n", ls)
        line = line.replace("\"", "")
        line = line.replace("made.\\\\", "made.")
        line = line.replace("made.&&&&&&\\\\", "made.")
        line = line.replace("antenatal", "Antenatal Visits")
        line = line.replace("prenate_doc", "Prenatal (Doctor)")
        line = line.replace("prenate_nurse", "Prenatal (Nurse)")
        line = line.replace("prenate_none", "Prenatal (None)")
        line = line.replace("Notes:", 
        "\\hline\\hline\\multicolumn{7}{p{14.3cm}}{\\begin{footnotesize}\\textsc{Notes:}")
        line = line.replace("r2", dd*6+ls+"R-squared")
        line = line.replace("N&", "Observations &")
        line = re.sub(r"(?<=\d),(?=\d)",".", line)
        if ftype=='csv':
            line=line.replace(';;;;;;R-squared','R-squared')
            line=line.replace('\\hline\\hline\\multicolumn{7}{p{14.3cm}}','')
            line=line.replace('{\\begin{footnotesize}\\textsc{Notes:}','NOTES:')
        twino.write(line+'\n')

if ftype=='csv':
    twino.write(foot)
elif ftype=='tex':
    twino.write(foot+"\n \\end{footnotesize}}\\\\ \\hline \\normalsize "
    "\\end{tabular}\\end{center}\\end{table}\\end{landscape} \n")

twino.close()


#==============================================================================
#== (8) Read in summary stats, LaTeX format
#==============================================================================
counti = open(Results2+"Summary/"+coun, 'r')

addL = []
for i,line in enumerate(counti):
    if i<5:
        if ftype=='csv':
            line = line.replace('\\multicolumn{2}{c}{','')
            line = line.replace('}','')
            if i==3 or i==4:
                line = line.replace('&',';;')
            line = line.replace('&',';')
            line = line.replace('\\\\','')
        addL.append(line.replace("( ","("))
    elif i==5:
        nk = line
print nk

summi = open(Results2+"Summary/"+summ, 'r')
summo = open(Tables+"Summary."+end, 'w')

if ftype=='tex':
    summo.write("\\begin{table}[htpb!]\\caption{Summary Statistics} \n"
    "\\label{TWINtab:sumstats}\\begin{center}\\begin{tabular}{lcccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{2}{c}{Low Income}&\\multicolumn{2}{c}{Middle Income}\\\\ \n" 
    "\\cmidrule(r){2-3} \\cmidrule(r){4-5}\n"
    "& Single & Twins & Single & Twins\\\\ \\midrule \n"
    "\\textsc{Fertility} & & & & \\\\ \n")
elif ftype=='csv':
    summo.write(";Low Income;;Middle Income; \n" 
    "; Single ; Twins ; Single ; Twins \n"
    "FERTILITY ; ; ; ; \n")

for i,line in enumerate(summi):
    if i>2 and i%3!=2:
        line=re.sub(r"\s+", dd, line)
        line=re.sub(r"&\((\d+.\d+)\)&$", ls+ls, line)
        line=re.sub(r"&(\d+.\d+)&$", ls+ls, line)

        line = line.replace("bord"           , "Birth Order"           )
        line = line.replace("fert"           , "Fertility"             )
        line = line.replace("idealnumkids"   , "Ideal Family Size"     )
        line = line.replace("agemay"         , "Age"                   )
        line = line.replace("educf"          , "Education"             )
        line = line.replace("height"         , "Height"                )
        line = line.replace("bmi"            , "BMI"                   )
        line = line.replace("noeduc"         , "No Education (Percent)")
        line = line.replace("educ"           , "Education (Years)"     )
        line = line.replace("school_zsc~e"   , "Education (Z-Score)"   )
        line = line.replace("infantmort~y"   , "Infant Mortality"      )
        line = line.replace("childmorta~y"   , "Child Mortality"       )

        line = line.replace("Age", 
        addL[3]+ addL[4]+"\\textsc{Mother's Characteristics}&&&&\\\\ Age\n")

        line = line.replace("Education (Years)", 
        "\\textsc{Children's Outcomes}&&&&\\\\ Education (Years)\n")

        if ftype=='csv':
            line=line.replace("\\textsc{Mother's Characteristics}&&&&\\\\ Age\n",
            'MOTHER\'S CHARACTERISTICS \n Age')
            line=line.replace("\\textsc{Children's Outcomes}&&&&\\\\ Education (Years)\n",
            'CHILDREN\'S OUTCOMES \n Education (Years)')

        summo.write(line+'\n')

summo.write(
mr +'\n'+ addL[0] + addL[1] + addL[2] + mr + "\n"
+mc1+twid[7]+tcm[7]+mc3+" Group "
"means are presented with standard deviation below in parenthesis.  Education" 
" is reported as years total attained, attendance is a binary variable "
"indicating current attendance status.  Infant mortality refers to the "
"proportion of children who die before 1 year of age, while child mortality"
" refers to the proportion who die before 5 years.  Maternal height is "
"reported in cm.  Summary statistics are for the full sample of " +nk+ 
" children.  For a full list of country and years of survey, see appendix "
"table \\ref{TWINtab:countries}.")
if ftype=='tex':
    summo.write("\\end{footnotesize}} \\\\ \\bottomrule "
    "\\end{tabular}\\end{center}\\end{table}")

summo.close()


#==============================================================================
#== (9) Create Conley et al. table
#==============================================================================
conli = open(Results2+"Conley/"+conl, 'r').readlines()
conlo = open(Tables+"Conley."+end, 'w')


if ftype=='tex':
    conlo.write("\\begin{table}[htpb!]\\caption{`Plausibly Exogenous' Bounds} \n"
    "\\label{TWINtab:Conley}\\vspace{-5mm}\\begin{center}\\begin{tabular}{lcccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{2}{c}{UCI: $\\gamma\\in [0,\\delta]$}"
    "&\\multicolumn{2}{c}{LTZ: $\\gamma \\sim U(0,\\delta)$}\\\\ \n" 
    "\\cmidrule(r){2-3} \\cmidrule(r){4-5}\n")
elif ftype=='csv':
    conlo.write("UCI:;gamma in [0,delta];LTZ:;gamma ~ U(0,delta) \n")

for i,line in enumerate(conli):
    if i<5:
        line = re.sub('\s+', dd, line) 
        line = re.sub('&$', ls+ls, line)
        line = line.replace('Plus', ' Plus')
        line = line.replace('Bound', ' Bound')
        conlo.write(line + "\n")
    if i==5:
        delta = line.replace('deltas', '')
        delta = re.sub('\s+', ', ', delta) 
        delta = re.sub(', $', '.', delta)
        delta = re.sub('^,', ' ', delta)

conlo.write(mr+mc1+twid[3]+tcm[3]+mc3+
"This table presents upper and lower bounds of a 95\\% confidence interval "
"for the effects of family size on (standardised) children's education "
"attainment. These are estimated by the methodology of "
"\\citet{Conleyetal2012}  under various priors about the direct effect "
"that being from a twin family has on educational outcomes ("+mi+ "gamma"+
mo+"). In the UCI (union of confidence interval) approach, it is assumed "
"the true "+mi+"gamma\\in[0,\\delta]"+mo+", while in the LTZ (local to zero) "
"approach it is assumed that "+mi+"gamma\sim U(0,\\delta)"+mo+".  In each "
"case $\\delta$ is estimated by including twinning in the first stage  "
"equation and observing the effect size $\\hat\\gamma$.  Estimated "
"$\\hat\\gamma$'s are (respectively for two plus to five plus): "+delta)

if ftype=='tex':
    conlo.write("\\end{footnotesize}}  \n"
    "\\\\ \\bottomrule \\end{tabular}\\end{center}\\end{table} \n")


conlo.close()

#==============================================================================
#== (10) Create country list table
#==============================================================================
dhssi = open(Results2+"Summary/"+dhss, 'r').readlines()
dhsso = open(Tables+"Countries."+end, 'w')

if ftype=='tex':
    dhsso.write("\\end{spacing}\\begin{spacing}{1} \n"
    "\\begin{longtable}{llccccccc}\\caption{Full Survey Countries and Years} \\\\ \n"
    "\\toprule\\label{TWINtab:countries} \n"
    "& & \\multicolumn{7}{c}{Survey Year} \\\\ \\cmidrule(r){3-9} \n"
    "\\textsc{Country}&\\textsc{Income}&1&2&3&4&5&6&7\\\\ \\midrule \n")
elif ftype=='csv':
    dhsso.write(";;Survey Year;;;;;; \n"
    "Country;Income;1;2;3;4;5;6;7 \n")

country = "Chile"
counter=7
for i,line in enumerate(dhssi):
    countryn = re.search("\w+[ \,\'\w+]*", line).group(0)
    income = re.search('Middle|Low',line).group(0)
    if countryn!= country:
        dif=7-counter
        counter = 0
        country=countryn
        if i==0:
            dhsso.write(countryn+dd+income)
        else:
            dhsso.write(dd*dif+ls+'\n'+country+dd+income)
    year = re.search("\d+", line).group(0)
    dhsso.write(dd+year)
    counter = counter + 1

dhsso.write(ls+"\n"+mr+mc1+twid[4]+tcm[4]+mc3+
"Country income status is based upon World Bank classifications"
" described at http://data.worldbank.org/about/country-classifications "
"and available for download at "
"http://siteresources.worldbank.org/DATASTATISTICS/Resources/OGHIST.xls "
"(consulted 1 April, 2014).  Income status varies by country and time.  Where "
"a country's status changed between DHS waves only the most recent status is "
"listed above.  Middle refers to both lower-middle and upper-middle income "
"countries, while low refers just to those considered to be low-income economies.")
if ftype=='tex':
    dhsso.write("\\end{footnotesize}}  \n"
    "\\\\ \\bottomrule \\end{longtable}\\end{spacing}\\begin{spacing}{1.5}")


dhsso.close()

#==============================================================================
#== (11) Gender table
#==============================================================================
genfi = open(Results+gend[0],'r').readlines
genmi = open(Results+gend[1],'r').readlines

gendo = open(Tables+'Gender.'+end, 'w')


FB, FS, FN = plustable(Results+gend[0],1,13,"fert")
MB, MS, MN = plustable(Results+gend[1],1,13,"fert")


Ns = format(float(FN[0][0]), "n")+', '+format(float(MN[0][0]), "n")+', '
Ns = Ns + format(float(FN[0][3]),"n")+', '+format(float(MN[0][3]),"n")+', '
Ns = Ns + format(float(FN[0][8]),"n")+', '+format(float(MN[0][8]),"n")

if ftype=='tex':
    gendo.write("\\begin{table}[htpb!]\\caption{Q-Q IV Estimates by Gender} \n"
    "\\label{TWINtab:gend}\\vspace{-5mm}\\begin{center}\\begin{tabular}{lcccccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{3}{c}{Females}""&\\multicolumn{3}{c}{Males}\\\\ \n" 
    "\\cmidrule(r){2-4} \\cmidrule(r){5-7} \n" 
    "&Base&Socioec&Health&Base&Socioec&Health \\\\ \\midrule \n"+lineadd)
elif ftype=='csv':
    gendo.write(";Females;;;Males;; \n"  
    ";Base;Socioec;Health;Base;Socioec;Health \n")


gendo.write("Two Plus "+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+dd
+MB[0][0]+dd+MB[0][1]+dd+MB[0][2]+ls+'\n'
+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd
+MS[0][0]+dd+MS[0][1]+dd+MS[0][2]+ls+'\n' + lineadd +
"Three Plus "+dd+FB[0][3]+dd+FB[0][4]+dd+FB[0][5]+dd
+MB[0][3]+dd+MB[0][4]+dd+MB[0][5]+ls+'\n'
+dd+FS[0][3]+dd+FS[0][4]+dd+FS[0][5]+dd
+MS[0][3]+dd+MS[0][4]+dd+MS[0][5]+ls+'\n'+ lineadd +
"Four Plus "+dd+FB[0][6]+dd+FB[0][7]+dd+FB[0][8]+dd
+MB[0][6]+dd+MB[0][7]+dd+MB[0][8]+ls+'\n'
+dd+FS[0][6]+dd+FS[0][7]+dd+FS[0][8]+dd
+MS[0][6]+dd+MS[0][7]+dd+MS[0][8]+ls+'\n'
#+ lineadd +
#"Five Plus &"+FB[0][9]+'&'+FB[0][10]+'&'+FB[0][11]+'&'
#+MB[0][9]+'&'+MB[0][10]+'&'+MB[0][11]+'\\\\ \n'
#"&"+FS[0][9]+'&'+FS[0][10]+'&'+FS[0][11]+'&'
#+MS[0][9]+'&'+MS[0][10]+'&'+MS[0][11]+'\\\\ \n' 
+mr+mc1+twid[5]+tcm[5]+mc3+
"Female or male refers to the gender of the index child of the regression. \n"
"Sample sizes are, respectively "+Ns+ " for female and male two plus, F and M \n"
"three plus and F and M four plus groups.  Additional controls are listed in \n"
"the notes to table \\ref{TWINtab:IVTwoplus}.  Standard errors are clustered \n"
"by mother."+foot+"\n")
if ftype=='tex':
    gendo.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")

gendo.close()


#==============================================================================
#== (12) IMR Test table
#==============================================================================
imrti = open(Results2+"New/"+imrt, 'r').readlines()
imrto = open(Tables+"IMRtest."+end, 'w')

if ftype=='tex':
    imrto.write("\\begin{table}[htpb!]\\caption{IMR Test} \n"
    "\\label{TWINtab:IMR}\\vspace{-5mm}\\begin{center}\\begin{tabular}{lccc}\n"
    "\\toprule \\toprule \n"
    "\\textsc{IMR}& Base & +S\\&H & Observations \\\\ \\midrule \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}& \n"
    "\\begin{footnotesize}\\end{footnotesize}\\\\ \n")
elif ftype=='csv':
    imrto.write("IMR; Base ; +S&H ; Observations \n")
for i,line in enumerate(imrti):
    if re.match("treated", line):
        index=i
    if re.match("N", line):
        ind2=i


betas = imrti[index].split()
ses   = imrti[index+1].split()
Ns    = imrti[ind2].split()

imrto.write('Treated (2+)'+dd+betas[1]+dd+betas[3]+dd+Ns[2]+ls+'\n'
+dd+ses[0]+dd+ses[2]+dd+ls+'\n'
'Treated (3+)'+hs+dd+betas[4]+dd+betas[6]+dd+Ns[4]+ls+'\n'
+dd+ses[3]+dd+ses[5]+dd+ls+'\n'
'Treated (4+)'+dd+betas[7]+dd+betas[9]+dd+Ns[7]+ls+'\n'
+dd+ses[6]+dd+ses[8]+dd+ls+'\n'
'Treated (5+)'+dd+betas[10]+dd+betas[12]+dd+Ns[10]+ls+'\n'
+dd+ses[9]+dd+ses[11]+dd+ls+
'\n'+mr+mc1+twid[6]+tcm[6]+mc3+
foot+" \n")
if ftype=='tex':
    imrto.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")


#==============================================================================
#== (14) First stage table
#==============================================================================
fstao = open(Tables+"firstStage."+end, 'w')

os.chdir(Results)

if ftype=='tex':
    fstao.write("\\begin{table}[htpb!]"
    "\\caption{First Stage Results} \n\\label{TWINtab:FS}\\vspace{-5mm}"
    "\\begin{center}\\begin{tabular}{lccccc}\n\\toprule \\toprule \n"
    "\\textsc{Fertility}& Pre-Twins & +bord & Low-Income & Mid-Income &Twin+Pre"
    "\\\\ \\midrule \n"
    +"\\begin{footnotesize}\\end{footnotesize}& \n"*5+
    "\\begin{footnotesize}\\end{footnotesize}\\\\ \n")
elif ftype=='csv':
    fstao.write("FERTILITY;Pre-Twins;+bord;Low-Income;Mid-Income;Twin+Pre \n")


for num in ['two','three','four']:
    searcher='twin\_'+num+'\_fam'
    title = num.title()+'-Plus'

    FSB, FSS, FSN    = plustable(firs, 1, 4,searcher)
    FBB, FBS, FBN    = plustable(fbor, 1, 4,searcher)
    FLB, FLS, FLN    = plustable(flow, 1, 4,searcher)
    FMB, FMS, FMN    = plustable(fmid, 1, 4,searcher)
    FTB, FTS, FTN    = plustable(ftwi, 1, 4,searcher)


    fstao.write(tsc+title+ebr+dd*5+ls+"\n"
    "Base"+dd+FSB[0][0]+dd+FBB[0][0]+dd+FLB[0][0]+dd+FMB[0][0]+dd+FTB[0][0]+ls+"\n"
    +dd1+FSS[0][0]+dd2+FBS[0][0]+dd2+FLS[0][0]+dd2+FMS[0][0]+dd2+FTS[0][0]+dd3+ls+"\n"
    "+S"+dd+FSB[0][1]+dd+FBB[0][1]+dd+FLB[0][1]+dd+FMB[0][1]+dd+FTB[0][1]+ls+"\n"
    +dd+FSS[0][1]+dd+FBS[0][1]+dd+FLS[0][1]+dd+FMS[0][1]+dd+FTS[0][1]+ls+"\n"
    "+S\\&H"+dd+FSB[0][2]+dd+FBB[0][2]+dd+FLB[0][2]+dd+FMB[0][2]+dd+FTB[0][2]+ls+"\n"
    +dd+FSS[0][2]+dd+FBS[0][2]+dd+FLS[0][2]+dd+FMS[0][2]+dd+FTS[0][2]+ls+"\n")

fstao.write('\n'+mr+mc1+twid[8]+tcm[8]+mc3+foot+" \n")
if ftype=='tex':
    fstao.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")

print "Terminated Correctly."
