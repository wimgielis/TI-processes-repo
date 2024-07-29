601,100
602,"WG_DUMP_INFORMATION_overview_of_measures"
562,"NULL"
586,
585,
564,
565,"sGcnA\Y<<LyR9^>wJGgatpJa]3Tjg7V36yt[\gkdF10K@4P1Uqcyc:vTwz<MEcB[EIN<vY6ltN0AufydJ3KfMOr4TwftwyY?nLsss0tmC@daLOCC8FW\KNnAQpwAu2i8^0zc?snsa`mifc`?A:`9M1u1v97BQFwKkqdTEv^`A1NZBS`XFd307Bz3DhBp]J]G7TzEGdQp"
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
pFile
pFieldDelimiter
561,2
2
2
590,2
pFile,"Export of measures.csv"
pFieldDelimiter,";"
637,2
pFile,"Filename for textual output ?"
pFieldDelimiter,"Delimiter character for fields in the output ?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,104

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This TI process can export measures elements and information related to them.
#
###########################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_measures'
  , 'pFile', 'Export of measures.csv'
  , 'pFieldDelimiter', ','
  );
EndIf;
#EndRegion CallThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of measures', 'pMainFolder', '1+' );


vFile = Trim( pFile );
If( Long( vFile ) = 0 );
   vFile = cDestination_Folder | 'Export the measures.csv';
EndIf;

DataSourceAsciiDelimiter = pFieldDelimiter;
DataSourceAsciiQuoteCharacter = '';


# Title record in a text file
# Note: this process fills in the columns up until 'Element Name'
# After that column, additional columns of your own liking can be added in th column headers
TextOutput( vFile, 'Cube', 'Dimension', 'Element index', 'Element Type', 'Element Name', 'Source (TI/Manual input or picklist)/Rule)', 'Calc' );

# Loop over cubes. Turn on the logging and set the measures dimension

c = 1;
While( c <= Dimsiz( '}Cubes' ));

   vCube = Dimnm( '}Cubes', c );
   vNrOfDims = CubeDimensionCountGet( vCube );

   If( Scan( '}', vCube ) <> 1 );

      # measures dimension
      vMeasuresDim = CellGetS( '}CubeProperties', vCube, 'MEASURES_DIMENSION' );
      vDimFound = 0;
      n = 1;
      While( n <= vNrOfDims );
         vDim = Tabdim( vCube, n );
         If( Dimix( '}Dimensions', vDim ) = Dimix( '}Dimensions', vMeasuresDim ));
            vDimFound = 1;
            Break;
         EndIf;
      n = n + 1;
      End;
      If( vDimFound = 0 );
         vMeasuresDim = Tabdim( vCube, vNrOfDims );
      EndIf;

      # Output to a text file
      If( Dimsiz( vMeasuresDim ) = 0 );
         TextOutput( vFile, vCube, vMeasuresDim, '0', '', Expand( 'No elements found in dimension ''%vMeasuresDim%'' used in cube ''%vCube%'''));
      Else;

         m = Dimsiz( vMeasuresDim );
         If( m > 250 );
            TextOutput( vFile, vCube, vMeasuresDim, '0', '', Expand( 'There are more than 250 elements in dimension ''%vMeasuresDim%'' used in cube ''%vCube%''. The first 10 elements are listed.' ));
            m = 10;
         EndIf;

         e = 1;
         While( e <= m );
            vElement = Dimnm( vMeasuresDim, e );
            TextOutput( vFile, vCube, vMeasuresDim, NumberToString( e ), DType( vMeasuresDim, vElement ), vElement );
            e = e + 1;
         End;

      EndIf;

   EndIf;

   c = c + 1;

End;
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
