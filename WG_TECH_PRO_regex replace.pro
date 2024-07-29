601,100
602,"WG_TECH_PRO_regex replace"
562,"NULL"
586,
585,
564,
565,"m[np2E[EvmnxYampLYe=rtCJ:e\2UcoOVd8gN=BylwOy04IRC@tKL;bX2:2yDSZ=yIvxlJ_=oB\tc>@UqCXbfQP]f5=d:wVcaY0:u9v4MNwR3N=ndwS:>5c9OrlE02b31rRJFy\AwA<JtEeG4DQbVv>rg<6bBYrezc1vV<iqfEBZLyD@hNl1R=mwQRxaEJwGREup\RR4"
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
589,"."
568,""""
570,
571,
569,0
592,0
599,1000
560,5
pString
pExpression
pReplacement
pRun
pEntryPos
561,5
2
2
2
1
1
590,5
pString,""
pExpression,""
pReplacement,""
pRun,0
pEntryPos,0
637,5
pString,"String?"
pExpression,"Expression?"
pReplacement,"Replacement?"
pRun,"Run? (1-256)"
pEntryPos,"Entry Position?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,195

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# March 2023
# https://www.wimgielis.com
####################################################

####################################################
#
# Written by: Dennis Bontekoning (Aexis)
# February 2016
# Source: http://www.tm1forum.com/viewtopic.php?f=21&t=12296
#
####################################################
#EndRegion IntroduceThisProcess


DataSourceASCIIQuoteCharacter = '';
StringGlobalVariable('Regex_replace_result');

## Determine character length of string and expression.
## Determine maximum number of options
####
vStrLen = Long(pString);
vExprLen = Long(pExpression);
vMaxOptions = vStrLen * vExprLen;

pRunStr = NumberToString(pRun);

## Set starting values
####
vMatchString = '';
vUsedOptions = 0;
vStrPosEntry = 0;
vStrPosMatch = 0;
vStartPos = 0;


## Loop over expression string per character and see if string is valid
##
## The following arguments are supported
##  1: Single character
##  2: ? (question mark), represents a single character
##  3: * (asterix), represents any number of characters
##
####
vExprPos = 1;
While(vExprPos <= vExprLen & vUsedOptions <= vMaxOptions);

  ## Loop over string characters
  ####
  vFound = 0;
  vStrPos = 1 + vStrPosMatch + vStrPosEntry + pEntryPos;
  While(vStrPos <= vStrLen);

    ## Check if next expression character matches
    ####
    vFound_next = 0;
    If(vExprPos < vExprLen & Subst(pExpression, vExprPos, 1) @= '*');
      If((Subst(pExpression, vExprPos + 1, 1) @= '?' & Subst(pString, vStrPos, 1) @<> '') %
        Subst(pExpression, vExprPos + 1, 1) @= Subst(pString, vStrPos, 1));
        vFound_next = 1;
      EndIf;
    EndIf;

    ## Check for any character (asterix)
    ## In case next expression character has a match, do not add the matched character to
    ## to the matchstring
    ####
    If(Subst(pExpression, vExprPos, 1) @= '*' & (Subst(pString, vStrPos, 1) @<> '' % Subst(pString, vStrPos, 1) @= ' '));
      If(vFound_next = 0);
        vMatchString = vMatchString | Subst(pString, vStrPos, 1);
        vFound = 1;
      Else;
        vFound = 1;
      EndIf;
    EndIf;

    ## Check for any single character (question mark)
    ####
    If(Subst(pExpression, vExprPos, 1) @= '?' & Subst(pString, vStrPos, 1) @<> '');
      vMatchString = vMatchString | Subst(pString, vStrPos, 1);
      vFound = 1;
    EndIf;

    ## Check for 1 on 1 character
    ####
    If(Subst(pExpression, vExprPos, 1) @= Subst(pString, vStrPos, 1));
      vMatchString = vMatchString | Subst(pString, vStrPos, 1);
      vFound = 1;
    EndIf;

    ## Determine found string start position
    ####
    If(vFound = 1 & Long(vMatchString) = 1);
      vStartPos = vStrPos;
    EndIf;

    ## DEBUG
    ####
    #TextOutput('c:\tmp\regex_' | pRunStr | '.txt', pExpression, NumberToString(vExprLen), NumberToString(vExprPos), Subst(pExpression, vExprPos, 1),
      #pString, NumberToString(vStrLen), NumberToString(vStrPosEntry), NumberToString(vStrPos),
     #Subst(pString, vStrPos, 1), NumberToString(vStrPosMatch), NumberToString(vFound), NumberToString(vStartPos), vMatchSTring);

    ## If a match has been found in the input string, skip to next character of expression
    ## otherwise skip to next input string character
    ####
    If(vFound = 1 & Subst(pExpression, vExprPos, 1) @<> '*');
      vStrPosMatch = vStrPos - vStrPosEntry - pEntryPos;
      vStrPos = vStrLen + 1;
      vExprPosReset = 0;
    ElseIf(vFound = 1 & Subst(pExpression, vExprPos, 1) @= '*');
      ## If the next character in the expression also has a match on the current string character
      ## break out of the loop and continue with the next expression character
      ####
      If(vFound_next = 1);
        vStrPosMatch = vStrPos - vStrPosEntry - 1 - pEntryPos;
        vStrPos = vStrLen + 1;
        vExprPosReset = 0;
      Else;
        vStrPosMatch = vStrPos - vStrPosEntry - pEntryPos;
        vStrPos = vStrPos + 1;
        vExprPosReset = 0;
      EndIf;
    Else;
      vMatchString = '';
      vStrPosMatch = 0;
      vExprPosReset = 1;
      vStrPosEntry = vStrPosEntry + 1;
      vStrPos = vStrLen + 1;
    EndIf;
  End;

  ## If the expression position is reset, set expression position back to 1 and increment the
  ## counter for used options. Otherwise increase the expression position by 1.
  ####
  If(vExprPosReset = 1);
    vUsedOptions = vUsedOptions + 1;
    vExprPos = 1;
  Else;
    vExprPos = vExprPos + 1;
  EndIf;

End;


## Replace string
####
vReplLen = Long(vMatchString);
vReplPos = Scan(vMatchString, 'a' | pString) -1;

## If the substring $& exists in the replacement string, the $& must be replaced by the matched string
## otherwise the replacement string will be the new string
####
vReplNeedlePos = Scan('$&', 'a' | pReplacement)-1;
If(vReplNeedlePos > 0);
  vNewString_tmp = Insrt(vMatchString, Delet(pReplacement, vReplNeedlePos, 2), vReplNeedlePos);
Else;
  vNewString_tmp = pReplacement;
EndIf;

## Thew new string will be generated by concatenating the first part of the string, the newly created string above and the remainder of the string
####
vNewString = Subst(pString, 1, vStartPos - 1) | vNewString_tmp | Subst(pString, Long(vMatchString) + vStartPos, Long(pString) - Long(vMatchString) - vStartPos + 1);


## Check if anything has been found by checking the length of the matched string to the length of the expression
####
If(vReplLen >= vExprLen);

  ## DEBUG
  ####
  #TextOutput('C:\tmp\regex_' | pRunStr | '.txt', '------------------------------------------------------------------------------------------------');
  #TextOutput('C:\tmp\regex_' | pRunStr | '.txt', 'Replacement from here:');
  #TextOutput('C:\tmp\regex_' | pRunStr | '.txt', '------------------------------------------------------------------------------------------------');
  #TextOutput('C:\tmp\regex_' | pRunStr | '.txt', pReplacement);
  #TextOutput('C:\tmp\regex_' | pRunStr | '.txt', vNewString_tmp);
  #TextOutput('C:\tmp\regex_' | pRunStr | '.txt', vNewString);

  Regex_replace_result = vNewString;

  ## If there are any runs left (256 should be sufficient), execute process again with new string and updated start position
  ####
  vNewStartPos = Long(vNewString_tmp) + vStartPos - 1;
  vNewRun = pRun + 1;
  If(vNewRun < 257);
    ExecuteProcess( GetProcessName, 'pString', vNewString, 'pExpression', pExpression, 'pReplacement', pReplacement, 'pRun', vNewRun, 'pEntryPos', vNewStartPos);
  EndIf;

EndIf;
573,4

#****Begin: Generated Statements***
#****End: Generated Statements****

574,4

#****Begin: Generated Statements***
#****End: Generated Statements****

575,4

#****Begin: Generated Statements***
#****End: Generated Statements****

576,CubeAction=1511DataAction=1503CubeLogChanges=0_DeployParams={&quotdimensionConflictResolutions&quot:{}&#044&quotclass&quot:&quotDeployParams&quot&#044&quotdataAction&quot:&quotACCUMULATE&quot}_ParseParams={&quotskipRows&quot:&quot0&quot&#044&quotlocale&quot:{&quotlanguange&quot:&quoten&quot&#044&quotvariant&quot:&quot&quot&#044&quotcountry&quot:&quotUS&quot}&#044&quotdimensions&quot:[]&#044&quotmeasures&quot:[]&#044&quotnumColumns&quot:&quot0&quot&#044&quothasHeader&quot:&quotfalse&quot}_importSourceDefinition={"scriptOnlySource":{},"sourceType":"NONE","originalColumns":null,"locale":{"localeIsDefault":false,"localeCurrencySymbol":"$","languageCode":"en","languageDisplay":"English","thousandsSeparator":",","localeCode":"en_US","localeCurrencyCode":"$","localeDisplay":"English (United States)","countryDisplay":"United States","countryCode":"US","decimalSeparator":"."},"excludedColumns":[],"columns":[],"sourceTypeHasBeenChanged":false}_ParameterConstraints=e30=
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
920,0
921,""
922,""
923,0
924,""
925,""
926,""
927,""
