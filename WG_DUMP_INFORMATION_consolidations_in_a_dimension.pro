601,100
602,"WG_DUMP_INFORMATION_consolidations_in_a_dimension"
562,"NULL"
586,
585,
564,
565,"gPnVFMia8;Wb4qEp3RqbyBDnghE]s3YUWI\taU>9^KGQJeeBn?7r[K[;B4LmW_3W60F=c`IGKj4v=CtZ]85nBx`:Vi8ar@w=0N5wPE8<RMe^qHUvomPQ9M8UM0qCBv]a^YGgjS[eHI[1@oyNNEIr9\ISFBcMz@@@E@j26WIfC2rKXTEDE1a0>X;GH[^8nfv_p<Yvt@?H"
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
560,7
pDimension
pOutputLayout
pIncludeElementsWithZeroWeight
pSeparatorLine
pElementsInSquareBrackets
pMarkConsolidations
pMaxNumberOfChildren
561,7
2
2
2
2
2
2
1
590,7
pDimension,"Period"
pOutputLayout,"H"
pIncludeElementsWithZeroWeight,"Y"
pSeparatorLine,"Y"
pElementsInSquareBrackets,"Y"
pMarkConsolidations,"Y"
pMaxNumberOfChildren,50
637,7
pDimension,"Dimension name ?"
pOutputLayout,"Have a Horizontaal / Line by line output ( H ) or Verical / Collapsed layout ( V ) ?"
pIncludeElementsWithZeroWeight,"Include elements with zero weight in their parent ? ( Y or anything else )"
pSeparatorLine,"Add empty lines to separate visually ? ( Y or anything else )"
pElementsInSquareBrackets,"Wrap element names in square brackets ? ( Y or anything else )"
pMarkConsolidations,"Add a mark for consolidated elements ? ( Y or anything else )"
pMaxNumberOfChildren,"What is the maximal number of children to output ? (0 if unlimited)"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,251

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
###########################################################
#
# This process can write out, in an easy format, the consolidations of a dimension.
# You will see the + and - signs (weights), and you can tweak the output using several parameters.
#
# The process does not yet support IBM PA alternate hierarchies.
#
###########################################################

#####
# Add the following process(es) to this TM1 model:
# - 
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_DUMP_INFORMATION_consolidations_in_a_dimension'
  , 'pDimension', 'Period'
  , 'pOutputLayout', 'H'
  , 'pIncludeElementsWithZeroWeight', 'Y'
  , 'pSeparatorLine', 'Y'
  , 'pElementsInSquareBrackets', 'Y'
  , 'pMarkConsolidations', 'Y'
  , 'pMaxNumberOfChildren', 50
  );
EndIf;
#EndRegion CallThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Consolidations in a dimension', 'pMainFolder', '1+' );


vFile_WrittenOutConso = cDestination_Folder | 'Written out consolidations.csv';
AsciiDelete( vFile_Locks );


# Writing out consolidations to a text file
#####

# Validate/rework the user input
If( DimensionExists( pDimension ) = 0 );
   ProcessError;
Else;
   vDim = pDimension;
EndIf;

pMaxNumberOfChildren = Max( 0, pMaxNumberOfChildren );
If( pMaxNumberOfChildren = 0 );
   pMaxNumberOfChildren = Dimsiz( pDimension );
EndIf;

DatasourceASCIIQuoteCharacter = '';

If( pElementsInSquareBrackets @= 'Y' );
   vLeftSquareBracket = '[';
   vRightSquareBracket = ']';
Else;
   vLeftSquareBracket = '';
   vRightSquareBracket = '';
EndIf;


If( Upper( pOutputLayout ) @= 'H' );

   e = 1;

   While( e <= Dimsiz( vDim ));

      vElement = Dimnm( vDim, e );

      If( DType( vDim, vElement) @= 'C' );

         vOutput = '';

         c = 1;

         While( c <= Min( pMaxNumberOfChildren, ElcompN( vDim, vElement )));

            vChild = Dimnm( vDim, Dimix( vDim, Elcomp( vDim, vElement, c )));
            vWeight = ElWeight( vDim, vElement, vChild );

            If( vWeight = 1 );

               vMiddlePart = ' + ';

            ElseIf( vWeight = -1 );

               vMiddlePart = ' - ';

            ElseIf( vWeight = 0 );

               If( pIncludeElementsWithZeroWeight @= 'Y' );

                  vMiddlePart = ' + 0 * ';

               EndIf;

            ElseIf( vWeight > 0 );

               vMiddlePart = ' + ' | Trim( Str( vWeight, 5, 3)) | ' * ';

            Else;

               vMiddlePart = ' - ' | Trim( Str( Abs( vWeight ), 5, 3)) | ' * ';

            EndIf;

            If( c = 1 );
               If( Scan( '+', vMiddlePart ) > 0 );
                  vMiddlePart = Delet( vMiddlePart, 1, 3 );
               EndIf;
            EndIf;

            vOutput = vOutput | vMiddlePart | vLeftSquareBracket | ' ''' | vChild | ''' ' | vRightSquareBracket;

            If( pMarkConsolidations @= 'Y' );
               If( DType( vDim, vChild) @= 'C' );
                  vOutput = vOutput |  ' (c)';
               EndIf;
            EndIf;

            c = c + 1;

         End;

         vOutput = vLeftSquareBracket | ' ''' | vElement | ''' ' | vRightSquareBracket | ' = ' | vOutput | ';';
         TextOutput( vFile_WrittenOutConso, vOutput );

         vNotShown = ElcompN( vDim, vElement ) - pMaxNumberOfChildren;
         If( vNotShown > 0 );
            vOutput = '... and ' | NumberToString( vNotShown ) | ' element' | If( vNotShown = 1, '', 's') | ' not shown.';
            TextOutput( vFile_WrittenOutConso, vOutput );
         EndIf;

         If( pSeparatorLine @= 'Y' );
         TextOutput( vFile_WrittenOutConso, '' );
         EndIf;

      EndIf;

      e = e + 1;

   End;

ElseIf( Upper( pOutputLayout ) @= 'V' );

   vLayoutSeparator = Fill( Char(9), 1);

   e = 1;

   While( e <= Dimsiz( vDim ));

      vElement = Dimnm( vDim, e );

      If( DType( vDim, vElement) @= 'C' );

         vOutput = vLeftSquareBracket | ' ''' | vElement | ''' ' | vRightSquareBracket | ' =';

         TextOutput( vFile_WrittenOutConso, vOutput );

         c = 1;

         While( c <= Min( pMaxNumberOfChildren, ElcompN( vDim, vElement )));

            vChild = Dimnm( vDim, Dimix( vDim, Elcomp( vDim, vElement, c )));
            vWeight = ElWeight( vDim, vElement, vChild );

            If( vWeight = 1 );

               vMiddlePart = ' + ';

            ElseIf( vWeight = -1 );

               vMiddlePart = ' - ';

            ElseIf( vWeight = 0 );

               If( pIncludeElementsWithZeroWeight @= 'Y' );

                  vMiddlePart = ' + 0 * ';

               EndIf;

            ElseIf( vWeight > 0 );

               vMiddlePart = ' + ' | Trim( Str( vWeight, 5, 3)) | ' * ';

            Else;

               vMiddlePart = ' - ' | Trim( Str( Abs( vWeight ), 5, 3)) | ' * ';

            EndIf;

            If( c = 1 );
               vMiddlePart = Delet( vMiddlePart, 1, Scan( '+', vMiddlePart ));
            EndIf;

            vOutput = vLayoutSeparator | Trim( vMiddlePart ) | vLayoutSeparator | vLeftSquareBracket | ' ''' | vChild | ''' ' | vRightSquareBracket;

            If( pMarkConsolidations @= 'Y' );
               If( DType( vDim, vChild) @= 'C' );
                  vOutput = vOutput |  ' (c)';
               EndIf;
            EndIf;

            If( c = ElcompN( vDim, vElement ) );
               vOutput = vOutput | ';';
            EndIf;

            TextOutput( vFile_WrittenOutConso, vOutput );

            c = c + 1;

         End;

         vNotShown = ElcompN( vDim, vElement ) - pMaxNumberOfChildren;
         If( vNotShown > 0 );
            vOutput = '... and ' | NumberToString( vNotShown ) | ' element' | If( vNotShown = 1, '', 's') | ' not shown.';
            TextOutput( vFile_WrittenOutConso, vOutput );
         EndIf;

         If( pSeparatorLine @= 'Y' );
         TextOutput( vFile_WrittenOutConso, '' );
         EndIf;

      EndIf;

      e = e + 1;

   End;

Else;

   ProcessError;

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
