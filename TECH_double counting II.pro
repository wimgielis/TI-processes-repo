601,100
602,"TECH_double counting II"
562,"VIEW"
586,"}TECH_Double_Countings"
585,"}TECH_Double_Countings"
564,
565,"mK3Vy;yQckQ3la42EjlkpIi]X_8Kp2l6SwRt_L]Wy3HfYG4iwUygp9]Xc^[j@fZF]btLFizAqvB6iG5N=v[be=9=<kNM:;LYJE<1JJ5cLuc>hbpB_QMMHDvhyvAaP;LYTJw]W9?\6Qci72gv_@CkHCn\ZtLUWqV7nhhTbqAU2PzkAU7W\qkCdpl1HO0Mw7FR=k36Ozl<"
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
570,Default
571,
569,0
592,0
599,1000
560,5
pCube
pDim
pHier
pSubsetAndAttrWithDC
cTemp
561,5
2
2
2
2
2
590,5
pCube,""
pDim,""
pHier,""
pSubsetAndAttrWithDC,""
cTemp,""
637,5
pCube,"Cube name ?"
pDim,"Name of the original dimension ?"
pHier,"Name of the original hierarchy ?"
pSubsetAndAttrWithDC,"Name of the subset on the original hierarchy for storing the double counting issues ?"
cTemp,"A cube to determine the weights"
577,7
vAll
vConso
vMsr
Value
NVALUE
SVALUE
VALUE_IS_STRING
578,7
2
2
2
1
1
2
1
579,7
1
2
3
4
0
0
0
580,7
0
0
0
0
0
0
0
581,7
0
0
0
0
0
0
0
582,4
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=33ColType=827
603,0
572,60

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# January 2024
# https://www.wimgielis.com
####################################################
# Do not execute this process in isolation or manually.
# It is kicked off automatically by the main double counting process.
####################################################
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'TECH_double counting II'
     , 'pCube', pCube
     , 'pDim', pDim
     , 'pHier', pHier
     , 'pSubsetAndAttrWithDC', ''
     , 'cTemp', ''
);
EndIf;
#EndRegion CallThisProcess


# populate a second measure with the double counting issues
c0 = 'tmp_' | GetProcessName | '_' | Timst( Now, '\Y\m\d\h\i\s' ) | '_' | NumberToString( Int( Rand * 100000 ));
vDim3 = CellGetS( '}CubeProperties', pCube, 'MEASURES_DIMENSION' );
c03 = 'Count of instances';
c04 = 'Double counting issue';

ViewCreate( pCube, c0, 1 );
SubsetCreateByMDX( c0, '{[' | vDim3 | '].[' | vDim3 | '].[' | c03 |']}', 1);
ViewSubsetAssign( pCube, c0, vDim3, c0 );

DataSourceType = 'VIEW';
DataSourceNameForServer = pCube;
DataSourceCubeView = c0;


vFillSubset = 0;
If( DimensionExists( pDim ) > 0 );
   If( HierarchySubsetExists( pDim, pHier, pSubsetAndAttrWithDC ) > 0 );
      vFillSubset = 1;
   EndIf;
EndIf;

vFillWeight = 0;
If( CubeExists( cTemp ) > 0 );
   If( DimensionExists( cTemp ) > 0 );
      HierarchyElementInsert( pDim, pHier, '', cTemp, 'N' );
      vFillWeight = 1;
   EndIf;
EndIf;
573,4

#****Begin: Generated Statements***
#****End: Generated Statements****

574,66

#****Begin: Generated Statements***
#****End: Generated Statements****


If( Value > 1 );

   CellPutN( Value, pCube, vAll, vConso, c04 );
   CellPutS( vAll, pCube, vAll, vConso, 'Descendant' );
   CellPutS( vConso, pCube, vAll, vConso, 'consolidation' );

   # we have a double counting issue
   If( vFillSubset = 1 );

      If( HierarchySubsetElementExists( pDim, pHier, pSubsetAndAttrWithDC, vAll ) = 0 );
          HierarchySubsetElementInsert( pDim, pHier, pSubsetAndAttrWithDC, vAll, 0 );
      EndIf;

   EndIf;

   # determine the weights
   If( vFillWeight = 1 );

      # measure the effect of the double counted element on the consolidated element
      If( ElementType( pDim, pHier, vAll ) @= 'N' );
         # use the existing double counted element to measure this effect
         CellPutN( 1, cTemp, pHier:vAll, 'Weight' );
         vWeight = CellGetN( cTemp, pHier:vConso, 'Weight' );
         CellPutN( vWeight, pCube, vAll, vConso, 'Weight' );
         CellPutN( 0, cTemp, pHier:vAll, 'Weight' );
      Else;
         # use a dummy element of type N to measure this effect
         If( ElementParent( pDim, pHier, cTemp, 1 ) @<> vAll );
            If( ElementParent( pDim, pHier, cTemp, 1 ) @<> '' );
               HierarchyElementComponentDeleteDirect( pDim, pHier, ElementParent( pDim, pHier, cTemp, 1 ), cTemp );
            EndIf;
            HierarchyElementComponentAddDirect( pDim, pHier, vAll, cTemp, 1 );
         EndIf;

         CellPutN( 1, cTemp, pHier:cTemp, 'Weight' );
         vWeight = CellGetN( cTemp, pHier:vConso, 'Weight' );
         CellPutN( vWeight, pCube, vAll, vConso, 'Weight' );
         CellPutN( 0, cTemp, pHier:cTemp, 'Weight' );
      EndIf;

   EndIf;

   # add to a text attribute
   vParents = ElementAttrS( pDim, pHier, vAll, pSubsetAndAttrWithDC );
   vScan = Scan( ':', vParents );
   If( vScan = 0 );
      vParents = '1: ' | vConso;
      If( vFillWeight = 1 );
         vParents = vParents | ' (' | NumberToString( vWeight ) | ')';
      EndIf;
   Else;
      vNrOfParents = StringToNumber( Subst( vParents,  1, vScan - 1 ));
      vParents = NumberToString( vNrOfParents + 1 ) | Delet( vParents, 1, vScan - 1 ) | ' | ' | vConso;
      If( vFillWeight = 1 );
         vParents = vParents | ' (' | NumberToString( vWeight ) | ')';
      EndIf;
   EndIf;

   ElementAttrPutS( Subst( vParents, 1, Min( 200, Long( vParents ))), pDim, pHier, vAll, pSubsetAndAttrWithDC );

EndIf;
575,8

#****Begin: Generated Statements***
#****End: Generated Statements****


If( ElementIndex( pDim, pHier, cTemp ) > 0 );
   HierarchyElementDeleteDirect( pDim, pHier, cTemp );
EndIf;
576,CubeAction=1511DataAction=1503CubeLogChanges=0
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
