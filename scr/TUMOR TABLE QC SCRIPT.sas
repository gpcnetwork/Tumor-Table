
/*****************************************************************************
 *  TUMOR TABLE QC SCRIPT.sas
 *  Bradley McDowell, University of Iowa
 *  Christie Spinka, University of Missouri
 *
 * 
 *  Input: tumor table, Version 1.2, and encounter table, Version 6.0
 *
 *  Assumptions: The tumor table must be named "TUMOR" and located in the 
 *  same folder as the other CDM tables.
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
 use SEQUENCE_NUMBER_HOSPITA_N560, but some use SEQUENCE_NUMBER_CENTRAL_N380. This script
 defaults to the former, but analysts should make sure it is populated before running this
 program. If it is not, check to see whether SEQUENCE_NUMBER_CENTRAL_N380 is appropriate to use;
%LET SEQNUM = SEQUENCE_NUMBER_HOSPITA_N560; *default;





********************************************************************;
********** END OF USER INPUTS **************************************;
********************************************************************;

options mprint;

data ttvariables;
	length variable $32 flag $8. timing $1.;
	input variable$ flag$ timing$;
	datalines;
PATID                                  PRIORITY       1
RECORD_TYPE_N10                        NORMAL         1
PATIENT_ID_NUMBER_N20                  PRIVATE        1
PATIENT_SYSTEM_ID_HOSP_N21             PRIVATE        1
REGISTRY_TYPE_N30                      NORMAL         1
REGISTRY_ID_N40                        NORMAL         1
NPI_REGISTRY_ID_N45                    NORMAL         1
NAACCR_RECORD_VERSION_N50              NORMAL         1
TUMOR_RECORD_NUMBER_N60                PRIORITY       1
ADDR_AT_DX_CITY_N70                    PRIVATE        1
ADDR_AT_DX_STATE_N80                   NORMAL         1
STATE_AT_DX_GEOCODE1970_N81            NORMAL         1
STATE_AT_DX_GEOCODE2000_N82            NORMAL         1
STATE_AT_DX_GEOCODE2010_N83            NORMAL         1
STATE_AT_DX_GEOCODE2020_N84            NORMAL         1
COUNTY_AT_DX_ANALYSIS_N89              PRIVATE        1
COUNTY_AT_DX_N90                       PRIVATE        1
COUNTY_AT_DX_GEOCODE199_N94            PRIVATE        1
COUNTY_AT_DX_GEOCODE200_N95            PRIVATE        1
COUNTY_AT_DX_GEOCODE201_N96            PRIVATE        1
COUNTY_AT_DX_GEOCODE202_N97            PRIVATE        1
ADDR_AT_DX_POSTAL_CODE_N100            PRIVATE        1
ADDR_AT_DX_COUNTRY_N102                NORMAL         1
CENSUS_TRACT19708090_N110              PRIVATE        1
CENSUS_COD_SYS19708090_N120            NORMAL         1
CENSUS_TRACT2020_N125                  PRIVATE        1
CENSUS_TRACT2000_N130                  PRIVATE        1
CENSUS_TRACT2010_N135                  PRIVATE        1
CENSUS_TR_POVERTY_INDIC_N145           NORMAL         1
MARITAL_STATUS_AT_DX_N150              NORMAL         1
RACE1_N160                             PRIORITY       2
RACE2_N161                             PRIORITY       2
RACE3_N162                             PRIORITY       2
RACE4_N163                             PRIORITY       2
RACE5_N164                             PRIORITY       2
RACE_CODING_SYS_CURRENT_N170           NORMAL         1
RACE_CODING_SYS_ORIGINA_N180           NORMAL         1
SPANISH_HISPANIC_ORIGIN_N190           PRIORITY       2
NHIA_DERIVED_HISP_ORIGI_N191           NORMAL         2
IHS_LINK_N192                          NORMAL         1
RACE_NAPIIA_N193                       NORMAL         1
COMPUTED_ETHNICITY_N200                NORMAL         1
COMPUTED_ETHNICITY_SOUR_N210           NORMAL         1
SEX_N220                               PRIORITY       2
AGE_AT_DIAGNOSIS_N230                  PRIORITY       2
DATE_OF_BIRTH_N240                     NORMAL         1
DATE_OF_BIRTH_FLAG_N241                NORMAL         1
BIRTHPLACE_N250                        NORMAL         1
BIRTHPLACE_STATE_N252                  NORMAL         1
BIRTHPLACE_COUNTRY_N254                NORMAL         1
CENSUS_OCC_CODE19702000_N270           NORMAL         1
CENSUS_IND_CODE2010_N272               NORMAL         1
CENSUS_IND_CODE19702000_N280           NORMAL         1
CENSUS_OCC_CODE2010_N282               NORMAL         1
OCCUPATION_SOURCE_N290                 NORMAL         1
INDUSTRY_SOURCE_N300                   NORMAL         1
TEXT_USUAL_OCCUPATION_N310             PRIVATE        1
TEXT_USUAL_INDUSTRY_N320               PRIVATE        1
CENSUS_OCC_IND_SYS7000_N330            NORMAL         1
RUCA2000_N339                          NORMAL         1
RUCA2010_N341                          NORMAL         1
URIC2000_N345                          NORMAL         1
URIC2010_N346                          NORMAL         1
CENSUS_BLOCK_GROUP2020_N361            PRIVATE        1
CENSUS_BLOCK_GROUP2000_N362            PRIVATE        1
CENSUS_BLOCK_GROUP2010_N363            PRIVATE        1
CENSUS_TR_CERT19708090_N364            NORMAL         1
CENSUS_TR_CERTAINTY2000_N365           NORMAL         1
GIS_COORDINATE_QUALITY_N366            NORMAL         1
CENSUS_TR_CERTAINTY2010_N367           NORMAL         1
CENSUS_BLOCK_GRP197090_N368            PRIVATE        1
CENSUS_TRACT_CERTAINTY2_N369           NORMAL         1
SEQUENCE_NUMBER_CENTRAL_N380           PRIORITY       2
DATE_OF_DIAGNOSIS_N390                 PRIORITY       2
DATE_OF_DIAGNOSIS_FLAG_N391            NORMAL         1
PRIMARY_SITE_N400                      PRIORITY       2
LATERALITY_N410                        PRIORITY       2
HISTOLOGY_ICD_O2_N420                  NORMAL         1
BEHAVIOR_ICD_O2_N430                   NORMAL         1
DATE_OF_MULT_TUMORS_FLA_N439           NORMAL         1
GRADE_N440                             PRIORITY       3
GRADE_PATH_VALUE_N441                  NORMAL         1
AMBIGUOUS_TERMINOLOGY_D_N442           NORMAL         1
DATE_CONCLUSIVE_DX_N443                NORMAL         1
MULT_TUM_RPT_AS_ONE_PRI_N444           NORMAL         1
DATE_OF_MULT_TUMORS_N445               NORMAL         1
MULTIPLICITY_COUNTER_N446              NORMAL         1
DATE_CONCLUSIVE_DX_FLAG_N448           NORMAL         1
GRADE_PATH_SYSTEM_N449                 NORMAL         1
SITE_CODING_SYS_CURRENT_N450           NORMAL         1
SITE_CODING_SYS_ORIGINA_N460           NORMAL         1
MORPH_CODING_SYS_CURREN_N470           NORMAL         1
MORPH_CODING_SYS_ORIGIN_N480           NORMAL         1
DIAGNOSTIC_CONFIRMATION_N490           PRIORITY       2
TYPE_OF_REPORTING_SOURC_N500           NORMAL         1
CASEFINDING_SOURCE_N501                NORMAL         1
HISTOLOGIC_TYPE_ICD_O3_N522            PRIORITY       2
BEHAVIOR_CODE_ICD_O3_N523              PRIORITY       2
REPORTING_FACILITY_N540                PRIVATE        1
NPI_REPORTING_FACILITY_N545            PRIVATE        1
ACCESSION_NUMBER_HOSP_N550             PRIVATE        1
SEQUENCE_NUMBER_HOSPITA_N560           PRIORITY       2
ABSTRACTED_BY_N570                     NORMAL         1
DATE_OF1ST_CONTACT_N580                NORMAL         1
DATE_OF1ST_CONTACT_FLAG_N581           NORMAL         1
DATE_OF_INPT_ADM_N590                  NORMAL         1
DATE_OF_INPT_ADM_FLAG_N591             NORMAL         1
DATE_OF_INPT_DISCH_N600                NORMAL         1
DATE_OF_INPT_DISCH_FLAG_N601           NORMAL         1
INPATIENT_STATUS_N605                  NORMAL         1
CLASS_OF_CASE_N610                     PRIORITY       2
PRIMARY_PAYER_AT_DX_N630               NORMAL         1
RX_HOSP_SURG_APP2010_N668              NORMAL         1
RX_HOSP_SURG_PRIM_SITE_N670            PRIORITY       2
RX_HOSP_SCOPE_REG_LN_SU_N672           NORMAL         1
RX_HOSP_SURG_OTH_REG_DI_N674           NORMAL         1
RX_HOSP_REG_LN_REMOVED_N676            NORMAL         1
DATE_REGIONAL_LYMPH_NOD_N682           NORMAL         1
DATE_REGIONAL_LYMPH_NOD_N683           NORMAL         1
RX_HOSP_RADIATION_N690                 PRIORITY       3
RX_HOSP_CHEMO_N700                     NORMAL         1
RX_HOSP_HORMONE_N710                   NORMAL         1
RX_HOSP_BRM_N720                       NORMAL         1
RX_HOSP_OTHER_N730                     NORMAL         1
RX_HOSP_DX_STG_PROC_N740               NORMAL         1
RX_HOSP_SURG_SITE9802_N746             NORMAL         1
RX_HOSP_SCOPE_REG9802_N747             NORMAL         1
RX_HOSP_SURG_OTH9802_N748              NORMAL         1
TUMOR_SIZE_CLINICAL_N752               NORMAL         1
TUMOR_SIZE_PATHOLOGIC_N754             NORMAL         1
TUMOR_SIZE_SUMMARY_N756                NORMAL         1
SEER_SUMMARY_STAGE2000_N759            PRIORITY       5
SEER_SUMMARY_STAGE1977_N760            NORMAL         1
DERIVED_SUMMARY_STAGE20_N762           NORMAL         4
SUMMARY_STAGE2018_N764                 PRIORITY       4
EOD_PRIMARY_TUMOR_N772                 NORMAL         1
EOD_REGIONAL_NODES_N774                NORMAL         1
EOD_METS_N776                          NORMAL         1
EOD_TUMOR_SIZE_N780                    NORMAL         1
DERIVED_EOD2018_T_N785                 NORMAL         1
EOD_EXTENSION_N790                     NORMAL         1
DERIVED_EOD2018_M_N795                 NORMAL         1
EOD_EXTENSION_PROST_PAT_N800           NORMAL         1
EOD_LYMPH_NODE_INVOLV_N810             NORMAL         1
DERIVED_EOD2018_N_N815                 NORMAL         1
DERIVED_EOD2018_STAGE_G_N818           NORMAL         1
REGIONAL_NODES_POSITIVE_N820           NORMAL         1
REGIONAL_NODES_EXAMINED_N830           NORMAL         1
DATE_OF_SENTINEL_LYMPH__N832           NORMAL         1
DATE_SENTINEL_LYMPH_NOD_N833           NORMAL         1
SENTINEL_LYMPH_NODES_EX_N834           NORMAL         1
SENTINEL_LYMPH_NODES_PO_N835           NORMAL         1
EOD_OLD13_DIGIT_N840                   NORMAL         1
EOD_OLD2_DIGIT_N850                    NORMAL         1
EOD_OLD4_DIGIT_N860                    NORMAL         1
CODING_SYSTEM_FOR_EOD_N870             NORMAL         1
TNM_PATH_T_N880                        NORMAL         1
TNM_PATH_N_N890                        NORMAL         1
TNM_PATH_M_N900                        NORMAL         1
TNM_PATH_STAGE_GROUP_N910              NORMAL         1
TNM_PATH_DESCRIPTOR_N920               NORMAL         1
TNM_PATH_STAGED_BY_N930                NORMAL         1
TNM_CLIN_T_N940                        NORMAL         1
TNM_CLIN_N_N950                        NORMAL         1
TNM_CLIN_M_N960                        NORMAL         1
TNM_CLIN_STAGE_GROUP_N970              NORMAL         1
TNM_CLIN_DESCRIPTOR_N980               NORMAL         1
TNM_CLIN_STAGED_BY_N990                NORMAL         1
AJCC_ID_N995                           NORMAL         1
AJCC_TNM_CLIN_T_N1001                  NORMAL         1
AJCC_TNM_CLIN_N_N1002                  NORMAL         1
AJCC_TNM_CLIN_M_N1003                  NORMAL         1
AJCC_TNM_CLIN_STAGE_GRO_N1004          NORMAL         1
AJCC_TNM_PATH_T_N1011                  NORMAL         1
AJCC_TNM_PATH_N_N1012                  NORMAL         1
AJCC_TNM_PATH_M_N1013                  NORMAL         1
AJCC_TNM_PATH_STAGE_GRO_N1014          NORMAL         1
AJCC_TNM_POST_THERAPY_T_N1021          NORMAL         1
AJCC_TNM_POST_THERAPY_N_N1022          NORMAL         1
AJCC_TNM_POST_THERAPY_M_N1023          NORMAL         1
AJCC_TNM_POST_THERAPY_S_N1024          NORMAL         1
AJCC_TNM_CLIN_T_SUFFIX_N1031           NORMAL         1
AJCC_TNM_PATH_T_SUFFIX_N1032           NORMAL         1
AJCC_TNM_POST_THERAPY_T_N1033          NORMAL         1
AJCC_TNM_CLIN_N_SUFFIX_N1034           NORMAL         1
AJCC_TNM_PATH_N_SUFFIX_N1035           NORMAL         1
AJCC_TNM_POST_THERAPY_N_N1036          NORMAL         1
TNM_EDITION_NUMBER_N1060               NORMAL         1
METS_AT_DX_BONE_N1112                  NORMAL         1
METS_AT_DX_BRAIN_N1113                 NORMAL         1
METS_AT_DX_DISTANT_LN_N1114            NORMAL         1
METS_AT_DX_LIVER_N1115                 NORMAL         1
METS_AT_DX_LUNG_N1116                  NORMAL         1
METS_AT_DX_OTHER_N1117                 NORMAL         1
PEDIATRIC_STAGE_N1120                  NORMAL         1
PEDIATRIC_STAGING_SYSTE_N1130          NORMAL         1
PEDIATRIC_STAGED_BY_N1140              NORMAL         1
TUMOR_MARKER1_N1150                    NORMAL         1
TUMOR_MARKER2_N1160                    NORMAL         1
TUMOR_MARKER3_N1170                    NORMAL         1
LYMPH_VASCULAR_INVASION_N1182          NORMAL         1
RX_DATE_SURGERY_N1200                  NORMAL         1
RX_DATE_SURGERY_FLAG_N1201             NORMAL         1
RX_DATE_RADIATION_N1210                NORMAL         1
RX_DATE_RADIATION_FLAG_N1211           NORMAL         1
RX_DATE_CHEMO_N1220                    NORMAL         1
RX_DATE_CHEMO_FLAG_N1221               NORMAL         1
RX_DATE_HORMONE_N1230                  NORMAL         1
RX_DATE_HORMONE_FLAG_N1231             NORMAL         1
RX_DATE_BRM_N1240                      NORMAL         1
RX_DATE_BRM_FLAG_N1241                 NORMAL         1
RX_DATE_OTHER_N1250                    NORMAL         1
RX_DATE_OTHER_FLAG_N1251               NORMAL         1
DATE_INITIAL_RX_SEER_N1260             NORMAL         1
DATE_INITIAL_RX_SEER_FL_N1261          NORMAL         1
DATE1ST_CRS_RX_COC_N1270               NORMAL         1
DATE1ST_CRS_RX_COC_FLAG_N1271          NORMAL         1
RX_DATE_DX_STG_PROC_N1280              NORMAL         1
RX_DATE_DX_STG_PROC_FLA_N1281          NORMAL         1
RX_SUMM_TREATMENT_STATU_N1285          NORMAL         1
RX_SUMM_SURG_PRIM_SITE_N1290           PRIORITY       2
RX_SUMM_SCOPE_REG_LN_SU_N1292          NORMAL         1
RX_SUMM_SURG_OTH_REG_DI_N1294          NORMAL         1
RX_SUMM_REG_LN_EXAMINED_N1296          NORMAL         1
RX_SUMM_SURGICAL_APPROC_N1310          NORMAL         1
RX_SUMM_SURGICAL_MARGIN_N1320          NORMAL         1
RX_SUMM_RECONSTRUCT1ST_N1330           NORMAL         1
REASON_FOR_NO_SURGERY_N1340            NORMAL         1
RX_SUMM_DX_STG_PROC_N1350              NORMAL         1
RX_SUMM_RADIATION_N1360                PRIORITY       3
RX_SUMM_RAD_TO_CNS_N1370               NORMAL         1
RX_SUMM_SURG_RAD_SEQ_N1380             NORMAL         1
RX_SUMM_CHEMO_N1390                    NORMAL         1
RX_SUMM_HORMONE_N1400                  NORMAL         1
RX_SUMM_BRM_N1410                      NORMAL         1
RX_SUMM_OTHER_N1420                    NORMAL         1
REASON_FOR_NO_RADIATION_N1430          PRIORITY       4
RX_CODING_SYSTEM_CURREN_N1460          NORMAL         1
PHASE1_DOSE_PER_FRACTIO_N1501          NORMAL         1
PHASE1_RADIATION_EXTERN_N1502          NORMAL         1
PHASE1_NUMBER_OF_FRACTI_N1503          NORMAL         1
PHASE1_RADIATION_PRIMAR_N1504          NORMAL         1
PHASE1_RADIATION_TO_DRA_N1505          NORMAL         1
PHASE1_RADIATION_TREATM_N1506          NORMAL         1
PHASE1_TOTAL_DOSE_N1507                NORMAL         1
RAD_REGIONAL_DOSE_CGY_N1510            NORMAL         1
PHASE2_DOSE_PER_FRACTIO_N1511          NORMAL         1
PHASE2_RADIATION_EXTERN_N1512          NORMAL         1
PHASE2_NUMBER_OF_FRACTI_N1513          NORMAL         1
PHASE2_RADIATION_PRIMAR_N1514          NORMAL         1
PHASE2_RADIATION_TO_DRA_N1515          NORMAL         1
PHASE2_RADIATION_TREATM_N1516          NORMAL         1
PHASE2_TOTAL_DOSE_N1517                NORMAL         1
RAD_NO_OF_TREATMENT_VOL_N1520          NORMAL         1
PHASE3_DOSE_PER_FRACTIO_N1521          NORMAL         1
PHASE3_RADIATION_EXTERN_N1522          NORMAL         1
PHASE3_NUMBER_OF_FRACTI_N1523          NORMAL         1
PHASE3_RADIATION_PRIMAR_N1524          NORMAL         1
PHASE3_RADIATION_TO_DRA_N1525          NORMAL         1
PHASE3_RADIATION_TREATM_N1526          NORMAL         1
PHASE3_TOTAL_DOSE_N1527                NORMAL         1
RADIATION_TREATMENT_DIS_N1531          NORMAL         1
NUMBER_OF_PHASES_OF_RAD_N1532          NORMAL         1
TOTAL_DOSE_N1533                       NORMAL         1
RAD_TREATMENT_VOLUME_N1540             NORMAL         1
RAD_LOCATION_OF_RX_N1550               NORMAL         1
RAD_REGIONAL_RX_MODALIT_N1570          NORMAL         1
RX_SUMM_SYSTEMIC_SUR_SE_N1639          NORMAL         1
RX_SUMM_SURGERY_TYPE_N1640             NORMAL         1
RX_SUMM_SURG_SITE9802_N1646            NORMAL         1
RX_SUMM_SCOPE_REG9802_N1647            NORMAL         1
RX_SUMM_SURG_OTH9802_N1648             NORMAL         1
SUBSQ_RX2ND_COURSE_DATE_N1660          NORMAL         1
SUBSQ_RX2NDCRS_DATE_FLA_N1661          NORMAL         1
SUBSQ_RX2ND_COURSE_SURG_N1671          NORMAL         1
SUBSQ_RX2ND_COURSE_RAD_N1672           NORMAL         1
SUBSQ_RX2ND_COURSE_CHEM_N1673          NORMAL         1
SUBSQ_RX2ND_COURSE_HORM_N1674          NORMAL         1
SUBSQ_RX2ND_COURSE_BRM_N1675           NORMAL         1
SUBSQ_RX2ND_COURSE_OTH_N1676           NORMAL         1
SUBSQ_RX2ND_SCOPE_LN_SU_N1677          NORMAL         1
SUBSQ_RX2ND_SURG_OTH_N1678             NORMAL         1
SUBSQ_RX2ND_REG_LN_REM_N1679           NORMAL         1
SUBSQ_RX3RD_COURSE_DATE_N1680          NORMAL         1
SUBSQ_RX3RDCRS_DATE_FLA_N1681          NORMAL         1
SUBSQ_RX3RD_COURSE_SURG_N1691          NORMAL         1
SUBSQ_RX3RD_COURSE_RAD_N1692           NORMAL         1
SUBSQ_RX3RD_COURSE_CHEM_N1693          NORMAL         1
SUBSQ_RX3RD_COURSE_HORM_N1694          NORMAL         1
SUBSQ_RX3RD_COURSE_BRM_N1695           NORMAL         1
SUBSQ_RX3RD_COURSE_OTH_N1696           NORMAL         1
SUBSQ_RX3RD_SCOPE_LN_SU_N1697          NORMAL         1
SUBSQ_RX3RD_SURG_OTH_N1698             NORMAL         1
SUBSQ_RX3RD_REG_LN_REM_N1699           NORMAL         1
SUBSQ_RX4TH_COURSE_DATE_N1700          NORMAL         1
SUBSQ_RX4THCRS_DATE_FLA_N1701          NORMAL         1
SUBSQ_RX4TH_COURSE_SURG_N1711          NORMAL         1
SUBSQ_RX4TH_COURSE_RAD_N1712           NORMAL         1
SUBSQ_RX4TH_COURSE_CHEM_N1713          NORMAL         1
SUBSQ_RX4TH_COURSE_HORM_N1714          NORMAL         1
SUBSQ_RX4TH_COURSE_BRM_N1715           NORMAL         1
SUBSQ_RX4TH_COURSE_OTH_N1716           NORMAL         1
SUBSQ_RX4TH_SCOPE_LN_SU_N1717          NORMAL         1
SUBSQ_RX4TH_SURG_OTH_N1718             NORMAL         1
SUBSQ_RX4TH_REG_LN_REM_N1719           NORMAL         1
SUBSQ_RX_RECONSTRUCT_DE_N1741          NORMAL         1
DATE_OF_LAST_CONTACT_N1750             NORMAL         1
DATE_OF_LAST_CONTACT_FL_N1751          NORMAL         1
DATE_OF_DEATH_CANADA_N1755             NORMAL         1
DATE_OF_DEATH_CANADA_FL_N1756          NORMAL         1
VITAL_STATUS_N1760                     NORMAL         1
VITAL_STATUS_RECODE_N1762              NORMAL         1
CANCER_STATUS_N1770                    NORMAL         1
DATE_OF_LAST_CANCER_STA_N1772          NORMAL         1
DATE_OF_LAST_CANCER_STA_N1773          NORMAL         1
RECORD_NUMBER_RECODE_N1775             NORMAL         1
QUALITY_OF_SURVIVAL_N1780              NORMAL         1
SURV_DATE_ACTIVE_FOLLOW_N1782          NORMAL         1
SURV_FLAG_ACTIVE_FOLLOW_N1783          NORMAL         1
SURV_MOS_ACTIVE_FOLLOWU_N1784          NORMAL         1
SURV_DATE_PRESUMED_ALIV_N1785          NORMAL         1
SURV_FLAG_PRESUMED_ALIV_N1786          NORMAL         1
SURV_MOS_PRESUMED_ALIVE_N1787          NORMAL         1
SURV_DATE_DX_RECODE_N1788              NORMAL         1
FOLLOW_UP_SOURCE_N1790                 NORMAL         1
FOLLOW_UP_SOURCE_CENTRA_N1791          NORMAL         1
NEXT_FOLLOW_UP_SOURCE_N1800            NORMAL         1
ADDR_CURRENT_CITY_N1810                PRIVATE        1
ADDR_CURRENT_STATE_N1820               NORMAL         1
ADDR_CURRENT_POSTAL_COD_N1830          PRIVATE        1
ADDR_CURRENT_COUNTRY_N1832             NORMAL         1
COUNTY_CURRENT_N1840                   PRIVATE        1
FOLLOW_UP_CONTACT_CITY_N1842           PRIVATE        1
FOLLOW_UP_CONTACT_STATE_N1844          NORMAL         1
FOLLOW_UP_CONTACT_POSTA_N1846          PRIVATE        1
FOLLOWUP_CONTACT_COUNTR_N1847          NORMAL         1
UNUSUAL_FOLLOW_UP_METHO_N1850          NORMAL         1
RECURRENCE_DATE1ST_N1860               NORMAL         1
RECURRENCE_DATE1ST_FLAG_N1861          NORMAL         1
RECURRENCE_TYPE1ST_N1880               NORMAL         1
CAUSE_OF_DEATH_N1910                   NORMAL         1
SEER_CAUSE_SPECIFIC_COD_N1914          NORMAL         1
SEER_OTHER_COD_N1915                   NORMAL         1
ICD_REVISION_NUMBER_N1920              NORMAL         1
AUTOPSY_N1930                          NORMAL         1
PLACE_OF_DEATH_N1940                   NORMAL         1
PLACE_OF_DEATH_STATE_N1942             NORMAL         1
PLACE_OF_DEATH_COUNTRY_N1944           NORMAL         1
SITE_ICD_O1_N1960                      NORMAL         1
HISTOLOGY_ICD_O1_N1971                 NORMAL         1
BEHAVIOR_ICD_O1_N1972                  NORMAL         1
GRADE_ICD_O1_N1973                     NORMAL         1
ICD_O2_CONVERSION_FLAG_N1980           NORMAL         1
OVER_RIDE_SS_NODESPOS_N1981            NORMAL         1
OVER_RIDE_SS_TNM_N_N1982               NORMAL         1
OVER_RIDE_SS_TNM_M_N1983               NORMAL         1
OVER_RIDE_ACSN_CLASS_SE_N1985          NORMAL         1
OVER_RIDE_HOSPSEQ_DXCON_N1986          NORMAL         1
OVER_RIDE_COC_SITE_TYPE_N1987          NORMAL         1
OVER_RIDE_HOSPSEQ_SITE_N1988           NORMAL         1
OVER_RIDE_SITE_TNM_STGG_N1989          NORMAL         1
OVER_RIDE_AGE_SITE_MORP_N1990          NORMAL         1
OVER_RIDE_TNM_STAGE_N1992              NORMAL         1
OVER_RIDE_TNM_TIS_N1993                NORMAL         1
OVER_RIDE_TNM3_N1994                   NORMAL         1
OVER_RIDE_SEQNO_DXCONF_N2000           NORMAL         1
OVER_RIDE_SITE_LAT_SEQN_N2010          NORMAL         1
OVER_RIDE_SURG_DXCONF_N2020            NORMAL         1
OVER_RIDE_SITE_TYPE_N2030              NORMAL         1
OVER_RIDE_HISTOLOGY_N2040              NORMAL         1
OVER_RIDE_REPORT_SOURCE_N2050          NORMAL         1
OVER_RIDE_ILL_DEFINE_SI_N2060          NORMAL         1
OVER_RIDE_LEUK_LYMPHOMA_N2070          NORMAL         1
OVER_RIDE_SITE_BEHAVIOR_N2071          NORMAL         1
OVER_RIDE_SITE_EOD_DX_D_N2072          NORMAL         1
OVER_RIDE_SITE_LAT_EOD_N2073           NORMAL         1
OVER_RIDE_SITE_LAT_MORP_N2074          NORMAL         1
OVER_RIDE_NAME_SEX_N2078               NORMAL         1
CRC_CHECKSUM_N2081                     NORMAL         1
DATE_CASE_INITIATED_N2085              NORMAL         1
DATE_CASE_COMPLETED_N2090              NORMAL         1
DATE_CASE_COMPLETED_COC_N2092          NORMAL         1
DATE_CASE_LAST_CHANGED_N2100           NORMAL         1
DATE_CASE_REPORT_EXPORT_N2110          NORMAL         1
DATE_CASE_REPORT_RECEIV_N2111          NORMAL         1
DATE_CASE_REPORT_LOADED_N2112          NORMAL         1
DATE_TUMOR_RECORD_AVAIL_N2113          NORMAL         1
ICD_O3_CONVERSION_FLAG_N2116           NORMAL         1
SEER_CODING_SYS_CURRENT_N2120          NORMAL         1
SEER_CODING_SYS_ORIGINA_N2130          NORMAL         1
COC_CODING_SYS_CURRENT_N2140           NORMAL         1
COC_CODING_SYS_ORIGINAL_N2150          NORMAL         1
COC_ACCREDITED_FLAG_N2152              NORMAL         1
RQRS_NCDB_SUBMISSION_FL_N2155          NORMAL         1
VENDOR_NAME_N2170                      NORMAL         1
SEER_TYPE_OF_FOLLOW_UP_N2180           NORMAL         1
SEER_RECORD_NUMBER_N2190               NORMAL         1
DIAGNOSTIC_PROC7387_N2200              NORMAL         1
STATE_REQUESTOR_ITEMS_N2220            PRIVATE        1
NAME_LAST_N2230                        PRIVATE        1
NAME_FIRST_N2240                       PRIVATE        1
NAME_MIDDLE_N2250                      PRIVATE        1
NAME_PREFIX_N2260                      PRIVATE        1
NAME_SUFFIX_N2270                      PRIVATE        1
NAME_ALIAS_N2280                       PRIVATE        1
NAME_SPOUSE_PARENT_N2290               PRIVATE        1
MEDICAL_RECORD_NUMBER_N2300            PRIVATE        1
MILITARY_RECORD_NO_SUFF_N2310          PRIVATE        1
MEDICARE_BENEFICIARY_ID_N2315          PRIVATE        1
SOCIAL_SECURITY_NUMBER_N2320           PRIVATE        1
ADDR_AT_DX_NO_STREET_N2330             PRIVATE        1
ADDR_AT_DX_SUPPLEMENTL_N2335           PRIVATE        1
ADDR_CURRENT_NO_STREET_N2350           PRIVATE        1
LATITUDE_N2352                         PRIVATE        1
LONGITUDE_N2354                        PRIVATE        1
ADDR_CURRENT_SUPPLEMENT_N2355          PRIVATE        1
TELEPHONE_N2360                        PRIVATE        1
DC_STATE_FILE_NUMBER_N2380             PRIVATE        1
NAME_MAIDEN_N2390                      PRIVATE        1
FOLLOW_UP_CONTACT_NOST_N2392           PRIVATE        1
FOLLOW_UP_CONTACT_SUPPL_N2393          PRIVATE        1
FOLLOW_UP_CONTACT_NAME_N2394           PRIVATE        1
INSTITUTION_REFERRED_FR_N2410          PRIVATE        1
NPI_INST_REFERRED_FROM_N2415           PRIVATE        1
INSTITUTION_REFERRED_TO_N2420          PRIVATE        1
NPI_INST_REFERRED_TO_N2425             PRIVATE        1
FOLLOWING_REGISTRY_N2440               PRIVATE        1
NPI_FOLLOWING_REGISTRY_N2445           PRIVATE        1
PHYSICIAN_MANAGING_N2460               PRIVATE        1
NPI_PHYSICIAN_MANAGING_N2465           PRIVATE        1
PHYSICIAN_FOLLOW_UP_N2470              PRIVATE        1
NPI_PHYSICIAN_FOLLOW_UP_N2475          PRIVATE        1
PHYSICIAN_PRIMARY_SURG_N2480           PRIVATE        1
NPI_PHYSICIAN_PRIMARY_S_N2485          PRIVATE        1
PHYSICIAN3_N2490                       PRIVATE        1
NPI_PHYSICIAN3_N2495                   PRIVATE        1
PHYSICIAN4_N2500                       PRIVATE        1
NPI_PHYSICIAN4_N2505                   PRIVATE        1
EHR_REPORTING_N2508                    PRIVATE        1
TEXT_DX_PROC_PE_N2520                  PRIVATE        1
TEXT_DX_PROC_X_RAY_SCAN_N2530          PRIVATE        1
TEXT_DX_PROC_SCOPES_N2540              PRIVATE        1
TEXT_DX_PROC_LAB_TESTS_N2550           PRIVATE        1
TEXT_DX_PROC_OP_N2560                  PRIVATE        1
TEXT_DX_PROC_PATH_N2570                PRIVATE        1
TEXT_PRIMARY_SITE_TITLE_N2580          PRIVATE        1
TEXT_HISTOLOGY_TITLE_N2590             PRIVATE        1
TEXT_STAGING_N2600                     PRIVATE        1
RX_TEXT_SURGERY_N2610                  PRIVATE        1
RX_TEXT_RADIATION_N2620                PRIVATE        1
RX_TEXT_RADIATION_OTHER_N2630          PRIVATE        1
RX_TEXT_CHEMO_N2640                    PRIVATE        1
RX_TEXT_HORMONE_N2650                  PRIVATE        1
RX_TEXT_BRM_N2660                      PRIVATE        1
RX_TEXT_OTHER_N2670                    PRIVATE        1
TEXT_REMARKS_N2680                     PRIVATE        1
TEXT_PLACE_OF_DIAGNOSIS_N2690          PRIVATE        1
CS_TUMOR_SIZE_N2800                    NORMAL         1
CS_EXTENSION_N2810                     NORMAL         1
CS_TUMOR_SIZE_EXT_EVAL_N2820           NORMAL         1
CS_LYMPH_NODES_N2830                   NORMAL         1
CS_LYMPH_NODES_EVAL_N2840              NORMAL         1
CS_METS_AT_DX_N2850                    NORMAL         1
CS_METS_AT_DX_BONE_N2851               NORMAL         1
CS_METS_AT_DX_BRAIN_N2852              NORMAL         1
CS_METS_AT_DX_LIVER_N2853              NORMAL         1
CS_METS_AT_DX_LUNG_N2854               NORMAL         1
CS_METS_EVAL_N2860                     NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2861          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2862          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2863          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2864          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2865          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2866          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2867          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2868          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2869          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2870          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2871          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2872          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2873          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2874          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2875          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2876          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2877          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2878          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2879          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2880          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2890          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2900          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2910          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2920          NORMAL         1
CS_SITE_SPECIFIC_FACTOR_N2930          NORMAL         1
CS_VERSION_INPUT_ORIGIN_N2935          NORMAL         1
CS_VERSION_DERIVED_N2936               NORMAL         1
CS_VERSION_INPUT_CURREN_N2937          NORMAL         1
DERIVED_AJCC6_T_N2940                  NORMAL         1
DERIVED_AJCC6_T_DESCRIP_N2950          NORMAL         1
DERIVED_AJCC6_N_N2960                  NORMAL         1
DERIVED_AJCC6_N_DESCRIP_N2970          NORMAL         1
DERIVED_AJCC6_M_N2980                  NORMAL         1
DERIVED_AJCC6_M_DESCRIP_N2990          NORMAL         1
DERIVED_AJCC6_STAGE_GRP_N3000          NORMAL         1
DERIVED_SS1977_N3010                   NORMAL         1
DERIVED_SS2000_N3020                   PRIORITY       6
DERIVED_AJCC_FLAG_N3030                NORMAL         1
DERIVED_SS1977_FLAG_N3040              NORMAL         1
DERIVED_SS2000_FLAG_N3050              NORMAL         1
ARCHIVE_FIN_N3100                      PRIVATE        1
NPI_ARCHIVE_FIN_N3105                  PRIVATE        1
COMORBID_COMPLICATION1_N3110           NORMAL         1
COMORBID_COMPLICATION2_N3120           NORMAL         1
COMORBID_COMPLICATION3_N3130           NORMAL         1
COMORBID_COMPLICATION4_N3140           NORMAL         1
COMORBID_COMPLICATION5_N3150           NORMAL         1
COMORBID_COMPLICATION6_N3160           NORMAL         1
COMORBID_COMPLICATION7_N3161           NORMAL         1
COMORBID_COMPLICATION8_N3162           NORMAL         1
COMORBID_COMPLICATION9_N3163           NORMAL         1
COMORBID_COMPLICATION10_N3164          NORMAL         1
ICD_REVISION_COMORBID_N3165            NORMAL         1
RX_DATE_MOST_DEFIN_SURG_N3170          NORMAL         1
RX_DATE_MOST_DEFIN_SURG_N3171          NORMAL         1
RX_DATE_SURGICAL_DISCH_N3180           NORMAL         1
RX_DATE_SURGICAL_DISCH__N3181          NORMAL         1
READM_SAME_HOSP30_DAYS_N3190           NORMAL         1
RAD_BOOST_RX_MODALITY_N3200            NORMAL         1
RAD_BOOST_DOSE_CGY_N3210               NORMAL         1
RX_DATE_RADIATION_ENDED_N3220          NORMAL         1
RX_DATE_RADIATION_ENDED_N3221          NORMAL         1
RX_DATE_SYSTEMIC_N3230                 NORMAL         1
RX_DATE_SYSTEMIC_FLAG_N3231            NORMAL         1
RX_SUMM_TRANSPLNT_ENDOC_N3250          NORMAL         1
RX_SUMM_PALLIATIVE_PROC_N3270          NORMAL         1
RX_HOSP_PALLIATIVE_PROC_N3280          NORMAL         1
RURALURBAN_CONTINUUM199_N3300          NORMAL         1
RURALURBAN_CONTINUUM200_N3310          NORMAL         1
RURALURBAN_CONTINUUM201_N3312          NORMAL         1
DERIVED_AJCC7_T_N3400                  NORMAL         1
DERIVED_AJCC7_T_DESCRIP_N3402          NORMAL         1
DERIVED_AJCC7_N_N3410                  NORMAL         1
DERIVED_AJCC7_N_DESCRIP_N3412          NORMAL         1
DERIVED_AJCC7_M_N3420                  NORMAL         1
DERIVED_AJCC7_M_DESCRIP_N3422          NORMAL         1
DERIVED_AJCC7_STAGE_GRP_N3430          NORMAL         1
DERIVED_PRERX7_T_N3440                 NORMAL         1
DERIVED_PRERX7_T_DESCRI_N3442          NORMAL         1
DERIVED_PRERX7_N_N3450                 NORMAL         1
DERIVED_PRERX7_N_DESCRI_N3452          NORMAL         1
DERIVED_PRERX7_M_N3460                 NORMAL         1
DERIVED_PRERX7_M_DESCRI_N3462          NORMAL         1
DERIVED_PRERX7_STAGE_GR_N3470          NORMAL         1
DERIVED_POSTRX7_T_N3480                NORMAL         1
DERIVED_POSTRX7_N_N3482                NORMAL         1
DERIVED_POSTRX7_M_N3490                NORMAL         1
DERIVED_POSTRX7_STGE_GR_N3492          NORMAL         1
DERIVED_NEOADJUV_RX_FLA_N3600          NORMAL         1
DERIVED_SEER_PATH_STG_G_N3605          NORMAL         1
DERIVED_SEER_CLIN_STG_G_N3610          NORMAL         1
DERIVED_SEER_CMB_STG_GR_N3614          NORMAL         1
DERIVED_SEER_COMBINED_T_N3616          NORMAL         1
DERIVED_SEER_COMBINED_N_N3618          NORMAL         1
DERIVED_SEER_COMBINED_M_N3620          NORMAL         1
DERIVED_SEER_CMB_T_SRC_N3622           NORMAL         1
DERIVED_SEER_CMB_N_SRC_N3624           NORMAL         1
DERIVED_SEER_CMB_M_SRC_N3626           NORMAL         1
NPCR_DERIVED_AJCC8_TNM__N3645          NORMAL         1
NPCR_DERIVED_AJCC8_TNM__N3646          NORMAL         1
NPCR_DERIVED_AJCC8_TNM__N3647          NORMAL         1
NPCR_DERIVED_CLIN_STG_G_N3650          NORMAL         1
NPCR_DERIVED_PATH_STG_G_N3655          NORMAL         1
SEER_SITE_SPECIFIC_FACT_N3700          NORMAL         1
SEER_SITE_SPECIFIC_FACT_N3702          NORMAL         1
SEER_SITE_SPECIFIC_FACT_N3704          NORMAL         1
SEER_SITE_SPECIFIC_FACT_N3706          NORMAL         1
SEER_SITE_SPECIFIC_FACT_N3708          NORMAL         1
SEER_SITE_SPECIFIC_FACT_N3710          NORMAL         1
NPCR_SPECIFIC_FIELD_N3720              NORMAL         1
OVER_RIDE_CS1_N3750                    NORMAL         1
OVER_RIDE_CS2_N3751                    NORMAL         1
OVER_RIDE_CS3_N3752                    NORMAL         1
OVER_RIDE_CS4_N3753                    NORMAL         1
OVER_RIDE_CS5_N3754                    NORMAL         1
OVER_RIDE_CS6_N3755                    NORMAL         1
OVER_RIDE_CS7_N3756                    NORMAL         1
OVER_RIDE_CS8_N3757                    NORMAL         1
OVER_RIDE_CS9_N3758                    NORMAL         1
OVER_RIDE_CS10_N3759                   NORMAL         1
OVER_RIDE_CS11_N3760                   NORMAL         1
OVER_RIDE_CS12_N3761                   NORMAL         1
OVER_RIDE_CS13_N3762                   NORMAL         1
OVER_RIDE_CS14_N3763                   NORMAL         1
OVER_RIDE_CS15_N3764                   NORMAL         1
OVER_RIDE_CS16_N3765                   NORMAL         1
OVER_RIDE_CS17_N3766                   NORMAL         1
OVER_RIDE_CS18_N3767                   NORMAL         1
OVER_RIDE_CS19_N3768                   NORMAL         1
OVER_RIDE_CS20_N3769                   NORMAL         1
SECONDARY_DIAGNOSIS1_N3780             NORMAL         1
SECONDARY_DIAGNOSIS2_N3782             NORMAL         1
SECONDARY_DIAGNOSIS3_N3784             NORMAL         1
SECONDARY_DIAGNOSIS4_N3786             NORMAL         1
SECONDARY_DIAGNOSIS5_N3788             NORMAL         1
SECONDARY_DIAGNOSIS6_N3790             NORMAL         1
SECONDARY_DIAGNOSIS7_N3792             NORMAL         1
SECONDARY_DIAGNOSIS8_N3794             NORMAL         1
SECONDARY_DIAGNOSIS9_N3796             NORMAL         1
SECONDARY_DIAGNOSIS10_N3798            NORMAL         1
SCHEMA_ID_N3800                        NORMAL         1
CHROMOSOME1P_LOSS_OF_HE_N3801          NORMAL         1
CHROMOSOME19Q_LOSS_OF_H_N3802          NORMAL         1
ADENOID_CYSTIC_BASALOID_N3803          NORMAL         1
ADENOPATHY_N3804                       NORMAL         1
AFP_POST_ORCHIECTOMY_LA_N3805          NORMAL         1
AFP_POST_ORCHIECTOMY_RA_N3806          NORMAL         1
AFP_PRE_ORCHIECTOMY_LAB_N3807          NORMAL         1
AFP_PRE_ORCHIECTOMY_RAN_N3808          NORMAL         1
AFP_PRETREATMENT_INTERP_N3809          NORMAL         1
AFP_PRETREATMENT_LAB_VA_N3810          NORMAL         1
ANEMIA_N3811                           NORMAL         1
B_SYMPTOMS_N3812                       NORMAL         1
BILIRUBIN_PRETREATMENT__N3813          NORMAL         1
BILIRUBIN_PRETREATMENT__N3814          NORMAL         1
BONE_INVASION_N3815                    NORMAL         1
BRAIN_MOLECULAR_MARKERS_N3816          NORMAL         1
BRESLOW_TUMOR_THICKNESS_N3817          NORMAL         1
CA125_PRETREATMENT_INTE_N3818          NORMAL         1
CEA_PRETREATMENT_INTERP_N3819          NORMAL         1
CEA_PRETREATMENT_LAB_VA_N3820          NORMAL         1
CHROMOSOME3_STATUS_N3821               NORMAL         1
CHROMOSOME8Q_STATUS_N3822              NORMAL         1
CIRCUMFERENTIAL_RESECTI_N3823          NORMAL         1
CREATININE_PRETREATMENT_N3824          NORMAL         1
CREATININE_PRETREATMENT_N3825          NORMAL         1
ESTROGEN_RECEPTOR_PERCE_N3826          NORMAL         1
ESTROGEN_RECEPTOR_SUMMA_N3827          NORMAL         1
ESTROGEN_RECEPTOR_TOTAL_N3828          NORMAL         1
ESOPHAGUS_AND_EGJ_TUMOR_N3829          NORMAL         1
EXTRANODAL_EXTENSION_CL_N3830          NORMAL         1
EXTRANODAL_EXTENSION_HE_N3831          NORMAL         1
EXTRANODAL_EXTENSION_HE_N3832          NORMAL         1
EXTRANODAL_EXTENSION_PA_N3833          NORMAL         1
EXTRAVASCULAR_MATRIX_PA_N3834          NORMAL         1
FIBROSIS_SCORE_N3835                   NORMAL         1
FIGO_STAGE_N3836                       NORMAL         1
GESTATIONAL_TROPHOBLAST_N3837          NORMAL         1
GLEASON_PATTERNS_CLINIC_N3838          NORMAL         1
GLEASON_PATTERNS_PATHOL_N3839          NORMAL         1
GLEASON_SCORE_CLINICAL_N3840           NORMAL         1
GLEASON_SCORE_PATHOLOGI_N3841          NORMAL         1
GLEASON_TERTIARY_PATTER_N3842          NORMAL         1
GRADE_CLINICAL_N3843                   PRIORITY       4
GRADE_PATHOLOGICAL_N3844               PRIORITY       4
GRADE_POST_THERAPY_N3845               PRIORITY       4
HCG_POST_ORCHIECTOMY_LA_N3846          NORMAL         1
HCG_POST_ORCHIECTOMY_RA_N3847          NORMAL         1
HCG_PRE_ORCHIECTOMY_LAB_N3848          NORMAL         1
HCG_PRE_ORCHIECTOMY_RAN_N3849          NORMAL         1
HER2_IHC_SUMMARY_N3850                 NORMAL         1
HER2_ISH_DUAL_PROBE_COP_N3851          NORMAL         1
HER2_ISH_DUAL_PROBE_RAT_N3852          NORMAL         1
HER2_ISH_SINGLE_PROBE_C_N3853          NORMAL         1
HER2_ISH_SUMMARY_N3854                 NORMAL         1
HER2_OVERALL_SUMMARY_N3855             NORMAL         1
HERITABLE_TRAIT_N3856                  NORMAL         1
HIGH_RISK_CYTOGENETICS_N3857           NORMAL         1
HIGH_RISK_HISTOLOGIC_FE_N3858          NORMAL         1
HIV_STATUS_N3859                       NORMAL         1
INTERNATIONAL_NORMALIZE_N3860          NORMAL         1
IPSILATERAL_ADRENAL_GLA_N3861          NORMAL         1
JAK2_N3862                             NORMAL         1
KI67_N3863                             NORMAL         1
INVASION_BEYOND_CAPSULE_N3864          NORMAL         1
KIT_GENE_IMMUNOHISTOCHE_N3865          NORMAL         1
KRAS_N3866                             NORMAL         1
LDH_POST_ORCHIECTOMY_RA_N3867          NORMAL         1
LDH_PRE_ORCHIECTOMY_RAN_N3868          NORMAL         1
LDH_PRETREATMENT_LEVEL_N3869           NORMAL         1
LDH_UPPER_LIMITS_OF_NOR_N3870          NORMAL         1
LN_ASSESSMENT_METHOD_FE_N3871          NORMAL         1
LN_ASSESSMENT_METHOD_PA_N3872          NORMAL         1
LN_ASSESSMENT_METHOD_PE_N3873          NORMAL         1
LN_DISTANT_ASSESSMENT_M_N3874          NORMAL         1
LN_DISTANT_MEDIASTINAL__N3875          NORMAL         1
LN_HEAD_AND_NECK_LEVELS_N3876          NORMAL         1
LN_HEAD_AND_NECK_LEVELS_N3877          NORMAL         1
LN_HEAD_AND_NECK_LEVELS_N3878          NORMAL         1
LN_HEAD_AND_NECK_OTHER_N3879           NORMAL         1
LN_ISOLATED_TUMOR_CELLS_N3880          NORMAL         1
LN_LATERALITY_N3881                    NORMAL         1
LN_POSITIVE_AXILLARY_LE_N3882          NORMAL         1
LN_SIZE_N3883                          NORMAL         1
LN_STATUS_FEMORAL_INGUI_N3884          NORMAL         1
LYMPHOCYTOSIS_N3885                    NORMAL         1
MAJOR_VEIN_INVOLVEMENT_N3886           NORMAL         1
MEASURED_BASAL_DIAMETER_N3887          NORMAL         1
MEASURED_THICKNESS_N3888               NORMAL         1
METHYLATION_OF_O6_METHY_N3889          NORMAL         1
MICROSATELLITE_INSTABIL_N3890          NORMAL         1
MICROVASCULAR_DENSITY_N3891            NORMAL         1
MITOTIC_COUNT_UVEAL_MEL_N3892          NORMAL         1
MITOTIC_RATE_MELANOMA_N3893            NORMAL         1
MULTIGENE_SIGNATURE_MET_N3894          NORMAL         1
MULTIGENE_SIGNATURE_RES_N3895          NORMAL         1
NCCN_INTERNATIONAL_PROG_N3896          NORMAL         1
NUMBER_OF_CORES_EXAMINE_N3897          NORMAL         1
NUMBER_OF_CORES_POSITIV_N3898          NORMAL         1
NUMBER_OF_EXAMINED_PARA_N3899          NORMAL         1
NUMBER_OF_EXAMINED_PELV_N3900          NORMAL         1
NUMBER_OF_POSITIVE_PARA_N3901          NORMAL         1
NUMBER_OF_POSITIVE_PELV_N3902          NORMAL         1
ONCOTYPE_DX_RECURRENCE__N3903          NORMAL         1
ONCOTYPE_DX_RECURRENCE__N3904          NORMAL         1
ONCOTYPE_DX_RISK_LEVEL__N3905          NORMAL         1
ONCOTYPE_DX_RISK_LEVEL__N3906          NORMAL         1
ORGANOMEGALY_N3907                     NORMAL         1
PERCENT_NECROSIS_POST_N_N3908          NORMAL         1
PERINEURAL_INVASION_N3909              NORMAL         1
PERIPHERAL_BLOOD_INVOLV_N3910          NORMAL         1
PERITONEAL_CYTOLOGY_N3911              NORMAL         1
PLEURAL_EFFUSION_N3913                 NORMAL         1
PROGESTERONE_RECEPTOR_P_N3914          NORMAL         1
PROGESTERONE_RECEPTOR_S_N3915          NORMAL         1
PROGESTERONE_RECEPTOR_T_N3916          NORMAL         1
PRIMARY_SCLEROSING_CHOL_N3917          NORMAL         1
PROFOUND_IMMUNE_SUPPRES_N3918          NORMAL         1
PROSTATE_PATHOLOGICAL_E_N3919          NORMAL         1
PSA_LAB_VALUE_N3920                    NORMAL         1
RESIDUAL_TUMOR_VOLUME_P_N3921          NORMAL         1
RESPONSE_TO_NEOADJUVANT_N3922          NORMAL         1
S_CATEGORY_CLINICAL_N3923              NORMAL         1
S_CATEGORY_PATHOLOGICAL_N3924          NORMAL         1
SARCOMATOID_FEATURES_N3925             NORMAL         1
SCHEMA_DISCRIMINATOR1_N3926            NORMAL         1
SCHEMA_DISCRIMINATOR2_N3927            NORMAL         1
SCHEMA_DISCRIMINATOR3_N3928            NORMAL         1
SEPARATE_TUMOR_NODULES_N3929           NORMAL         1
SERUM_ALBUMIN_PRETREATM_N3930          NORMAL         1
SERUM_BETA2_MICROGLOBUL_N3931          NORMAL         1
LDH_PRETREATMENT_LAB_VA_N3932          NORMAL         1
THROMBOCYTOPENIA_N3933                 NORMAL         1
TUMOR_DEPOSITS_N3934                   NORMAL         1
TUMOR_GROWTH_PATTERN_N3935             NORMAL         1
ULCERATION_N3936                       NORMAL         1
VISCERAL_AND_PARIETAL_P_N3937          NORMAL         1
PATH_REPORTING_FAC_ID1_N7010           PRIVATE        1
PATH_REPORTING_FAC_ID2_N7011           PRIVATE        1
PATH_REPORTING_FAC_ID3_N7012           PRIVATE        1
PATH_REPORTING_FAC_ID4_N7013           PRIVATE        1
PATH_REPORTING_FAC_ID5_N7014           PRIVATE        1
PATH_REPORT_NUMBER1_N7090              PRIVATE        1
PATH_REPORT_NUMBER2_N7091              PRIVATE        1
PATH_REPORT_NUMBER3_N7092              PRIVATE        1
PATH_REPORT_NUMBER4_N7093              PRIVATE        1
PATH_REPORT_NUMBER5_N7094              PRIVATE        1
PATH_ORDER_PHYS_LIC_NO1_N7100          PRIVATE        1
PATH_ORDER_PHYS_LIC_NO2_N7101          PRIVATE        1
PATH_ORDER_PHYS_LIC_NO3_N7102          PRIVATE        1
PATH_ORDER_PHYS_LIC_NO4_N7103          PRIVATE        1
PATH_ORDER_PHYS_LIC_NO5_N7104          PRIVATE        1
PATH_ORDERING_FAC_NO1_N7190            PRIVATE        1
PATH_ORDERING_FAC_NO2_N7191            PRIVATE        1
PATH_ORDERING_FAC_NO3_N7192            PRIVATE        1
PATH_ORDERING_FAC_NO4_N7193            PRIVATE        1
PATH_ORDERING_FAC_NO5_N7194            PRIVATE        1
PATH_DATE_SPEC_COLLECT1_N7320          NORMAL         1
PATH_DATE_SPEC_COLLECT2_N7321          NORMAL         1
PATH_DATE_SPEC_COLLECT3_N7322          NORMAL         1
PATH_DATE_SPEC_COLLECT4_N7323          NORMAL         1
PATH_DATE_SPEC_COLLECT5_N7324          NORMAL         1
PATH_REPORT_TYPE1_N7480                NORMAL         1
PATH_REPORT_TYPE2_N7481                NORMAL         1
PATH_REPORT_TYPE3_N7482                NORMAL         1
PATH_REPORT_TYPE4_N7483                NORMAL         1
PATH_REPORT_TYPE5_N7484                NORMAL         1

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
	value $TUMOR_RECORD_NUMBER_N60_f	'01'-'99' = 'valid coded value'
										' ' = 'missing value' other = 'invalid value'
										;

	value	$RACE1_N160_f	'01','02','03','04','05','06','07','08','10',
							'11','12','13','14','15','16','17','20','21',
							'22','25','26','27','28','30','31','32','96',
							'97','98','99' = 'valid coded value' other = 'invalid value'
							' ' = 'missing value'
							;
	
	value	$RACE2_N161_f	'01','02','03','04','05','06','07','08','10',
							'11','12','13','14','15','16','17','20','21',
							'22','25','26','27','28','30','31','32','96',
							'97','88','98','99' = 'valid coded value'
							' ' = 'missing value' other = 'invalid value'
							;

	value	$RACE3_N162_f	'01','02','03','04','05','06','07','08','10',
							'11','12','13','14','15','16','17','20','21',
							'22','25','26','27','28','30','31','32','96',
							'97','88','98','99' = 'valid coded value'
							' ' = 'missing value' other = 'invalid value'
							;
	value	$RACE4_N163_f	'01','02','03','04','05','06','07','08','10',
							'11','12','13','14','15','16','17','20','21',
							'22','25','26','27','28','30','31','32','96',
							'97','88','98','99' = 'valid coded value'
							' ' = 'missing value' other = 'invalid value'
							;

	value	$RACE5_N164_f	'01','02','03','04','05','06','07','08','10',
							'11','12','13','14','15','16','17','20','21',
							'22','25','26','27','28','30','31','32','96',
							'97','88','98','99' = 'valid coded value'
							' ' = 'missing value' other = 'invalid value'
							;

	value $SPANISH_HISPANIC_ORIGIN_N190_f	'0','1','2','3','4','5','6',
											'7','8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $NHIA_DERIVED_HISP_ORIGI_N191_f	'0','1','2','3','4','5','6',
											'7','8' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $SEX_N220_f		'1','2','3','4','5','6','9' = 'valid coded value'
							' ' = 'missing value' other = 'invalid value'
							;

	value $SEQUENCE_NUMBER_CENTRAL_N380_f	'00'-'59','60'-'87','88',
											'98','99' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value';
											;

	*Most sites should have the sequence number-hospital variable populated, but some may use the
	central version instead;

	value $SEQUENCE_NUMBER_HOSPITA_N560_f	'00'-'59','60'-'87','88',
											'98','99' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value';
											;

	value $LATERALITY_N410_f	'0','1','2','3','4','5','9' = 'valid coded value'
								' ' = 'missing value' other = 'invalid value'
								;

	value $DIAGNOSTIC_CONFIRMATION_N490_f	'1','2','3','4','5','6','7',
											'8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $BEHAVIOR_CODE_ICD_O3_N523_f		'0','1','2','3' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $CLASS_OF_CASE_N610_f		'00','10','11','12','13','14','20','21','22','30',
									'31','32','33','34','35','36','37','38','40','41',
									'42','43','49','99' = 'valid coded value'
									' ' = 'missing value' other = 'invalid value'
									;

	value $VITAL_STATUS_N1760_f		'0','1' = 'valid coded value'
									' ' = 'missing value' other = 'invalid value'
									;

	value $RX_HOSP_SURG_PRIM_SITE_N670_f 	'00','10'-'19','20'-'80',
											'90','98','99' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $RX_SUMM_SURG_PRIM_SITE_N1290_f	'00','10'-'19','20'-'80',
											'90','98','99' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $RX_HOSP_RADIATION_N690_f			'0','1','2','3','4','5',
											'9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $RX_SUMM_RADIATION_N1360_f 		'0','1','2','3','4','5',
											'6','7','8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $REASON_FOR_NO_RADIATION_N1430_f	'0','1','2','5','6','7',
											'8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value';
											;

	value $SEER_SUMMARY_STAGE2000_N759_f	'0','1','2','3','4','5',
											'7','8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $SUMMARY_STAGE2018_N764_f			'0','1','2','3','4',
											'7','8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $DERIVED_SUMMARY_STAGE20_N762_f	'0','1','2','3','4',
											'7','8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $GRADE_N440_f 					'1','2','3','4','5','6','7',
											'8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $GRADE_CLINICAL_N3843_f			'1','2','3','4','5','A','B',
											'C','D','E','L','H','M','S',
											'8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $GRADE_PATHOLOGICAL_N3844_f		'1','2','3','4','5','A','B',
											'C','D','E','L','H','M','S',
											'8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $GRADE_POST_THERAPY_N3845_f		'1','2','3','4','5','A','B',
											'C','D','E','L','H','M','S',
											'8','9' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $PRIMARY_SITE_N400_f			'C000'-'C809' = 'valid coded value'
										' ' = 'missing value' other = 'invalid value';

	value $HISTOLOGIC_TYPE_ICD_O3_N522_f	'8000'-'9989' = 'valid coded value'
											' ' = 'missing value' other = 'invalid value'
											;

	value $DERIVED_SS2000_N3020_f	'0','1','2','3','4','5',
									'7','8','9' = 'valid coded value'
									' ' = 'missing value' other = 'invalid value'
									;

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

	value	$timing_f		'1' = 'not a priority variable'
							'2' = 'priority variable for all dx years'
							'3' = 'priority variables for dx through 2017'
							'4' = 'priority variables for 2018+ dx'
							'5' = 'SEER_SUMMARY_STAGE2000_N759 - 2001+ diagnoses'
							;
	value tumor_count_f     . = 'Missing' 1 = '1' 2 = '2' 3 = '3' 4 - HIGH = '>=4';
run;

/************************************************************

 CHECK THAT THE CORRECT VARIABLES ARE PRESENT IN TUMOR TABLE

 ************************************************************/

proc contents data = indata.TUMOR
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
/*proc print data = missingvars noobs;
	var variable flag;
run;*/

footnote1 justify=center "Missing priority variables are highlighted in green, missing normal variables are highlighted in blue.";

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
            if flag0='PRIORITY' then do;
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
            if flag1='PRIORITY' then do;
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
            if flag2='PRIORITY' then do;
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

%put &private_varlist;

%do x = 1 %to &private_values_num;
proc freq data = indata.TUMOR noprint;
	format %scan(&private_varlist,&x) $private_f.;
	table %scan(&private_varlist,&x) / missing out=work.temp_freq;
run;

data work.temp_freq1;
set work.temp_freq;
format var_name $char32. Cat_lab $char18.;
var_name="%scan(&private_varlist,&x)";
if %scan(&private_varlist,&x) = '' then Cat_lab = 'NULL'; else Cat_lab = put(%scan(&private_varlist,&x),private_f.);
run;

proc transpose data=work.temp_freq1 out=work.freqwide;
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

*create list of included priority variables;
data priority; set includedvars;
	if flag = 'PRIORITY';
run;

data priority_categorical; set priority;
	if variable in ('PATID','AGE_AT_DIAGNOSIS_N230','DATE_OF_DIAGNOSIS_N390')
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
run;

***********;

*Examine values of priority variables;
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

	%if %scan(&priority_timing,&x) = 3 %then
		%str(where dxyear <= 2017;);
	%else %if %scan(&priority_timing,&x) = 4 %then
		%str(where dxyear >=2018;);
	%else %if %scan(&priority_timing,&x) = 5 %then
		%str(where dxyear >=2001;);
	%else %if %scan(&priority_timing,&x) = 6 %then
		%str(where dxyear >=2004;);

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
footnote1 justify=left 'Either SEQUENCE_NUMBER_HOSPITA_N560 or SEQUENCE_NUMBER_CENTRAL_N380 should be populated. 
Some missing and invalid values may not be cause for concern. Future versions of this report will flag percentages 
that reach problem levels.';


*footnote1 justify=center '';
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
proc freq data = indata.TUMOR noprint;
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
	tables patid*&SEQNUM / out = tumor_count;
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
footnote1 justify=left "There should not be any patients in tumor table without encounters. 
Each unique tumor (indicated by combination of PATID and sequence number) should have one record.";

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
