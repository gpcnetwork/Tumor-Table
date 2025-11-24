
/*****************************************************************************
 *  pcornet tumor table v2025 qc.sas
 *  Bradley McDowell, University of Iowa
 *  Christie Spinka, University of Missouri
 *
 * 
 *  Input: tumor table, Version 2025, and encounter table, Version 7.0
 *
 *  Assumptions: The tumor table must be located in the same folder as 
 *  the other CDM tables.
 *
 *  Known issue: There must be a range of diagnosis years that are 2017 or 
 *  earlier and other that are 2018 or later.
 *
 *
 *****************************************************************************/


/******** USER INPUTS ********/

*Edit DMID and Site ID;
%LET DMID = ;
%LET SITEID = ;

%LET ttable = tumor_v2025; *name of Version 2025 of table;


/********** FOLDER CONTAINING INPUT DATA FILES AND CDM DATA **************************************
* IMPORTANT NOTE: end of path separators are needed;                                             
*   Windows-based platforms:    "\", e.g. "C:\user\sas\" and not "C:\user\sas";                  
*   Unix-based platforms:      "/", e.g."/home/user/sas/" and not "/home/user/sas";              
*                                                                                                
********** FOLDER CONTAINING INPUT DATA FILES AND CDM DATA ***************************************/

/*Data in CDM Format where tumor table resides*/
libname indata 'C:\CDM_folder\';

/********** FOLDER CONTAINING FILES TO BE EXPORTED*/;
/*Output Files*/	
%LET outputpath = C:\output_path\; *do not enclose path in quotes;

*There are two NAACCR numbers that indicate sequence of the tumor. Most hospital registries
 use sequenceNumberHospital, but some use the central sequence number (NAACCR #380. This script
 defaults to the former, but analysts should make sure it is populated before running this
 program. If it is not, check to see whether sequenceNumberCentral is appropriate to use;
%LET SEQNUM = sequenceNumberHospital; *default;



********************************************************************;
********** END OF USER INPUTS **************************************;
********************************************************************;

options mprint;

/************************************************************

 CHECK THAT THE FACILITY VARIABLE IS PRESENT AND POPULATED

 ************************************************************/
%macro testfacility;

data _null_;
	call symputx('VAR_EXISTS', '0');
	call symputx('NONMISS_COUNT', '0');

    dsid = open("indata.&ttable");

	if (dsid > 0) then
   		/* Check if the FACILITY variable exists:
		VARNUM returns the variable number (non-zero) or 0 */
   		if (varnum(dsid, "FACILITY") > 0) then
			do;
				call symputx('VAR_EXISTS', '1');
			end;
	dsid = close(dsid);
run;

%if &VAR_EXISTS = 0 %then
	%do;
		%put %str(***************  ERROR  ******************);
		%put %str(FACILITY variable not found in tumor table);
		%put %str(******************************************);
		%abort cancel;
	%end;
%else %if &VAR_EXISTS = 1 %then
	%do;
		/* Use PROC SQL to count non-missing values  */
		proc sql noprint;
			select count(a.FACILITY) into :NONMISS_COUNT trimmed
           	from indata.&ttable as a;
		quit;

		%if &NONMISS_COUNT = 0 %then
			%do;
				%put %str(***********************  ERROR  ****************************);
				%put %str(FACILITY variable is in tumor table, but it is not populated);
				%put %str(************************************************************);
				%abort cancel;
			%end;
    %end;

%mend;

%testfacility;

********************************************************************;

data ttvariables;
	length naaccrnum $4. variable $32 flag $8. timing $1.;
	input naaccrnum$ variable$ flag$ timing$;
	datalines;
00      PATID                                 NORMAL         1
00      FACILITY                              NORMAL         1
10      RECORDTYPE                            NORMAL         1
20      PATIENTIDNUMBER                       PRIVATE        1
21      PATIENTSYSTEMIDHOSP                   PRIVATE        1
30      REGISTRYTYPE                          NORMAL         1
40      REGISTRYID                            PRIVATE        1
45      NPIREGISTRYID                         PRIVATE        1
50      NAACCRRECORDVERSION                   NORMAL         1
60      TUMORRECORDNUMBER                     NORMAL         1
70      ADDRATDXCITY                          PRIVATE        1
80      ADDRATDXSTATE                         NORMAL         1
81      STATEATDXGEOCODE19708090              NORMAL         1
82      STATEATDXGEOCODE2000                  NORMAL         1
83      STATEATDXGEOCODE2010                  NORMAL         1
84      STATEATDXGEOCODE2020                  NORMAL         1
86      GEOCODINGQUALITYCODE                  NORMAL         1
87      GEOCODINGQUALITYCODEDETAIL            NORMAL         1
89      COUNTYATDXANALYSIS                    PRIVATE        1
90      COUNTYATDX                            PRIVATE        1
94      COUNTYATDXGEOCODE1990                 PRIVATE        1
95      COUNTYATDXGEOCODE2000                 PRIVATE        1
96      COUNTYATDXGEOCODE2010                 PRIVATE        1
97      COUNTYATDXGEOCODE2020                 PRIVATE        1
100     ADDRATDXPOSTALCODE                    PRIVATE        1
102     ADDRATDXCOUNTRY                       NORMAL         1
110     CENSUSTRACT19708090                   PRIVATE        1
120     CENSUSCODSYS19708090                  NORMAL         1
125     CENSUSTRACT2020                       PRIVATE        1
130     CENSUSTRACT2000                       PRIVATE        1
135     CENSUSTRACT2010                       PRIVATE        1
145     CENSUSTRPOVERTYINDICTR                NORMAL         1
150     MARITALSTATUSATDX                     CORE           1
160     RACE1                                 CORE           1
161     RACE2                                 NORMAL         1
162     RACE3                                 NORMAL         1
163     RACE4                                 NORMAL         1
164     RACE5                                 NORMAL         1
190     SPANISHHISPANICORIGIN                 CORE           1
191     NHIADERIVEDHISPORIGIN                 NORMAL         1
192     IHSLINK                               NORMAL         1
193     RACENAPIIA                            NORMAL         1
194     IHSPURCHREFCAREDELIVERYAREA           NORMAL         1
200     COMPUTEDETHNICITY                     NORMAL         1
210     COMPUTEDETHNICITYSOURCE               NORMAL         1
220     SEX                                   CORE           1
230     AGEATDIAGNOSIS                        CORE           1
240     DATEOFBIRTH                           NORMAL         1
252     BIRTHPLACESTATE                       NORMAL         1
254     BIRTHPLACECOUNTRY                     NORMAL         1
272     CENSUSINDCODE2010                     NORMAL         1
282     CENSUSOCCCODE2010                     NORMAL         1
284     URBANINDIANHEALTHORGANIZATION         NORMAL         1
285     UIHOFACILITY                          NORMAL         1
290     OCCUPATIONSOURCE                      NORMAL         1
300     INDUSTRYSOURCE                        NORMAL         1
310     TEXTUSUALOCCUPATION                   PRIVATE        1
320     TEXTUSUALINDUSTRY                     PRIVATE        1
339     RUCA2000                              NORMAL         1
341     RUCA2010                              NORMAL         1
344     TOBACCOUSESMOKINGSTATUS               NORMAL         1
345     URIC2000                              NORMAL         1
346     URIC2010                              NORMAL         1
361     CENSUSBLOCKGROUP2020                  PRIVATE        1
362     CENSUSBLOCKGROUP2000                  PRIVATE        1
363     CENSUSBLOCKGROUP2010                  PRIVATE        1
364     CENSUSTRCERT19708090                  NORMAL         1
365     CENSUSTRCERTAINTY2000                 NORMAL         1
366     GISCOORDINATEQUALITY                  NORMAL         1
367     CENSUSTRCERTAINTY2010                 NORMAL         1
368     CENSUSBLOCKGRP197090                  PRIVATE        1
369     CENSUSTRACTCERTAINTY2020              NORMAL         1
380     SEQUENCENUMBERCENTRAL                 CORE           1
390     DATEOFDIAGNOSIS                       CORE           1
400     PRIMARYSITE                           CORE           1
410     LATERALITY                            CORE           1
420     HISTOLOGYICDO2                        NORMAL         1
430     BEHAVIORICDO2                         NORMAL         1
440     GRADE                                 NORMAL         1
441     GRADEPATHVALUE                        NORMAL         1
442     AMBIGUOUSTERMINOLOGYDX                NORMAL         1
443     DATECONCLUSIVEDX                      NORMAL         1
444     MULTTUMRPTASONEPRIM                   NORMAL         1
445     DATEOFMULTTUMORS                      NORMAL         1
446     MULTIPLICITYCOUNTER                   NORMAL         1
449     GRADEPATHSYSTEM                       NORMAL         1
450     SITECODINGSYSCURRENT                  NORMAL         1
460     SITECODINGSYSORIGINAL                 NORMAL         1
470     MORPHCODINGSYSCURRENT                 NORMAL         1
480     MORPHCODINGSYSORIGINL                 NORMAL         1
490     DIAGNOSTICCONFIRMATION                NORMAL         1
500     TYPEOFREPORTINGSOURCE                 NORMAL         1
501     CASEFINDINGSOURCE                     NORMAL         1
522     HISTOLOGICTYPEICDO3                   CORE           1
523     BEHAVIORCODEICDO3                     CORE           1
530     EDPMDELINKDATE                        NORMAL         1
531     EDPMDELINK                            NORMAL         1
540     REPORTINGFACILITY                     PRIVATE        1
545     NPIREPORTINGFACILITY                  PRIVATE        1
550     ACCESSIONNUMBERHOSP                   PRIVATE        1
560     SEQUENCENUMBERHOSPITAL                CORE           1
570     ABSTRACTEDBY                          NORMAL         1
580     DATEOF1STCONTACT                      NORMAL         1
590     DATEOFINPTADM                         NORMAL         1
600     DATEOFINPTDISCH                       NORMAL         1
610     CLASSOFCASE                           CORE           1
630     PRIMARYPAYERATDX                      NORMAL         1
668     RXHOSPSURGAPP2010                     NORMAL         1
670     RXHOSPSURGPRIMSITE                    NORMAL         1
671     RXHOSPSURGPRIMSITE2023                NORMAL         1
672     RXHOSPSCOPEREGLNSUR                   NORMAL         1
674     RXHOSPSURGOTHREGDIS                   NORMAL         1
676     RXHOSPREGLNREMOVED                    NORMAL         1
682     DATEREGIONALLNDISSECTION              NORMAL         1
690     RXHOSPRADIATION                       NORMAL         1
700     RXHOSPCHEMO                           NORMAL         1
710     RXHOSPHORMONE                         NORMAL         1
720     RXHOSPBRM                             NORMAL         1
730     RXHOSPOTHER                           NORMAL         1
740     RXHOSPDXSTGPROC                       NORMAL         1
746     RXHOSPSURGSITE9802                    NORMAL         1
747     RXHOSPSCOPEREG9802                    NORMAL         1
748     RXHOSPSURGOTH9802                     NORMAL         1
751     RXHOSPRECONBREAST                     NORMAL         1
752     TUMORSIZECLINICAL                     NORMAL         1
754     TUMORSIZEPATHOLOGIC                   NORMAL         1
756     TUMORSIZESUMMARY                      NORMAL         1
759     SEERSUMMARYSTAGE2000                  NORMAL         1
760     SEERSUMMARYSTAGE1977                  NORMAL         1
762     DERIVEDSUMMARYSTAGE2018               NORMAL         1
764     SUMMARYSTAGE2018                      CORE           4
772     EODPRIMARYTUMOR                       NORMAL         1
774     EODREGIONALNODES                      NORMAL         1
776     EODMETS                               NORMAL         1
780     EODTUMORSIZE                          NORMAL         1
785     DERIVEDEOD2018T                       NORMAL         1
790     EODEXTENSION                          NORMAL         1
795     DERIVEDEOD2018M                       NORMAL         1
800     EODEXTENSIONPROSTPATH                 NORMAL         1
810     EODLYMPHNODEINVOLV                    NORMAL         1
815     DERIVEDEOD2018N                       NORMAL         1
818     DERIVEDEOD2018STAGEGROUP              NORMAL         1
820     REGIONALNODESPOSITIVE                 NORMAL         1
830     REGIONALNODESEXAMINED                 NORMAL         1
832     DATESENTINELLYMPHNODEBIOPSY           NORMAL         1
834     SENTINELLYMPHNODESEXAMINED            NORMAL         1
835     SENTINELLYMPHNODESPOSITIVE            NORMAL         1
840     EODOLD13DIGIT                         NORMAL         1
850     EODOLD2DIGIT                          NORMAL         1
860     EODOLD4DIGIT                          NORMAL         1
870     CODINGSYSTEMFOREOD                    NORMAL         1
880     TNMPATHT                              NORMAL         1
890     TNMPATHN                              NORMAL         1
900     TNMPATHM                              NORMAL         1
910     TNMPATHSTAGEGROUP                     CORE           3
920     TNMPATHDESCRIPTOR                     NORMAL         1
930     TNMPATHSTAGEDBY                       NORMAL         1
940     TNMCLINT                              NORMAL         1
950     TNMCLINN                              NORMAL         1
960     TNMCLINM                              NORMAL         1
970     TNMCLINSTAGEGROUP                     CORE           3
980     TNMCLINDESCRIPTOR                     NORMAL         1
990     TNMCLINSTAGEDBY                       NORMAL         1
995     AJCCID                                NORMAL         1
1001    AJCCTNMCLINT                          NORMAL         1
1002    AJCCTNMCLINN                          NORMAL         1
1003    AJCCTNMCLINM                          NORMAL         1
1004    AJCCTNMCLINSTAGEGROUP                 CORE           4
1011    AJCCTNMPATHT                          NORMAL         1
1012    AJCCTNMPATHN                          NORMAL         1
1013    AJCCTNMPATHM                          NORMAL         1
1014    AJCCTNMPATHSTAGEGROUP                 CORE           4
1021    AJCCTNMPOSTTHERAPYT                   NORMAL         1
1022    AJCCTNMPOSTTHERAPYN                   NORMAL         1
1023    AJCCTNMPOSTTHERAPYM                   NORMAL         1
1024    AJCCTNMPOSTTHERAPYSTAGEGROUP          NORMAL         1
1031    AJCCTNMCLINTSUFFIX                    NORMAL         1
1032    AJCCTNMPATHTSUFFIX                    NORMAL         1
1033    AJCCTNMPOSTTHERAPYTSUFFIX             NORMAL         1
1034    AJCCTNMCLINNSUFFIX                    NORMAL         1
1035    AJCCTNMPATHNSUFFIX                    NORMAL         1
1036    AJCCTNMPOSTTHERAPYNSUFFIX             NORMAL         1
1060    TNMEDITIONNUMBER                      NORMAL         1
1062    AJCCTNMPOSTTHERAPYCLINT               NORMAL         1
1063    AJCCTNMPOSTTHERAPYCLINTSUFFIX         NORMAL         1
1064    AJCCTNMPOSTTHERAPYCLINN               NORMAL         1
1065    AJCCTNMPOSTTHERAPYCLINNSUFFIX         NORMAL         1
1066    AJCCTNMPOSTTHERAPYCLINM               NORMAL         1
1067    AJCCTNMPOSTTHERAPYCLINSTAGEGRP        NORMAL         1
1068    GRADEPOSTTHERAPYCLIN                  NORMAL         1
1112    METSATDXBONE                          NORMAL         1
1113    METSATDXBRAIN                         NORMAL         1
1114    METSATDXDISTANTLN                     NORMAL         1
1115    METSATDXLIVER                         NORMAL         1
1116    METSATDXLUNG                          NORMAL         1
1117    METSATDXOTHER                         NORMAL         1
1120    PEDIATRICSTAGE                        NORMAL         1
1130    PEDIATRICSTAGINGSYSTEM                NORMAL         1
1132    PEDIATRICID                           NORMAL         1
1133    PEDIATRICIDVERSIONCURRENT             NORMAL         1
1134    PEDIATRICIDVERSIONORIGINAL            NORMAL         1
1135    TORONTOVERSIONNUMBER                  NORMAL         1
1136    PEDIATRICPRIMARYTUMOR                 NORMAL         1
1137    PEDIATRICREGIONALNODES                NORMAL         1
1138    PEDIATRICMETS                         NORMAL         1
1140    PEDIATRICSTAGEDBY                     NORMAL         1
1142    DERIVEDPEDIATRICT                     NORMAL         1
1143    DERIVEDPEDIATRICN                     NORMAL         1
1144    DERIVEDPEDIATRICM                     NORMAL         1
1145    DERIVEDPEDIATRICSTAGEGROUP            NORMAL         1
1146    TORONTOT                              NORMAL         1
1147    TORONTON                              NORMAL         1
1148    TORONTOM                              NORMAL         1
1149    TORONTOSTAGEGROUP                     NORMAL         1
1150    TUMORMARKER1                          NORMAL         1
1160    TUMORMARKER2                          NORMAL         1
1170    TUMORMARKER3                          NORMAL         1
1172    PTLD                                  NORMAL         1
1174    PDL1                                  NORMAL         1
1182    LYMPHVASCULARINVASION                 NORMAL         1
1184    WHITEBLOODCELLCOUNT                   NORMAL         1
1185    INRGSS                                NORMAL         1
1186    NMYCAMPLIFICATION                     NORMAL         1
1187    INPC                                  NORMAL         1
1188    IRSSSTAGEFOREYE2                      NORMAL         1
1189    CHROMOSOME16QLOSSHETEROZYGOSITY       NORMAL         1
1190    CHROMOSOME1QSTATUS                    NORMAL         1
1191    EWSR1FLI1FUSION                       NORMAL         1
1192    PRETEXTCLINICALSTAGING                NORMAL         1
1193    FOXO1GENEREARRANGEMENTS               NORMAL         1
1200    RXDATESURGERY                         NORMAL         1
1210    RXDATERADIATION                       NORMAL         1
1220    RXDATECHEMO                           NORMAL         1
1230    RXDATEHORMONE                         NORMAL         1
1240    RXDATEBRM                             NORMAL         1
1250    RXDATEOTHER                           NORMAL         1
1260    DATEINITIALRXSEER                     NORMAL         1
1270    DATE1STCRSRXCOC                       NORMAL         1
1280    RXDATEDXSTGPROC                       NORMAL         1
1285    RXSUMMTREATMENTSTATUS                 NORMAL         1
1290    RXSUMMSURGPRIMSITE                    NORMAL         1
1291    RXSUMMSURGPRIMSITE2023                NORMAL         1
1292    RXSUMMSCOPEREGLNSUR                   NORMAL         1
1294    RXSUMMSURGOTHREGDIS                   NORMAL         1
1296    RXSUMMREGLNEXAMINED                   NORMAL         1
1310    RXSUMMSURGICALAPPROCH                 NORMAL         1
1320    RXSUMMSURGICALMARGINS                 NORMAL         1
1330    RXSUMMRECONSTRUCT1ST                  NORMAL         1
1335    RXSUMMRECONBREAST                     NORMAL         1
1340    REASONFORNOSURGERY                    NORMAL         1
1350    RXSUMMDXSTGPROC                       NORMAL         1
1360    RXSUMMRADIATION                       NORMAL         1
1370    RXSUMMRADTOCNS                        NORMAL         1
1380    RXSUMMSURGRADSEQ                      NORMAL         1
1390    RXSUMMCHEMO                           NORMAL         1
1400    RXSUMMHORMONE                         NORMAL         1
1410    RXSUMMBRM                             NORMAL         1
1420    RXSUMMOTHER                           NORMAL         1
1430    REASONFORNORADIATION                  NORMAL         1
1460    RXCODINGSYSTEMCURRENT                 NORMAL         1
1501    PHASE1DOSEPERFRACTION                 NORMAL         1
1502    PHASE1RADIATIONEXTERNALBEAMTECH       NORMAL         1
1503    PHASE1NUMBEROFFRACTIONS               NORMAL         1
1504    PHASE1RADIATIONPRIMARYTXVOLUME        NORMAL         1
1505    PHASE1RADIATIONTODRAININGLN           NORMAL         1
1506    PHASE1RADIATIONTREATMENTMODALITY      NORMAL         1
1507    PHASE1TOTALDOSE                       NORMAL         1
1511    PHASE2DOSEPERFRACTION                 NORMAL         1
1512    PHASE2RADIATIONEXTERNALBEAMTECH       NORMAL         1
1513    PHASE2NUMBEROFFRACTIONS               NORMAL         1
1514    PHASE2RADIATIONPRIMARYTXVOLUME        NORMAL         1
1515    PHASE2RADIATIONTODRAININGLN           NORMAL         1
1516    PHASE2RADIATIONTREATMENTMODALITY      NORMAL         1
1517    PHASE2TOTALDOSE                       NORMAL         1
1521    PHASE3DOSEPERFRACTION                 NORMAL         1
1522    PHASE3RADIATIONEXTERNALBEAMTECH       NORMAL         1
1523    PHASE3NUMBEROFFRACTIONS               NORMAL         1
1524    PHASE3RADIATIONPRIMARYTXVOLUME        NORMAL         1
1525    PHASE3RADIATIONTODRAININGLN           NORMAL         1
1526    PHASE3RADIATIONTREATMENTMODALITY      NORMAL         1
1527    PHASE3TOTALDOSE                       NORMAL         1
1531    RADIATIONTXDISCONTINUEDEARLY          NORMAL         1
1532    NUMBERPHASESOFRADTXTOVOLUME           NORMAL         1
1533    TOTALDOSE                             NORMAL         1
1550    RADLOCATIONOFRX                       NORMAL         1
1570    RADREGIONALRXMODALITY                 NORMAL         1
1632    NEOADJUVANTTHERAPY                    NORMAL         1
1633    NEOADJUVTHERAPYCLINICALRESPONSE       NORMAL         1
1634    NEOADJUVTHERAPYTREATMENTEFFECT        NORMAL         1
1639    RXSUMMSYSTEMICSURSEQ                  NORMAL         1
1640    RXSUMMSURGERYTYPE                     NORMAL         1
1646    RXSUMMSURGSITE9802                    NORMAL         1
1647    RXSUMMSCOPEREG9802                    NORMAL         1
1648    RXSUMMSURGOTH9802                     NORMAL         1
1660    SUBSQRX2NDCOURSEDATE                  NORMAL         1
1671    SUBSQRX2NDCOURSESURG                  NORMAL         1
1672    SUBSQRX2NDCOURSERAD                   NORMAL         1
1673    SUBSQRX2NDCOURSECHEMO                 NORMAL         1
1674    SUBSQRX2NDCOURSEHORM                  NORMAL         1
1675    SUBSQRX2NDCOURSEBRM                   NORMAL         1
1676    SUBSQRX2NDCOURSEOTH                   NORMAL         1
1677    SUBSQRX2NDSCOPELNSU                   NORMAL         1
1678    SUBSQRX2NDSURGOTH                     NORMAL         1
1679    SUBSQRX2NDREGLNREM                    NORMAL         1
1680    SUBSQRX3RDCOURSEDATE                  NORMAL         1
1691    SUBSQRX3RDCOURSESURG                  NORMAL         1
1692    SUBSQRX3RDCOURSERAD                   NORMAL         1
1693    SUBSQRX3RDCOURSECHEMO                 NORMAL         1
1694    SUBSQRX3RDCOURSEHORM                  NORMAL         1
1695    SUBSQRX3RDCOURSEBRM                   NORMAL         1
1696    SUBSQRX3RDCOURSEOTH                   NORMAL         1
1697    SUBSQRX3RDSCOPELNSU                   NORMAL         1
1698    SUBSQRX3RDSURGOTH                     NORMAL         1
1699    SUBSQRX3RDREGLNREM                    NORMAL         1
1700    SUBSQRX4THCOURSEDATE                  NORMAL         1
1711    SUBSQRX4THCOURSESURG                  NORMAL         1
1712    SUBSQRX4THCOURSERAD                   NORMAL         1
1713    SUBSQRX4THCOURSECHEMO                 NORMAL         1
1714    SUBSQRX4THCOURSEHORM                  NORMAL         1
1715    SUBSQRX4THCOURSEBRM                   NORMAL         1
1716    SUBSQRX4THCOURSEOTH                   NORMAL         1
1717    SUBSQRX4THSCOPELNSU                   NORMAL         1
1718    SUBSQRX4THSURGOTH                     NORMAL         1
1719    SUBSQRX4THREGLNREM                    NORMAL         1
1750    DATEOFLASTCONTACT                     NORMAL         1
1755    DATEOFDEATHCANADA                     NORMAL         1
1760    VITALSTATUS                           NORMAL         1
1762    VITALSTATUSRECODE                     NORMAL         1
1770    CANCERSTATUS                          NORMAL         1
1772    DATEOFLASTCANCERSTATUS                NORMAL         1
1775    RECORDNUMBERRECODE                    NORMAL         1
1782    SURVDATEACTIVEFOLLOWUP                NORMAL         1
1783    SURVFLAGACTIVEFOLLOWUP                NORMAL         1
1784    SURVMOSACTIVEFOLLOWUP                 NORMAL         1
1785    SURVDATEPRESUMEDALIVE                 NORMAL         1
1786    SURVFLAGPRESUMEDALIVE                 NORMAL         1
1787    SURVMOSPRESUMEDALIVE                  NORMAL         1
1788    SURVDATEDXRECODE                      NORMAL         1
1790    FOLLOWUPSOURCE                        NORMAL         1
1791    FOLLOWUPSOURCECENTRAL                 NORMAL         1
1800    NEXTFOLLOWUPSOURCE                    NORMAL         1
1810    ADDRCURRENTCITY                       PRIVATE        1
1820    ADDRCURRENTSTATE                      NORMAL         1
1830    ADDRCURRENTPOSTALCODE                 PRIVATE        1
1832    ADDRCURRENTCOUNTRY                    NORMAL         1
1840    COUNTYCURRENT                         PRIVATE        1
1842    FOLLOWUPCONTACTCITY                   PRIVATE        1
1844    FOLLOWUPCONTACTSTATE                  NORMAL         1
1846    FOLLOWUPCONTACTPOSTAL                 PRIVATE        1
1847    FOLLOWUPCONTACTCOUNTRY                NORMAL         1
1850    UNUSUALFOLLOWUPMETHOD                 NORMAL         1
1854    NOPATIENTCONTACTFLAG                  NORMAL         1
1856    REPORTINGFACILITYRESTRICTIONFLAG      NORMAL         1
1860    RECURRENCEDATE1ST                     NORMAL         1
1880    RECURRENCETYPE1ST                     NORMAL         1
1910    CAUSEOFDEATH                          NORMAL         1
1914    SEERCAUSESPECIFICCOD                  NORMAL         1
1915    SEEROTHERCOD                          NORMAL         1
1920    ICDREVISIONNUMBER                     NORMAL         1
1930    AUTOPSY                               NORMAL         1
1942    PLACEOFDEATHSTATE                     NORMAL         1
1944    PLACEOFDEATHCOUNTRY                   NORMAL         1
1960    SITEICDO1                             NORMAL         1
1971    HISTOLOGYICDO1                        NORMAL         1
1972    BEHAVIORICDO1                         NORMAL         1
1973    GRADEICDO1                            NORMAL         1
1975    DERIVEDSUMMARYGRADE2018               NORMAL         1
1981    OVERRIDESSNODESPOS                    NORMAL         1
1982    OVERRIDESSTNMN                        NORMAL         1
1983    OVERRIDESSTNMM                        NORMAL         1
1985    OVERRIDEACSNCLASSSEQ                  NORMAL         1
1986    OVERRIDEHOSPSEQDXCONF                 NORMAL         1
1987    OVERRIDECOCSITETYPE                   NORMAL         1
1988    OVERRIDEHOSPSEQSITE                   NORMAL         1
1989    OVERRIDESITETNMSTGGRP                 NORMAL         1
1990    OVERRIDEAGESITEMORPH                  NORMAL         1
1992    OVERRIDETNMSTAGE                      NORMAL         1
1993    OVERRIDETNMTIS                        NORMAL         1
1994    OVERRIDETNM3                          NORMAL         1
2000    OVERRIDESEQNODXCONF                   NORMAL         1
2010    OVERRIDESITELATSEQNO                  NORMAL         1
2020    OVERRIDESURGDXCONF                    NORMAL         1
2030    OVERRIDESITETYPE                      NORMAL         1
2040    OVERRIDEHISTOLOGY                     NORMAL         1
2050    OVERRIDEREPORTSOURCE                  NORMAL         1
2060    OVERRIDEILLDEFINESITE                 NORMAL         1
2070    OVERRIDELEUKLYMPHOMA                  NORMAL         1
2071    OVERRIDESITEBEHAVIOR                  NORMAL         1
2072    OVERRIDESITEEODDXDT                   NORMAL         1
2073    OVERRIDESITELATEOD                    NORMAL         1
2074    OVERRIDESITELATMORPH                  NORMAL         1
2078    OVERRIDENAMESEX                       NORMAL         1
2085    DATECASEINITIATED                     NORMAL         1
2090    DATECASECOMPLETED                     NORMAL         1
2092    DATECASECOMPLETEDCOC                  NORMAL         1
2100    DATECASELASTCHANGED                   NORMAL         1
2110    DATECASEREPORTEXPORTED                NORMAL         1
2111    DATECASEREPORTRECEIVED                NORMAL         1
2112    DATECASEREPORTLOADED                  NORMAL         1
2113    DATETUMORRECORDAVAILBL                NORMAL         1
2116    ICDO3CONVERSIONFLAG                   NORMAL         1
2117    SCHEMAIDVERSIONCURRENT                NORMAL         1
2118    SCHEMAIDVERSIONORIGINAL               NORMAL         1
2140    COCCODINGSYSCURRENT                   NORMAL         1
2150    COCCODINGSYSORIGINAL                  NORMAL         1
2152    COCACCREDITEDFLAG                     NORMAL         1
2156    AJCCAPIVERSIONCURRENT                 NORMAL         1
2157    AJCCAPIVERSIONORIGINAL                NORMAL         1
2158    AJCCCANCERSURVAPIVERSIONCURRENT       NORMAL         1
2159    AJCCCANCERSURVAPIVERSIONORIGINAL      NORMAL         1
2170    VENDORNAME                            NORMAL         1
2230    NAMELAST                              PRIVATE        1
2232    NAMEBIRTHSURNAME                      NORMAL         1
2240    NAMEFIRST                             PRIVATE        1
2250    NAMEMIDDLE                            PRIVATE        1
2260    NAMEPREFIX                            PRIVATE        1
2270    NAMESUFFIX                            PRIVATE        1
2280    NAMEALIAS                             PRIVATE        1
2290    NAMESPOUSEPARENT                      PRIVATE        1
2300    MEDICALRECORDNUMBER                   PRIVATE        1
2315    MEDICAREBENEFICIARYIDENTIFIER         PRIVATE        1
2320    SOCIALSECURITYNUMBER                  PRIVATE        1
2330    ADDRATDXNOSTREET                      PRIVATE        1
2335    ADDRATDXSUPPLEMENTL                   PRIVATE        1
2350    ADDRCURRENTNOSTREET                   PRIVATE        1
2352    LATITUDE                              PRIVATE        1
2354    LONGITUDE                             PRIVATE        1
2355    ADDRCURRENTSUPPLEMENTL                PRIVATE        1
2360    TELEPHONE                             PRIVATE        1
2380    DCSTATEFILENUMBER                     PRIVATE        1
2392    FOLLOWUPCONTACTNOST                   PRIVATE        1
2393    FOLLOWUPCONTACTSUPPL                  PRIVATE        1
2394    FOLLOWUPCONTACTNAME                   PRIVATE        1
2410    INSTITUTIONREFERREDFROM               PRIVATE        1
2415    NPIINSTREFERREDFROM                   PRIVATE        1
2420    INSTITUTIONREFERREDTO                 PRIVATE        1
2425    NPIINSTREFERREDTO                     PRIVATE        1
2440    FOLLOWINGREGISTRY                     PRIVATE        1
2445    NPIFOLLOWINGREGISTRY                  PRIVATE        1
2460    PHYSICIANMANAGING                     PRIVATE        1
2465    NPIPHYSICIANMANAGING                  PRIVATE        1
2470    PHYSICIANFOLLOWUP                     PRIVATE        1
2475    NPIPHYSICIANFOLLOWUP                  PRIVATE        1
2480    PHYSICIANPRIMARYSURG                  PRIVATE        1
2485    NPIPHYSICIANPRIMARYSURG               PRIVATE        1
2490    PHYSICIAN3                            PRIVATE        1
2495    NPIPHYSICIAN3                         PRIVATE        1
2500    PHYSICIAN4                            PRIVATE        1
2505    NPIPHYSICIAN4                         PRIVATE        1
2508    EHRREPORTING                          PRIVATE        1
2520    TEXTDXPROCPE                          PRIVATE        1
2530    TEXTDXPROCXRAYSCAN                    PRIVATE        1
2540    TEXTDXPROCSCOPES                      PRIVATE        1
2550    TEXTDXPROCLABTESTS                    PRIVATE        1
2560    TEXTDXPROCOP                          PRIVATE        1
2570    TEXTDXPROCPATH                        PRIVATE        1
2580    TEXTPRIMARYSITETITLE                  PRIVATE        1
2590    TEXTHISTOLOGYTITLE                    PRIVATE        1
2600    TEXTSTAGING                           PRIVATE        1
2610    RXTEXTSURGERY                         PRIVATE        1
2620    RXTEXTRADIATION                       PRIVATE        1
2630    RXTEXTRADIATIONOTHER                  PRIVATE        1
2640    RXTEXTCHEMO                           PRIVATE        1
2650    RXTEXTHORMONE                         PRIVATE        1
2660    RXTEXTBRM                             PRIVATE        1
2670    RXTEXTOTHER                           PRIVATE        1
2680    TEXTREMARKS                           PRIVATE        1
2690    TEXTPLACEOFDIAGNOSIS                  PRIVATE        1
2800    CSTUMORSIZE                           NORMAL         1
2810    CSEXTENSION                           NORMAL         1
2820    CSTUMORSIZEEXTEVAL                    NORMAL         1
2830    CSLYMPHNODES                          NORMAL         1
2840    CSLYMPHNODESEVAL                      NORMAL         1
2850    CSMETSATDX                            NORMAL         1
2851    CSMETSATDXBONE                        NORMAL         1
2852    CSMETSATDXBRAIN                       NORMAL         1
2853    CSMETSATDXLIVER                       NORMAL         1
2854    CSMETSATDXLUNG                        NORMAL         1
2860    CSMETSEVAL                            NORMAL         1
2861    CSSITESPECIFICFACTOR7                 NORMAL         1
2862    CSSITESPECIFICFACTOR8                 NORMAL         1
2863    CSSITESPECIFICFACTOR9                 NORMAL         1
2864    CSSITESPECIFICFACTOR10                NORMAL         1
2865    CSSITESPECIFICFACTOR11                NORMAL         1
2866    CSSITESPECIFICFACTOR12                NORMAL         1
2867    CSSITESPECIFICFACTOR13                NORMAL         1
2868    CSSITESPECIFICFACTOR14                NORMAL         1
2869    CSSITESPECIFICFACTOR15                NORMAL         1
2870    CSSITESPECIFICFACTOR16                NORMAL         1
2871    CSSITESPECIFICFACTOR17                NORMAL         1
2872    CSSITESPECIFICFACTOR18                NORMAL         1
2873    CSSITESPECIFICFACTOR19                NORMAL         1
2874    CSSITESPECIFICFACTOR20                NORMAL         1
2875    CSSITESPECIFICFACTOR21                NORMAL         1
2876    CSSITESPECIFICFACTOR22                NORMAL         1
2877    CSSITESPECIFICFACTOR23                NORMAL         1
2878    CSSITESPECIFICFACTOR24                NORMAL         1
2879    CSSITESPECIFICFACTOR25                NORMAL         1
2880    CSSITESPECIFICFACTOR1                 NORMAL         1
2890    CSSITESPECIFICFACTOR2                 NORMAL         1
2900    CSSITESPECIFICFACTOR3                 NORMAL         1
2910    CSSITESPECIFICFACTOR4                 NORMAL         1
2920    CSSITESPECIFICFACTOR5                 NORMAL         1
2930    CSSITESPECIFICFACTOR6                 NORMAL         1
2935    CSVERSIONINPUTORIGINAL                NORMAL         1
2936    CSVERSIONDERIVED                      NORMAL         1
2937    CSVERSIONINPUTCURRENT                 NORMAL         1
2940    DERIVEDAJCC6T                         NORMAL         1
2950    DERIVEDAJCC6TDESCRIPT                 NORMAL         1
2960    DERIVEDAJCC6N                         NORMAL         1
2970    DERIVEDAJCC6NDESCRIPT                 NORMAL         1
2980    DERIVEDAJCC6M                         NORMAL         1
2990    DERIVEDAJCC6MDESCRIPT                 NORMAL         1
3000    DERIVEDAJCC6STAGEGRP                  NORMAL         1
3010    DERIVEDSS1977                         NORMAL         1
3020    DERIVEDSS2000                         NORMAL         1
3030    DERIVEDAJCCFLAG                       NORMAL         1
3040    DERIVEDSS1977FLAG                     NORMAL         1
3050    DERIVEDSS2000FLAG                     NORMAL         1
3100    ARCHIVEFIN                            PRIVATE        1
3105    NPIARCHIVEFIN                         PRIVATE        1
3110    COMORBIDCOMPLICATION1                 NORMAL         1
3120    COMORBIDCOMPLICATION2                 NORMAL         1
3130    COMORBIDCOMPLICATION3                 NORMAL         1
3140    COMORBIDCOMPLICATION4                 NORMAL         1
3150    COMORBIDCOMPLICATION5                 NORMAL         1
3160    COMORBIDCOMPLICATION6                 NORMAL         1
3161    COMORBIDCOMPLICATION7                 NORMAL         1
3162    COMORBIDCOMPLICATION8                 NORMAL         1
3163    COMORBIDCOMPLICATION9                 NORMAL         1
3164    COMORBIDCOMPLICATION10                NORMAL         1
3165    ICDREVISIONCOMORBID                   NORMAL         1
3170    RXDATEMOSTDEFINSURG                   NORMAL         1
3180    RXDATESURGICALDISCH                   NORMAL         1
3190    READMSAMEHOSP30DAYS                   NORMAL         1
3220    RXDATERADIATIONENDED                  NORMAL         1
3230    RXDATESYSTEMIC                        NORMAL         1
3250    RXSUMMTRANSPLNTENDOCR                 NORMAL         1
3270    RXSUMMPALLIATIVEPROC                  NORMAL         1
3280    RXHOSPPALLIATIVEPROC                  NORMAL         1
3300    RURALURBANCONTINUUM1993               NORMAL         1
3310    RURALURBANCONTINUUM2003               NORMAL         1
3312    RURALURBANCONTINUUM2013               NORMAL         1
3400    DERIVEDAJCC7T                         NORMAL         1
3402    DERIVEDAJCC7TDESCRIPT                 NORMAL         1
3410    DERIVEDAJCC7N                         NORMAL         1
3412    DERIVEDAJCC7NDESCRIPT                 NORMAL         1
3420    DERIVEDAJCC7M                         NORMAL         1
3422    DERIVEDAJCC7MDESCRIPT                 NORMAL         1
3430    DERIVEDAJCC7STAGEGRP                  NORMAL         1
3605    DERIVEDSEERPATHSTGGRP                 NORMAL         1
3610    DERIVEDSEERCLINSTGGRP                 NORMAL         1
3614    DERIVEDSEERCMBSTGGRP                  NORMAL         1
3616    DERIVEDSEERCOMBINEDT                  NORMAL         1
3618    DERIVEDSEERCOMBINEDN                  NORMAL         1
3620    DERIVEDSEERCOMBINEDM                  NORMAL         1
3622    DERIVEDSEERCMBTSRC                    NORMAL         1
3624    DERIVEDSEERCMBNSRC                    NORMAL         1
3626    DERIVEDSEERCMBMSRC                    NORMAL         1
3645    NPCRDERIVEDAJCC8TNMCLINSTGGRP         NORMAL         1
3646    NPCRDERIVEDAJCC8TNMPATHSTGGRP         NORMAL         1
3647    NPCRDERIVEDAJCC8TNMPOSTSTGGRP         NORMAL         1
3700    SEERSITESPECIFICFACT1                 NORMAL         1
3702    SEERSITESPECIFICFACT2                 NORMAL         1
3704    SEERSITESPECIFICFACT3                 NORMAL         1
3706    SEERSITESPECIFICFACT4                 NORMAL         1
3708    SEERSITESPECIFICFACT5                 NORMAL         1
3710    SEERSITESPECIFICFACT6                 NORMAL         1
3750    OVERRIDECS1                           NORMAL         1
3751    OVERRIDECS2                           NORMAL         1
3752    OVERRIDECS3                           NORMAL         1
3753    OVERRIDECS4                           NORMAL         1
3754    OVERRIDECS5                           NORMAL         1
3755    OVERRIDECS6                           NORMAL         1
3756    OVERRIDECS7                           NORMAL         1
3757    OVERRIDECS8                           NORMAL         1
3758    OVERRIDECS9                           NORMAL         1
3759    OVERRIDECS10                          NORMAL         1
3760    OVERRIDECS11                          NORMAL         1
3761    OVERRIDECS12                          NORMAL         1
3762    OVERRIDECS13                          NORMAL         1
3763    OVERRIDECS14                          NORMAL         1
3764    OVERRIDECS15                          NORMAL         1
3765    OVERRIDECS16                          NORMAL         1
3766    OVERRIDECS17                          NORMAL         1
3767    OVERRIDECS18                          NORMAL         1
3768    OVERRIDECS19                          NORMAL         1
3769    OVERRIDECS20                          NORMAL         1
3780    SECONDARYDIAGNOSIS1                   NORMAL         1
3782    SECONDARYDIAGNOSIS2                   NORMAL         1
3784    SECONDARYDIAGNOSIS3                   NORMAL         1
3786    SECONDARYDIAGNOSIS4                   NORMAL         1
3788    SECONDARYDIAGNOSIS5                   NORMAL         1
3790    SECONDARYDIAGNOSIS6                   NORMAL         1
3792    SECONDARYDIAGNOSIS7                   NORMAL         1
3794    SECONDARYDIAGNOSIS8                   NORMAL         1
3796    SECONDARYDIAGNOSIS9                   NORMAL         1
3798    SECONDARYDIAGNOSIS10                  NORMAL         1
3800    SCHEMAID                              NORMAL         1
3801    CHROMOSOME1PLOSSHETEROZYGOSITY        NORMAL         1
3802    CHROMOSOME19QLOSSHETEROZYGOSITY       NORMAL         1
3803    ADENOIDCYSTICBASALOIDPATTERN          NORMAL         1
3804    ADENOPATHY                            NORMAL         1
3805    AFPPOSTORCHIECTOMYLABVALUE            NORMAL         1
3806    AFPPOSTORCHIECTOMYRANGE               NORMAL         1
3807    AFPPREORCHIECTOMYLABVALUE             NORMAL         1
3808    AFPPREORCHIECTOMYRANGE                NORMAL         1
3809    AFPPRETREATMENTINTERPRETATION         NORMAL         1
3810    AFPPRETREATMENTLABVALUE               NORMAL         1
3811    ANEMIA                                NORMAL         1
3812    BSYMPTOMS                             NORMAL         1
3813    BILIRUBINPRETXTOTALLABVALUE           NORMAL         1
3814    BILIRUBINPRETXUNITOFMEASURE           NORMAL         1
3815    BONEINVASION                          NORMAL         1
3816    BRAINMOLECULARMARKERS                 NORMAL         1
3817    BRESLOWTUMORTHICKNESS                 NORMAL         1
3818    CA125PRETREATMENTINTERPRETATION       NORMAL         1
3819    CEAPRETREATMENTINTERPRETATION         NORMAL         1
3820    CEAPRETREATMENTLABVALUE               NORMAL         1
3821    CHROMOSOME3STATUS                     NORMAL         1
3822    CHROMOSOME8QSTATUS                    NORMAL         1
3823    CIRCUMFERENTIALRESECTIONMARGIN        NORMAL         1
3824    CREATININEPRETREATMENTLABVALUE        NORMAL         1
3825    CREATININEPRETXUNITOFMEASURE          NORMAL         1
3826    ESTROGENRECEPTORPERCNTPOSORRANGE      NORMAL         1
3827    ESTROGENRECEPTORSUMMARY               NORMAL         1
3828    ESTROGENRECEPTORTOTALALLREDSCORE      NORMAL         1
3829    ESOPHAGUSANDEGJTUMOREPICENTER         NORMAL         1
3830    EXTRANODALEXTENSIONCLIN               NORMAL         1
3831    EXTRANODALEXTENSIONHEADNECKCLIN       NORMAL         1
3832    EXTRANODALEXTENSIONHEADNECKPATH       NORMAL         1
3833    EXTRANODALEXTENSIONPATH               NORMAL         1
3834    EXTRAVASCULARMATRIXPATTERNS           NORMAL         1
3835    FIBROSISSCORE                         NORMAL         1
3836    FIGOSTAGE                             NORMAL         1
3837    GESTATIONALTROPHOBLASTICPXINDEX       NORMAL         1
3838    GLEASONPATTERNSCLINICAL               NORMAL         1
3839    GLEASONPATTERNSPATHOLOGICAL           NORMAL         1
3840    GLEASONSCORECLINICAL                  NORMAL         1
3841    GLEASONSCOREPATHOLOGICAL              NORMAL         1
3842    GLEASONTERTIARYPATTERN                NORMAL         1
3843    GRADECLINICAL                         NORMAL         1
3844    GRADEPATHOLOGICAL                     NORMAL         1
3845    GRADEPOSTTHERAPY                      NORMAL         1
3846    HCGPOSTORCHIECTOMYLABVALUE            NORMAL         1
3847    HCGPOSTORCHIECTOMYRANGE               NORMAL         1
3848    HCGPREORCHIECTOMYLABVALUE             NORMAL         1
3849    HCGPREORCHIECTOMYRANGE                NORMAL         1
3850    HER2IHCSUMMARY                        NORMAL         1
3851    HER2ISHDUALPROBECOPYNUMBER            NORMAL         1
3852    HER2ISHDUALPROBERATIO                 NORMAL         1
3853    HER2ISHSINGLEPROBECOPYNUMBER          NORMAL         1
3854    HER2ISHSUMMARY                        NORMAL         1
3855    HER2OVERALLSUMMARY                    NORMAL         1
3856    HERITABLETRAIT                        NORMAL         1
3857    HIGHRISKCYTOGENETICS                  NORMAL         1
3858    HIGHRISKHISTOLOGICFEATURES            NORMAL         1
3859    HIVSTATUS                             NORMAL         1
3860    INRPROTHROMBINTIME                    NORMAL         1
3861    IPSILATERALADRENALGLANDINVOLVE        NORMAL         1
3862    JAK2                                  NORMAL         1
3863    KI67                                  NORMAL         1
3864    INVASIONBEYONDCAPSULE                 NORMAL         1
3865    KITGENEIMMUNOHISTOCHEMISTRY           NORMAL         1
3866    KRAS                                  NORMAL         1
3867    LDHPOSTORCHIECTOMYRANGE               NORMAL         1
3868    LDHPREORCHIECTOMYRANGE                NORMAL         1
3869    LDHPRETREATMENTLEVEL                  NORMAL         1
3870    LDHUPPERLIMITSOFNORMAL                NORMAL         1
3871    LNASSESSMETHODFEMORALINGUINAL         NORMAL         1
3872    LNASSESSMETHODPARAAORTIC              NORMAL         1
3873    LNASSESSMETHODPELVIC                  NORMAL         1
3874    LNDISTANTASSESSMETHOD                 NORMAL         1
3875    LNDISTANTMEDIASTINALSCALENE           NORMAL         1
3876    LNHEADANDNECKLEVELS1TO3               NORMAL         1
3877    LNHEADANDNECKLEVELS4TO5               NORMAL         1
3878    LNHEADANDNECKLEVELS6TO7               NORMAL         1
3879    LNHEADANDNECKOTHER                    NORMAL         1
3880    LNISOLATEDTUMORCELLS                  NORMAL         1
3881    LNLATERALITY                          NORMAL         1
3882    LNPOSITIVEAXILLARYLEVEL1TO2           NORMAL         1
3883    LNSIZE                                NORMAL         1
3885    LYMPHOCYTOSIS                         NORMAL         1
3886    MAJORVEININVOLVEMENT                  NORMAL         1
3887    MEASUREDBASALDIAMETER                 NORMAL         1
3888    MEASUREDTHICKNESS                     NORMAL         1
3889    METHYLATIONOFO6MGMT                   NORMAL         1
3890    MICROSATELLITEINSTABILITY             NORMAL         1
3891    MICROVASCULARDENSITY                  NORMAL         1
3892    MITOTICCOUNTUVEALMELANOMA             NORMAL         1
3893    MITOTICRATEMELANOMA                   NORMAL         1
3894    MULTIGENESIGNATUREMETHOD              NORMAL         1
3895    MULTIGENESIGNATURERESULTS             NORMAL         1
3896    NCCNINTERNATIONALPROGNOSTICINDEX      NORMAL         1
3897    NUMBEROFCORESEXAMINED                 NORMAL         1
3898    NUMBEROFCORESPOSITIVE                 NORMAL         1
3899    NUMBEROFEXAMINEDPARAAORTICNODES       NORMAL         1
3900    NUMBEROFEXAMINEDPELVICNODES           NORMAL         1
3901    NUMBEROFPOSITIVEPARAAORTICNODES       NORMAL         1
3902    NUMBEROFPOSITIVEPELVICNODES           NORMAL         1
3903    ONCOTYPEDXRECURRENCESCOREDCIS         NORMAL         1
3904    ONCOTYPEDXRECURRENCESCOREINVASIV      NORMAL         1
3905    ONCOTYPEDXRISKLEVELDCIS               NORMAL         1
3906    ONCOTYPEDXRISKLEVELINVASIVE           NORMAL         1
3907    ORGANOMEGALY                          NORMAL         1
3908    PERCENTNECROSISPOSTNEOADJUVANT        NORMAL         1
3909    PERINEURALINVASION                    NORMAL         1
3910    PERIPHERALBLOODINVOLVEMENT            NORMAL         1
3911    PERITONEALCYTOLOGY                    NORMAL         1
3913    PLEURALEFFUSION                       NORMAL         1
3914    PROGESTERONERECEPPRCNTPOSORRANGE      NORMAL         1
3915    PROGESTERONERECEPSUMMARY              NORMAL         1
3916    PROGESTERONERECEPTOTALALLREDSCOR      NORMAL         1
3917    PRIMARYSCLEROSINGCHOLANGITIS          NORMAL         1
3918    PROFOUNDIMMUNESUPPRESSION             NORMAL         1
3919    PROSTATEPATHOLOGICALEXTENSION         NORMAL         1
3920    PSALABVALUE                           NORMAL         1
3921    RESIDUALTUMVOLPOSTCYTOREDUCTION       NORMAL         1
3922    RESPONSETONEOADJUVANTTHERAPY          NORMAL         1
3923    SCATEGORYCLINICAL                     NORMAL         1
3924    SCATEGORYPATHOLOGICAL                 NORMAL         1
3925    SARCOMATOIDFEATURES                   NORMAL         1
3926    SCHEMADISCRIMINATOR1                  NORMAL         1
3927    SCHEMADISCRIMINATOR2                  NORMAL         1
3928    SCHEMADISCRIMINATOR3                  NORMAL         1
3929    SEPARATETUMORNODULES                  NORMAL         1
3930    SERUMALBUMINPRETREATMENTLEVEL         NORMAL         1
3931    SERUMBETA2MICROGLOBULINPRETXLVL       NORMAL         1
3932    LDHPRETREATMENTLABVALUE               NORMAL         1
3933    THROMBOCYTOPENIA                      NORMAL         1
3934    TUMORDEPOSITS                         NORMAL         1
3935    TUMORGROWTHPATTERN                    NORMAL         1
3936    ULCERATION                            NORMAL         1
3937    VISCERALPARIETALPLEURALINVASION       NORMAL         1
3938    ALKREARRANGEMENT                      NORMAL         1
3939    EGFRMUTATIONALANALYSIS                NORMAL         1
3940    BRAFMUTATIONALANALYSIS                NORMAL         1
3941    NRASMUTATIONALANALYSIS                NORMAL         1
3942    CA199PRETXLABVALUE                    NORMAL         1
3943    NCDBSARSCOV2TEST                      NORMAL         1
3944    NCDBSARSCOV2POS                       NORMAL         1
3945    NCDBSARSCOV2POSDATE                   NORMAL         1
3946    NCDBCOVID19TXIMPACT                   NORMAL         1
3950    MACROSCOPICEVALOFTHEMESORECTUM        NORMAL         1
3955    DERIVEDRAISTAGE                       NORMAL         1
3956    P16                                   NORMAL         1
3957    LNSTATUSPELVIC                        NORMAL         1
3958    LNSTATUSPARAAORTIC                    NORMAL         1
3959    LNSTATUSFEMORALINGUINAL               NORMAL         1
3960    HISTOLOGICSUBTYPE                     NORMAL         1
3961    CLINICALMARGINWIDTH                   NORMAL         1
3964    BRAINPRIMARYTUMORLOCATION             NORMAL         1
7010    PATHREPORTINGFACID1                   PRIVATE        1
7011    PATHREPORTINGFACID2                   PRIVATE        1
7012    PATHREPORTINGFACID3                   PRIVATE        1
7013    PATHREPORTINGFACID4                   PRIVATE        1
7014    PATHREPORTINGFACID5                   PRIVATE        1
7090    PATHREPORTNUMBER1                     PRIVATE        1
7091    PATHREPORTNUMBER2                     PRIVATE        1
7092    PATHREPORTNUMBER3                     PRIVATE        1
7093    PATHREPORTNUMBER4                     PRIVATE        1
7094    PATHREPORTNUMBER5                     PRIVATE        1
7100    PATHORDERPHYSLICNO1                   PRIVATE        1
7101    PATHORDERPHYSLICNO2                   PRIVATE        1
7102    PATHORDERPHYSLICNO3                   PRIVATE        1
7103    PATHORDERPHYSLICNO4                   PRIVATE        1
7104    PATHORDERPHYSLICNO5                   PRIVATE        1
7190    PATHORDERINGFACNO1                    PRIVATE        1
7191    PATHORDERINGFACNO2                    PRIVATE        1
7192    PATHORDERINGFACNO3                    PRIVATE        1
7193    PATHORDERINGFACNO4                    PRIVATE        1
7194    PATHORDERINGFACNO5                    PRIVATE        1
7320    PATHDATESPECCOLLECT1                  NORMAL         1
7321    PATHDATESPECCOLLECT2                  NORMAL         1
7322    PATHDATESPECCOLLECT3                  NORMAL         1
7323    PATHDATESPECCOLLECT4                  NORMAL         1
7324    PATHDATESPECCOLLECT5                  NORMAL         1
7480    PATHREPORTTYPE1                       NORMAL         1
7481    PATHREPORTTYPE2                       NORMAL         1
7482    PATHREPORTTYPE3                       NORMAL         1
7483    PATHREPORTTYPE4                       NORMAL         1
7484    PATHREPORTTYPE5                       NORMAL         1
170     RACECODINGSYSCURRENT                  NORMAL         1
180     RACECODINGSYSORIGINAL                 NORMAL         1
241     DATEOFBIRTHFLAG                       NORMAL         1
250     BIRTHPLACE                            NORMAL         1
270     CENSUSOCCCODE19702000                 NORMAL         1
280     CENSUSINDCODE19702000                 NORMAL         1
330     CENSUSOCCINDSYS7000                   NORMAL         1
391     DATEOFDIAGNOSISFLAG                   NORMAL         1
439     DATEOFMULTTUMORSFLAG                  NORMAL         1
448     DATECONCLUSIVEDXFLAG                  NORMAL         1
581     DATEOF1STCONTACTFLAG                  NORMAL         1
591     DATEOFINPTADMFLAG                     NORMAL         1
601     DATEOFINPTDISCHFLAG                   NORMAL         1
605     INPATIENTSTATUS                       NORMAL         1
683     DATEREGIONALLNDISSECTIONFLAG          NORMAL         1
833     DATESENTINELLYMPHNODEBIOPSYFLAG       NORMAL         1
1201    RXDATESURGERYFLAG                     NORMAL         1
1211    RXDATERADIATIONFLAG                   NORMAL         1
1221    RXDATECHEMOFLAG                       NORMAL         1
1231    RXDATEHORMONEFLAG                     NORMAL         1
1241    RXDATEBRMFLAG                         NORMAL         1
1251    RXDATEOTHERFLAG                       NORMAL         1
1261    DATEINITIALRXSEERFLAG                 NORMAL         1
1271    DATE1STCRSRXCOCFLAG                   NORMAL         1
1281    RXDATEDXSTGPROCFLAG                   NORMAL         1
1510    RADREGIONALDOSECGY                    NORMAL         1
1520    RADNOOFTREATMENTVOL                   NORMAL         1
1540    RADTREATMENTVOLUME                    NORMAL         1
1661    SUBSQRX2NDCRSDATEFLAG                 NORMAL         1
1681    SUBSQRX3RDCRSDATEFLAG                 NORMAL         1
1701    SUBSQRX4THCRSDATEFLAG                 NORMAL         1
1741    SUBSQRXRECONSTRUCTDEL                 NORMAL         1
1751    DATEOFLASTCONTACTFLAG                 NORMAL         1
1756    DATEOFDEATHCANADAFLAG                 NORMAL         1
1773    DATEOFLASTCANCERSTATUSFLAG            NORMAL         1
1780    QUALITYOFSURVIVAL                     NORMAL         1
1861    RECURRENCEDATE1STFLAG                 NORMAL         1
1940    PLACEOFDEATH                          NORMAL         1
1980    ICDO2CONVERSIONFLAG                   NORMAL         1
2081    CRCCHECKSUM                           NORMAL         1
2120    SEERCODINGSYSCURRENT                  NORMAL         1
2130    SEERCODINGSYSORIGINAL                 NORMAL         1
2155    RQRSNCDBSUBMISSIONFLAG                NORMAL         1
2180    SEERTYPEOFFOLLOWUP                    NORMAL         1
2190    SEERRECORDNUMBER                      NORMAL         1
2200    DIAGNOSTICPROC7387                    NORMAL         1
2220    STATEREQUESTORITEMS                   NORMAL         1
2310    MILITARYRECORDNOSUFFIX                NORMAL         1
2390    NAMEMAIDEN                            NORMAL         1
3171    RXDATEMOSTDEFINSURGFLAG               NORMAL         1
3181    RXDATESURGICALDISCHFLAG               NORMAL         1
3200    RADBOOSTRXMODALITY                    NORMAL         1
3210    RADBOOSTDOSECGY                       NORMAL         1
3221    RXDATERADIATIONENDEDFLAG              NORMAL         1
3231    RXDATESYSTEMICFLAG                    NORMAL         1
3440    DERIVEDPRERX7T                        NORMAL         1
3442    DERIVEDPRERX7TDESCRIP                 NORMAL         1
3450    DERIVEDPRERX7N                        NORMAL         1
3452    DERIVEDPRERX7NDESCRIP                 NORMAL         1
3460    DERIVEDPRERX7M                        NORMAL         1
3462    DERIVEDPRERX7MDESCRIP                 NORMAL         1
3470    DERIVEDPRERX7STAGEGRP                 NORMAL         1
3480    DERIVEDPOSTRX7T                       NORMAL         1
3482    DERIVEDPOSTRX7N                       NORMAL         1
3490    DERIVEDPOSTRX7M                       NORMAL         1
3492    DERIVEDPOSTRX7STGEGRP                 NORMAL         1
3600    DERIVEDNEOADJUVRXFLAG                 NORMAL         1
3650    NPCRDERIVEDCLINSTGGRP                 NORMAL         1
3655    NPCRDERIVEDPATHSTGGRP                 NORMAL         1
3720    NPCRSPECIFICFIELD                     NORMAL         1
3884    LNSTATUSFEMORINGUINPARAAORTPELV       NORMAL         1
;;
run;

/*Include PCORNET style template to match EDC format */ 

options nodate nonumber nobyline orientation=landscape validvarname=upcase 
        formchar="|___|||___+=|_/\<>" missing=' ' /*mprint mlogic symbolgen ls=max*/;
goptions reset=all dev=png300 rotate=landscape gsfmode=replace htext=0.9 
         ftext='Albany AMT' hsize=9 vsize=5.5;
ods html close;

proc template;
    define style PCORNET_DCTL / store=work.templat;
    parent=styles.rtf;

    replace fonts /
        'TitleFont'           = ("Times",12pt)
        'TitleFont2'          = ("Times",10pt)        
        'StrongFont'          = ("Times",10pt)
        'EmphasisFont'        = ("Times",10pt)
        'FixedEmphasisFont'   = ("Courier New,Courier",9pt)
        'FixedStrongFont'     = ("Courier New,Courier",9pt)
        'FixedHeadingFont'    = ("Courier New,Courier",9pt)
        'BatchFixedFont'      = ("SAS Monospace,Courier New,Courier",9pt)
        'FixedFont'           = ("Courier New,Courier",9pt)
        'headingEmphasisFont' = ("Times",10pt)
        'headingFont'         = ("Times",10pt)
        'docFont'             = ("Times",9pt)
        'FootnoteFont'        = ("Times",9pt);

        style table from table / rules=groups
                                 frame=hsides
                                 cellspacing=0pt
                                 cellpadding=2pt
                                 borderwidth=2pt;

        style PageNo from PageNo / font_size=0.1pt
                                   background=white
                                   foreground=white;

        style BodyDate from BodyDate / font_size=0.1pt
                                       background=white
                                       foreground=white;

        style Header from Header / protectspecialchars=off 
                                   background=_undef_
                                   borderwidth=0.25pt
                                   frame=below
                                   rules=groups;

        style SystemFooter from TitlesAndFooters / protectspecialchars=off
                                                   font=Fonts('FootnoteFont');

        style systemtitle from systemtitle / protectspecialchars=off;
        
        style Data from Cell / protectspecialchars=off;    

        replace Body from Document /
                       bottommargin=0.40in  /*1.01 from footnote to edge*/
                       topmargin   =0.90in  /*1.18 from 1st header title to edge*/
                       rightmargin =0.75in
                       leftmargin  =0.75in;
    end;
    

******************************;
ods path sashelp.tmplmst(read) work.templat(read);
ods pdf file="&outputpath.&DMID.&SITEID._OutputEdits.pdf"  
    style=pcornet_dctl nogtitle nogfootnote pdftoc=1;

proc format;
/*	value $TUMOR_RECORD_NUMBER_N60_f	'01'-'99' = 'valid coded value'*/
/*										' ' = 'missing value' other = 'invalid value'*/
/*										;*/

*marital status;
	value $MARITALSTATUSATDX_f	'1','2','3','4','5','6','9' = 'valid coded value'
								' ' = 'missing value'
								other = 'invalid value'
								;

	value	$race1_f		'01','02','03','04','05','06','07','08','10',
							'11','12','13','14','15','16','17','20','21',
							'22','25','26','27','28','30','31','32','96',
							'97','98','99' = 'valid coded value' other = 'invalid value'
							' ' = 'missing value'
							;

	value $sex_f			'1','2','3','4','5','6','9' = 'valid coded value'
							' ' = 'missing value' other = 'invalid value'
							;

	value $SPANISHHISPANICORIGIN_f		'0','1','2','3','4','5','6','7',
										'8','9' = 'valid coded value'
										' ' = 'missing value'
										other = 'invalid value'
										;


	value $primarySite_f				'C000'-'C809' = 'valid coded value'
										' ' = 'missing value' other = 'invalid value';

	value $laterality_f			'0','1','2','3','4','5','9' = 'valid coded value'
								' ' = 'missing value' other = 'invalid value'
								;

	value $histologicTypeIcdO3_f			'8000'-'9989' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $behaviorCodeIcdO3_f				'0','1','2','3' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $summaryStage2018_f				'0','1','2','3','4','7','8','9' = 'valid coded value'
											' ' = 'missing value'
											OTHER = 'invalid value'
											;

	value $SEERSUMMARYSTAGE2000_f			'0','1','2','3','4','7','8','9' = 'valid coded value'
											' ' = 'missing value'
											OTHER = 'invalid value'
											;
/* FOR THESE STAGE VARIABLES NEED TO DETERMINE INVALID AND VALID VALUES - NOW ONLY TESTS FOR MISSING VALUES */

	value $AJCCTNMCLINSTAGEGROUP_f			' ' = 'missing value' 
											'x' = 'invalid value'
											OTHER = 'valid coded value'
											;

	value $AJCCTNMPATHSTAGEGROUP_f			' ' = 'missing value' 
											'x' = 'invalid value'
											OTHER = 'valid coded value'
											;

	value $AJCCTNMPOSTTHERAPYCLINSTAGEGRP_f	' ' = 'missing value' 
											'x' = 'invalid value'
											OTHER = 'valid coded value'
											;

	value $AJCCTNMPOSTTHERAPYSTAGEGROUP_f	' ' = 'missing value' 
											'x' = 'invalid value'
											OTHER = 'valid coded value'
											;

	value $TNMCLINSTAGEGROUP_f				' ' = 'missing value' 
											'x' = 'invalid value'
											OTHER = 'valid coded value'
											;

	value $TNMPATHSTAGEGROUP_f				' ' = 'missing value' 
											'x' = 'invalid value'
											OTHER = 'valid coded value'
											;

	value $SEQUENCENUMBERCENTRAL_f			'00'-'59','60'-'87','88',
											'98','99' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value';
											;

	*Most sites should have the sequence number-hospital variable populated, but some may use the
	central version instead;

	value $sequenceNumberHospital_f			'00'-'59','60'-'87','88',
											'98','99' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value';
											;



/*	value $DIAGNOSTIC_CONFIRMATION_N490_f	'1','2','3','4','5','6','7',*/
/*											'8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/



	value $classOfCase_f			'00','10','11','12','13','14','20','21','22','30',
									'31','32','33','34','35','36','37','38','40','41',
									'42','43','49','99' = 'valid coded value'
									' ' = 'missing value' other = 'invalid value'
									;

/*	value $VITAL_STATUS_N1760_f		'0','1' = 'valid coded value'*/
/*									' ' = 'missing value' other = 'invalid value'*/
/*									;*/
/**/
/*	value $RX_HOSP_SURG_PRIM_SITE_N670_f 	'00','10'-'19','20'-'80',*/
/*											'90','98','99' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $RX_SUMM_SURG_PRIM_SITE_N1290_f	'00','10'-'19','20'-'80',*/
/*											'90','98','99' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $RX_HOSP_RADIATION_N690_f			'0','1','2','3','4','5',*/
/*											'9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $RX_SUMM_RADIATION_N1360_f 		'0','1','2','3','4','5',*/
/*											'6','7','8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $REASON_FOR_NO_RADIATION_N1430_f	'0','1','2','5','6','7',*/
/*											'8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value';*/
/*											;*/
/**/
/*	value $SEER_SUMMARY_STAGE2000_N759_f	'0','1','2','3','4','5',*/
/*											'7','8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $SUMMARY_STAGE2018_N764_f			'0','1','2','3','4',*/
/*											'7','8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $DERIVED_SUMMARY_STAGE20_N762_f	'0','1','2','3','4',*/
/*											'7','8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $GRADE_N440_f 					'1','2','3','4','5','6','7',*/
/*											'8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $GRADE_CLINICAL_N3843_f			'1','2','3','4','5','A','B',*/
/*											'C','D','E','L','H','M','S',*/
/*											'8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $GRADE_PATHOLOGICAL_N3844_f		'1','2','3','4','5','A','B',*/
/*											'C','D','E','L','H','M','S',*/
/*											'8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/
/**/
/*	value $GRADE_POST_THERAPY_N3845_f		'1','2','3','4','5','A','B',*/
/*											'C','D','E','L','H','M','S',*/
/*											'8','9' = 'valid coded value'*/
/*											' ' = 'missing value' other = 'invalid value'*/
/*											;*/



/*	value $DERIVED_SS2000_N3020_f	'0','1','2','3','4','5',*/
/*									'7','8','9' = 'valid coded value'*/
/*									' ' = 'missing value' other = 'invalid value'*/
/*									;*/


*6 stage variables;

	value	$private_f		' ' = 'null'
							OTHER = 'not null'
							;

	value	dxyear_f		. = 'Missing'
							LOW - 2009 = '<=2009' 2010 = '2010' 
                            2011 = '2011' 2012 = '2012' 2013 = '2013'
                            2014 = '2014' 2015 = '2015' 2016 = '2016'
                            2017 = '2017' 2018 = '2018' 2019 = '2019'
                            2020 = '2020' 2021 = '2021' 2022 = '2022'
                            2023 - HIGH = '>=2023'   
							;

	value	$timing_f		'1' = 'not a core variable'
							'2' = 'core variable for all dx years'
							'3' = 'core variables for dx through 2017'
							'4' = 'core variables for 2018+ dx'
							'5' = 'core variables for 2021+ dx'
							;
	value tumor_count_f     . = 'Missing' 1 = '1' 2 = '2' 3 = '3' 4 - HIGH = '>=4';
run;

/************************************************************

 CHECK THAT THE CORRECT VARIABLES ARE PRESENT IN TUMOR TABLE

 ************************************************************/

proc contents data = indata.&ttable
	out = sitelist (KEEP = name)
	noprint;
RUN;

data sitelist (drop = name); set sitelist;
	variable = upcase(name);
run;

proc sort data = ttvariables; by variable; run;
proc sort data = sitelist; by variable; run;

data missingvars extravars includedvars;
	merge ttvariables (in = a) sitelist (in = b);
	by variable;

	*variables that are part of spec but not present in table;
	if a and not b then output missingvars;

	*variables that are not part of spec but are present in table;
	if b and not a then output extravars;

	*variables that are part of spec and are present in table;
	if a and b then output includedvars;
run;

***********;

%macro check_missing;

%let dsid = %sysfunc(open(work.missingvars));
%let missing_num = %sysfunc(attrn(&dsid.,NOBS));
%let rc = %sysfunc(close(&dsid.));

%if &missing_num = 0 %then %do;

proc sql;
   insert into work.missingvars
      set variable='No Missing Variables',
          flag='NORMAL',
          timing='1';
quit;


%end;

data missingwork;
set missingvars;
colflag=mod(_n_-1, 3);
run;

data missingwork2;
merge missingwork(where=(colflag = 0) rename=(flag=flag0 variable=variable0))
   missingwork(where=(colflag = 1) rename=(flag=flag1 variable=variable1))
   missingwork(where=(colflag = 2) rename=(flag=flag2 variable=variable2));
run;

*sites may choose not to include private variables, so not
a problem if those are the only ones that are missing;
title1 justify=center 'Missing variables: variables listed in black may be omitted at your discretion, while those highlighted are required.';
title2 justify=center "Site &DMID.&SITEID";
/*proc print data = missingvars noobs;
	var variable flag;
run;*/

/*CHANGE: Changed priority to core */
footnote1 justify=center "Missing core variables are highlighted in green, missing normal variables are highlighted in blue.";

proc report data=missingwork2 split='|' style(header)=[backgroundcolor=CXCCCCCC];
         column variable0 flag0 varprint0 variable1 flag1 varprint1 variable2 flag2 varprint2;

         define flag0 /display noprint;
		 define variable0   /display noprint;
         define varprint0   /computed flow "Missing Variables"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];
         define flag1 /display noprint;
		 define variable1   /display noprint;
         define varprint1   /computed flow "Missing Variables"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];
         define flag2 /display noprint;
		 define variable2   /display noprint;
         define varprint2   /computed flow "Missing Variables"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];
         compute varprint0 / char length=32;
            if flag0='CORE' then do;
                varprint0=variable0;
                call define(_col_, "style", "style=[color=green textdecoration=underline]");
            end;
            else if flag0^='PRIVATE' then do;
                varprint0=variable0;
                call define(_col_, "style", "style=[color=blue textdecoration=underline]");
            end;
            else do;
                varprint0=variable0;
            end;
         endcomp;
         compute varprint1 / char length=32;
            if flag1='CORE' then do;
                varprint1=variable1;
                call define(_col_, "style", "style=[color=green textdecoration=underline]");
            end;
            else if flag1^='PRIVATE' then do;
                varprint1=variable1;
                call define(_col_, "style", "style=[color=blue textdecoration=underline]");
            end;
            else do;
                varprint1=variable1;
            end;
         endcomp;
         compute varprint2 / char length=32;
            if flag2='CORE' then do;
                varprint2=variable2;
                call define(_col_, "style", "style=[color=green textdecoration=underline]");
            end;
            else if flag2^='PRIVATE' then do;
                varprint2=variable2;
                call define(_col_, "style", "style=[color=blue textdecoration=underline]");
            end;
            else do;
                varprint2=variable2;
            end;
         endcomp;
    run;

%mend;
%check_missing;

%macro check_extra;

%let dsid = %sysfunc(open(work.extravars));
%let extra_num = %sysfunc(attrn(&dsid.,NOBS));
%let rc = %sysfunc(close(&dsid.));

%if &extra_num = 0 %then %do;

proc sql;
   insert into work.extravars
      set variable='No Extra Variables',
          flag='NORMAL',
          timing='1';
quit;

%end;

data extrawork;
set extravars;
colflag=mod(_n_-1, 3);
run;

data extrawork2;
merge extrawork(where=(colflag = 0) rename=(flag=flag0 variable=variable0))
   extrawork(where=(colflag = 1) rename=(flag=flag1 variable=variable1))
   extrawork(where=(colflag = 2) rename=(flag=flag2 variable=variable2));
run;

title1 justify=center 'Extra variables: these variables are found in the table, but are not in the table specification';
title2 justify=center "Site &DMID.&SITEID";
footnote1 justify=center /*'Variables in this table are not included in the table specification, but may be added to suit site goals.'*/;

proc report data=extrawork2 split='|' style(header)=[backgroundcolor=CXCCCCCC];
         column variable0 variable1 variable2;

         define variable0   /display flow "Extra Variables"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];
         define variable1   /display flow "Extra Variables"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];
         define variable2   /display flow "Extra Variables"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];

    run;

%mend;
%check_extra;

/************************************************************

 CHECK VALUES OF VARIABLES

 ************************************************************/



*examine values of private variables to determine
if set to NULL;
%macro check_private_values;

data private_values; set includedvars;
	where flag = 'PRIVATE';
run;

proc sql;
   create table work.private_var_dist
       (var_name char(32),
        _NAME_ char(8),
        null num,
		not_null num);
quit;

%let dsid = %sysfunc(open(work.private_values));
%let private_values_num = %sysfunc(attrn(&dsid.,NOBS));
%let rc = %sysfunc(close(&dsid.));

%if &private_values_num > 0 %then %do;

proc sql noprint;
	select variable
	into :private_varlist separated by ' '
	from private_values;
quit;

%do x = 1 %to &private_values_num;
proc freq data = indata.&ttable noprint;
	format %scan(&private_varlist,&x) $private_f.;
	table %scan(&private_varlist,&x) / missing out=work.temp_freq;
run;

data work.temp_freq1;
set work.temp_freq;
format var_name $char32. Cat_lab $char18.;
var_name="%scan(&private_varlist,&x)";
if %scan(&private_varlist,&x) = '' then Cat_lab = 'NULL'; else Cat_lab = put(%scan(&private_varlist,&x),private_f.);
run;

proc transpose data=work.temp_freq1 out=work.freqwide (drop = _LABEL_); /*CHANGE added drop lable */
by var_name;
var Count;
id Cat_lab;
run;

proc append base=private_var_dist data=work.freqwide force;
run;

%end;
%end;

%else %do;

proc sql;
   create table work.private_var_dist
       (var_name char(32),
        _NAME_ char(8),
        null num,
		not_null num);
   insert into work.private_var_dist
      values('No Private Variables',null,.,.);
quit;

%end;

title1 justify=center 'Values of included private variables -- should all be null';
title2 justify=center "Site &DMID.&SITEID";
*footnote1 justify=center 'Percentages greater than zero are highlighted in blue';

proc report data=private_var_dist split='|' style(header)=[backgroundcolor=CXCCCCCC];
         column var_name null not_null total_val per_not_null;

         define var_name   /display flow "Private Variable"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];
         define null   /display noprint;
         define not_null   /display flow "Populated Values"  style(header)=[just=center cellwidth=20%] style(column)=[just=center];
		 define total_val   /computed flow "Total Records"  style(header)=[just=center cellwidth=20%] style(column)=[just=center];
         define per_not_null   /computed format=percent10.1 flow "Percentage Populated"  style(header)=[just=center cellwidth=20%] style(column)=[just=center];
		 compute total_val;
		    total_val=(null+not_null);
		 endcomp;
         compute per_not_null;
		    per_not_null=(not_null)/(null+not_null);
            if per_not_null >0 then do;
                call define(_col_, "style", "style=[color=blue]");
            end;
         endcomp;
    run;

%mend;
%check_private_values;

***********;

*create list of included core variables;
data priority; set includedvars;
	if flag = 'CORE';
run;

/*CHANGE: variable names changed here and below */
data priority_categorical; set priority;
	if variable in ('PATID','AGEATDIAGNOSIS','DATEOFDIAGNOSIS')
		then delete; *these variables will be summarized differently (or not summarized,
			in the case of PATID);
run;

PROC SQL NOPRINT;
	SELECT variable, timing
	INTO :pricat_varlist separated BY ' ',
		:priority_timing separated BY ' '
	FROM priority_categorical;
QUIT;

%let pricat_varlist_num = %sysfunc(countw(&pricat_varlist));



*create derived variables;
data tumor01; set indata.&ttable;
	dxyear = input(substr(DATEOFDIAGNOSIS,1,4),4.);

	dxage = input(AGEATDIAGNOSIS,3.);
	if dxage = 999 then dxage = .;
run;

*anomaly expected in 2014 with affordable care act;
title1 'Distribution of diagnosis years';

proc freq data = tumor01 noprint;
	format dxyear dxyear_f.;
	table dxyear/missing out=work.dxyear_dist;
run;

***********;

*Examine values of core variables;
*this will fail if there is not a range of records before and
after dxyear of 2018;
%macro priority_dist;

proc sql;
   create table work.priority_var_dist
       (var_name char(32),
        _NAME_ char(8),
        valid_coded_value num,
		missing_value num,
		invalid_value num);
quit;

%do x = 1 %to &pricat_varlist_num;
	
/*title1 "%scan(&pricat_varlist,&x)";*/

proc summary data = tumor01 nway completetypes;

/* dx year constraints for specified core variables */
	%if %scan(&priority_timing,&x) = 3 %then
		%str(where dxyear <= 2017;);
	%else %if %scan(&priority_timing,&x) = 4 %then
		%str(where dxyear >=2018;);
	%else %if %scan(&priority_timing,&x) = 5 %then
		%str(where dxyear >=2021;);

	class %scan(&pricat_varlist,&x) / preloadfmt order = data missing;
	format %scan(&pricat_varlist,&x) $%scan(&pricat_varlist,&x)_f.;
	output out = temp_counts;
run;

proc freq data = temp_counts order = data noprint;
	format %scan(&pricat_varlist,&x) $%scan(&pricat_varlist,&x)_f.;
	tables %scan(&pricat_varlist,&x) / missing out=work.temp_freq;
	weight _freq_ / zeros;
run;

data work.temp_freq1;
set work.temp_freq;
format var_name $char32. Cat_lab $char18.;
var_name="%scan(&pricat_varlist,&x)";
if %scan(&pricat_varlist,&x) = '' then Cat_lab = 'missing value'; else Cat_lab = put(%scan(&pricat_varlist,&x),%scan(&pricat_varlist,&x)_f.);
run;

proc transpose data=work.temp_freq1 out=work.freqwide;
by var_name;
var Count;
id Cat_lab;
run;

proc append base=priority_var_dist data=work.freqwide force;
run;

%end;

title1 justify=center 'Distribution of Priority Variables';
title2 justify=center "Site &DMID.&SITEID";
footnote1 justify=center '';

proc report data=priority_var_dist split='|' style(header)=[backgroundcolor=CXCCCCCC];
         column var_name valid_coded_value missing_value invalid_value total_val per_missing per_invalid;

         define var_name   /display flow "Priority Variable"  style(header)=[just=center cellwidth=30%] style(column)=[just=left];
         define valid_coded_value   /display noprint;
         define missing_value   /display flow "Missing Values"  style(header)=[just=center cellwidth=12%] style(column)=[just=center];
         define invalid_value   /display flow "Invalid Values"  style(header)=[just=center cellwidth=12%] style(column)=[just=center];
		 define total_val   /computed flow "Total Records"  style(header)=[just=center cellwidth=12%] style(column)=[just=center];
         define per_missing   /computed format=percent10.1 flow "Percent Missing"  style(header)=[just=center cellwidth=12%] style(column)=[just=center];
         define per_invalid   /computed format=percent10.1 flow "Percent Invalid"  style(header)=[just=center cellwidth=12%] style(column)=[just=center];
		 compute total_val;
		    total_val=(valid_coded_value+missing_value+invalid_value);
		 endcomp;
         compute per_missing;
		    per_missing=(missing_value)/(valid_coded_value+missing_value+invalid_value);
         endcomp;
         compute per_invalid;
		    per_invalid=(invalid_value)/(valid_coded_value+missing_value+invalid_value);
         endcomp;
    run;

%mend;
%priority_dist;

***********;

title1 'Diagnosis age';
proc means data = tumor01 n min p25 p50 p75 max mean std maxdec=1 noprint;
	var dxage;
	output out=work.dxage_means N = N min = min p25 = lowerq p50=median p75 = upperq max = max mean=mean std=std nmiss=nmiss;
run;

/************************************************************

 CHECK FOR RECORDS IN ENCOUNTER TABLE

 ************************************************************/

*get list of tumor table PATIDs;
proc freq data = indata.&ttable noprint;
	tables patid / out = tt_patid_list (drop = count percent);
run;

proc sql;
	create table tt_encounters00 as
	select a.patid,b.encounterid from
	tt_patid_list as a inner join indata.ENCOUNTER as b
	on a.patid = b.patid;
quit;

proc freq data = tt_encounters00 noprint;
	tables patid / out = tt_encounters_cnt00;
run;

data tt_encounters_cnt01 (drop = percent);
	merge tt_patid_list (in = a) tt_encounters_cnt00;
	by patid;
	if a;

	if missing(count) then count = 0;
run;

title1 'Average number of encounters associated with tumor table cases';
proc means data = tt_encounters_cnt01 n min p25 p50 p75 max mean std maxdec=2 noprint;
	var count;
	output out=work.encounter_means N = N min = min p25 = lowerq p50=median p75 = upperq max = max mean=mean std=std nmiss=nmiss;
run;

proc datasets library=work nolist;
  modify encounter_means;
  attrib _all_ label='';
quit;

data work.all_means;
set dxage_means (in=dxage) encounter_means (in=enc);
if dxage then variable = 'Age at Diagnosis'; else if enc then variable = 'Encounters';
if dxage then ord=4; else if enc then ord=5;
ord2=0;
run; 

/*title 'Distribution of Selected Continuous Variables';
proc print data=work.all_means;
run;*/

title1 'Number of unique patients';
proc sql;
    create table work.pat_count as
	select 'Total Unique Patients' as statistic format=$char40., 0 as ord, 0 as ord2, count(distinct patid) as value
	from tt_encounters_cnt01
quit;

title1 'Number of unique patients with no encounters';
proc sql;
    create table work.no_enc as
	select 'Unique Patients without Encounters' as statistic format=$char40., 1 as ord, 0 as ord2, count(distinct patid) as value
	from tt_encounters_cnt01
	where count = 0;
quit;

data work.no_enc2 (drop=pat_count);
merge work.no_enc work.pat_count(rename=(value=pat_count)) work.no_enc;
percent = value/pat_count*100;
run;

data work.counts;
length statistic $40;
set work.pat_count work.no_enc2;
run;

/*proc print data=work.counts;
run;*/

/************************************************************

 ASSESS MULTIPLE RECORDS FOR SAME CANCER

 ************************************************************/

/*title1 'Distribution of number of records for each tumor';*/
proc freq data = tumor01 noprint;
	tables patid*&SEQNUM*FACILITY / out = tumor_count;
run;

data tumor_count2;
set tumor_count;
*label count='';
rename count=tumor_count;
run;

proc freq data = tumor_count2 noprint;
    format tumor_count tumor_count_f.;
	tables tumor_count/out=tumor_count_dist;
run;

data dxyear_dist2;
set dxyear_dist;
ord2=_N_;
run;

data tumor_count_dist2;
set tumor_count_dist;
ord2=_N_;
run;

data work.freqs;
set dxyear_dist2(in=dxyear_in drop=percent) tumor_count_dist2(in=tumor_count_in);
if dxyear_in then variable='Diagnosis Year'; else if tumor_count_in then variable = 'Records per Tumor';
if dxyear_in then Cat_lab = put(dxyear,dxyear_f.); else if tumor_count_in then Cat_lab = put(tumor_count,tumor_count_f.);
if dxyear_in then ord=2; else if tumor_count_in then ord=3;
run;

/*title 'Descriptive Statistics for Selected Values';
proc print data=work.freqs;
var Variable Cat_lab count percent; 
run;*/

/* Create table formats */
proc format;
     value rowfmt
        0='Unique Patients'
        1='Unique Patients without Encounters'
        2='Diagnosis Year'
        3='Records per Tumor'
        4='Age at Diagnosis'
        5='Encounters'
         ;
run;

/* Create dummy row dataset */
data dummy;
     length col1 $50;
     do ord = 0 to 5;
        ord2=0;
        col1=put(ord,rowfmt.);
        output;
     end;
run;

/*Create total dataset*/
data tbl (drop=_TYPE_ _FREQ_ dxyear tumor_count);
set work.counts(rename=(value=N)) work.freqs(rename=(count=N variable=statistic cat_lab=col1)) work.all_means(rename=(variable=statistic));
run;

proc sort data=tbl;
     by ord ord2;
run;

*- Bring everything together - separate count and percent records -*;
data pooled_table;
    length col1 $50;
     merge tbl  dummy    ;
     by ord ord2;

/*     if ord<=5 then pg=1;
     else pg=2;*/
run;

*- Produce output -*;
%macro print_diag;

title1 justify=center "Descriptive Statistics for Selected Variables";
title2 justify=center "Site &DMID.&SITEID";
footnote1 justify=left ' ';

    proc report data=pooled_table split='|' style(header)=[backgroundcolor=CXCCCCCC];
         column col1 ord2 N Percent percent_disp min lowerq median upperq max mean std nmiss per_miss;

         define ord2     /display noprint;
		 define percent /display noprint;
		 define nmiss    /display noprint;
         define col1     /display flow "" style(header)=[just=left cellwidth=20%];
         define N     /display flow "N" style(column)=[just=center cellwidth=7%];
         define Percent_disp /computed format=percent10.1 flow "%" style(column)=[just=center cellwidth=6%];
         define Min     /display format=comma10.1 flow "Min" style(column)=[just=center cellwidth=7%];
         define Lowerq     /display format=comma10.1 flow "Q1" style(column)=[just=center cellwidth=7%];
         define Median     /display format=comma10.1 flow "Median" style(column)=[just=center cellwidth=7%];
         define Upperq     /display format=comma10.1 flow "Q3" style(column)=[just=center cellwidth=7%];
         define Max     /display format=comma10.1 flow "Max" style(column)=[just=center cellwidth=7%];
         define Mean     /display format=comma10.1 flow "Mean" style(column)=[just=center cellwidth=7%];
         define std     /display format=comma10.1 flow "STD" style(column)=[just=center cellwidth=7%];
		 define per_miss   /computed format=percent10.1 flow "% Missing" style(column)=[just=center cellwidth=7%];
         compute ord2;
            if ord2^=0 then CALL DEFINE('_c1_',"STYLE","STYLE={PRETEXT='    ' ASIS=ON}");
         endcomp;
		 compute percent_disp;
		    percent_disp = percent/100;
		 endcomp;
		 compute per_miss;
		    per_miss=(nmiss)/(nmiss+N);
         endcomp;
    run;

%mend print_diag;
%print_diag;



ods pdf close;

