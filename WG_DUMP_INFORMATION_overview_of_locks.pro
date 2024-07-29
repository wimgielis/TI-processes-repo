601,100
602,"WG_DUMP_INFORMATION_overview_of_locks"
562,"NULL"
586,
585,
564,
565,"iRM7s5O8>ao6Ql1fqjk>?\ZMO^]e9?NLu_\yOq]iJ>cG0>dR5O>sptL2\Lq8jm4KE7Bap3c7UAMuyfbuAhENbBOm;Ri]3B007MmsKTwPa^W\GWet1@]ney6dFhd0PP7qpSxBLr?jQu4i6n9<kaTtyK9rpaY_4n1C6`W;0vMNQKKcneT24>20czZFd>\asV`RaU8viSny"
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
572,216

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This process can populate a text file with an overview of locks in a TM1 model:
# - locks on what object ? (cube, dimension, hierarchy, element in a dimension, element in a hierarchy)
# - who holds the lock ?
# - is the lock rules-driven or static ?
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
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_locks' );
EndIf;
#EndRegion CallThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of locks', 'pMainFolder', '1+' );


vFile_Locks = cDestination_Folder | 'Locks.csv';
AsciiDelete( vFile_Locks );


DataSourceAsciiQuoteCharacter = '';
DataSourceAsciiDelimiter = ';';

# output the titles in the output file
TextOutput( vFile_Locks, 'Area', 'Full object reference', 'Lock owner', 'Affected cubes' );


#############################
##  CUBE LOCKS
#############################

# loop over cubes
n = 0;
c = 1;
While( c <= ElementCount( '}Cubes', '' ));

   vCube = ElementName( '}Cubes', '', c );

   vLock_Cube_Cell = CellGetS( '}CubeProperties', vCube, 'LOCK' );
   If( vLock_Cube_Cell @<> '' );

      n = n + 1;

      If( ElementIndex( '}Clients', '', vLock_Cube_Cell ) > 0 );
         vLock_Owner = vLock_Cube_Cell;
      Else;
         vLock_Owner = 'Unknown lock owner';
      EndIf;

      vAffected_Cubes = vCube;
      vArea = 'Cube';
      TextOutput( vFile_Locks, vArea, vCube, vLock_Owner, vCube );

   EndIf;

   c = c + 1;
End;

If( n = 0 );
   TextOutput( vFile_Locks, 'No locks on cubes were found.', '', '', '' );
EndIf;


#############################
##  DIMENSION LOCKS
#############################

# loop over dimensions
n = 0;
d = 1;
While( d <= ElementCount( '}Dimensions', '' ));

   vDim = ElementName( '}Dimensions', '', d );

   # hierarchies cannot be locked separately from their dimensions
   If( Scan( ':', vDim ) = 0 );

      vLock_Dimension_Cell = CellGetS( '}DimensionProperties', vDim, 'LOCK' );
      If( vLock_Dimension_Cell @<> '' );

         n = n + 1;

         If( ElementIndex( '}Clients', '', vLock_Dimension_Cell ) > 0 );
            vLock_Owner = vLock_Dimension_Cell;
         Else;
            vLock_Owner = 'Unknown lock owner';
         EndIf;

         vAffected_Cubes = '';
         cLoop = 1;
         While( cLoop <= ElementCount( '}Cubes', '' ));
            cCube = ElementName( '}Cubes', '', cLoop );
            dLoop = 1;
            While( dLoop <= CubeDimensionCountGet( cCube ));

               cDim = Tabdim( cCube, dLoop );
               If( vDim @= cDim );
                  vAffected_Cubes = vAffected_Cubes | If( vAffected_Cubes @= '', '', ' | ' ) | cCube;
                  dLoop = 10000;
               EndIf;

               dLoop = dLoop + 1;
            End;

            cLoop = cLoop + 1;
         End;

         vArea = 'Dimension';
         TextOutput( vFile_Locks, vArea, vDim, vLock_Owner, vAffected_Cubes );

      EndIf;

   EndIf;

   d = d + 1;
End;

If( n = 0 );
   TextOutput( vFile_Locks, 'No locks on dimensions were found.', '', '', '' );
EndIf;


#############################
##  ELEMENT LOCKS
#############################

# loop over dimensions
n = 0;
d = 1;
While( d <= ElementCount( '}Dimensions', '' ));

   vDim = ElementName( '}Dimensions', '', d );

   # elments in hierarchies cannot be locked separately from their dimensions
   If( Scan( ':', vDim ) = 0 );

      vLock_Cube_For_Elements = '}ElementProperties_' | vDim;
      If( CubeExists( vLock_Cube_For_Elements ) = 1 );

         # loop over elements
         e = 1;
         While( e <= ElementCount( vDim, '' ));

            vElement = ElementName( vDim, '', e );

            vLock_Cube_Elements = CellGetS( vLock_Cube_For_Elements, vElement, 'LOCK' );
            If( vLock_Cube_Elements @<> '' );

               n = n + 1;

               If( ElementIndex( '}Clients', '', vLock_Cube_Elements ) > 0 );
                  vLock_Owner = vLock_Cube_Elements;
               Else;
                  vLock_Owner = 'Unknown lock owner';
               EndIf;

               vAffected_Cubes = '';
               cLoop = 1;
               While( cLoop <= ElementCount( '}Cubes', '' ));
                  cCube = ElementName( '}Cubes', '', cLoop );
                  dLoop = 1;
                  While( dLoop <= CubeDimensionCountGet( cCube ));

                     cDim = Tabdim( cCube, dLoop );
                     If( vDim @= cDim );
                        vAffected_Cubes = vAffected_Cubes | If( vAffected_Cubes @= '', '', ' | ' ) | cCube;
                        dLoop = 10000;
                     EndIf;

                     dLoop = dLoop + 1;
                  End;

                  cLoop = cLoop + 1;
               End;

               vArea = 'Element';
               TextOutput( vFile_Locks, vArea, vDim | ':' | vElement, vLock_Owner, vAffected_Cubes );

            EndIf;

            e = e + 1;
         End;

      EndIf;

   EndIf;

   d = d + 1;
End;

If( n = 0 );
   TextOutput( vFile_Locks, 'No locks on elements were found.', '', '', '' );
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
