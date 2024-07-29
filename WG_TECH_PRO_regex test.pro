601,100
602,"WG_TECH_PRO_regex test"
562,"NULL"
586,
585,
564,
565,"e^Hxral7O>pg2]V<59<mJ9HhGQ4hmw<O6=Y4\4EM2y]hpTA24ZGGf1:E68MhYn3OrkrFEvh<[51Llixs>]_e3`L0m2wTgLxj;]8>f`W:1=QhiUqqj;Ip:K^uJgNbD^[G`2EF5]^DLgHD?rYmiU:4oNqyjtIfr3GvS<i`<3=vZ4V:<N6=NgPQ`dtXn=Kvk;Svel:q3uN4"
559,1
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,0
567,","
588,"."
589,"."
568,""""
570,
571,
569,0
592,0
599,1000
560,0
561,0
590,0
637,0
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,52

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# March 2023
# https://www.wimgielis.com
####################################################

####################################################
#
# Written by: Dennis Bontekoning (Aexis)
# February 2016
# Source: http://www.tm1forum.com/viewtopic.php?f=21&t=12296
#
####################################################

#####
# Add the following process(es) to this TM1 model:
# - WG_TECH_PRO_regex find
# - WG_TECH_PRO_regex replace
#####
#EndRegion IntroduceThisProcess


StringGlobalVariable('Regex_replace_result');
NumericGlobalVariable('Regex_find_position');
NumericGlobalVariable('Regex_find_length');


#vString = 'vVariabletestname = vOthervariablename * (CellGetN(vCubename, cm_dim1, cm_dim2, cm_dim3) \ CellGetN(vCubename, cm_dim1, cm_dim2, cm_dim3))';
#vExpression = 'CellGet?(*,';
#vReplacement = '$& cm_extra,';

#vString = 'CellPutN(vVariabletestname, vCubename, cm_dim1, cm_dim2, cm_dim3)';
#vExpression = 'CellPut?(*,*,';
#vReplacement = '$& cm_extra,';

vString = 'TM1 is relatively ok!';
vExpression = '1*!';
vReplacement = '_';

ExecuteProcess('WG_TECH_PRO_regex find', 'pString', vString, 'pExpression', vExpression);
TextOutput( GetProcessErrorFileDirectory | 'regex_find_test.txt', vString, vExpression, NumberToString(Regex_find_position), NumberToString(Regex_find_length));


TextOutput( GetProcessErrorFileDirectory | 'regex_replace_test.txt', vString);
ExecuteProcess('WG_TECH_PRO_regex replace', 'pString', vString, 'pExpression', vExpression, 'pReplacement', vReplacement, 'pRun', 1, 'pEntryPos', 0);
TextOutput( GetProcessErrorFileDirectory | 'regex_replace_test.txt', Regex_replace_result);
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,3

#****Begin: Generated Statements***
#****End: Generated Statements****
576,CubeAction=1511DataAction=1503CubeLogChanges=0_DeployParams={&quotdimensionConflictResolutions&quot:{}&#044&quotclass&quot:&quotDeployParams&quot&#044&quotdataAction&quot:&quotACCUMULATE&quot}_ParseParams={&quotskipRows&quot:&quot0&quot&#044&quotlocale&quot:{&quotlanguange&quot:&quoten&quot&#044&quotvariant&quot:&quot&quot&#044&quotcountry&quot:&quotUS&quot}&#044&quotdimensions&quot:[]&#044&quotmeasures&quot:[]&#044&quotnumColumns&quot:&quot0&quot&#044&quothasHeader&quot:&quotfalse&quot}_importSourceDefinition={"scriptOnlySource":{},"sourceType":"NONE","originalColumns":null,"locale":{"localeIsDefault":false,"localeCurrencySymbol":"$","languageCode":"en","languageDisplay":"English","thousandsSeparator":",","localeCode":"en_US","localeCurrencyCode":"$","localeDisplay":"English (United States)","countryDisplay":"United States","countryCode":"US","decimalSeparator":"."},"excludedColumns":[],"columns":[],"sourceTypeHasBeenChanged":false}_ParameterConstraints=e30=
930,0
638,1
804,0
1217,1
900,
901,
902,
938,0
937,
936,
935,
934,
932,0
933,0
903,
906,
929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,0
921,""
922,""
923,0
924,""
925,""
926,""
927,""
