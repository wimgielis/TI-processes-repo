601,100
602,"WG_CUBE_manipulations"
562,"NULL"
586,
585,
564,
565,"noR<>AI0oNLSqBaDxm@wh0\b;<W?pnd<Fc;OKr37Ds[FJ_8Kp8Dp@u]L2zS6d>nnBpW]eH>Zq=\Da>C7D^7uC4ChV<w=QN1g]spaeiUS7rsFkq8A2>CDY^HW=D]eKBkDGBkEgkCboCCf\JehuVt0j0KYd=cWsgo;nA@rOof:rY[=AN?7AOYSReG2Rd<98zzREKIZ0:z8"
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
572,284

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# March 2024
# https://www.wimgielis.com
####################################################
#EndRegion IntroduceThisProcess


##########################################################
# 1. UNIQUE ALIAS VALUES BY ADDING AN INDEX
##########################################################

vLevel10SOName_NoSO = '';
vLevel10SO = '';

vDim = 'Customer';

vDone = 0;
vOffset = 0;
While( vDone = 0 );

   vBasis = vLevel10SOName_NoSO;
   vElement = vLevel10SO;

   If( vOffset = 0 );
      vAttr = vBasis;
   Else;
      vAttr = vBasis | ' (' | NumberToString( vOffset ) | ')';
   EndIf;

   If( Dimix( vDim, vAttr ) = 0 );
      AttrPutS( vAttr, vDim, vElement, 'Attribute name' );
      vDone = 1;
   Else;
      vOffset = vOffset + 1;
   EndIf;

End;


##########################################################
# 2. CHECKING VALIDITY OF ACCOUNT NUMBERS
##########################################################

# Remarks:
#   the account should be at least 9 characters
#   only numbers can be used in the account

vSrcAccount = '12345678';

vAccount = Trim( vSrcAccount );
vAccountCheck = 'OK';

If( Long( vAccount) >= 9 );

   aLoop = 1;
   While( aLoop <= Long( vAccount ) & vAccountCheck @= 'OK' );

      If( Code( vAccount, aLoop ) < 48 % Code( vAccount, aLoop ) > 57 );
         vAccountCheck = 'NOT OK';
      EndIf;

      # Or:
      If( Scan( Subst( vAccount, aLoop, 1 ), '0123456789' ) = 0 );
         vAccountCheck = 'NOT OK';
      EndIf;

      aLoop = aLoop + 1;
   End;

Else;
   vAccountCheck = 'NOT OK';
EndIf;

If( vAccountCheck @= 'OK' );
   #... (other code)
   # to test numeric input: vNumber = StringToNumber(vString);
Else;
   ItemSkip;
EndIf;


##########################################################
# 3. REWORKING FIGURES WITH BRACKETS FOR THE NEGATIVE VALUES - OPTION 1
##########################################################

# Remarks:
#   ( ) is reworked to obtain the negative value
#   the TM1 functions StringToNumber and NumberToString use decimal separator for the current user locale!

vAmount = '(123,45)';

vString = Trim( vAmount );
If( Scan( '(', vString ) = 1 & Scan( ')', vString ) = Long( vString ));
   vString = '-' | Trim( Subst( vString, 2, Long( vString ) - 2 ));
EndIf;
If( Scan( '(', vString ) > 0 % Scan( ')', vString ) > 0 );
   ItemReject( 'Unknown data format for ' | vAmount );
EndIf;

vAmount_N = StringToNumber( vString );
If( vAmount_N <> 0 );
# ...
EndIf;


##########################################################
# 4. REWORKING FIGURES WITH TRAILING MINUS FOR THE NEGATIVE VALUES - OPTION 2
##########################################################

# Remarks:
#   123456,78- is reworked to obtain the negative value by shifting the minus sign to the front
#   123456,78- becomes -123456,78

vAmount = '123,45-';

vAmount = Trim( vAmount );
If( Scan( '-', vAmount ) = Long( vAmount ));
   vAmount = '-' | Trim( Delet( vAmount, Long( vAmount ), 1 ));
EndIf;

vAmount_N = StringToNumber( vAmount );
If( vAmount_N <> 0 );
# ...
EndIf;


##########################################################
# 5. REMOVE CHARACTERS FROM A STRING
##########################################################

# Remarks:
#   remove certain characters from a string

CreditLimit = 'test$.test';

cRemoveCharacters = '€$£ .';

c = Long( CreditLimit );
While( c >= 1 );
   sChar = Subst( CreditLimit, c, 1 );
   vScan = Scan( sChar, cRemoveCharacters );
   If( vScan > 0 );
      CreditLimit = Delet( CreditLimit, c, 1 );
   EndIf;
   c = c - 1;
End;

# for numeric values:
If( CreditLimit @= '' );
CreditLimit_N = 0;
Else;
CreditLimit_N = StringToNumber( Trim( CreditLimit ));
EndIf;

# - NumberToStringEx can also be useful


##########################################################
# 6. REPLACING CHARACTERS IN A STRING - OPTION 1
##########################################################

# Remarks:
#   this is an easy replace, 1 character is replaced with 1 other character
#   it is not case-sensitive
#   characters are treated as single characters

vActivity = 'test&<>other characters';

cReplaceCharacters = ',';
cReplacedCharacters = '.';

If( cReplaceCharacters @<> cReplacedCharacters );
If( Long( cReplaceCharacters ) = Long( cReplacedCharacters ));
   v = vActivity;
   r = 1;
   While( r <= Long( cReplaceCharacters ));
      rChar = Subst( cReplaceCharacters, r, 1 );

      c = Long( v );
      While( c >= 1 );
         sChar = Subst( v, c, 1 );
         If( sChar @= rChar );
            v = Insrt( Subst( cReplacedCharacters, r, 1 ), Delet( v, c, 1 ), c );
         EndIf;
         c = c - 1;
      End;

      r = r + 1;
   End;
   vActivity = v;
EndIf;
EndIf;


##########################################################
# 7. REPLACING CHARACTERS IN A STRING - OPTION 2
##########################################################

# Remarks:
#   similar to OPTION 1 BUT
#   it is case-sensitive here

vActivity = 'test&<>other characters';

cReplaceCharacters = ',';
cReplacedCharacters = '.';

If( Long( cReplaceCharacters ) = Long( cReplacedCharacters ));
   v = vActivity;
   r = 1;
   While( r <= Long( cReplaceCharacters ));
      rChar = Subst( cReplaceCharacters, r, 1 );

      If( Scan( rChar, v ) > 0 );
         c = Long( v );
         While( c >= 1 );
            If( CodeW( v, c ) = CodeW( cReplaceCharacters, r ));
               v = Insrt( Subst( cReplacedCharacters, c, 1 ), Delet( v, c, 1 ), c );
            EndIf;
            c = c - 1;
         End;
      EndIf;

      r = r + 1;
   End;
   vActivity = v;
EndIf;


##########################################################
# 8. REPLACING CHARACTERS IN A STRING - OPTION 3
##########################################################

# Remarks:
#   remove certain characters from a string and replace them with other characters
#   example: for XML files, we typically escape:
#   & ==> &amp;
#   < ==> &lt;
#   > ==> &gt;

# Create a dimension called 'XML_Escape_Characters' to contain the characters to be replaced.
# In an attribute called 'Replacement' store the replacement string.

vActivity = 'test&<>other characters';

v = vActivity;
c = Long( v );
While( c >= 1 );
   sChar = Subst( v, c, 1 );
   If( Dimix( 'XML_Escape_Characters', sChar ) > 0 );
      v = Insrt( Attrs( 'XML_Escape_Characters', sChar, 'Replacement' ), Delet( v, c, 1 ), c );
   EndIf;
   c = c - 1;
End;
vActivity = v;


##########################################################
# 9. REMOVE ALL UNWANTED CHARACTERS FROM A STRING
##########################################################

# Remarks:
#   

CreditLimit = 'test$.test';

cKeepCharacters = '€$£ .';

c = Long( CreditLimit );
While( c >= 1 );
   sChar = Subst( CreditLimit, c, 1 );
   vScan = Scan( sChar, cKeepCharacters );
   If( vScan = 0 );
      CreditLimit = Delet( CreditLimit, c, 1 );
   EndIf;
   c = c - 1;
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
