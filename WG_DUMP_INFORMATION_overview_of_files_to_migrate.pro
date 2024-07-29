601,100
602,"WG_DUMP_INFORMATION_overview_of_files_to_migrate"
562,"NULL"
586,
585,
564,
565,"rUexNk9n1<JqPx2e>Va9J?RGL>FE;B`EY@2ZBDARTdpu[m5X`2K6arXG<pqxW[t7v;s=cCm`U5FaS::9GibPNG8td99geM5T3M=_?RTYp[USm8tQ0qrDZG5OH1k2ZwZ>Z1tZ4fdnlHs]JiLW_qy1]:OoO@v_GmRWz_aas^>aUn`1L;EmTnm?ppHWxRe0N7j[bkkZxJe3"
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
560,2
pName
pMode
561,2
2
1
590,2
pName,""
pMode,2
637,2
pName,"Dimension name or cube name ?"
pMode,"Mode ? (1 = dimension, 2 = cube. See inside the process for all options.)"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,222

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This process lists files that you need to backup given an object to delete/remove/ ...
#
# The parameter pMode determines the object:
# If pMode = 1, you treat 1 dimension. Specify the dimension name in pName.
# If pMode = 2, you treat 1 cube. Specify the cube name in pName.
#
# The output is a text file in the TM1 logging directory
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
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_holds'
  , 'pName', 'Dimension name or cube name ?'
  , 'pMode', 'Mode ? (1 = dimension, 2 = cube. See inside the process for all options.)'
  );
EndIf;
#EndRegion CallThisProcess


DataSourceAsciiQuoteCharacter = '';

# TO DO:
# - application items, views and subsets (both public and private)
# - Also on "auxiliary" cubes like attributes and security but this is most probably overkill to program

# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of files to migrate', 'pMainFolder', '1+' );


vFile = cDestination_Folder | 'backup_' | Timst( Now, '\Y-\m-\d \h\i\s' ) | '.txt';
TextOutput( vFile, 'Object type', 'Object type' );


If( pMode = 2 );

   pCube = pName;

   # cube itself
   If( CubeExists( pCube ) = 1 );
      TextOutput( vFile, 'application cube', pCube | '.cub' );
   Else;
      LogOutput( 'ERROR', 'The cube ''' | pCube | ''' does not exist.');
      ProcessQuit;
   EndIf;

   # cell security cube
   If( CubeExists( '}CellSecurity_' | pCube ) = 1 );
      TextOutput( vFile, 'cell security cube', '}CellSecurity_' | pCube | '.cub' );
   EndIf;

   # picklist cube
   If( CubeExists( '}Picklist_' | pCube ) = 1 );
      TextOutput( vFile, 'picklist cube', '}Picklist_' | pCube | '.cub' );
   EndIf;

   # picklist dimension
   If( DimensionExists( '}PickList' ) = 1 );
      TextOutput( vFile, 'picklist dimension', '}PickList.dim' );
   EndIf;

   # rules
   If( FileExists( '}Picklist_' | pCube | '.rux' ) = 1 );
      TextOutput( vFile, 'picklist cube rules', '}Picklist_' | pCube | '.rux' );
   EndIf;

   # cube security
   TextOutput( vFile, 'cube security cube', '}CubeSecurity' | '.cub' );

   If( FileExists( '}CubeSecurity.rux' ) = 1 );
      TextOutput( vFile, 'cube security cube rules', '}CubeSecurity.rux' );
   EndIf;

   TextOutput( vFile, 'dimension security cube', '}DimensionSecurity' | '.cub' );

   If( FileExists( '}DimensionSecurity.rux' ) = 1 );
      TextOutput( vFile, 'dimension security cube rules', '}DimensionSecurity.rux' );
   EndIf;


   # }Drill
   
   # cube drill cube
   If( CubeExists( '}CubeDrill_' | pCube ) = 1 );
      TextOutput( vFile, 'cube drill cube', '}CubeDrill_' | pCube | '.cub' );
   
      # cube drill dimension
      If( DimensionExists( '}CubeDrillString' ) = 1 );
         TextOutput( vFile, 'cube drill dimension', '}CubeDrillString.dim' );
      EndIf;
   
      # cube drill rules
      If( FileExists( '}CubeDrill_' | pCube | '.rux' ) = 1 );
         TextOutput( vFile, 'cube drill rules', '}CubeDrill_' | pCube | '.rux' );
      EndIf;
   
      # TO DO: other types of data like LOGGING, MEASURES dim, etc. also at the level of the dimensions
   
      If( CubeExists( '}CubeProperties' ) = 1 );
         TextOutput( vFile, 'cube properties cube', '}CubeProperties.cub' );
      EndIf;
   
      If( CubeExists( '}DimensionProperties' ) = 1 );
         TextOutput( vFile, 'dimension properties cube', '}DimensionProperties.cub' );
      EndIf;
   
   EndIf;

   # rules
   If( FileExists( pCube | '.rux' ) = 1 );
      TextOutput( vFile, 'cube rules', pCube | '.rux' );
   EndIf;

   # loop over dimensions
   m = 1;
   While( m <= CubeDimensionCountGet( pCube ));
      vDim = Tabdim( pCube, m );
   
      # dimension header
      TextOutput( vFile, ' ' );
      TextOutput( vFile, '# dimension name', vDim );
   
      # dimension
      TextOutput( vFile, 'dimension', vDim );
   
      # attributes cube
      If( CubeExists( '}ElementAttributes_' | vDim ) = 1 );
      TextOutput( vFile, 'element attributes cube', '}ElementAttributes_' | vDim | '.cub' );
      EndIf;
   
      # attributes dimension
      If( DimensionExists( '}ElementAttributes_' | vDim ) = 1 );
      TextOutput( vFile, 'element attributes dimension', '}ElementAttributes_' | vDim | '.dim' );
      EndIf;
   
      # element attributes cube rules
      If( FileExists( '}ElementAttributes_' | vDim | '.rux' ) = 1 );
      TextOutput( vFile, 'element attributes cube rules', '}ElementAttributes_' | vDim | '.rux' );
      EndIf;
   
      # element security cube
      If( CubeExists( '}ElementSecurity_' | vDim ) = 1 );
      TextOutput( vFile, 'element security cube', '}ElementSecurity_' | vDim | '.cub' );
      EndIf;
   
      # element security dimension
      If( DimensionExists( '}ElementSecurity_' | vDim ) = 1 );
      TextOutput( vFile, 'element security dimension', '}ElementSecurity_' | vDim | '.dim' );
      EndIf;
   
      # element security rules
      If( FileExists( '}ElementSecurity_' | vDim | '.rux' ) = 1 );
      TextOutput( vFile, 'element security cube rules', '}ElementSecurity_' | vDim | '.rux' );
      EndIf;
   
      m = m + 1;
   End;

ElseIf( pMode = 1 );

   pDimension = pName;
   
   # dimension itself
   If( DimensionExists( pDimension ) = 1 );
      TextOutput( vFile, 'application dimension', pDimension | '.dim' );
   Else;
      LogOutput( 'ERROR', 'The dimension ''' | pDimension | ''' does not exist.');
      ProcessQuit;
   EndIf;
   
   # attributes cube
   If( CubeExists( '}ElementAttributes_' | pDimension ) = 1 );
      TextOutput( vFile, 'element attributes cube', '}ElementAttributes_' | pDimension | '.cub' );
   EndIf;
   
   # attributes dimension
   If( DimensionExists( '}ElementAttributes_' | pDimension ) = 1 );
      TextOutput( vFile, 'element attributes dimension', '}ElementAttributes_' | pDimension | '.dim' );
   EndIf;
   
   # element attributes cube rules
   If( FileExists( '}ElementAttributes_' | pDimension | '.rux' ) = 1 );
      TextOutput( vFile, 'element attributes cube rules', '}ElementAttributes_' | pDimension | '.rux' );
   EndIf;
   
   # element security cube
   If( CubeExists( '}ElementSecurity_' | pDimension ) = 1 );
      TextOutput( vFile, 'element security cube', '}ElementSecurity_' | pDimension | '.cub' );
   EndIf;
   
   # element security dimension
   If( DimensionExists( '}ElementSecurity_' | pDimension ) = 1 );
      TextOutput( vFile, 'element security dimension', '}ElementSecurity_' | pDimension | '.dim' );
   EndIf;
   
   # element security rules
   If( FileExists( '}ElementSecurity_' | pDimension | '.rux' ) = 1 );
      TextOutput( vFile, 'element security cube rules', '}ElementSecurity_' | pDimension | '.rux' );
   EndIf;

EndIf;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,3

#****Begin: Generated Statements***
#****End: Generated Statements****
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
