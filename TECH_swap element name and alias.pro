601,100
602,"TECH_swap element name and alias"
562,"NULL"
586,
585,
564,
565,"kzbB<TWml@Ba?_5@=DzZk3M:Ta:lS]ZexKZG[rt8Cu0EYx>eyN>J=b[P8^D`z;3yZ>S43LCmw82on5TizK]iSnE`REPK[qtMB:hdOnAGjLyL^yeDA0dkoZma93`lKy3IG;<U;\SjmJu4b`EE<ztATG;hCiLb9o@cUklWaUAN5kis9sKs:DMwZmnPR^i57aQGnHvi_T<5"
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
560,2
pDimension
pAlias
561,2
2
2
590,2
pDimension,""
pAlias,""
637,2
pDimension,"Dimension name ?"
pAlias,"Alias name ?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,125

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# November 2020
# https://www.wimgielis.com
####################################################
#
# The function below can be used to swap the element names with the values of an alias
# Hence, it can be used to change element names / rename elements
# Rules-calculated aliases seem to work as well
#
# Ideally, proceed as follows:
#
# 1. create a backup copy of the entire TM1 model
# 2. export all cube data (usually, only lowest level, no rules-calculated cells, no zeros) for all cubes that use the chosen dimension
# 3. create a temporary alias on the dimension
# 4. fill the temporary alias with the new element names
# 5. execute the function "SwapAliasWithPrincipalName" in a small process like this one
# 6. reload the data on the new element names ( use the functions DimensionElementPrincipalName or Dimnm(Dimix(...)) )
# 7. inspect / change all rules/feeders/attributes/security in the entire TM1 model
# 8. delete the temporary alias again
#
# Steps 1, 2, 6 are optional but recommended
#
# As a quick-and-dirty solution, stick to points 3-4-5-8 and don't bother about the other points
####################################################
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'TECH_swap element name and alias'
  , 'pDimension', 'DIMENSION NAME'
  , 'pAlias', 'ALIAS NAME' );
EndIf;
#EndRegion CallThisProcess


cEA = '}ElementAttributes_';

# dimension and hierarchy name
h = Scan( ':', pDimension );
If( h = 0 );
   sDim = pDimension;
Else;
   sDim = Subst( pDimension, 1, h - 1 );
EndIf;

# does the dimension/hierarchy exist ?
If( DimensionExists( sDim ) = 0 );

   LogOutput( 'ERROR', Expand( 'The dimension ''%sDim%'' does not exist.' ));
   ProcessError;

Else;
   sDim = DimensionElementPrincipalName( '}Dimensions', sDim );
EndIf;

# does the attributes dimension exist ?
If( DimensionExists( cEA | sDim ) = 0 );
   LogOutput( 'ERROR', Expand( 'The attributes dimension ''%cEA%%sDim%'' does not exist.' ));
   ProcessError;
EndIf;

# does the attributes cube exist ?
If( CubeExists( cEA | sDim ) = 0 );
   LogOutput( 'ERROR', Expand( 'The attributes cube ''%cEA%%sDim%'' does not exist.' ));
   ProcessError;
EndIf;

# does the chosen alias exist ?
If( DType( cEA | sDim, pAlias ) @<> 'AA' );
   LogOutput( 'ERROR', Expand( '''%pAlias%'' cannot be found as an alias on dimension ''%sDim%''.' ));
   If( DType( cEA | sDim, pAlias ) @= 'AS' );
      LogOutput( 'ERROR', Expand( 'However, ''%pAlias%'' is a text attribute on dimension ''%sDim%''.' ));
   ElseIf( DType( cEA | sDim, pAlias ) @= 'AN' );
      LogOutput( 'ERROR', Expand( 'However, ''%pAlias%'' is a numeric attribute on dimension ''%sDim%''.' ));
   EndIf;
   ProcessError;
EndIf;

# (We do not test if the alias values are rules-calculated)
LogOutput( 'INFO', Expand( '''%sDim%'' - ''%pAlias%''' ));
SwapAliasWithPrincipalName( sDim, pAlias, 0 );



# In a similar spirit, what if you wanted to rename an element only for the case or the spaces ?
# https://www.tm1forum.com/viewtopic.php?f=3&t=14785#p73230, George Tonkin

# Parameters
# pDim, pElement

# Prolog tab
# If( Dimix( pDim, pElement ) = 0 );
   # ProcessQuit;
# EndIf;

# sSubset = '_S-Change Case';
# If( SubsetExists( pDim, sSubset )= 1 );
   # SubsetDeleteAllElements( pDim, sSubset );
# Else;
   # SubsetCreate( pDim, sSubset );
# EndIf;

# sMDX = '{[' | pDim | '].[' | pElement | ']}';
# SubsetMDXSet( pDim, sSubset, sMDX);
# SubsetMDXSet( pDim, sSubset, '');

# DatasourceNameForServer = pDim;
# DatasourceDimensionSubset = sSubset;

# DimensionElementDelete( pDim, pElement);

# Metadata tab
# DimensionElementInsert( pDim, '', pElement, 'N' );

# Epilog tab
# SubsetDestroy( pDim, sSubset );
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,3

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
