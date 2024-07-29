601,100
602,"WG_DUMP_INFORMATION_overview_of_picklists"
562,"NULL"
586,
585,
564,
565,"hTKc:X^ya^urCS7vS9SHtA??3ZZVZPJ>jllQM;tD`T4l_;wB<L:>^PF=f2H`o\C^ZJxNgNPrZM70QunlMizVVLG0Z=l5]LM?WVV6rPH3yS^4ZC5X4FQY4tyb[Y7KJ[pX``8oKV8x>i3_had7svX?bnvZoVLOaJ]BYpP0Wjyeb6>6yixkacwx0qMiJp@:bb>U9pg>FZx3"
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
589,","
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
572,374

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This process can populate 2 text files with an overview of picklists:
# - picklists created as an attribute on a dimension
# - picklists created through a picklist control cube
#
# Allowed picklist syntax:
# - static picklists ==> static::Electronics:Furniture:Equipment
# - subset picklists on the main hierarchy ==> subset:Products:Electronics
# - subset picklists on an alternate hierarchy ==> subset:Products\:All Products:Electronics
# - dimension picklists ==> dimension:Products
# - dimension picklists ==> dimension:Products\:All Products
#
# A picklist can show options with a certain alias, yet store the chosen option with the principal name in the cell
# In that case you must use '<StoreAlias=F>' in the picklist string.
#
# When multiple picklists apply to an individual cube cell, the following order of precedence is used to determine which picklist is used in the cell:
# - If a picklist control cube exists and contains a picklist definition for the current cube cell, the definition in the picklist control cube is used.
# - If a picklist control cube does not exist, the elements that identify the current cell are examined in reverse order in a search for picklist element attributes.
#   The first picklist element attribute that is encountered in this search is used in the cell.
#
# It is perfectly possible (and rather common) that some measures are validated through attributes picklist definitions,
# while other measures are validated through a picklist control cube.
#
# This process supports all of the above - except the order of precedence. The process just lists the picklists that exist.
#
# For picklists created with picklist control cube, the output is more limited.
# These cubes tend to be not always small and also, rule-derived. Analyzing the picklist definitions is much harder in that case.
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
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_picklists' );
EndIf;
#EndRegion CallThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of picklists', 'pMainFolder', '1+' );


vFile_DimAttr = cDestination_Folder | 'PickListAttributes.csv';
AsciiDelete( vFile_DimAttr );
m = 0;

vFile_PLControlCube = cDestination_Folder | 'PickListControlCube.csv';
AsciiDelete( vFile_PLControlCube );
n = 0;
cStore_Alias = '<StoreAlias=F>';

DataSourceAsciiQuoteCharacter = '';
DataSourceAsciiDelimiter = ';';

# Output the titles in the output file
TextOutput( vFile_DimAttr, 'Base Dimension', 'Element', 'Element Type', 'Nr of Options', 'Type', 'Definition', 'Dimension Used', 'Hierarchy Used', 'Subset Used', 'Static Values Used', 'MDX used for Subset', 'Alias used for Subset', 'Show alias but store Element name', 'User-Specific Subset', 'First few choices' );

# Loop over the attributes dimensions
d = 1;
While( d <= ElementCount( '}Dimensions', '' ));

   vDim = ElementName( '}Dimensions', '', d );

   If( Scan( '}ElementAttributes_', vDim ) = 1 );

      # We have a dimension for attributes
      # Do we have a PickList ?
      If( ElementIndex( vDim, '', 'PickList' ) > 0 );

         # Is it a text attribute ?
         If( ElementType( vDim, '', 'PickList' ) @= 'AS' );

            # Get the base dimension and collect the PickList types
            vBaseDimension = Delet( vDim, 1, Long( '}ElementAttributes_' ));

            e = 1;
            While( e <= ElementCount( vBaseDimension, '' ));
               vElement = ElementName( vBaseDimension, '', e );
               vElementType = ElementType( vBaseDimension, '', vElement );
               vPickListDef = ElementAttrS( vBaseDimension, '', vElement, 'PickList' );
               If( Long( vPickListDef ) > 0 );

                  # Determine the PickList type
                  If( Scan( ':', vPickListDef ) = 0 );
                     TextOutput( vFile_DimAttr, vBaseDimension, vElement, '', '', 'The PickList definition seems invalid !', vPickListDef, '', '', '', '', '', '', '', '', '' );
                  Else;

                     vPickListType = Subst( vPickListDef, 1, Scan( ':', vPickListDef ) - 1 );

                     # Output to file
                     If( vPickListType @= 'static' );

                        sDefinition = vPickListDef;

                        # Collection of the findings
                        vComponent1 = Lower( vPickListType );
                        vPickListType = vComponent1;

                        vAfterComponent1 = Subst( sDefinition, Long( vComponent1 ) + 2, Long( sDefinition ));
                        vComponent2 = vAfterComponent1;
                        vStaticList = vComponent2;

                        # Count the number of choices
                        s = vStaticList;
                        cRemoveCharacters = ':';

                        c = Long( s );
                        While( c >= 1 );
                           sChar = Subst( s, c, 1 );
                           vScan = Scan( sChar, cRemoveCharacters );
                           If( vScan > 0 );
                              s = Delet( s, c, 1 );
                           EndIf;
                           c = c - 1;
                        End;

                        # Output of the findings
                        vNrOfChoices = Long( vStaticList ) - Long( s ) + 1;
                        sNrOfChoices = NumberToString( vNrOfChoices );

                        If( vNrOfChoices >= 1 );
                           vChoice = If( Subst( vAfterComponent1, 1, 1 ) @= ':', '', Subst( vAfterComponent1, 1, Scan( ':', vAfterComponent1 ) - 1 ));
                           vAfterComponent1 = Delet( vAfterComponent1, 1, Long( vChoice ) + 1 );
                           vFirstFewChoices = If( vChoice @= '', 'Empty choice', vChoice );
                        EndIf;
                        If( vNrOfChoices >= 2 );
                           vChoice = If( Subst( vAfterComponent1, 1, 1 ) @= ':', 'Empty choice', Subst( vAfterComponent1, 1, Scan( ':', vAfterComponent1 ) - 1 ));
                           vAfterComponent1 = Delet( vAfterComponent1, 1, Long( vChoice ) + 1 );
                           vFirstFewChoices = vFirstFewChoices | ', ' | If( vChoice @= '', 'Empty choice', vChoice );
                        EndIf;
                        If( vNrOfChoices >= 3 );
                           vChoice = If( Subst( vAfterComponent1, 1, 1 ) @= ':', 'Empty choice', Subst( vAfterComponent1, 1, Scan( ':', vAfterComponent1 ) - 1 ));
                           vAfterComponent1 = Delet( vAfterComponent1, 1, Long( vChoice ) + 1 );
                           vFirstFewChoices = vFirstFewChoices | ', ' | If( vChoice @= '', 'Empty choice', vChoice );
                        EndIf;
                        If( vNrOfChoices >= 4 );
                           vChoice = ', ...';
                           vFirstFewChoices = vFirstFewChoices | vChoice;
                        EndIf;

                        TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, sNrOfChoices, vPickListType, vPickListDef, '', '', '', vStaticList, '', '', '', '', vFirstFewChoices );


                     ElseIf( vPickListType @= 'subset' );

                        sDefinition = vPickListDef;

                        # Collection of the findings
                        vComponent1 = Lower( vPickListType );
                        vPickListType = vComponent1;

                        vAfterComponent1 = Subst( sDefinition, Long( vComponent1 ) + 2, Long( sDefinition ));

                        # Let's rework the syntax to include a choice of hierarchy within the dimension
                        # The hierarchy choice will be empty anyway if the picklist does not use an alternate hierarchy
                        If( Scan( '\:', vAfterComponent1 ) < Scan( ':', vAfterComponent1 ));
                           vAfterComponent1 = Insrt( '\:', vAfterComponent1, Scan( ':', vAfterComponent1 ));
                        EndIf;

                        vComponent2 = Subst( vAfterComponent1, 1, Scan( '\:', vAfterComponent1 ) - 1 );
                        vDimension = vComponent2;

                        vAfterComponent2 = Subst( vAfterComponent1, Long( vComponent2 ) + 3, Long( vAfterComponent1 ));

                        vComponent3 = Subst( vAfterComponent2, 1, Scan( ':', vAfterComponent2 ) - 1 );
                        vHierarchy = vComponent3;

                        vAfterComponent3 = Subst( vAfterComponent2, Long( vComponent3 ) + 2, Long( vAfterComponent2 ));

                        # A picklist can show options with a certain alias, yet store the chosen option with the principal name in the cell
                        # Refer to: https://www.tm1forum.com/viewtopic.php?p=78363#p78363
                        If( Scan( Lower( cStore_Alias ), Lower( vAfterComponent3 )) > 0 );
                           vComponent4 = Subst( vAfterComponent3, 1, Scan( Lower( cStore_Alias ), Lower( vAfterComponent3 )) - 1 );
                           vAfterComponent4 = cStore_Alias;
                        Else;
                           vComponent4 = vAfterComponent3;
                           vAfterComponent4 = '';
                        EndIf;
                        vSubset = vComponent4;

                        vComponent5 = vAfterComponent4;
                        vStore_Alias = If( vAfterComponent4 @<> '', 'Yes', 'No' );

                        # Output of the findings
                        If( DimensionExists( vDimension ) = 0 );
                           TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, '', vPickListType, vPickListDef, 'The dimension ''' | vDimension | ''' does not exist !', vHierarchy, vSubset, '', '', '', '', '', '' );
                        ElseIf( HierarchyExists( vDimension, vHierarchy ) = 0 );
                           TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, '', vPickListType, vPickListDef, vDimension, 'The hierarchy ''' | vHierarchy | ''' does not exist on the dimension ''' | vDimension | ''' !', vSubset, '', '', '', '', '', '' );
                        ElseIf( HierarchySubsetExists( vDimension, vHierarchy, vSubset ) = 0 );
                           TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, '', vPickListType, vPickListDef, vDimension, vHierarchy, 'The subset ''' | vSubset | ''' does not exist on the hierarchy ''' | vHierarchy | ''' of the dimension ''' | vDimension | ''' !', '', '', '', '', '', '' );
                        Else;
                           vNrOfChoices = HierarchySubsetGetSize( vDimension, vHierarchy, vSubset );
                           sNrOfChoices = NumberToString( vNrOfChoices );

                           vMDX = HierarchySubsetMDXGet( vDimension, vHierarchy, vSubset );
                           If( vMDX @= '' );
                              vMDX = 'Attention, a static subset !';
                           EndIf;
                           If( Scan( Lower( vMDX ), Lower( TM1User )) > 0 );
                              vUser_Specific = 'Yes';
                           Else;
                              vUser_Specific = 'No';
                           EndIf;
                           vAlias = HierarchySubsetAliasGet( vDimension, vHierarchy, vSubset );

                           # First few choices for the user
                           If( vNrOfChoices >= 1 );
                              vChoice = HierarchySubsetGetElementName( vDimension, vHierarchy, vSubset, 1 );
                              vFirstFewChoices = vChoice;
                           EndIf;
                           If( vNrOfChoices >= 2 );
                              vChoice = HierarchySubsetGetElementName( vDimension, vHierarchy, vSubset, 2 );
                              vFirstFewChoices = vFirstFewChoices | ', ' | vChoice;
                           EndIf;
                           If( vNrOfChoices >= 3 );
                              vChoice = HierarchySubsetGetElementName( vDimension, vHierarchy, vSubset, 3 );
                              vFirstFewChoices = vFirstFewChoices | ', ' | vChoice;
                           EndIf;
                           If( vNrOfChoices >= 4 );
                              vChoice = ', ...';
                              vFirstFewChoices = vFirstFewChoices | vChoice;
                           EndIf;

                           TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, sNrOfChoices, vPickListType, vPickListDef, vDimension, vHierarchy, vSubset, '', vMDX, vAlias, vStore_Alias, vUser_Specific, vFirstFewChoices );
                        EndIf;


                     ElseIf( vPickListType @= 'dimension' );

                        # Note: most of the logic is reused from the treatment of a picklist towards a subset

                        sDefinition = vPickListDef;

                        # Collection of the findings
                        vComponent1 = Lower( vPickListType );
                        vPickListType = vComponent1;

                        vAfterComponent1 = Subst( sDefinition, Long( vComponent1 ) + 2, Long( sDefinition ));

                        # Let's rework the syntax to include a choice of hierarchy within the dimension
                        # The hierarchy choice will be empty anyway if the picklist does not use an alternate hierarchy
                        If( Scan( '\:', vAfterComponent1 ) < Scan( ':', vAfterComponent1 ));
                           vAfterComponent1 = Insrt( '\:', vAfterComponent1, Scan( ':', vAfterComponent1 ));
                        EndIf;

                        vComponent2 = Subst( vAfterComponent1, 1, Scan( '\:', vAfterComponent1 ) - 1 );
                        vDimension = vComponent2;

                        vAfterComponent2 = Subst( vAfterComponent1, Long( vComponent2 ) + 3, Long( vAfterComponent1 ));

                        vComponent3 = Subst( vAfterComponent2, 1, Scan( ':', vAfterComponent2 ) - 1 );
                        vHierarchy = vComponent3;

                        # Output of the findings
                        If( DimensionExists( vDimension ) = 0 );
                           TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, '', vPickListType, vPickListDef, 'The dimension ''' | vDimension | ''' does not exist !', vHierarchy, '', '', '', '', '', '', '' );
                        ElseIf( HierarchyExists( vDimension, vHierarchy ) = 0 );
                           TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, '', vPickListType, vPickListDef, vDimension, 'The hierarchy ''' | vHierarchy | ''' does not exist on the dimension ''' | vDimension | ''' !', '', '', '', '', '', '', '' );
                        Else;
                           vNrOfChoices = ElementCount( vDimension, vHierarchy );
                           sNrOfChoices = NumberToString( vNrOfChoices );

                           # First few choices for the user
                           If( vNrOfChoices >= 1 );
                              vChoice = ElementName( vDimension, vHierarchy, 1 );
                              vFirstFewChoices = vChoice;
                           EndIf;
                           If( vNrOfChoices >= 2 );
                              vChoice = ElementName( vDimension, vHierarchy, 2 );
                              vFirstFewChoices = vFirstFewChoices | ', ' | vChoice;
                           EndIf;
                           If( vNrOfChoices >= 3 );
                              vChoice = ElementName( vDimension, vHierarchy, 3 );
                              vFirstFewChoices = vFirstFewChoices | ', ' | vChoice;
                           EndIf;
                           If( vNrOfChoices >= 4 );
                              vChoice = ', ...';
                              vFirstFewChoices = vFirstFewChoices | vChoice;
                           EndIf;

                           TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, sNrOfChoices, vPickListType, vPickListDef, vDimension, vHierarchy, '', '', '', '', '', '', vFirstFewChoices );
                        EndIf;


                     Else;

                        vComponent1 = vPickListType;

                        TextOutput( vFile_DimAttr, vBaseDimension, vElement, vElementType, '', 'The PickList definition seems invalid !', vPickListDef, '', '', '', '', '', '', '', '', '' );

                     EndIf;

                     m = m + 1;

                  EndIf;

               EndIf;

               e = e + 1;

            End;

         EndIf;

      EndIf;

   EndIf;

   d = d + 1;
End;


# output the titles in the output file
TextOutput( vFile_PLControlCube, 'Base Cube', 'Rules-driven' );

# loop over cubes
c = 1;
While( c <= ElementCount( '}Cubes', '' ));

   vCube = ElementName( '}Cubes', '', c );

   If( Scan( '}PickList_', vCube ) = 1 );

      # get the base cube
      vBaseCube = Delet( vCube, 1, Long( '}PickList_' ));

      # does this cube exist on the TM1 server ?
      If( CubeExists( vBaseCube ) > 0 );

         # is the PickList cube rules-driven ?
         If( FileExists( vCube | '.rux' ) > 0 );
            TextOutput( vFile_PLControlCube, vBaseCube, 'Yes' );
         Else;
            TextOutput( vFile_PLControlCube, vBaseCube, 'No' );
         EndIf;

         n = n + 1;

      EndIf;

   EndIf;

   c = c + 1;

End;



If( m = 0 );
   TextOutput( vFile_DimAttr, 'No PickLists were found using the loop over }ElementAttributes dimensions.' );
EndIf;

If( n = 0 );
   TextOutput( vFile_PLControlCube, 'No PickLists control cubes were found using the loop over cubes.' );
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

576,CubeAction=1511DataAction=1503CubeLogChanges=0_ParameterConstraints=e30
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
