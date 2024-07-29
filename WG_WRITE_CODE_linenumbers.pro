601,100
602,"WG_WRITE_CODE_linenumbers"
562,"NULL"
586,
585,
564,
565,"jyo[psbA]edoj9zcEIICO0u1F_p8PezHUKtUh0D6gSC<zUhRuUD\@5:UsS:]V_=fcg[_xe7An9atjn=?JbXiHTzJAXoChU^D2xWsQmasqrT2:>=pt^=M<D@rSqBc`L2nkpoFcnIQTDXRCOf=wC_=WAO5gxp9NcPJ\0_ji=<<6a2m<Fnl2x[^YvBM`C38Ye;^hX4n35XR"
559,0
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
567,
588,
589,
568,""
570,
571,
569,0
592,0
599,1000
560,2
pDim
pMethod
561,2
2
2
590,2
pDim,""
pMethod,"ALL / 1 / 2 / 3"
637,2
pDim,"Dimension name ?"
pMethod,"Which method ? (ALL, or method 1 / 2 / 3)"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,212

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# October 2023
# https://www.wimgielis.com
####################################################
#
# This process generates a text file with code to script a loop in a so-called linenumber dimension.
# See the process: WG_TECH_DIM_linenumbers
#
# Purpose of the loop is to find the line for the next entry (the first empty line)
#
# Method 1: a counter measure
# Method 2: looping over all lines in the dimension (a flat list)
# Method 3: looping over all children of the total
#
####################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
# - WG_TECH_DIM_linenumbers
#####
#EndRegion IntroduceThisProcess


If( DimensionExists( pDim ) = 0 );
   LogOutput( 'ERROR', 'The dimension ''' | pDim | ''' does not exist.' );
   ProcessError;
EndIf;

If( Dimsiz( pDim ) = 0 );
   LogOutput( 'ERROR', 'The dimension ''' | pDim | ''' is empty.' );
   ProcessError;
EndIf;

If( pMethod @<> 'ALL'
  & pMethod @<> '1'
  & pMethod @<> '2'
  & pMethod @<> '3' );
   LogOutput( 'ERROR', 'The ''pMethod'' parameter (''' | pMethod | ''') should be set to ALL, 1, 2 or 3.' );
   ProcessError;
EndIf;


pDim = DimensionElementPrincipalName( '}Dimensions', pDim );


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Script a loop in a linenumber dimension', 'pMainFolder', '1+' );

DataSourceAsciiQuoteCharacter = '';

vFile = cDestination_Folder | pDim | '_' | pMethod | '.txt';


# header
TextOutput( vFile, '###########################' );
TextOutput( vFile, Expand( '# Dimension: %pDim%' ));
TextOutput( vFile, Expand( '# Method: %pMethod%' ));
TextOutput( vFile, '###########################' );

# generating code for the different methods
TextOutput( vFile, '' );
TextOutput( vFile, '' );
TextOutput( vFile, Expand( 'vDim = ''%pDim%'';' ));
TextOutput( vFile, '' );
TextOutput( vFile, 'dp = ''}DimensionProperties'';');
TextOutput( vFile, '' );
TextOutput( vFile, '# Retrieve the settings for the line numbers' );
TextOutput( vFile, 'vTotal_Element = ''Total Line'';' );
TextOutput( vFile, 'vElement_Mask = ''"L"000'';' );
TextOutput( vFile, 'vStarting_Number = 1;' );
TextOutput( vFile, 'vLine_Zero = ''No'';' );
TextOutput( vFile, '' );
TextOutput( vFile, 'If( ElementIndex( dp, dp, ''Line Number - Total element'' ) > 0 );' );
TextOutput( vFile, '   If( CellGetS( dp, vDim, ''Line Number - Total element'' ) @<> '''' );' );
TextOutput( vFile, '      vTotal_Element = CellGetS( dp, vDim, ''Line Number - Total element'' );' );
TextOutput( vFile, '   EndIf;' );
TextOutput( vFile, '   vElement_Mask = CellGetS( dp, vDim, ''Line Number - Element mask'' );' );
TextOutput( vFile, '   vStarting_Number = StringToNumber( CellGetS( dp, vDim, ''Line Number - Starting number'' ));' );
TextOutput( vFile, '   vLine_Zero = CellGetS( dp, vDim, ''Line Number - Line zero'' );' );
TextOutput( vFile, 'EndIf;' );
TextOutput( vFile, '' );
TextOutput( vFile, 'nDefault_Line = If( vLine_Zero @= ''No'', 1, 0 );' );
TextOutput( vFile, 'sDefault_Line = NumberToStringEx( nDefault_Line, vElement_Mask, '''', '''' );' );
TextOutput( vFile, '' );
TextOutput( vFile, '# Loop over the lines to find the first empty line' );
TextOutput( vFile, '' );
TextOutput( vFile, '' );

If( pMethod @= 'ALL' % pMethod @= '1' );
TextOutput( vFile, '' );
TextOutput( vFile, '# Option 1: a counter measure' );
TextOutput( vFile, 'CellIncrementN( 1, ''Cube_Name'', ''...'', sDefault_Line, ''...'', ''Counter'' );' );
TextOutput( vFile, 'nNext_Line = CellGetN( ''Cube_Name'', ''...'', sDefault_Line, ''...'', ''Counter'' );' );
TextOutput( vFile, 'vNext_Line = NumberToStringEx( nNext_Line, vElement_Mask, '''', '''' );' );
TextOutput( vFile, 'If( ElementIndex( vDim, vDim, vNext_Line ) = 0 );' );
TextOutput( vFile, '   LogOutput( ''INFO'', ''Not enough input lines.'' );' );
TextOutput( vFile, '' );
TextOutput( vFile, '   ExecuteProcess( ''WG_TECH_DIM_linenumbers''' );
TextOutput( vFile, '     , ''pDim'', vDim' );
TextOutput( vFile, '     , ''pNumber_Of_Elements'', ''+1''' );
TextOutput( vFile, '     , ''pElement_Mask'', vElement_Mask' );
TextOutput( vFile, '     , ''pTotal_Element'', vTotal_Element' );
TextOutput( vFile, '     , ''pStarting_Number'', vStarting_Number' );
TextOutput( vFile, '     , ''pAdd_LineNumber_Zero'', vLine_Zero' );
TextOutput( vFile, '   );' );
TextOutput( vFile, 'EndIf;' );
TextOutput( vFile, '' );
TextOutput( vFile, '' );
EndIf;


If( pMethod @= 'ALL' % pMethod @= '2' );
TextOutput( vFile, '' );
TextOutput( vFile, '# Option 2: looping over all lines in the dimension (a flat list)' );
TextOutput( vFile, 'vNext_Line = '''';' );
TextOutput( vFile, 'If( LevelCount( vDim, vDim ) = 1 );' );
TextOutput( vFile, '' );
TextOutput( vFile, '   n = 1;' );
TextOutput( vFile, '   While( n <= ElementCount( vDim, vDim ));' );
TextOutput( vFile, '' );
TextOutput( vFile, '      vLine = ElementName( vDim, vDim, n );' );
TextOutput( vFile, '' );
TextOutput( vFile, '      If( ( vLine_Zero @= ''No'' ) % ( vLine @<> sDefault_Line ));' );
TextOutput( vFile, '      If( CellGetS( ''Cube_Name'', ''...'', vLine, ''...'', ''Active'' ) @= '''' );' );
TextOutput( vFile, '      If( CellGetN( ''Cube_Name'', ''...'', vLine, ''...'', ''Value'' ) = 0 );' );
TextOutput( vFile, '      If( CellGetS( ''Cube_Name'', ''...'', vLine, ''...'', ''Account'' ) @= '''' );' );
TextOutput( vFile, '' );
TextOutput( vFile, '         # New empty line found' );
TextOutput( vFile, '         vNext_Line = vLine;' );
TextOutput( vFile, '         Break;' );
TextOutput( vFile, '' );
TextOutput( vFile, '      EndIf;' );
TextOutput( vFile, '      EndIf;' );
TextOutput( vFile, '      EndIf;' );
TextOutput( vFile, '' );
TextOutput( vFile, '      n = n + 1;' );
TextOutput( vFile, '   End;' );
TextOutput( vFile, '' );
TextOutput( vFile, '   If( vNext_Line @= '''' );' );
TextOutput( vFile, '      LogOutput( ''INFO'', ''Not enough input lines. We add a new line.'' );' );
TextOutput( vFile, '' );
TextOutput( vFile, '      ExecuteProcess( ''WG_TECH_DIM_linenumbers''' );
TextOutput( vFile, '        , ''pDim'', vDim' );
TextOutput( vFile, '        , ''pNumber_Of_Elements'', ''+1''' );
TextOutput( vFile, '        , ''pElement_Mask'', vElement_Mask' );
TextOutput( vFile, '        , ''pTotal_Element'', ''''' );
TextOutput( vFile, '        , ''pStarting_Number'', vStarting_Number' );
TextOutput( vFile, '        , ''pAdd_LineNumber_Zero'', vLine_Zero' );
TextOutput( vFile, '      );' );
TextOutput( vFile, '      vNext_Line = ElementName( vDim, vDim, n );' );
TextOutput( vFile, '   EndIf;' );
TextOutput( vFile, '' );
TextOutput( vFile, 'EndIf;' );
TextOutput( vFile, '' );
TextOutput( vFile, '' );
EndIf;

If( pMethod @= 'ALL' % pMethod @= '3' );
TextOutput( vFile, '' );
TextOutput( vFile, '# Option 3: looping over all children of the total' );
TextOutput( vFile, 'vNext_Line = '''';' );
TextOutput( vFile, 'If( LevelCount( vDim, vDim ) = 2 );' );
TextOutput( vFile, '' );
TextOutput( vFile, '   n = 1;' );
TextOutput( vFile, '   While( n <= ElementComponentCount( vDim, vDim, vTotal_Element ));' );
TextOutput( vFile, '' );
TextOutput( vFile, '      vLine = ElementComponent( vDim, vDim, vTotal_Element, n );' );
TextOutput( vFile, '' );
TextOutput( vFile, '      If( ( vLine_Zero @= ''No'' ) % ( vLine @<> sDefault_Line ));' );
TextOutput( vFile, '      If( CellGetS( ''Cube_Name'', ''...'', vLine, ''...'', ''Active'' ) @= '''' );' );
TextOutput( vFile, '      If( CellGetN( ''Cube_Name'', ''...'', vLine, ''...'', ''Value'' ) = 0 );' );
TextOutput( vFile, '      If( CellGetS( ''Cube_Name'', ''...'', vLine, ''...'', ''Account'' ) @= '''' );' );
TextOutput( vFile, '' );
TextOutput( vFile, '         # New empty line found' );
TextOutput( vFile, '         vNext_Line = vLine;' );
TextOutput( vFile, '         Break;' );
TextOutput( vFile, '' );
TextOutput( vFile, '      EndIf;' );
TextOutput( vFile, '      EndIf;' );
TextOutput( vFile, '      EndIf;' );
TextOutput( vFile, '' );
TextOutput( vFile, '      n = n + 1;' );
TextOutput( vFile, '   End;' );
TextOutput( vFile, '' );
TextOutput( vFile, '   If( vNext_Line @= '''' );' );
TextOutput( vFile, '      LogOutput( ''INFO'', ''Not enough input lines. We add a new line.'' );' );
TextOutput( vFile, '' );
TextOutput( vFile, '      ExecuteProcess( ''WG_TECH_DIM_linenumbers''' );
TextOutput( vFile, '        , ''pDim'', vDim' );
TextOutput( vFile, '        , ''pNumber_Of_Elements'', ''+1''' );
TextOutput( vFile, '        , ''pElement_Mask'', vElement_Mask' );
TextOutput( vFile, '        , ''pTotal_Element'', vTotal_Element' );
TextOutput( vFile, '        , ''pStarting_Number'', vStarting_Number' );
TextOutput( vFile, '        , ''pAdd_LineNumber_Zero'', vLine_Zero' );
TextOutput( vFile, '      vNext_Line = ElementComponent( vDim, vDim, vTotal_Element, n );' );
TextOutput( vFile, '      );' );
TextOutput( vFile, '   EndIf;' );
TextOutput( vFile, '' );
TextOutput( vFile, 'EndIf;' );
EndIf;
TextOutput( vFile, '' );
TextOutput( vFile, '' );
TextOutput( vFile, '' );
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
