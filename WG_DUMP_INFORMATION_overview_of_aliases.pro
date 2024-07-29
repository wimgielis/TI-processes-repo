601,100
602,"WG_DUMP_INFORMATION_overview_of_aliases"
562,"NULL"
586,
585,
564,
565,"cdha\Md?>MQ9T4TJC\^E?Vlj;nVtGI\H=PSXq7_kDaLQfoSs1ZGuPDeaL:SvV^hBqRUUCIz?CmUM7BgE7Ob@izs;Kb7Ov4iP>]IjDUr0q:5QiBthoLLBs]1@e>SrUsEErgwnQ3XT<gLI:P7H8y9=Vix>@@S>1Z9J`ZbB:yr[mb_u[a?2VWy1`8qQ@L[<HSoryx6]e1c\"
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
588,","
589," "
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
572,81

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
###################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This process creates a CSV file
# The file contains 4 columns:
# - dimension name
# - subset name
# - alias name
# - *.sub path and file name
#
# Internet resources:
# https://greenydangerous.com/2013/07/04/tm1-list-all-subsets-per-dimension-and-their-assigned-aliases/
#
#######################################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_aliases' );
EndIf;
#EndRegion CallThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of aliases', 'pMainFolder', '1+' );

vFile_Code = cDestination_Folder | 'dims-subs-alias.ps1';
vFile_Output = cDestination_Folder | 'Subsets with alias.csv';
AsciiDelete( vFile_Output );


vCommand = 'Get-ChildItem -Recurse -Include *.sub |
Where-Object {$_.Directory -match "\w*}subs\b"} | Select-String -pattern "274," |
Select-Object Path, Filename, Line |
Where-Object {$_.Line -notmatch ",$" -AND $_.Path -notmatch "datafiles\\}" -AND $_.Path -notmatch "datafiles\\tunit"} |
ForEach-Object { $_.Path.Split(''\'')[-2].Split(''}'')[0] + ";"  + $_.Filename.Split(''.'')[0] + ";" + $_.Line.Split('','')[1] + ";" + $_.Path } |
Set-Content "' | vFile_Output | '"';


DataSourceAsciiQuoteCharacter = '';

TextOutput( vFile_Code, vCommand );
TextOutput( vFile_Code, 'Remove-Item $MyInvocation.InvocationName' );


######
# Note with respect to the use of PowerShell:
######
# Intermezzo:
# TECHNICAL REQUIREMENT:
# a certain folder should exist ! Even if it exists, delete it and recreate it manually
# Refer to: http://www.tm1forum.com/viewtopic.php?f=3&t=7697#p34024
# and the information contained in: http://forums.techarena.in/windows-security/1297117.htm
#
# The account that has to create this folder should be the TM1 service account
######
# cPath = 'C:\Windows\System32\config\systemprofile\Desktop\';
# vCommand = 'cmd /c if not exist "' | cPath | '\NUL" md "' | cPath | '"';
# ExecuteCommand( vCommand, 1 );
#
# cPath = 'C:\Windows\SysWOW64\config\systemprofile\Desktop\';
# vCommand = 'cmd /c if not exist "' | cPath | '\NUL" md "' | cPath | '"';
# ExecuteCommand( vCommand, 1 );
######
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,11

#****Begin: Generated Statements***
#****End: Generated Statements****


If( FileExists( vFile_Code ) > 0 );

   vCommand = 'cmd /c "PowerShell.exe -file "' | vFile_Code | '""';
   ExecuteCommand( vCommand, 1 );

EndIf;
576,CubeAction=1511DataAction=1503CubeLogChanges=0_ParameterConstraints=e30=
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
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
