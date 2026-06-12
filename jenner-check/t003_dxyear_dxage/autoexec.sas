/* jenner-check bundle autoexec.
   Mock CDM "indata" library standing in for the site's C:\CDM_folder\.
   The mock TUMOR table carries DATE_OF_DIAGNOSIS_N390 (NAACCR yyyymmdd, char)
   and AGE_AT_DIAGNOSIS_N230 (char) across a span of diagnosis years so the
   repo's diagnosis-year distribution and diagnosis-age summary run for real.
   Values are synthetic but realistic (incl. one 999 unknown-age sentinel). */
options obs=100;
libname indata '.';

data indata.TUMOR;
    length DATE_OF_DIAGNOSIS_N390 $8 AGE_AT_DIAGNOSIS_N230 $3 PRIMARY_SITE_N400 $4;
    input DATE_OF_DIAGNOSIS_N390 $ AGE_AT_DIAGNOSIS_N230 $ PRIMARY_SITE_N400 $;
    datalines;
20080115 071 C509
20100620 058 C619
20120311 063 C504
20140702 045 C341
20150918 067 C509
20160405 072 C619
20170822 055 C504
20180226 049 C509
20190312 061 C341
20200705 074 C619
20210101 038 C504
20211015 067 C509
20220330 999 C341
20230610 052 C619
20240219 069 C504
;
run;
