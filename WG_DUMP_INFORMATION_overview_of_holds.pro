﻿601,100
602,"WG_DUMP_INFORMATION_overview_of_holds"
562,"NULL"
586,
585,
564,
565,"jcqyvR[g99a96v6LBlnm8<T_GaM6DzI\4ZggbfuoAnFz?kPIADb:LnG[HK89LjN7`A^f6zH1@863Rf<KflJHY5RmICAaP\1k]]APRF8=b]:mJCU=;UgJVXBL^6vZiuGqYohYgtg9hHKWE9y@ls1lGK7xHSHSx^jeiTG`yT=_qYRq@]WV=fUbIw24bmJc>mFt@ANXqyPq"
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
571,
569,0
592,0
599,1000
560,5
pCube
pClient
pGroup
pDelim
pSkipNonExistentHoldsCubes
561,5
2
2
2
2
1
590,5
pCube,""
pClient,""
pGroup,""
pDelim,"&"
pSkipNonExistentHoldsCubes,0
637,5
pCube,"REQUIRED: Treat which Holds cube(s) ? Provide the base cube name(s). Supports a list and wildcards * and ? and keyword MODELCUBES."
pClient,"REQUIRED or used in conjunction with pGroup. Treat the Holds cube(s) of which client(s) ? Supports a list and wildcards * and ? and keyword MYSELF."
pGroup,"REQUIRED or used in conjunction with pClient. Treat the Holds cube(s) of which client(s) in which group(s) ? Supports a list and wildcards * and ? and keyword MYGROUPS."
pDelim,"OPTIONAL: Delimiter character for the different lists. (default value if blank = '&')"
pSkipNonExistentHoldsCubes,"OPTIONAL: When using lists and wildcards, it can lead to non-existent holds cubes. 1=Silently ignore these. Default=0."
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,397


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This TI process can export TM1 cube holds to text files. Holds are a personal tool for a TM1 user in any TM1 client.
# This process is a simplified version of the process 'WG_CUBE_holds'.
#
# A hold by client A does not restrict data entry by client B.
# A client needs write access to a cell in order to apply a hold to the cell.
# Existing Bedrock processes are leveraged including their default parameter values.
#
# Parameters:
# - pCube (mandatory). Provide the base cuube name(s), not the Holds cube names! It could be a combination of:
#     * multiple cubes separated with pDelim
#     * wildcards * and ?
#     * the keyword MODELCUBES (the cubes excluding the control cubes)
# - pClient (mandatory or used in conjunction with pGroup). It could be a combination of:
#     * multiple clients separated with pDelim
#     * wildcards * and ?
#     * the keyword MYSELF (the client running this TI process)
# - pGroup (mandatory or used in conjunction with pClient). It could be a combination of:
#     * multiple clients separated with pDelim
#     * wildcards * and ?
#     * the keyword MYGROUPS (the groups that the client running this TI process is a member of)
# - pDelim (standard Bedrock parameter to manage above lists, default value if blank = '&')
# - pSkipNonExistentHoldsCubes (When using lists and wildcards, it can lead to non-existent holds cubes. Use 1 to skip silently.
#
# Note:
# - The file format will respect the default values of the Bedrock process to export data. The file name is '}Hold_[ClientName]_}}_[CubeName].csv so it matches the Holds cubename.
# - The selections for pClient and pGroup will lead to a list of unique clients, for which we export.
#   For a group, the members in the group are retrieved, and added to the selected client(s).
# - At least 1 client should be returned from the provided parameter values, if not the process will abort
# - No support for PAW alternate hierarchies
#
###########################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
# - }bedrock.cube.create
# - }bedrock.cube.data.clear
# - }bedrock.cube.data.export
# - }bedrock.cube.data.import
# - }bedrock.hier.create
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_holds'
  , 'pCube', ''
  , 'pClient', ''
  , 'pGroup', ''
  , 'pDelim', '&'
  , 'pSkipNonExistentHoldsCubes', 1
  );
EndIf;
#EndRegion CallThisProcess


##Global Variables
StringGlobalVariable('sProcessReturnCode');
NumericGlobalVariable('nProcessReturnCode');
nProcessReturnCode = 0;

### Constants ###
cThisProcName     = GetProcessName();
cTimeStamp        = TimSt( Now, '\Y\m\d\h\i\s' );
cRandomInt        = NumberToString( INT( RAND( ) * 1000 ));
cTempSub          = cThisProcName |'_'| cTimeStamp |'_'| cRandomInt;
cUserName         = TM1User;
cHoldsCube        = '}Hold_%sClient%_}}_%sCube%';
cMsrDim           = '}Hold';
nCubes            = 0;
nDimMax           = 100;
nErrors           = 0;
sMessage          = '';
cUserName         = TM1User();
cMsgErrorLevel    = 'ERROR';
cMsgErrorContent  = 'User:%cUserName% Process:%cThisProcName% ErrorMsg:%sMessage%';
cLogInfo          = 'Process:%cThisProcName% run with parameters pCube:%pCube%, pClient:%pClient%, pGroup:%pGroup%, pDelim:%pDelim%, pMode:%pMode%, pSkipNonExistentHoldsCubes:%pSkipNonExistentHoldsCubes%.' ;


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of holds', 'pMainFolder', '1+' );


## LogOutput parameters
LogOutput('INFO', Expand( cLogInfo ) );

### Validate Parameters ###
nErrors = 0;

## Validate the Cube parameter
If( TRIM(pCube) @= '' );
   sMessage = 'A cube name must be provided.';
   nErrors = nErrors + 1;
   LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;

# If no clients and groups have been specified then terminate process
If( Trim( pClient ) @= '' & Trim( pGroup ) @= '' );
   nErrors = 1;
   sMessage = 'No clients and groups specified.';
   LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;

# If blank delimiter specified then convert to default
If( pDelim @= '' );
   pDelim = '&';
EndIf;

# Skipping non-existent holds cubes
If( pSkipNonExistentHoldsCubes <> 1 );
   pSkipNonExistentHoldsCubes = 0;
EndIf;

### Check for errors before continuing
If( nErrors <> 0 );
   ProcessQuit;
EndIf;



# # # # # # # # # #        SEARCH FOR CUBES BY INSPECTING CUBE PARAMETER
# - pCube (mandatory). It could be a combination of:
#     * multiple cubes separated with pDelim
#     * wildcards * and ?
#     * the keyword MODELCUBES (the cubes excluding the control cubes)

### Split parameter into individual cubes and store in a temporary subset ###
SubsetCreate( '}Cubes', 'Cubes subset', 1 );

sCubes = pCube;
nDelimiterIndex = 1;
While( nDelimiterIndex <> 0 );
   nDelimiterIndex = Scan( pDelim, sCubes );
   If( nDelimiterIndex = 0 );
      sCube = sCubes;
   Else;
      sCube = Trim( SubSt( sCubes, 1, nDelimiterIndex - 1 ) );
      sCubes = Trim( Delet( sCubes, 1, nDelimiterIndex + Long(pDelim) ) );
   EndIf;

   If( sCube @<> '' );
      # Create subset of cubes. Wildcards could be involved.

      If( sCube @= 'MODELCUBES' );
         sMDX = '{Except( TM1SubsetAll( [}Cubes] ), TM1FilterByPattern( TM1SubsetAll( [}Cubes] ), "}*" ))}';
      Else;
         sMDX = '{TM1FilterByPattern( TM1SubsetAll( [}Cubes] ), "' | sCube | '" )}';
      EndIf;

      If( SubsetExists( '}Cubes', cTempSub ) = 1 );
         # If a delimited list of cube names includes wildcards then we may have to re-use the subset multiple times
         SubsetMDXSet( '}Cubes', cTempSub, sMDX );
      Else;
         # temp subset, therefore no need to destroy in the Epilog tab
         SubsetCreatebyMDX( cTempSub, sMDX, '}Cubes', 1 );
      EndIf;

      # Loop through the returned cubes, if any
      nCountCubes = 1;
      While( nCountCubes <= SubsetGetSize( '}Cubes', cTempSub ) );
         sCurrCube = SubsetGetElementName( '}Cubes', cTempSub, nCountCubes );
         # Validate cube name
         If( CubeExists( sCurrCube ) = 1 );
            If( SubsetElementExists( '}Cubes', 'Cubes subset', sCurrCube ) = 0 );
               SubsetElementInsert( '}Cubes', 'Cubes subset', sCurrCube, 0 );
            EndIf;
         EndIf;
         nCountCubes = nCountCubes + 1;
      End;
   EndIf;

End;

# If no cubes found
nFoundCubesCount = SubsetGetSize( '}Cubes', 'Cubes subset' );
If( nFoundCubesCount = 0 );
   nErrors = 1;
   sMessage = 'No cubes found after processing pCube.';
   LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
Else;
   sMessage = 'Number of cubes found that match pCube: ' | NumberToString( nFoundCubesCount );
   LogOutput('INFO', Expand( sMessage ) );
EndIf;


# # # # # # # # # #        SEARCH FOR CLIENTS BY INSPECTING CLIENTS AND GROUPS PARAMETERS
# - pClient (mandatory or used in conjunction with pGroup). It could be a combination of:
#     * multiple clients separated with pDelim
#     * wildcards * and ?
#     * the keyword MYSELF (the client running this TI process)

# - pGroup (mandatory or used in conjunction with pClient). It could be a combination of:
#     * multiple clients separated with pDelim
#     * wildcards * and ?
#     * the keyword MYGROUPS (the groups that the client running this TI process is a member of)

### Split parameter into individual clients and store in a temporary subset ###
SubsetCreate( '}Clients', 'Clients subset', 1 );

sClients = pClient;
nDelimiterIndex = 1;
While( nDelimiterIndex <> 0 );
   nDelimiterIndex = Scan( pDelim, sClients );
   If( nDelimiterIndex = 0 );
      sClient = sClients;
   Else;
      sClient = Trim( SubSt( sClients, 1, nDelimiterIndex - 1 ) );
      sClients = Trim( Delet( sClients, 1, nDelimiterIndex + Long(pDelim) ) );
   EndIf;

   If( sClient @<> '' );

      If( sClient @= 'MYSELF' );
         sClient = cUserName;
      EndIf;

      # Create subset of clients using Wildcard. Wildcards could be involved.
      sMDX = '{TM1FilterByPattern( TM1SubsetAll( [}Clients] ), "' | sClient | '" )}';

      If( SubsetExists( '}Clients', cTempSub ) = 1 );
         # If a delimited list of client names includes wildcards then we may have to re-use the subset multiple times
         SubsetMDXSet( '}Clients', cTempSub, sMDX );
      Else;
         # temp subset, therefore no need to destroy in the Epilog tab
         SubsetCreatebyMDX( cTempSub, sMDX, '}Clients', 1 );
      EndIf;

      # Loop through the returned clients, if any
      nCountClients = 1;
      While( nCountClients <= SubsetGetSize( '}Clients', cTempSub ) );
         sCurrClient = SubsetGetElementName( '}Clients', cTempSub, nCountClients );
         # Validate client name
         If( Dimix( '}Clients', sCurrClient ) > 0 );
            If( SubsetElementExists( '}Clients', 'Clients subset', sCurrClient ) = 0 );
               SubsetElementInsert( '}Clients', 'Clients subset', sCurrClient, 0 );
            EndIf;
         EndIf;
         nCountClients = nCountClients + 1;
      End;
   EndIf;

End;


### Split parameter into individual groups and store in a temporary subset ###
SubsetCreate( '}Groups', 'Groups subset', 1 );

sGroups = pGroup;
nDelimiterIndex = 1;
While( nDelimiterIndex <> 0 );
   nDelimiterIndex = Scan( pDelim, sGroups );
   If( nDelimiterIndex = 0 );
      sGroup = sGroups;
   Else;
      sGroup = Trim( SubSt( sGroups, 1, nDelimiterIndex - 1 ) );
      sGroups = Trim( Delet( sGroups, 1, nDelimiterIndex + Long(pDelim) ) );
   EndIf;

   If( sGroup @<> '' );
      # Create subset of groups. Wildcards could be involved.

      If( sGroup @= 'MYGROUPS' );
         sMDX = '{Filter( TM1SubsetAll( [}Groups] ), [}ClientGroups].( [}Clients].[' | cUserName | '] ) <> "" )}';
      Else;
         sMDX = '{TM1FilterByPattern( TM1SubsetAll( [}Groups] ), "' | sGroup | '" )}';
      EndIf;

      If( SubsetExists( '}Groups', cTempSub ) = 1 );
         # If a delimited list of group names includes wildcards then we may have to re-use the subset multiple times
         SubsetMDXSet( '}Groups', cTempSub, sMDX );
      Else;
         # temp subset, therefore no need to destroy in the Epilog tab
         SubsetCreatebyMDX( cTempSub, sMDX, '}Groups', 1 );
      EndIf;

      # Loop through the returned groups, if any
      nCountGroups = 1;
      While( nCountGroups <= SubsetGetSize( '}Groups', cTempSub ) );
         sCurrGroup = SubsetGetElementName( '}Groups', cTempSub, nCountGroups );
         # Validate group name
         If( Dimix( '}Groups', sCurrGroup ) > 0 );
            If( SubsetElementExists( '}Groups', 'Groups subset', sCurrGroup ) = 0 );
               SubsetElementInsert( '}Groups', 'Groups subset', sCurrGroup, 0 );
            EndIf;
         EndIf;
         nCountGroups = nCountGroups + 1;
      End;
   EndIf;

End;
nFoundGroupsCount = SubsetGetSize( '}Groups', 'Groups subset' );


# Now rework groups into their clients through the security memberships
If( nFoundGroupsCount > 0 );

   # Create subset of clients using Wildcard. Wildcards could be involved.
   sMDX = 'Generate( TM1SubsetToSet([}Groups], "Groups subset" ), Filter( TM1SubsetAll([}Clients]), [}ClientGroups].([}Groups].CurrentMember) <> "" ))';
   If( SubsetExists( '}Clients', cTempSub ) = 1 );
      SubsetMDXSet( '}Clients', cTempSub, sMDX );
   Else;
      SubsetCreatebyMDX( cTempSub, sMDX, '}Clients', 1 );
   EndIf;

   # Loop through the returned clients, if any
   nCountClients = 1;
   While( nCountClients <= SubsetGetSize( '}Clients', cTempSub ) );
      sCurrClient = SubsetGetElementName( '}Clients', cTempSub, nCountClients );
      If( SubsetElementExists( '}Clients', 'Clients subset', sCurrClient ) = 0 );
         SubsetElementInsert( '}Clients', 'Clients subset', sCurrClient, 0 );
      EndIf;
      nCountClients = nCountClients + 1;
   End;
EndIf;


# If no clients found
nFoundClientsCount = SubsetGetSize( '}Clients', 'Clients subset' );
If( nFoundClientsCount = 0 );
   nErrors = 1;
   sMessage = 'No clients found after processing pClient and pGroup.';
   LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
Else;
   sMessage = 'Number of clients found that match pClient and pGroup: ' | NumberToString( nFoundClientsCount );
   LogOutput('INFO', Expand( sMessage ) );
EndIf;


### Check for errors before continuing
If( nErrors <> 0 );
  ProcessQuit;
EndIf;


# A double loop over cubes and clients to apply the selected action
nCountCubes = 1;
While( nCountCubes <= nFoundCubesCount );
   sCube = SubsetGetElementName( '}Cubes', 'Cubes subset', nCountCubes );
   nCubeDimCount = CubeDimensionCountGet( sCube );

   nCountClients = 1;
   While( nCountClients <= nFoundClientsCount );
      sClient = SubsetGetElementName( '}Clients', 'Clients subset', nCountClients );

      sHoldsCube = Expand( cHoldsCube );

      # From an existing Holds cube, export all entries
      If( CubeExists( sHoldsCube ) = 0 );
         If( pSkipNonExistentHoldsCubes = 0 );
            nErrors = 1;
            sMessage = Expand( 'The holds cube ''%sHoldsCube%'' does not exist so all of its holds (if any) could not be exported.' );
            LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
            ProcessQuit;
         EndIf;
      Else;

         If( nCubeDimCount > nDimMax );
            nErrors = 1;
            sMessage = Expand( 'The base cube ''%sCube%'' for the holds cube ''%sHoldsCube%'' contains too many dimensions. ' | NumberToString( nCubeDimCount ) | ' instead of at most ' | NumberToString( nDimMax ) | '.' );
            LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
            ProcessQuit;
         EndIf;

         # the file directory (If empty, the error file directory is used. If not existing, an error is returned.)
         #    this is done by the called Bedrock process
         # the file name is simply the Holds cube name with file extension csv
         sFileName = sHoldsCube | '.csv';
         nRet = ExecuteProcess( '}bedrock.cube.data.export', 'pLogOutput', 0, 'pStrictErrorHandling', 0,
            'pCube', sHoldsCube, 'pView', '', 'pFilter', '', 'pSuppressConsol', 0, 'pSuppressConsolStrings', 0,
            'pCubeLogging', 2, 'pFilePath', cDestination_Folder, 'pFileName', sFileName );
         If( nRet <> 0 );
            sMessage = Expand( 'Error exporting all the holds from the cube ''%sHoldsCube%'' to a flat file.' );
            nErrors = 1;
            LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
            ProcessQuit;
         EndIf;
         sMessage = Expand( 'All the holds in the cube ''%sHoldsCube%'' were exported.' );
         LogOutput('INFO', Expand( sMessage ) );
      EndIf;

      nCountClients = nCountClients + 1;
   End;

   nCountCubes = nCountCubes + 1;
End;
573,1

574,1

575,15


### Return code & final error message handling
If( nErrors > 0 );
   sMessage = 'the process incurred at least 1 error. Please see above lines in this file for more details.';
   nProcessReturnCode = 0;
   LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
   sProcessReturnCode = Expand( '%sProcessReturnCode% Process:%cThisProcName% completed with errors. Check tm1server.log for details.' );
   ProcessQuit;
Else;
   sProcessAction = Expand( 'Process:%cThisProcName% successfully performed %pMode% for cube ''%pCube%'', with client ''%pGroup%'' and group ''%pGroup%''.' );
   sProcessReturnCode = Expand( '%sProcessReturnCode% %sProcessAction%' );
   nProcessReturnCode = 1;
   LogOutput('INFO', Expand( sProcessAction ) );
EndIf;
576,_ParameterConstraints=e30=
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