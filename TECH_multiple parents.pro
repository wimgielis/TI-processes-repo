601,100
602,"TECH_multiple parents"
562,"SUBSET"
586,"}Dimensions"
585,"}Dimensions"
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
589," "
568,""""
570,
571,All
569,0
592,0
599,1000
560,4
pName
pMode
pMinNumberOfParents
pMaxNumberOfParents
561,4
2
1
1
1
590,4
pName,""
pMode,1
pMinNumberOfParents,2
pMaxNumberOfParents,-1
637,4
pName,"Dimension name or cube name ?"
pMode,"Mode ? (0 = all cubes and all dimensions, 1 = dimension, 2 = cube, and so on until 14. See inside the process for all options.)"
pMinNumberOfParents,"Minimum number of parents ?"
pMaxNumberOfParents,"Maximum number of parents ? (-1 means no limitation)"
577,1
vDim
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
572,553

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# November 2022
# https://www.wimgielis.com
####################################################
#
# This process lists elements that have more than 1 parent element in its dimension.
# The output is organized in a simple text file.
# This process can help spot double countings in dimensions,
# but having multiple parents does not necessarily mean the presence of double countings
# (just think about parallel hierarchies in the traditional meaning, not PA-alternate hierarchies-
# For double countings we need to have multiple parents within 1 segment/tree of a dimension
# This process ignores element weights into the parents
#
# Since the user can choose the minimum and maximum number of unique, immediate, parents,
# it is possible to also list elements that are orphans, or elements with exactly 1 parent.
# The latter could be interesting for validations.
#
# The parameter pMode determines to what extend subsets will be created:
# If pMode = 0, you treat all application cubes and dimensions. pName is ignored.
# If pMode = 1, you treat 1 dimension. Specify the dimension name in pName.
# If pMode = 2, you treat 1 cube. Specify the cube name in pName.
# If pMode = 3, you treat all dimensions. pName is ignored.
# If pMode = 4, you treat all application dimensions. pName is ignored.
# If pMode = 5, you treat all control dimensions. pName is ignored.
# If pMode = 6, you treat all cubes. pName is ignored.
# If pMode = 7, you treat all application cubes. pName is ignored.
# If pMode = 8, you treat all control cubes. pName is ignored.
# If pMode = 9, you treat a number of control cubes related to security. pName is ignored.
# If pMode = 10, you treat all control cubes related to security. pName is ignored.
# If pMode = 11, you treat a number of control cubes related to statistics. pName is ignored.
# If pMode = 12, you treat all measures dimensions. pName is ignored.
# If pMode = 13, you treat all dimensions specified in a subset called 'auto subsets' (hard-coded value in this process). pName is ignored.
# If pMode = 14, you treat all cubes specified in a subset called 'auto subsets' (hard-coded value in this process). pName is ignored.
#
# Each case will lead to a number of dimensions to be treated in the Advanced > Metadata and Data tabs
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
ExecuteProcess( 'TECH_multiple parents'
  , 'pName', 'DIMENSION NAME / CUBE NAME / leave empty'
  , 'pMode', 1
  , 'pMinNumberOfParents', 2
  , 'pMaxNumberOfParents', -1
);
EndIf;
#EndRegion CallThisProcess


# A quick way of excluding certain dimensions ( for all pMode values )
# Fill in the names of dimensions to be skipped, separated by a backslash character
cExcludedDims = '\ \ \';


# Initial checks
pMode = Int( pMode );
If( pMode < 0 % pMode > 14 );
ProcessError;
EndIf;

# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Multiple parents', 'pMainFolder', '1+' );

vFile = cDestination_Folder | 'Multiple parents.csv';

DataSourceAsciiDelimiter = ';' ;
DataSourceAsciiQuoteCharacter = '' ;

# Settings regarding the number of parents
pMinNumberOfParents = Int( pMinNumberOfParents );
pMinNumberOfParents = Max( 0, pMinNumberOfParents );

pMaxNumberOfParents = Int( pMaxNumberOfParents );
If( pMaxNumberOfParents <> -1 );
    pMaxNumberOfParents = Max( 0, pMaxNumberOfParents );

    If( pMinNumberOfParents > pMaxNumberOfParents );
       a = pMaxNumberOfParents;
       pMaxNumberOfParents = pMinNumberOfParents;
       pMinNumberOfParents = a;
    EndIf;
EndIf;

vMultipleParents = 0;

cTimestamp = Timst( Now, '\d-\m-\Y' );
vRandom = cTimestamp | ' ~ ' | NumberToString( Int( Rand( ) * 100000000 ));

# Random dimension names to temporarily store the dimensions and cubes to be treated in the Metadata/Data tab
vTempDimForDims = vRandom | '_dims';
vTempDimForCubes = vRandom | '_cubes';

DimensionCreate( vTempDimForDims );
DimensionCreate( vTempDimForCubes );


# Other constants to be used in this process
c09 = 'multiple parents';
c10 = 'multiple parents';


####################
# The main code starts here #
####################


If( pMode = 0 );

   #############################
   # Treat all application dimensions
   #############################

   # d loops over the dimensions in the TM1 model
   d = 1;
   While( d <= Dimsiz( '}Dimensions' ));
      vDim = Dimnm( '}Dimensions', d );
      If( Subst( vDim, 1, 1 ) @<> '}' );

         DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

      EndIf;
      d = d + 1;
   End;

   #############################
   # Treat all application cubes
   #############################

   # c loops over the cubes in the TM1 model
   c = 1;
   While( c <= Dimsiz( '}Cubes' ));
      vCube = Dimnm( '}Cubes', c );

      If( CubeExists( vCube ) > 0 );

         If( Subst( vCube, 1, 1 ) @<> '}' );

            DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

         EndIf;

      EndIf;

      c = c + 1;
   End;


ElseIf( pMode = 1 );

   #############################
   # Treat 1 dimension
   #############################

   pDim = Trim( pName );
   If( DimensionExists( pDim ) > 0 );

      vDim = Dimnm( '}Dimensions', Dimix( '}Dimensions', pDim ));
      DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

   ElseIf( CubeExists( pDim ) > 0 );

      # be forgiving - if the mode for a dimension was chosen and the pName is not a valid dimension name
      # but a cube name, allow this case and treat like a cube

      pMode = 2;
      pCube = Trim( pName );

      vCube = Dimnm( '}Cubes', Dimix( '}Cubes', pCube ));
      DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

   EndIf;


ElseIf( pMode = 2 );

   #############################
   # Treat 1 cube
   #############################

   pCube = Trim( pName );
   If( CubeExists( pCube ) > 0 );

      vCube = Dimnm( '}Cubes', Dimix( '}Cubes', pCube ));

      # m loops over the dimensions in the cube
      m = 1;
      While( m <= CubeDimensionCountGet( vCube ));
         vDim = Tabdim( vCube, m );
         DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );
         DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );
         m = m + 1;
      End;

   ElseIf( DimensionExists( pCube ) > 0 );

      # be forgiving - if the mode for a cube was chosen and the pName is not a valid cube name
      # but a dimension name, allow this case and treat like a dimension

      pMode = 1;
      pDim = Trim( pName );

      vDim = Dimnm( '}Dimensions', Dimix( '}Dimensions', pDim ));
      DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

   EndIf;


ElseIf( pMode = 3 );

   #############################
   # Treat all dimensions
   #############################

   # d loops over the dimensions in the TM1 model
   d = 1;
   While( d <= Dimsiz( '}Dimensions' ));

      vDim = Dimnm( '}Dimensions', d );
      DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

      d = d + 1;
   End;


ElseIf( pMode = 4 );

   #############################
   # Treat all application dimensions
   #############################

   # d loops over the dimensions in the TM1 model
   d = 1;
   While( d <= Dimsiz( '}Dimensions' ));
      vDim = Dimnm( '}Dimensions', d );
      If( Subst( vDim, 1, 1 ) @<> '}' );

         DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

      EndIf;
      d = d + 1;
   End;


ElseIf( pMode = 5 );

   #############################
   # Treat all control dimensions
   #############################

   # d loops over the dimensions in the TM1 model
   d = 1;
   While( d <= Dimsiz( '}Dimensions' ));
      vDim = Dimnm( '}Dimensions', d );
      If( Subst( vDim, 1, 1 ) @= '}' );

         DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

      EndIf;
      d = d + 1;
   End;


ElseIf( pMode = 6 );

   #############################
   # Treat all cubes
   #############################

   # c loops over the cubes in the TM1 model
   c = 1;
   While( c <= Dimsiz( '}Cubes' ));
      vCube = Dimnm( '}Cubes', c );

      If( CubeExists( vCube ) > 0 );

         DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

      EndIf;

      c = c + 1;
   End;


ElseIf( pMode = 7 );

   #############################
   # Treat all application cubes
   #############################

   # c loops over the cubes in the TM1 model
   c = 1;
   While( c <= Dimsiz( '}Cubes' ));
      vCube = Dimnm( '}Cubes', c );

      If( CubeExists( vCube ) > 0 );

         If( Subst( vCube, 1, 1 ) @<> '}' );

            DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

         EndIf;

      EndIf;

      c = c + 1;
   End;


ElseIf( pMode = 8 );

   #############################
   # Treat all control cubes
   #############################

   # c loops over the cubes in the TM1 model
   c = 1;
   While( c <= Dimsiz( '}Cubes' ));
      vCube = Dimnm( '}Cubes', c );

      If( CubeExists( vCube ) > 0 );

         If( Subst( vCube, 1, 1 ) @= '}' );

            DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

         EndIf;

      EndIf;

      c = c + 1;
   End;


ElseIf( pMode = 9 );

   #############################
   # Treat certain cubes related to security
   #############################

   cCubes = '}ClientGroups\}CubeSecurity\}DimensionSecurity\}ProcessSecurity\}ChoreSecurity\}ApplicationSecurity\';

   If( Subst( cCubes, Long( cCubes ), 1 ) @<> '\' );
      cCubes = cCubes | '\';
   EndIf;

   While( Long( cCubes ) > 0 );
      vCube = Subst( cCubes, 1, Scan( '\', cCubes) - 1 );

      If( CubeExists( vCube ) > 0 );

         DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

      EndIf;

      cCubes = Delet( cCubes, 1, Long( vCube ) + 1 );
   End;


ElseIf( pMode = 10 );

   #############################
   # Treat all security cubes
   #############################

   # c loops over the cubes in the TM1 model
   c = 1;
   While( c <= Dimsiz( '}Cubes' ));
      vCube = Dimnm( '}Cubes', c );

      If( CubeExists( vCube ) > 0 );

         If( vCube @= '}ClientGroups' %
             vCube @= '}CubeSecurity' %
             vCube @= '}DimensionSecurity' %
             vCube @= '}ProcessSecurity' %
             vCube @= '}ChoreSecurity' %
             vCube @= '}ApplicationSecurity' %
             vCube @= '}CubeSecurityProperties' %
             Scan( '}ElementSecurity_', vCube) = 1 %
             Scan( '}CellSecurity_', vCube) = 1 %
             Scan( '}SecurityOverlayGlobal_', vCube) = 1 );
            DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

         EndIf;

      EndIf;
      c = c + 1;
   End;


ElseIf( pMode = 11 );

   #############################
   # Treat certain cubes related to statistics (}StatsByPool is mine rather than offical by TM1)
   #############################

   cCubes = '}StatsByChore\}StatsByClient\}StatsByCube\}StatsByCubeByClient\}StatsByProcess\}StatsByRule\}StatsForServer\}StatsByPool\';

   If( Subst( cCubes, Long( cCubes ), 1 ) @<> '\' );
      cCubes = cCubes | '\';
   EndIf;

   While( Long( cCubes ) > 0 );
      vCube = Subst( cCubes, 1, Scan( '\', cCubes) - 1 );

      If( CubeExists( vCube ) > 0 );

         DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

      EndIf;

      cCubes = Delet( cCubes, 1, Long( vCube ) + 1 );
   End;


ElseIf( pMode = 12 );

   #############################
   # Treat all measures dimensions
   #############################

   # c loops over the cubes in the TM1 model
   c = 1;
   While( c <= Dimsiz( '}Cubes' ));
      vCube = Dimnm( '}Cubes', c );
      vMeasureDim = CellGetS( '}CubeProperties', vCube, 'MEASURES_DIMENSION' );
      If( Dimix( '}Dimensions', vMeasureDim ) > 0 );

         # m loops over the dimensions in the cube
         m = 1;
         While( m > 0);
            vDim = Tabdim( vCube, m );
            If( vDim @<> '' );
               If( Dimix( '}Dimensions', vMeasureDim ) = Dimix( '}Dimensions', vDim ));

                  DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

                  Break;
               EndIf;
            Else;
               Break;
            EndIf;
         End;
      EndIf;

      c = c + 1;
   End;


ElseIf( pMode = 13 );

   #############################
   # Treat all dimensions in a certain subset
   #############################

   # c loops over the dimensions in the subset
   If( SubsetExists( '}Dimensions', c09 ) > 0 );
      c = 1;
      While( c <= SubsetGetSize( '}Dimensions', c09 ));

         vDim = Dimnm( '}Dimensions', Dimix( '}Dimensions', SubsetGetElementName( '}Dimensions', c09, c )));
         DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );

         c = c + 1;
      End;
   EndIf;


ElseIf( pMode = 14 );

   #############################
   # Treat all cubes in a certain subset
   #############################

   # c loops over the cubes in the subset
   If( SubsetExists( '}Cubes', c10 ) > 0 );
      c = 1;
      While( c <= SubsetGetSize( '}Cubes', c10 ));
         vCube = Dimnm( '}Cubes', Dimix( '}Cubes', SubsetGetElementName( '}Cubes', c10, c )));

         If( CubeExists( vCube ) > 0 );

            DimensionElementInsertDirect( vTempDimForCubes, '', vCube, 'N' );

         EndIf;

         c = c + 1;
      End;
   EndIf;



EndIf;



# Gather the dimension names
c = 1;
While( c <= Dimsiz( vTempDimForCubes ));
   vCube = Dimnm( vTempDimForCubes, c );

      # m loops over the dimensions in the cube
      m = 1;
      While( m <= CubeDimensionCountGet( vCube ));
         vDim = Tabdim( vCube, m );
         DimensionElementInsertDirect( vTempDimForDims, '', vDim, 'N' );
         m = m + 1;
      End;

   c = c + 1;
End;


# Remove the temporary dimensions from this process
If( Dimix( vTempDimForDims, vTempDimForDims ) > 0 );
DimensionElementDeleteDirect( vTempDimForDims, vTempDimForDims );
DimensionUpdateDirect( vTempDimForDims );
EndIf;
If( Dimix( vTempDimForDims, vTempDimForCubes ) > 0 );
DimensionElementDeleteDirect( vTempDimForDims, vTempDimForCubes );
DimensionUpdateDirect( vTempDimForDims );
EndIf;

# Check if there are dimensions to be done
If( Dimsiz( vTempDimForDims ) = 0 );
ProcessBreak;
EndIf;


# Set the DataSource equal to a subset
vSubset = vRandom;
SubsetCreateByMDX( vSubset, '{TM1SubsetAll( [ '| vTempDimForDims |' ] )}' );

DataSourceType = 'SUBSET';
DataSourceNameForServer = vTempDimForDims;
DataSourceDimensionSubset = vSubset;
573,3
#****Begin: Generated Statements***
#****End: Generated Statements****

574,54
#****Begin: Generated Statements***
#****End: Generated Statements****


If( Scan( '\' | Upper( vDim ) | '\', Upper( cExcludedDims )) = 0 );


### If( Dimsiz( vDim ) = 0 );
### ItemReject( 'Dimension ''' | vDim | ''' does not contain elements.' );
### EndIf;


   e = 1;
   While( e <= Dimsiz( vDim ));

      vElem = Dimnm( vDim, e );

      If( ElparN( vDim, vElem ) >= pMinNumberOfParents );

         If(( ElparN( vDim, vElem ) <= pMaxNumberOfParents ) % ( pMaxNumberOfParents = -1 ));

            # get the parent names
            vParents = '';
            p = 1;
            While( p <= ElparN( vDim, vElem ));
               vParent = Elpar( vDim, vElem, p );
               vParents = vParents | DataSourceAsciiDelimiter | vParent;
               p = p + 1;
            End;
            If( Long( vParents ) > 0 );
               vParents = Delet( vParents, 1, Long( DataSourceAsciiDelimiter ));
            EndIf;

            # a header for the text file
            If( vMultipleParents = 0 );
               TextOutput( vFile, 'Dimension', 'Element Index', 'Element Name', 'Element Type', 'Number of parents', 'Immediate parents...' );
            EndIf;

            # an entry in the text file
            TextOutput( vFile, vDim, NumberToString( e ), vElem, DType( vDim, vElem ), NumberToString( ElparN( vDim, vElem )), vParents );

            vMultipleParents = vMultipleParents + 1;

         EndIf;

      EndIf;

      e = e + 1;

   End;



EndIf;
575,40
#****Begin: Generated Statements***
#****End: Generated Statements****


# A simple report in case no elements with multiple parents were found
If( Dimsiz( vTempDimForDims ) = 0 );

   c0 = 'The process did not have any dimensions to treat.';
   TextOutput( vFile, c0 );
   LogOutput( 'INFO', c0 );

ElseIf( vMultipleParents = 0 );

   c0 = 'No elements with multiple parents were found in the dimension(s):';
   LogOutput( 'INFO', c0 | ' Check the file ''' | vFile | ''' to see which dimensions were investigated.' );

   TextOutput( vFile, c0 );

   d = 1;
   While( d <= Dimsiz( vTempDimForDims ));

      vDim = Dimnm( vTempDimForDims, d );
      TextOutput( vFile, vDim );

      d = d + 1;

   End;

Else;

   c0 = 'The process found elements with multiple parents.';
   LogOutput( 'INFO', c0 | ' Check the file ''' | vFile | ''' to see them.' );

EndIf;


# Delete the temporary objects again

DimensionDestroy( vTempDimForDims );
DimensionDestroy( vTempDimForCubes );
576,_ParameterConstraints=e30=
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
