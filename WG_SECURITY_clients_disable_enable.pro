601,100
602,"WG_SECURITY_clients_disable_enable"
562,"NULL"
586,
585,
564,
565,"yBY<Lshb4fle1b>HGr5:]6claa1M0=KE@O_ViI<pN:BLMjK5z`QQ^UUYa1YxrpcgHQ8VE4zZk`WI;xG;3J>t]uIzm@83ugvscO<DDjtC8k?wH62@W;pal_3ATM_<ATcF_M_cE37b<VXXH7yuT4osgKD^Vt1JYNmRTea=z[Wf;sxNiEK@<XuiHbhW^<aZEmS0nx9V]@eN"
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
560,1
pStatus
561,1
2
590,1
pStatus,""
637,1
pStatus,"The status of users except Admin can be changed. D = Disable, E = Enable"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,30

#****Begin: Generated Statements***
#****End: Generated Statements****


If( pStatus @<> 'E'
  & pStatus @<> 'D');
   ProcessError;
EndIf;


c = 1;
While( c <= Dimsiz( '}Clients' ));

   vClient = Dimnm( '}Clients', c );

   If( pStatus @= 'E' );
      CellPutN( 0, '}ClientProperties', vClient, 'IsDisabled' );

   ElseIf( pStatus @= 'D' );
      If( vClient @<> 'Admin' );
      If( CellGetS( '}ClientGroups', vClient, 'ADMIN' ) @<> 'ADMIN' );
         CellPutN( 1, '}ClientProperties', vClient, 'IsDisabled' );
      EndIf;
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
