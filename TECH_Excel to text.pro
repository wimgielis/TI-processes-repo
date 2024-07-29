601,100
602,"TECH_Excel to text"
562,"NULL"
586,
585,
564,
565,"g:EsB^WaEy]<\sFJ8zOB4g1MqSxvMm1<StTR=;HGXM@ss=EURtjAk=BlRKom4kMID];VUCn]j]kj^esyUFIF<5gv0gRn2[NRz@TPZmUUT@SInNkPJ\ihA\6?cZQpMAoMWWpb1u;xPzinJK[_^\;MH?;U;NB1Cg]Lr;<_qaG:6;=xxldVK2\n`z4>wP[VJq=7xfmiGPmr"
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
589,",	"
568,""""
570,
571,
569,0
592,0
599,1000
560,4
pFile
pPath
pScript
pExtension
561,4
2
2
2
2
590,4
pFile,"*"
pPath,"D:\OneDrive\OneDrive - Aexis Belgium NV\Z_Rest\TM1 Log files TI processes\TM1 output\Excel to text*\"
pScript,"D:\OneDrive\OneDrive - Aexis Belgium NV\Wim\TM1\TI processes\TECH_Excel to text.ps1"
pExtension,"txt"
637,4
pFile,"Excel files to be converted ? ( supported: xls / xlsx / xlsm / xlsb ) ( wildcards allowed )"
pPath,"Folder of the Excel file to be converted ? ( wildcards allowed )"
pScript,"PowerShell file and folder ? ( if no valid path specified, then TM1 data dir )"
pExtension,"Extension ? ( supported: txt / csv )"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,234

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# May 2021
# https://www.wimgielis.com
####################################################
#
# This process can convert an Excel file to a text file format
# You can create a txt file (tab delimited) or csv file
# Allowed extensions: xls, xlsx, xlsm, xlsb
#
# The process uses PowerShell but can also use vbScript if wanted
#  - If vbScript is used then the path cannot contain wildcards, the file can
#  - If PowerShell is used then the path and file can both contain wildcards
#
# It is possible to block runs of this process, if it's already running.
#    2 users could run it at the same time, for example.
#    Set nNumberOfSeconds_Allowed = 0 below in the code if you do not want to block the concurrent runs.
#
####################################################

######
# Intermezzo:
# TECHNICAL REQUIREMENT, other than Excel being installed, and closed at the moment of running the process:
# a certain folder should exist ! Even if it exists, delete it and recreate it manually
# Refer to: http://www.tm1forum.com/viewtopic.php?f=3&t=7697#p34024
# and the information contained in: http://forums.techarena.in/windows-security/1297117.htm
#
# The account that has to create this folder should be the TM1 service account
######
If( 1 = 0 );

cPath = 'C:\Windows\System32\config\systemprofile\Desktop\';
vCommand = 'cmd /c if not exist "' | cPath | '\NUL" md "' | cPath | '"';
ExecuteCommand( vCommand, 1 );

cPath = 'C:\Windows\SysWOW64\config\systemprofile\Desktop\';
vCommand = 'cmd /c if not exist "' | cPath | '\NUL" md "' | cPath | '"';
ExecuteCommand( vCommand, 1 );

EndIf;
######
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
nRet = ExecuteProcess( 'TECH_Excel to text'
  , 'pFile', 'data*.* or *.xls*'
  , 'pPath', 'TM1\Data*\'
  , 'pScript', 'TECH_Excel to text.ps1 or .vbs'
  , 'pExtension', 'txt or csv'
);
If( nRet <> 0 );
   ProcessQuit;
EndIf;
EndIf;
#EndRegion CallThisProcess


pFile = Trim( pFile );
pPath = Trim( pPath );
pScript = Trim( pScript );
pExtension = Lower( Trim( pExtension ));
vCountOfFiles = 0;


# technical requirement
attr = 'Block execution';

If( CubeExists( '}ProcessAttributes' ) = 0 );
   ProcessAttrDelete( attr );
   ProcessAttrInsert( '', attr, 'S' );
EndIf;

If( DimensionExists( '}ProcessAttributes' ) = 0 );
   ProcessAttrDelete( attr );
   ProcessAttrInsert( '', attr, 'S' );
EndIf;

If( Dimix( '}ProcessAttributes', attr ) = 0 );
   ProcessAttrDelete( attr );
   ProcessAttrInsert( '', attr, 'S' );
EndIf;


If( Subst( pPath, Long( pPath ), 1 ) @<> '\' );
   pPath = pPath | '\';
EndIf;

vInputFile = pPath | pFile;

# check the file extension for the new text file
If( pExtension @<> 'txt'
  & pExtension @<> 'csv' );
     LogOutput( 'ERROR', 'Invalid extension specified: ''' | pExtension | '''.');
     ProcessError;
Else;
     pExtension = '.' | pExtension;
EndIf;

# check the script file that will do the conversion
If( FileExists( pScript ) = 0 );
   LogOutput( 'ERROR', 'No script file found that will do the conversion. Test done on: ''' | pScript | '''.');
   ProcessError;
EndIf;

# check the file extension for the script file
If( Subst( pScript, Long( pScript ) - 2, 3 ) @<> 'ps1'
  & Subst( pScript, Long( pScript ) - 2, 3 ) @<> 'vbs' );
     LogOutput( 'ERROR', 'The provided file for the script does not seem to have .ps1 or .vbs as file extension. Test done on: ''' | pScript | '''.');
     ProcessError;
EndIf;

# for a vbScript file solution, the path cannot contain wildcards
If( Subst( pScript, Long( pScript ) - 2, 3 ) @= 'vbs' );

   If( Scan( '*', pPath ) > 0
     % Scan( '?', pPath ) > 0 );
      LogOutput( 'ERROR', 'The provided path for the files to be converted, contains wildcards. Test done on: ''' | pPath | '''.');
      # If( Scan( '*', vInputFile ) > 0
      #   % Scan( '?', vInputFile ) > 0 );
      #    LogOutput( 'ERROR', 'No file found for a vbScript conversion to text: ''' | vInputFile | '''.');
      # EndIf;
      ProcessError;
   EndIf;

EndIf;



# Blocking 2 runs of the same process
nNumberOfSeconds_Allowed = 30;
If( nNumberOfSeconds_Allowed > 0 );

attr = 'Block execution';

# ProcessAttrDelete( attr );
# ProcessAttrInsert( '', attr, 'S' );

vStop = 0;
One_Sec = 1 / 24 / 60 / 60;
vStart = Now;
While( vStop = 0 );

   # Wait for your own turn
   If( ProcessAttrS( GetProcessName, attr ) @= '' 
     % ProcessAttrS( GetProcessName, attr ) @= 'N' );
      vStop = 1;
   Else;
      # After x seconds, stop trying
      If( Now - vStart >= nNumberOfSeconds_Allowed * One_Sec );
         LogOutput( 'INFO', GetProcessName | ': ' | 'The run was blocked because of a different run of the same process (maybe the last run did not finish correctly). Waiting time of ' | NumberToString( nNumberOfSeconds_Allowed ) | 'second(s).');
         ProcessError;
      EndIf;
   EndIf;

   # Wait a second and retry
   Sleep( 1000 );

End;

# Now it's your turn, but don't let others come in
ProcessAttrPutS( 'Y', GetProcessName, attr );
CubeSaveData( '}ProcessAttributes' );

EndIf;


# Now the code follows, put differently, the real meat and potatoes of the process
If( Subst( pScript, Long( pScript ) - 2, 3 ) @= 'ps1' );

   # let's use PowerShell
   # the input file and or the path can contain wildcards
   # vCommand = 'cmd /c "PowerShell.exe -file "' | pScript | '" "' | vInputFile | '" "' | pExtension | '""';
   vCommand = Expand( 'cmd /c "PowerShell.exe -file "%pScript%" "%vInputFile%" "%pExtension%""' );
   ExecuteCommand( vCommand, 1 );

Else;

   # alternatively, let's use vbScript but then no wildcards are allowed in the path
   # loop over files and convert
   iLoop = 1;
   vMax = 2;
   vLastExcel = '';

   While( iLoop < vMax );

      vMask = pPath | pFile;
      vExcel = WildcardFileSearch( vMask, vLastExcel );
      If( vExcel @<> '' );
         vExtension = Subst( vExcel, Long( vExcel ) - 3, 4 );
         If( Lower( vExtension ) @= '.xls' %
             Lower( vExtension ) @= 'xlsx' %
             Lower( vExtension ) @= 'xlsm' %
             Lower( vExtension ) @= 'xlsb' );

               ExecuteCommand( 'cscript "' | pScript | '" "' | pPath | vExcel | '" "' | pExtension | '"', 1 );
               vCountOfFiles = vCountOfFiles + 1;

         EndIf;

         vLastExcel = vExcel;
         vMax = vMax + 1;
      Else;
         vMax = 1;
      EndIf;

      iLoop = iLoop + 1;

   End;

   # Summary
   If( vCountOfFiles = 0 );
      LogOutput( 'INFO', 'No Excel files were found. Test done on: ''' | vMask | '''.');
   ElseIf( vCountOfFiles = 1 );
      LogOutput( 'INFO', '1 Excel file was converted.');
   Else;
      LogOutput( 'INFO', NumberToString( vCountOfFiles ) | ' Excel files were converted.');
   EndIf;

EndIf;

# Leave for the next run of the process
If( nNumberOfSeconds_Allowed > 0 );
   ProcessAttrPutS( 'N', GetProcessName, attr );
   CubeSaveData( '}ProcessAttributes' );
EndIf;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,4

#****Begin: Generated Statements***
#****End: Generated Statements****

576,CubeAction=1511DataAction=1503CubeLogChanges=0
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
