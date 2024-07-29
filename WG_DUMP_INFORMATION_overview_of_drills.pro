601,100
602,"WG_DUMP_INFORMATION_overview_of_drills"
562,"SUBSET"
586,"}Clients"
585,"}Clients"
564,
565,"w4aA\]dQ8K\nvUsb]PE^=@\ady`dzA@0Esu<t\gQkD?bYvcEJqSbOAe23BHCNt3uLAY\iEiL\W4oPGe:zyqds4PoIehM8FDBx3FMSUQoDTHpfo:SCD2VDOQgI:sBrSX8;\[pp[r<c\iq;KNamjSFSV;L9=d66dX:9ffhXXn;8RW8_am8\WY[WS_hdY44Zi:OQWT1=yS4"
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
589,"."
568,""""
570,
571,All
569,0
592,0
599,1000
560,1
pMode
561,1
2
590,1
pMode,"DO NOT USE !!!"
637,1
pMode,"Do not use: Internal parameter for our recursive processing"
577,1
vItem
578,1
2
579,1
1
580,1
0
581,1
0
582,1
VarType=32ColType=827
603,0
572,107

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This process can populate a text file with an overview of drills in a TM1 model:
# - drill on what cube ?
# - drill name ?
# - drill target type: cube, ODBC, text file
#
# This process uses recursion.
#
# The approach of this process is looping over the processes in the model.
# In case a drill cube exists without any drill process, this would not be tracked in the output.
#
####################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_drills' );
EndIf;
#EndRegion CallThisProcess


StringGlobalVariable( 'vDrill_Process' );

c0 = 'SomeRandomTextAUserWouldNeverUse';
cPrefix_PRO = '}Drill_';
cPrefix_CUB = '}CubeDrill_';

If( Subst( pMode, 1, 32 ) @<> c0 );

   # start and finish of the main process
   # not treating a specific drill process as part of the main loop

   # Where do we output text files ?
   StringGlobalVariable( 'cDestination_Folder' );
   ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of drills', 'pMainFolder', '1+' );

   vFile_Drills = cDestination_Folder | 'Drills.csv';
   AsciiDelete( vFile_Drills );

   ElementAttrInsert( '}Processes', '', '', 'Drill Name', 'S' );
   ElementAttrInsert( '}Processes', '', '', 'Drill Type', 'S' );
   ElementAttrInsert( '}Processes', '', '', 'Drill Cube', 'S' );
   ElementAttrInsert( '}Processes', '', '', 'Drill Cube has rules', 'S' );

   # loop over processes
   p = 1;
   While( p <= ElementCount( '}Processes', '' ));

      vProcess = ElementName( '}Processes', '', p );

      If( Scan( cPrefix_PRO, vProcess ) = 1 );

         vDrill_Name = Delet( vProcess, 1, Long( cPrefix_PRO ));
         ElementAttrPutS( vDrill_Name, '}Processes', '', vProcess, 'Drill Name' );

         vDrill_Process = vProcess;
         ExecuteProcess( GetProcessName, 'pMode', c0 | NumberToString( Int( Rand * 1000000 )));

      EndIf;

      p = p + 1;
   End;

   # no need to have a data source
   DatasourceType = 'NULL';

Else;

   # treatment of 1 TI process for a drill
   # in the Data tab, we loop over the file contents

   # set the datasource
   vFilename = vDrill_Process | '.pro';
   # or make the filename dynamic
   If( FileExists( vFilename ) > 0 );
      DataSourceType = 'CHARACTERDELIMITED';
      DataSourceNameForServer = vFilename;
      DataSourceNameForClient = vFilename;
      DataSourceAsciiQuoteCharacter = '';
      DataSourceAsciiDelimiter = '§';
   Else;
      DataSourceType = 'NULL';
      ProcessError;
   EndIf;

   vCode_590_Was_Seen = 0;
   vCode_575_Was_Seen = 0;

EndIf;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,60

#****Begin: Generated Statements***
#****End: Generated Statements****


If( Subst( pMode, 1, 32 ) @= c0 );

   # treatment of 1 TI process for a drill

   If( vCode_590_Was_Seen = 0 );
      If( Scan( '590,', Trim( vItem )) = 1 );
         vCode_590_Was_Seen = 1;
         ItemSkip;
      EndIf;
   EndIf;

   If( vCode_590_Was_Seen = 2 );
   If( vCode_575_Was_Seen = 0 );
      If( Scan( '575,', Trim( vItem )) = 1 );
         vCode_575_Was_Seen = 1;
         ItemSkip;
      EndIf;
   EndIf;
   EndIf;

   # we want to find the drill cube name (it's part of the parameters section)
   If( vCode_590_Was_Seen = 1 );
      If( Scan( 'cubename,', Lower( Trim( vItem ))) = 1 );
         vDrill_Cube = Delet( vItem, 1, 10 );
         vDrill_Cube = Delet( vDrill_Cube, Long( vDrill_Cube ), 1 );
         If( CubeExists( vDrill_Cube ) = 1 );
            ElementAttrPutS( vDrill_Cube, '}Processes', '', vDrill_Process, 'Drill Cube' );
            ElementAttrPutS( If( FileExists( cPrefix_CUB | vDrill_Cube | '.rux' ) = 1, 'Yes', 'No' ), '}Processes', '', vDrill_Process, 'Drill Cube has rules' );
         Else;
            ElementAttrPutS( '''' | vDrill_Cube | ''' - DOES NOT EXIST !', '}Processes', '', vDrill_Process, 'Drill Cube' );
            ElementAttrPutS( 'No', '}Processes', '', vDrill_Process, 'Drill Cube has rules' );
         EndIf;
      EndIf;
      vCode_590_Was_Seen = 2;
      Itemskip;
   EndIf;

   # we want to find the drill call (it's part of the Epilog tab)
   If( vCode_575_Was_Seen = 1 );
      If( Scan( Lower( 'RETURNVIEWHANDLE' ), Lower( Trim( vItem ))) = 1 );
         ElementAttrPutS( 'CUBE', '}Processes', '', vDrill_Process, 'Drill Type' );
         vCode_575_Was_Seen = 2;
         Itemskip;
      ElseIf( Scan( Lower( 'ReturnSqlTableHandle' ), Lower( Trim( vItem ))) = 1 );
         ElementAttrPutS( 'ODBC', '}Processes', '', vDrill_Process, 'Drill Type' );
         vCode_575_Was_Seen = 2;
         Itemskip;
      ElseIf( Scan( Lower( 'ReturnCSVTableHandle' ), Lower( Trim( vItem ))) = 1 );
         ElementAttrPutS( 'TEXT FILE', '}Processes', '', vDrill_Process, 'Drill Type' );
         vCode_575_Was_Seen = 2;
         Itemskip;
      EndIf;
   EndIf;

EndIf;
575,48

#****Begin: Generated Statements***
#****End: Generated Statements****


If( Subst( pMode, 1, 32 ) @<> c0 );

   DataSourceAsciiQuoteCharacter = '';
   DataSourceAsciiDelimiter = ';';

   # output the titles in the output file
   TextOutput( vFile_Drills, 'Area', 'Main Cube', 'Drill Cube', 'Drill Name', 'Drill Type', 'Drill Cube has rules' );

   # loop over processes
   n = 0;
   p = 1;
   While( p <= ElementCount( '}Processes', '' ));

      vProcess = ElementName( '}Processes', '', p );

      If( Scan( cPrefix_PRO, vProcess ) = 1 );

         n = n + 1;

         vDrill_Cube = ElementAttrS( '}Processes', '', vProcess, 'Drill Cube' );
         vDrill_Name = ElementAttrS( '}Processes', '', vProcess, 'Drill Name' );
         vDrill_Type = ElementAttrS( '}Processes', '', vProcess, 'Drill Type' );
         vDrill_Cube_has_rules = ElementAttrS( '}Processes', '', vProcess, 'Drill Cube has rules' );

         vArea = 'Process';
         TextOutput( vFile_Drills, vArea, vDrill_Cube, cPrefix_CUB | vDrill_Cube, vDrill_Name, vDrill_Type, vDrill_Cube_has_rules );

      EndIf;

      p = p + 1;
   End;

   If( n = 0 );
      TextOutput( vFile_Drills, 'No drills were found.', '', '', '' );
   EndIf;

   # clean up temporary objects
   ElementAttrDelete( '}Processes', '', 'Drill Name' );
   ElementAttrDelete( '}Processes', '', 'Drill Type' );
   ElementAttrDelete( '}Processes', '', 'Drill Cube' );
   ElementAttrDelete( '}Processes', '', 'Drill Cube has rules' );

EndIf;
576,CubeAction=1511DataAction=1503CubeLogChanges=0_ParameterConstraints=e30=
930,0
638,1
804,0
1217,0
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
