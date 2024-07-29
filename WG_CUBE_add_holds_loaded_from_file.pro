601,100
602,"WG_CUBE_add_holds_loaded_from_file"
562,"CHARACTERDELIMITED"
586,"D:\OneDrive\OneDrive - Aexis Belgium NV\Z_Rest\TM1 Log files TI processes\TM1 output\Test load file for a cube\data.txt"
585,"D:\OneDrive\OneDrive - Aexis Belgium NV\Z_Rest\TM1 Log files TI processes\TM1 output\Test load file for a cube\data.txt"
564,
565,"n0F::>lOKZErFya`?k;p9dPXJHpVQb>:P=5CY>Mont0kyDBbh5OY5osGva:2v^ZdqncF0PN5?;Bda3TCVg6@OY`vs@uuwMEEGo6_Kr]a3[LomzW3C?T:ZR_g;iif=5i]wqv<<rIXGoHXyPbz;ae>DY7n`Uy[Urfg4DDg\a8bHJ5Sj\CIfOfOwCAPiZz2F1[0Dd9[C6?t"
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
567,"	"
588,","
589,"."
568,""""
570,
571,
569,1
592,0
599,1000
560,1
pCube
561,1
2
590,1
pCube,""
637,1
pCube,"Cube name ?"
577,20
V01
V02
V03
V04
V05
V06
V07
V08
V09
V10
V11
V12
V13
V14
V15
V16
V17
V18
V19
V20
578,20
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
579,20
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
580,20
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
581,20
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
582,20
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
603,0
572,107

#****Begin: Generated Statements***
#****End: Generated Statements****


# https://www.tm1forum.com/viewtopic.php?t=16519

nDimMax = 20;

vData_Cube = pCube;
If( CubeExists( vData_Cube ) = 0 );
   LogOutput( 'ERROR', 'The cube ''' | pCube | ''' does not exist.' );
   ProcessError;
EndIf;

nDimCount = CubeDimensionCountGet( vData_Cube );
If( nDimCount > nDimMax );
   LogOutput( 'ERROR', 'The process supports cubes with up to ' | NumberToString( nDimMax ) | ' dimensions. The chosen cube contains ' | NumberToString( nDimCount ) | ' dimensions.' );
   ProcessError;
EndIf;

vUser = TM1User;
If( Subst( vUser, 1, 2 ) @= 'R*' );
   vUser = 'Admin';
Else;
   vUser = Attrs( '}Clients', vUser, '}TM1_DefaultDisplayValue' );
   If( vUser @= '' );
      vUser = TM1User;
   EndIf;
EndIf;

vHolds_Cube = '}Hold_' | vUser | '_}}_' | vData_Cube;
vHolds_Dim_Msr = '}Hold';

If( DimensionExists( vHolds_Dim_Msr ) = 0 );

   DimensionCreate( vHolds_Dim_Msr );
   DimensionElementInsert( vHolds_Dim_Msr, '', 'HoldStatus', 'S' );

EndIf;


sDim01 = Tabdim( vData_Cube, 1  );
sDim02 = Tabdim( vData_Cube, 2  );
sDim03 = Tabdim( vData_Cube, 3  );
sDim04 = Tabdim( vData_Cube, 4  );
sDim05 = Tabdim( vData_Cube, 5  );
sDim06 = Tabdim( vData_Cube, 6  );
sDim07 = Tabdim( vData_Cube, 7  );
sDim08 = Tabdim( vData_Cube, 8  );
sDim09 = Tabdim( vData_Cube, 9  );
sDim10 = Tabdim( vData_Cube, 10 );
sDim11 = Tabdim( vData_Cube, 11 );
sDim12 = Tabdim( vData_Cube, 12 );
sDim13 = Tabdim( vData_Cube, 13 );
sDim14 = Tabdim( vData_Cube, 14 );
sDim15 = Tabdim( vData_Cube, 15 );
sDim16 = Tabdim( vData_Cube, 16 );
sDim17 = Tabdim( vData_Cube, 17 );
sDim18 = Tabdim( vData_Cube, 18 );
sDim19 = Tabdim( vData_Cube, 19 );
sDim20 = Tabdim( vData_Cube, 20 );


If( CubeExists( vHolds_Cube ) = 0 );

   If( nDimCount = 2 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, vHolds_Dim_Msr );
   ElseIf( nDimCount = 3  );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, vHolds_Dim_Msr );
   ElseIf( nDimCount = 4  );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, vHolds_Dim_Msr );
   ElseIf( nDimCount = 5  );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, vHolds_Dim_Msr );
   ElseIf( nDimCount = 6  );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, vHolds_Dim_Msr );
   ElseIf( nDimCount = 7  );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, vHolds_Dim_Msr );
   ElseIf( nDimCount = 8  );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, vHolds_Dim_Msr );
   ElseIf( nDimCount = 9  );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, vHolds_Dim_Msr );
   ElseIf( nDimCount = 10 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, vHolds_Dim_Msr );
   ElseIf( nDimCount = 11 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, vHolds_Dim_Msr );
   ElseIf( nDimCount = 12 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, vHolds_Dim_Msr );
   ElseIf( nDimCount = 13 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, vHolds_Dim_Msr );
   ElseIf( nDimCount = 14 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, sDim14, vHolds_Dim_Msr );
   ElseIf( nDimCount = 15 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, sDim14, sDim15, vHolds_Dim_Msr );
   ElseIf( nDimCount = 16 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, sDim14, sDim15, sDim16, vHolds_Dim_Msr );
   ElseIf( nDimCount = 17 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, sDim14, sDim15, sDim16, sDim17, vHolds_Dim_Msr );
   ElseIf( nDimCount = 18 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, sDim14, sDim15, sDim16, sDim17, sDim18, vHolds_Dim_Msr );
   ElseIf( nDimCount = 19 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, sDim14, sDim15, sDim16, sDim17, sDim18, sDim19, vHolds_Dim_Msr );
   ElseIf( nDimCount = 20 );
      CubeCreate( vHolds_Cube, sDim01, sDim02, sDim03, sDim04, sDim05, sDim06, sDim07, sDim08, sDim09, sDim10, sDim11, sDim12, sDim13, sDim14, sDim15, sDim16, sDim17, sDim18, sDim19, sDim20, vHolds_Dim_Msr );
   EndIf;

EndIf;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,72

#****Begin: Generated Statements***
#****End: Generated Statements****


# test the existence of the supplied element names
vExist = 1;
vCellType = 'N';
d = 1;
While( ( vExist = 1 ) & ( d <= nDimCount ));
   sDim = Expand( '%sDim' | NumberToStringEx( d, '00', '', '' ) | '%' );
   sElem = Expand( '%V' | NumberToStringEx( d, '00', '', '' ) | '%' );
   If( Dimix( sDim, sElem ) = 0 );
      vExist = 0;
   ElseIf( Dtype( sDim, sElem ) @= 'C' );
      vCellType = 'C';
   EndIf;
   d = d + 1;
End;

If( vExist = 0 );
   # Itemskip;
   ItemReject( 'This line contains not existing element references.' );
EndIf;

# hold type: C for consolidate, H for leaves
If( vCellType @= 'C' );
   vHoldType = 'C';
Else;
   vHoldType = 'H';
EndIf;

# update the control cube for the Holds
If( nDimCount = 2 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, 'HoldStatus' );
ElseIf( nDimCount = 3  );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, 'HoldStatus' );
ElseIf( nDimCount = 4  );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, 'HoldStatus' );
ElseIf( nDimCount = 5  );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, 'HoldStatus' );
ElseIf( nDimCount = 6  );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, 'HoldStatus' );
ElseIf( nDimCount = 7  );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, 'HoldStatus' );
ElseIf( nDimCount = 8  );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, 'HoldStatus' );
ElseIf( nDimCount = 9  );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, 'HoldStatus' );
ElseIf( nDimCount = 10 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, 'HoldStatus' );
ElseIf( nDimCount = 11 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, 'HoldStatus' );
ElseIf( nDimCount = 12 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, 'HoldStatus' );
ElseIf( nDimCount = 13 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, 'HoldStatus' );
ElseIf( nDimCount = 14 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, 'HoldStatus' );
ElseIf( nDimCount = 15 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15, 'HoldStatus' );
ElseIf( nDimCount = 16 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15, V16, 'HoldStatus' );
ElseIf( nDimCount = 17 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15, V16, V17, 'HoldStatus' );
ElseIf( nDimCount = 18 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15, V16, V17, V18, 'HoldStatus' );
ElseIf( nDimCount = 19 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, 'HoldStatus' );
ElseIf( nDimCount = 20 );
   CellPutS( vHoldType, vHolds_Cube, V01, V02, V03, V04, V05, V06, V07, V08, V09, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, 'HoldStatus' );
EndIf;
575,3

#****Begin: Generated Statements***
#****End: Generated Statements****
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
