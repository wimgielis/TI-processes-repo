601,100
602,"WG_SECURITY_lock_objects"
562,"NULL"
586,
585,
564,
565,"e>tfxachS4UikE;Y8j_;:6S^Ke3`4@D?_BkJUp@hekYb9B:XCRv63`SY9ZUu`^0a]Dn@6r5ffPbYM3<_?nU[g>yvp<X2@E:ICk@v5SdXzrRLX`tPE`aN8kfNxCY51\UgMRNSfBwbMqD0b@__^VAc4mRvp7Yk:IqV2aUwK>9YP2QDUNsCjnRcbLp@AFZfs]bkErH_Z5Qy"
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
572,166

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# September 2023
# https://www.wimgielis.com
####################################################
#EndRegion IntroduceThisProcess


vUser = TM1User;
# vUser = 'Admin';

vCube = 'IncomeStatement';
vDim = 'Rpt_Year';
vElement = '2024';


# Locks will block any user and any TI process.
# One way to circumvent it, is the function CubeLockOverride (see: https://cubewise.com/blog/things-might-not-know-tm1-security-part-2)


# Locking/unlocking a cube ( this locks/unlocks the entire cube, no data changes are possible )

# Our options include:
# - in Turbo Integrator:
#      * CubeSetLockStatus( <vCube>, <1=lock|0=unlock> ); (this appears to be an undocumented function, it is not recognized in PAW but the process saves and runs)
#      * When a chore runs this process, the username in the }CubeProperties cube becomes 'Admin'
#      * CellPutS( <vUser (TM1User() typically) to lock|'' to unlock>, '}CubeProperties', vCube, 'LOCK' );
# - manually, in PAW:
#      * right-click a cube > Cube operations > Lock cube (if it is currently unlocked) / Unlock cube (if it is currently locked) (a lock icon will appear when locked)
#      * editing the cell in the }CubeProperties cube on the measure LOCK and the said cube
# - manually, in Architect/Perspectives:
#      * right-click a cube in the Server Explorer > Security > Lock (if it is currently unlocked) / Unlock (if it is currently locked)
#      * editing the cell in the }CubeProperties cube on the measure LOCK and the said cube
# - in the TM1 REST API:
#      * POST /api/v1/Cubes('<vCube>')/tm1.Lock|/api/v1/Cubes('<vCube>')/tm1.Unlock (204 No Content) (the username in the }CubeProperties cube becomes the REST API account)

# to test the existence of a cube lock:
If( Dimix( '}Clients', CellGetS( '}CubeProperties', vCube, 'LOCK' )) > 0 );
   # the cube is locked
EndIf;

# to lock a cube:
If( CellIsUpdateable( '}CubeProperties', vCube, 'LOCK' ) > 0 );
   CellPutS( vUser, '}CubeProperties', vCube, 'LOCK' );
EndIf;

# to unlock a cube:
If( CellIsUpdateable( '}CubeProperties', vCube, 'LOCK' ) > 0 );
   CellPutS( '', '}CubeProperties', vCube, 'LOCK' );
EndIf;

# Alternatively:
# Security access checkbox is not needed
CubeSetLockStatus( vCube, 1 );



# Locking/unlocking an element in a hierarchy of a dimension ( this locks/unlocks all cubes that use this dimension, on the specified element )
# No data changes are possible on this element
# also, attributes for a locked element cannot be set or changed

# Our options include:
# - in Turbo Integrator:
#      * DimensionElementSetLockStatus( <vDim>, <vElement>, <1=lock|0=unlock> ); (this appears to be an undocumented function, it is not recognized in PAW but the process saves and runs)
#      * When a chore runs this process, the username in the }CubeProperties cube becomes 'Admin'
#      * CubeLockOverride( 1 );
#        CellPutS( <vUser (TM1User() typically) to lock|'' to unlock>, '}ElementProperties_<vDim>', vElement, 'LOCK' );
#        CubeLockOverride( 0 );
# - manually, in PAW:
#      * currently this is not possible (September 2023, probably implemented by the end of 2023)
#      * editing the cell in the }ElementProperties cube has never worked
# - manually, in Architect/Perspectives:
#      * right-click an element in the Subset Editor > Security > Lock (if it is currently unlocked) / Unlock (if it is currently locked)
#      * editing the cell in the }ElementProperties cube has never worked
# - in the TM1 REST API:
#      * Not possible with a POST query towards Dimensions('<vDim>')/Hierarchies('<vHier>')/Elements('<vElement>') and then tm1.Lock|tm1.Unlock
#      * Possible via:
# 
#          to lock:
# 
#          POST /api/v1/Cubes('}ElementProperties_vDim')/tm1.Update
#          {"Cells": [{"Tuple@odata.bind": ["Dimensions('}ElementProperties')/Hierarchies('}ElementProperties')/Elements('LOCK')",
#              "Dimensions('vDim')/Hierarchies('vDim')/Elements('vElement')"]}],"Value":"Admin"}
#          to unlock:
#          POST /api/v1/ExecuteMDX?$expand=Cells,Axes($expand=Tuples($expand=Members))
#          {"MDX":"SELECT {[}ElementProperties].[}ElementProperties].[LOCK]} ON 0, {[vDim].[vDim].[vElement]} ON 1 FROM [}ElementProperties_vDim]"}
#          DELETE /api/v1/Cellsets('...')

# to test the existence of an element lock:
If( CubeExists( '}ElementProperties_' | vDim ) = 0 );
   # the element is not locked
Else;
   If( Dimix( '}Clients', CellGetS( '}ElementProperties_' | vDim, vElement, 'LOCK' )) > 0 );
      # the element is locked
   EndIf;
EndIf;

# to lock:
If( CubeExists( '}ElementProperties_' | vDim ) = 0 );
   CubeCreate( '}ElementProperties_' | vDim, vDim, '}ElementProperties' );
EndIf;

# A simple CellPutS works fine provided we override existing locks
CubeLockOverride( 1 );
# If( CellIsUpdateable( '}ElementProperties_' | vDim, vElement, 'LOCK' ) > 0 );
   CellPutS( vUser, '}ElementProperties_' | vDim, vElement, 'LOCK' );
# EndIf;
# CubeLockOverride( 0 );

# to unlock:
# A simple CellPutS works fine provided we override existing locks
CubeLockOverride( 1 );
If( CubeExists( '}ElementProperties_' | vDim ) > 0 );
   # If( CellIsUpdateable( '}ElementProperties_' | vDim, vElement, 'LOCK' ) > 0 );
      CellPutS( '', '}ElementProperties_' | vDim, vElement, 'LOCK' );
   # EndIf;
EndIf;
# CubeLockOverride( 0 );

# Security access checkbox is not needed
DimensionElementSetLockStatus( vDim, vElement, 1 );



# Locking/unlocking a dimension ( this locks/unlocks the entire dimension, no metadata changes are possible )
# This does not block data changes in cube cells that reference any of the elements within the dimension, rather, changes to the contents and properties of the dimension

# Our options include:
# - in Turbo Integrator:
#      * DimensionSetLockStatus( <vDim>, <1=lock|0=unlock> ); (this appears to be an undocumented function, it is not recognized in PAW but the process saves and runs)
#      * When a chore runs this process, the username in the }DimensionProperties cube becomes 'Admin'
#      * CellPutS( <vUser (TM1User() typically) to lock|'' to unlock>, '}DimensionProperties', vDim, 'LOCK' );
# - manually, in PAW:
#      * right-click a dimension > Lock dimension (if it is currently unlocked) / Unlock dimension (if it is currently locked) (a lock icon will appear when locked)
#      * editing the cell in the }DimensionProperties cube on the measure LOCK and the said dimension
# - manually, in Architect/Perspectives:
#      * right-click a dimension in the Server Explorer > Security > Lock (if it is currently unlocked) / Unlock (if it is currently locked)
#      * editing the cell in the }DimensionProperties cube on the measure LOCK and the said dimension
# - in the TM1 REST API:
#      * POST /api/v1/Dimensions('<vDim>')/tm1.Lock|/api/v1/Dimensions('<vDim>')/tm1.Unlock (204 No Content) (the username in the }DimensionProperties cube becomes the REST API account)


# to test the existence of a dimension lock:
If( Dimix( '}Clients', CellGetS( '}DimensionProperties', vDim, 'LOCK' )) > 0 );
   # the dimension is locked
EndIf;

# to lock a dimension:
If( CellIsUpdateable( '}DimensionProperties', vDim, 'LOCK' ) > 0 );
   CellPutS( vUser, '}DimensionProperties', vDim, 'LOCK' );
EndIf;

# to unlock a dimension:
If( CellIsUpdateable( '}DimensionProperties', vDim, 'LOCK' ) > 0 );
   CellPutS( '', '}DimensionProperties', vDim, 'LOCK' );
EndIf;

# Alternatively:
# Security access checkbox is not needed
DimensionSetLockStatus( vDim, 1 );
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
