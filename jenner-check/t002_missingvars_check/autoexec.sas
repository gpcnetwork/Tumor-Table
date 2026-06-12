/* jenner-check bundle autoexec.
   Builds a mock CDM "indata" library standing in for the site's C:\CDM_folder\.
   The mock TUMOR table carries a realistic subset of NAACCR priority column NAMES
   so the repo's variable-presence QC (merge of the spec against PROC CONTENTS)
   runs for real. Column contents are synthetic; only the column shape drives
   this check. Some priority columns are intentionally omitted (to surface as
   "missing") and one site-local column is present but unspecified ("extra"). */
options obs=100;
libname indata '.';

data indata.TUMOR;
    length PATID $16
           TUMOR_RECORD_NUMBER_N60 $2
           SEX_N220 $1 AGE_AT_DIAGNOSIS_N230 $3
           SPANISH_HISPANIC_ORIGIN_N190 $1
           RACE1_N160 $2
           DATE_OF_DIAGNOSIS_N390 $8 PRIMARY_SITE_N400 $4
           LATERALITY_N410 $1
           HISTOLOGIC_TYPE_ICD_O3_N522 $4
           BEHAVIOR_CODE_ICD_O3_N523 $1
           SEQUENCE_NUMBER_HOSPITA_N560 $2
           SITE_SPECIFIC_LOCAL_FIELD $10 ;
    input PATID $ TUMOR_RECORD_NUMBER_N60 $ SEX_N220 $ AGE_AT_DIAGNOSIS_N230 $
          SPANISH_HISPANIC_ORIGIN_N190 $ RACE1_N160 $
          DATE_OF_DIAGNOSIS_N390 $ PRIMARY_SITE_N400 $ LATERALITY_N410 $
          HISTOLOGIC_TYPE_ICD_O3_N522 $ BEHAVIOR_CODE_ICD_O3_N523 $
          SEQUENCE_NUMBER_HOSPITA_N560 $ SITE_SPECIFIC_LOCAL_FIELD $;
    datalines;
P0001 01 2 061 0 01 20190312 C509 1 8500 3 00 localA
P0002 01 1 058 1 02 20171120 C619 0 8140 3 00 localB
P0003 02 2 072 6 01 20200705 C504 2 8520 2 01 localC
P0004 01 1 045 0 03 20180226 C341 1 8070 3 00 localD
P0005 01 2 067 4 01 20211015 C509 1 8500 3 00 localE
;
run;
