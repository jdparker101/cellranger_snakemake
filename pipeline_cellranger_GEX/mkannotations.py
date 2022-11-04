import os
import re
import itertools
SampleSheet=open("raw_data_download_GEX/SampleSheet.csv")
annout=open("annotations.csv","w")
annout.write("Lane,Sample,Index\n")
for sampleline in SampleSheet:
    if len(sampleline.split(",")) > 5 and "BN" in sampleline.split(",")[0]:
        sample_id=sampleline.split(",")[0]
        barcode=sampleline.split(",")[3]
        for indexline in open("Dual_Index_Kit_TT-Set_A_asap.csv"):
            if barcode in indexline:
                indexcode=indexline.split(",")[0]
        tmpline=('*',sample_id,indexcode+"\n")
        fnlline=",".join(tmpline)
        annout.write(fnlline)
   
