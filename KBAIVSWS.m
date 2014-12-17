KBAIVSWS ; GPL - NLM VALUESET WEB SERVICES ; 11/10/14 6:03PM
 ;;0.1;C0Q;NOPATCH;NORELEASEDATE;Build 13
 ;COPYRIGHT 2014 GEORGE LILLY.  LICENSED APACHE 2
 ;
 Q
 ;
wsOID(OUT,PARM)
 I $G(PARM("oid"))="" Q  ;
 I $G(PARM("format"))="" S PARM("format")="xml"
 S OUT=$NA(^TMP("KBAIVS",$J))
 K @OUT
 I PARM("format")="html" D OIDHTML(.OUT,.PARM)  Q  ;
 I PARM("format")'="xml" Q  ;
 S HTTPRSP("mime")="text/xml"
 S @OUT@(1)="<?xml version=""1.0"" encoding=""utf-8"" ?>"
 S @OUT@(2)="<result>"
 N RETURN
 D GETVS(.RETURN,.PARM)
 D FORMXML(.OUT,.RETURN,"valueset")
 I $G(PARM("filter"))'="codes" D FORMXML(.OUT,.RETURN,"measure")
 I $G(PARM("filter"))'="measures" D FORMXML(.OUT,.RETURN,"code")
 D ADDTO(OUT,"</result>")
 D ADDCRLF^VPRJRUT(.OUT) 
 Q
 ;
wsCODE(OUT,PARM)
 N VSIEN,CODE,VSCNT
 S VSCNT=0
 S CODE=$G(PARM("code"))
 Q:CODE=""
 N RETURN,KBAIRTN
 S OUT=$NA(^TMP("KBAIVS",$J))
 K @OUT
 S VSIEN=""
 F  S VSIEN=$O(^C0QVS(176.801,"CODE",CODE,VSIEN)) Q:VSIEN=""  D  ;
 . S VSCNT=VSCNT+1
 . S KBAIRTN=$NA(RETURN("result"))
 . D ONECODE(KBAIRTN,VSIEN,CODE)
 . S KBAIRTN=$NA(RETURN("result","valuesets"))
 . N OID
 . S OID=$$GET1^DIQ(176.801,VSIEN_",",.02)
 . S PARM("oid")=OID
 . S PARM("filter")="measures"
 . D GETVS(KBAIRTN,.PARM)
 S HTTPRSP("mime")="text/xml"
 D ARY2XML(.OUT,KBAIRTN)
 D ADDCRLF^VPRJRUT(.OUT) 
 Q
 ;
FORMXML(RTN,IN,TAG) ; 
 N TXT,CNT
 S CNT=""
 Q:'$D(IN(TAG))
 F  S CNT=$O(IN(TAG,CNT)) Q:CNT=""  D  ;
 . S TXT="<"_TAG
 . N ATTR S ATTR=""
 . F  S ATTR=$O(IN(TAG,CNT,ATTR)) Q:ATTR=""  D  ;
 . . S TXT=TXT_" "_ATTR_"="""_IN(TAG,CNT,ATTR)_""""
 . S TXT=TXT_" />"
 . D ADDTO(RTN,TXT)
 Q
 ;
GETVS(VSRTN,PARM) ; retrieve a valueset based on PARM("oid")
 ; PARM("filter")="codes" will return only the codes
 ; PARM("filter")="measures" will return only the measures
 ; no filter returns both codes and measures for the valueset
 N OIDIEN,OID
 S OID=$G(PARM("oid"))
 Q:OID=""
 S OIDIEN=$O(^C0QVS(176.801,"ID",OID,""))
 Q:OIDIEN=""
 N CMS,NDF,CMSDISP,OIDDISP
 S OIDDISP=$$GET1^DIQ(176.801,OIDIEN_",",.01)
 Q:OIDDISP=""
 S @VSRTN@("valueset@oid")=OID
 S @VSRTN@("valueset@oidDisplayName")=OIDDISP
 S @VSRTN@("valueset@oidIen")=OIDIEN
 N MEACNT S MEACNT=0
 I $G(PARM("filter"))'="codes" D  ; filter code means no measure info
 . N MEAIEN S MEAIEN=""
 . ;N RTNMEA S RTNMEA=$NA(@VSRTN@("measures"))
 . F  S MEAIEN=$O(^C0QVS(176.801,OIDIEN,4,"B",MEAIEN)) Q:MEAIEN=""  D  ;
 . . S MEACNT=MEACNT+1
 . . N MEADISP,NQF,CMS,GUID,VERSION
 . . S MEADISP=$$GET1^DIQ(176.802,MEAIEN_",",.01)
 . . S NQF=$$GET1^DIQ(176.802,MEAIEN_",",.03)
 . . S CMS=$$GET1^DIQ(176.802,MEAIEN_",",2.2)
 . . S GUID=$$GET1^DIQ(176.802,MEAIEN_",",.02)
 . . S VERSION=$$GET1^DIQ(176.802,MEAIEN_",",.04)
 . . N RTNMEA
 . . S RTNMEA=$NA(@VSRTN@("valueset",MEACNT))
 . . S @RTNMEA@("measure@measureDisplayName")=MEADISP
 . . S @RTNMEA@("measure@nqf")=NQF
 . . S @RTNMEA@("measure@cmsId")=CMS
 . . S @RTNMEA@("measure@guid")=GUID
 . . S @RTNMEA@("measure@measureDisplayName")=MEADISP
 . . S @RTNMEA@("measure@version")=VERSION
 . . S @RTNMEA@("measure@measureIen")=MEAIEN
 ;
 ; return codes if filter is not set to measure
 ;
 N CDCNT S CDCNT=0
 I $G(PARM("filter"))'="measures" D  ; filter code means no measure info
 . N CDIEN,CODE S CODE=""
 . F  S CODE=$O(^C0QVS(176.801,OIDIEN,2,"B",CODE)) Q:CODE=""  D  ;
 . . S CDCNT=CDCNT+1
 . . N ONECD
 . . S ONECD=$NA(@VSRTN@("codes",CDCNT))
 . . D ONECODE(ONECD,OIDIEN,CODE) ; get values for one code
 Q
 ;
ONECODE(RCD,OIDIEN,CODE) ; retrieve one code
 S CDIEN=$O(^C0QVS(176.801,OIDIEN,2,"B",CODE,""))
 N CDDISP,CDSYS,SYSOID,SYSVER
 S CDDISP=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.02)
 S CDSYS=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.04)
 S SYSOID=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.05)
 S SYSVER=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.06)
 S @RCD@("code@displayName")=CDDISP
 S @RCD@("code@code")=CODE
 S @RCD@("code@system")=CDSYS
 S @RCD@("code@systemOid")=SYSOID
 S @RCD@("code@systemVersion")=SYSVER
 Q
 ;
OIDHTML(OUT,PARM)
 Q
 ;
ADDTO(DEST,WHAT)
 N ZN
 S ZN=$O(@DEST@(" "),-1)+1
 S @DEST@(ZN)=WHAT
 Q
 ;
wsMEA(OUT,PARM)
 S OUT(1)="RESULT"
 Q
 ;
GETCODE(RTN,CODE,PARMS) ; retrieves a code that is used in Quality Measures
 ; returns the valuesets containing the code and the measures using the 
 ;   valuesets
 N VSCNT S VSCNT=0
 N OIDIEN S OIDIEN=""
 F  S OIDIEN=$O(^C0QVS(176.801,"CODE",CODE,OIDIEN)) Q:OIDIEN=""  D  ;
 . S VSCNT=VSCNT+1
 . N RTN1
 . D ONECODE("RTN1",OIDIEN,CODE)
 . M @RTN@("result")=RTN1
 . N OID
 . S OID=$$GET1^DIQ(176.801,OIDIEN_",",.02)
 . S PARM("oid")=OID
 . S PARM("filter")="measures"
 . D GETVS($NA(@RTN@("result","code",VSCNT)),.PARM)
 Q
 ;
GETREST(RXML,URL) ; make rest call to URL and return RXML, passed by name
 N RTN,OK
 S OK=$$httpGET^C0IEWD(URL,.RTN)
 I +OK=0 M @RXML=RTN
 Q OK
 ;
WGETCODE(RARY,CODE) ; call web service to get code array
 N URL
 S URL="http://cqm.healthspace.zone:9080/smokingGun/?code="_CODE
 D FETCH(RARY,URL)
 Q
 ;
WGETVS(RARY,OID) ; use web service to retrieve all codes in a valueset
 N URL
 S URL="http://cqm.healthspace.zone:9080/valueset/"_OID
 D FETCH(RARY,URL)
 Q
 ;
FETCH(RARY,URL)
 N OK,RXML
 S RXML=$NA(^TMP("KBAIVSWS",$J,"XML"))
 K @RXML
 S OK=$$GETREST(RXML,URL)
 I OK=1 D  Q  ;
 . W !,"ERROR RETRIEVING ",CODE
 S OK=$$PARSE(RXML)
 I OK=0 D  Q  ;
 . W !,"ERROR PARSING XML"
 . ZWR RXML
 . ZWR ^TMP("MXMLERR",$J,*)
 D DOMO(RARY)
 Q
 ;
PARSE(INXML)
 Q $$EN^MXMLDOM(INXML,"W")
 ;
DOMO(ZARY,WHAT,WHERE,ZDOM,LVL) ; SIMPLIFIED DOMO
 ; ZARY IS THE RETURN ARRAY
 ; WHAT IS THE TAG TO BEGIN WITH STARTING AT WHERE, A NODE IN THE ZDOM
 ; MULTIPLE IS THE INDEX TO BE USED FOR A MULIPLE ENTRY 0 IS A SINGLETON
 ;
 I '$D(ZDOM) S ZDOM=$NA(^TMP("MXMLDOM",$J,$O(^TMP("MXMLDOM",$J,"AAAAA"),-1)))
 I '$D(WHERE) S WHERE=1
 I $G(WHAT)="" S WHAT=@ZDOM@(WHERE)
 I '$D(LVL) S LVL=0 N ZNUM S ZNUM=0 ; FIRST TIME
 ;
 N TXT S TXT=$$CLEAN($$ALLTXT($NA(@ZDOM@(WHERE))))
 I TXT'="" I TXT'=" " D  ;
 . S @ZARY@(@ZDOM@(WHERE))=TXT
 ;
 N ZI S ZI=""
 F  S ZI=$O(@ZDOM@(WHERE,"A",ZI)) Q:ZI=""  D  ;
 . S @ZARY@(WHAT_"@"_ZI)=@ZDOM@(WHERE,"A",ZI)
 F  S ZI=$O(@ZDOM@(WHERE,"C",ZI)) Q:ZI=""  D  ;
 . N MULT S MULT=$$ISMULT(WHERE,ZDOM)
 . ;I '$D(ZNUM) N ZNUM S ZNUM(WHERE)=0
 . I MULT>0 S ZNUM(WHERE)=$G(ZNUM(WHERE))+1
 . I $G(C0DEBUG) I MULT>0 D  ;
 . . W !,"WHERE ",WHERE," WHAT ",WHAT," ZI ",ZI," LVL ",LVL,!
 . . ZWR ZNUM
 . I MULT=0 D DOMO($NA(@ZARY@(WHAT)),@ZDOM@(WHERE,"C",ZI),ZI,ZDOM,LVL+1)
 . I MULT>0 D DOMO($NA(@ZARY@(WHAT,ZNUM(WHERE))),@ZDOM@(WHERE,"C",ZI),ZI,ZDOM,LVL+1)
 Q
 ;
ISMULT(ZIDX,ZDOM) ; EXTRINSIC WHICH RETURNS ONE IF THE NODE CONTAINS MULTIPLE
 ; CHILDREN WITH THE SAME TAG
 N ZTAGS,ZZI,ZJ,RTN S ZZI="" S RTN=0
 F  S ZZI=$O(@ZDOM@(ZIDX,"C",ZZI)) Q:RTN=1  Q:ZZI=""  D  ;
 . S ZJ=@ZDOM@(ZIDX,"C",ZZI)
 . I $D(ZTAGS(ZJ)) S RTN=1
 . S ZTAGS(ZJ)=""
 Q RTN
 ;
ALLTXT(WHERE) ; EXTRINSIC RETURNS ALL TEXT LINES FROM THE NODE .. CONCATINATED
 ; TOGETHER
 N ZTI S ZTI=""
 N ZTR S ZTR=""
 F  S ZTI=$O(@WHERE@("T",ZTI)) Q:ZTI=""  D  ;
 . S ZTR=ZTR_$G(@WHERE@("T",ZTI))
 Q ZTR
 ;
CLEAN(STR) ; extrinsic function; returns string
 ;; Removes all non printable characters from a string.
 ;; STR by Value
 N TR,I
 F I=0:1:31 S TR=$G(TR)_$C(I)
 S TR=TR_$C(127)
 N ZR S ZR=$TR(STR,TR)
 S ZR=$$LDBLNKS(ZR) ; get rid of leading blanks
 QUIT ZR
 ;
LDBLNKS(ST)     ; EXTRINSIC WHICH REMOVES LEADING BLANKS FROM A STRING
 N POS F POS=1:1:$L(ST)  Q:$E(ST,POS)'=" "
 Q $E(ST,POS,$L(ST))
 ;
ONEOUT(ZBUF,ZTXT) ; ADDS A LINE TO ZBUF
 N ZI S ZI=$O(@ZBUF@(""),-1)+1
 S @ZBUF@(ZI)=ZTXT
 Q
 ;
PUSH(BUF,STR) ;
 D ONEOUT(BUF,STR)
 Q
 ;
POP(BUF) ; extrinsic returns the last element and then deletes it
 N NM,TX
 S NM=$O(@BUF@(""),-1)
 Q:NM="" NM
 S TX=@BUF@(NM)
 K @BUF@(NM)
 Q TX
 ;
ARY2XML(OUTXML,INARY,STK,CHILD) ; convert an array to xml
 I '$D(@OUTXML@(1)) S @OUTXML@(1)="<?xml version=""1.0"" encoding=""utf-8"" ?>"
 N II S II=""
 N DATTR S DATTR="" ; deffered attributes
 F  S II=$O(@INARY@(II),-1) Q:II=""  D  ;
 . N ATTR,TAG
 . S ATTR="" S TAG=""
 . I II["@" D  ;
 . . I TAG="" S TAG=$P(II,"@",1) S ATTR=$P(II,"@",2)_"="""_@INARY@(II)_""""
 . . W:$G(DEBUG) !,"TAG="_TAG_" ATTR="_ATTR
 . . ;I $O(@INARY@(II))["@" D  ;
 . . ;F  S II=$O(@INARY@(II),-1) Q:II=""  Q:$O(@INARY@(II),-1)'[(TAG_"@")  D  ;
 . . F  S II=$O(@INARY@(II),-1) Q:II=""  Q:II'[(TAG_"@")  D  ;
 . . . S ATTR=ATTR_" "_$P(II,"@",2)_"="""_@INARY@(II)_""""
 . . . W:$G(DEBUG) !,"ATTR= ",ATTR
 . . . W:$G(DEBUG) !,"II= ",II
 . . S II=$O(@INARY@(II)) ; reset to previous
 . . N ENDING S ENDING="/"
 . . I II["@" D  ;
 . . . I $O(@INARY@(II),-1)=TAG S DATTR=" "_ATTR Q  ; deffered attributes
 . . . I $D(@INARY@(TAG)) S ENDING=""
 . . . D ONEOUT(OUTXML,"<"_TAG_" "_ATTR_ENDING_">")
 . . . I ENDING="" D PUSH("STK","</"_TAG_">")
 . I II'["@" D  ;
 . . I +II=0 D  ;
 . . . D ONEOUT(OUTXML,"<"_II_DATTR_">")
 . . . S DATTR="" ; reinitialize after use
 . . . D PUSH("STK","</"_II_">")
 . I $D(@INARY@(II)) D ARY2XML(OUTXML,$NA(@INARY@(II)))
 I $D(STK) F  D ONEOUT(OUTXML,$$POP("STK")) Q:'$D(STK)
 Q
 ;
TEST
 K G,GXML
 D WGETCODE("G",1037045)
 ZWR G
 D ARY2XML("GXML","G")
 ZWR GXML
 Q
 ;
TEST2
 K G,GXML
 D WGETVS("G","2.16.840.1.113883.3.464.1003.196.12.1221")
 ZWR G
 D ARY2XML("GXML","G")
 ZWR GXML
 Q
 ;
TEST3
 K G,GXML,PARM
 D GETCODE("G",100,.PARM)
 ZWR G
 D ARY2XML("GXML","G")
 ZWR GXML
 Q
 ;
TEST4
 K G,GXML,PARM,GARY
 D GETCODE("G",3980006,.PARM)
 ZWR G
 D ARY2XML("GXML","G")
 ZWR GXML
 K ^TMP("MXMLDOM",$J)
 S TMPXML=$NA(^TMP("KBAIXML",$J))
 K @TMPXML
 M @TMPXML=GXML
 S OK=$$PARSE(TMPXML)
 I OK=0 ZWR ^TMP("MXMLERR",$J,*) Q  ;
 D DOMO("GARY")
 ZWR GARY
 Q
 ;
