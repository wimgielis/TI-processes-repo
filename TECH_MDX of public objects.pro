601,100
602,"TECH_MDX of public objects"
562,"NULL"
586,
585,
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
571,
569,0
592,0
599,1000
560,1
pPrivate_Objects_Root_Folder
561,1
2
590,1
pPrivate_Objects_Root_Folder,""
637,1
pPrivate_Objects_Root_Folder,"Root folder for private objects ?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,114

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
###########################################################
# Wim Gielis
# September 2021
# https://www.wimgielis.com
###########################################################
#
# As of PAL 2.0.9, MDX queries and element security rules have changed
# Therefore, it's useful to have an overview of all MDX statements in public views and subsets
# Also, as of TM1 server v12, MDX syntax will change (more restrictive).
# Hence, an overview of all MDX expressions is useful.
#
# See my Github repository for a Python script that does both public and private, views and subsets.
#
###########################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'TECH_MDX of public objects'
  , 'pPrivate_Objects_Root_Folder', ''
);
EndIf;
#EndRegion CallThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'MDX of public objects', 'pMainFolder', '1+' );

cOutputFile = cDestination_Folder | 'MDX.txt';
AsciiDelete( cOutputFile );

DataSourceAsciiQuoteCharacter = '';


# loop over cubes and retrieve their public views
dLoop = 1;
While( dLoop <= Dimsiz( '}Cubes' ));
   vCube = Dimnm( '}Cubes', dLoop );
   If( CubeExists( vCube ) > 0 );

      vDim_Views = '}Views_' | vCube;
      If( DimensionExists( vDim_Views ) > 0 );

         x = 1;
         While( x <= Dimsiz( vDim_Views ));

            vViewName = Dimnm( vDim_Views, x );

            s = Trim( ViewMDXGet( vCube, vViewName ));
            If( Long( s ) > 0 );
               TextOutput( cOutputFile, 'Cube', vCube, '', '', 'View', vViewName, 'Type', 'Public', 'MDX', s );
            EndIf;

            x = x + 1;
         End;

      EndIf;
   EndIf;

   dLoop = dLoop + 1;
End;


# loop over dimensions and hierarchies and retrieve their public subsets
dLoop = 1;
While( dLoop <= Dimsiz( '}Dimensions' ));
   vDimension = Dimnm( '}Dimensions', dLoop );
   If( DimensionExists( vDimension ) > 0 );

      vScan = Scan( ':', vDimension );
      If( vScan = 0 );

         vDim_Subsets = '}Subsets_' | vDimension;

         x = 1;
         While( x <= Dimsiz( vDim_Subsets ));

            vSubsetName = Dimnm( vDim_Subsets, x );
            vScan = Scan( ':', vSubsetName );
            If( vScan = 0 );
               vHier = vDimension;
            Else;
               vHier = Subst( vSubsetName, 1, vScan - 1 );
               vSubsetName = Delet( vSubsetName, 1, vScan );
            EndIf;

            s = Trim( HierarchySubsetMDXGet( vDimension, vHier, vSubsetName ));
            If( Long( s ) > 0 );
               TextOutput( cOutputFile, 'Dimension', vDimension, 'Hierarchy', vHier, 'Subset', vSubsetName, 'Type', 'Public', 'MDX', s );
            EndIf;

            x = x + 1;
         End;

      EndIf;

   EndIf;

   dLoop = dLoop + 1;
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
