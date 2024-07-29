601,100
602,"WG_CLOUD_viewconstruct"
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
572,86

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# March 2024
# https://www.wimgielis.com
####################################################
#
# This process can run a ViewConstruct on all public cube views that start with the word "viewconstruct_" (case insensitive)
#
####################################################
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_CLOUD_viewconstruct'
);
EndIf;
#EndRegion CallThisProcess


vPattern = 'viewconstruct_*';
c0 = 'temp';

# loop over the cubes
# if you are on PA local 2.0, for each cube, then we can loop over a control dimension that contains all public views, we loop using a subset that filters on the name pattern
# if you are not on PA local 2.0, for each cube, then we loop over files in the filesystem matching a certain name pattern

# Note: ViewConstruct on an MDX view does not work.

c = 1;
While( c <= Dimsiz( '}Cubes' ));
   vCube = Dimnm( '}Cubes', c );

   vDim_CubeViews = '}Views_' | vCube;
   If( DimensionExists( vDim_CubeViews ) > 0 );

      If( Dimsiz( vDim_CubeViews ) > 0 );

         # PA Local 2.0
         SubsetCreateByMDX( c0, '{TM1FilterByPattern( TM1SubsetAll( [' | vDim_CubeViews | '] ), "' | vPattern | '")}', vDim_CubeViews, 1 );
         # SubsetMDXSet( vDim_CubeViews, c0, '' );
         SubsetElementInsert( vDim_CubeViews, c0, Dfrst( vDim_CubeViews ), 1 );
         SubsetElementDelete( vDim_CubeViews, c0, 1 );

         x = 1;
         While( x <= SubsetGetSize( vDim_CubeViews, c0 ));

            vViewName = SubsetGetElementName( vDim_CubeViews, c0, x );
            ViewConstruct( vCube, vViewName );

            x = x + 1;
         End;

      EndIf;

   Else;

      # not PA Local 2.0

      # loop over the *.vue files using the name pattern
      # delete the view and make sure the *.vue file is deleted too

      sFile = '';
      While( 0 < 1 );

         sFile = WildcardFileSearch( vCube | '}vues\' | vPattern | '.vue', sFile );
         If( sFile @= '' ); Break; EndIf;

         vViewName = Subst( sFile, 1, Long( sFile ) - 4 );
         If( ViewExists( vCube, vViewName ) > 0 );
            ViewConstruct( vCube, vViewName );
         EndIf;

      End;

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
