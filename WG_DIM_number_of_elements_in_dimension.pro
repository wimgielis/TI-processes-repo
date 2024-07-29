601,100
602,"WG_DIM_number_of_elements_in_dimension"
562,"NULL"
586,
585,
564,
565,"vzSgdxu6LOpu>[P^?kiq2OaTjwxw^NhUHO;6RF:TsDJPoJrEB1fWPgA=<ZJmQ=[:Qt<PPZrgz?Pw<d2JF9XM5=Wu8vA8jEDqH7BWUYqD9cbK^yn2@R0a_xycj2>MvIXcL>Pq3F82TeEwn6>u=S_1Uhx37qlG_W;yaRoUeuauT\as@q?XMpX]fOA4lA6rwR<^vUHXtTOA"
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
560,1
pCube
561,1
2
590,1
pCube,""
637,1
pCube,"Cube name ? (If empty or invalid"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,108

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# May 2016
# https://www.wimgielis.com
####################################################
#
# TI code to output the number of (leaf-level) elements in every dimension of a cube or an entire TM1 model
#
####################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Number of elements in dimension', 'pMainFolder', '1+' );

vFile = cDestination_Folder | 'Number of elements.csv';

DataSourceAsciiDelimiter = ';';
DataSourceAsciiQuoteCharacter = '';

TextOutput( vFile, 'Dimension', 'Number of Elements', 'N', 'C', 'S' );


If( CubeExists( pCube ) = 1 );

     # m loops over the dimensions in the cube
     m = 1;
     While( m <= CubeDimensionCountGet( pCube ));

        vDim = Tabdim( pCube, m );

        vN_Elements = 0;
        vC_Elements = 0;
        vS_Elements = 0;

        # n loops over the elements in the dimension
        n = 1;
        While( n <= Dimsiz( vDim ));

           vElem = Dimnm( vDim, n );

           If( DType( vDim, vElem ) @= 'N' );
                vN_Elements = vN_Elements + 1;
           ElseIf( DType( vDim, vElem ) @= 'C' );
                vC_Elements = vC_Elements + 1;
           ElseIf( DType( vDim, vElem ) @= 'N' );
                vS_Elements = vS_Elements + 1;
           EndIf;

           n = n + 1;

        End;

        TextOutput(vFile, vDim, NumberToString( Dimsiz( vDim )), NumberToString( vN_Elements ), NumberToString( vC_Elements ), NumberToString( vS_Elements ));

        m = m + 1;

     End;

Else;

     # m loops over the dimensions in the TM1 model
     m = 1;
     While( m <= Dimsiz( '}Dimensions' ));

        vDim = Dimnm( '}Dimensions', m );

        vN_Elements = 0;
        vC_Elements = 0;
        vS_Elements = 0;

        # n loops over the elements in the dimension
        n = 1;
        While( n <= Dimsiz( vDim ));

           vElem = Dimnm(vDim,n);

           If( DType( vDim, vElem ) @= 'N' );
              vN_Elements = vN_Elements + 1;
           ElseIf( DType(vDim, vElem ) @= 'C' );
              vC_Elements = vC_Elements + 1;
           ElseIf( DType(vDim, vElem ) @= 'N' );
              vS_Elements = vS_Elements + 1;
           EndIf;

           n = n + 1;

        End;

        TextOutput( vFile, vDim, NumberToString( Dimsiz( vDim )), NumberToString( vN_Elements ), NumberToString( vC_Elements ), NumberToString( vS_Elements ));

     m = m + 1;

     End;

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
918,0
919,0
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
