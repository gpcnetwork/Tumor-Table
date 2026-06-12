/* Source: scr/TUMOR TABLE QC SCRIPT.sas (GPC Tumor-Table).
   Derived diagnosis-year / diagnosis-age QC, verbatim: dxyear is parsed from
   DATE_OF_DIAGNOSIS_N390, dxage from AGE_AT_DIAGNOSIS_N230 (999 -> missing),
   then the diagnosis-year distribution (PROC FREQ with the repo's dxyear_f
   format) and a diagnosis-age summary (PROC MEANS) are produced. Runs against
   the mock indata.TUMOR from autoexec. */

proc format;
	value	dxyear_f		. = 'Missing'
							LOW - 2009 = '<=2009' 2010 = '2010'
                                                        2011 = '2011' 2012 = '2012' 2013 = '2013'
                                                        2014 = '2014' 2015 = '2015' 2016 = '2016'
                                                        2017 = '2017' 2018 = '2018' 2019 = '2019'
                                                        2020 = '2020' 2021 = '2021' 2022 = '2022'
                                                        2023 - HIGH = '>=2023'
							;
run;

*create derived variables;
data tumor01; set indata.TUMOR;
	dxyear = input(substr(DATE_OF_DIAGNOSIS_N390,1,4),4.);

	dxage = input(AGE_AT_DIAGNOSIS_N230,3.);
	if dxage = 999 then dxage = .;
run;

*anomaly expected in 2014 with affordable care act;
title1 'Distribution of diagnosis years';
proc freq data = tumor01 noprint;
	format dxyear dxyear_f.;
	table dxyear/missing out=work.dxyear_dist;

title1 'Distribution of diagnosis years';
proc print data = work.dxyear_dist noobs label;
	label dxyear = 'Diagnosis Year' count = 'Records' percent = 'Percent';
	format dxyear dxyear_f.;
	var dxyear count percent;
run;

***********;

title1 'Diagnosis age';
proc means data = tumor01 n min p25 p50 p75 max mean std maxdec=1 noprint;
	var dxage;
	output out=work.dxage_means N = N min = min p25 = lowerq p50=median p75 = upperq max = max mean=mean std=std nmiss=nmiss;

title1 'Diagnosis age summary';
proc print data = work.dxage_means noobs; run;
