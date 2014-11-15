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
GETVS(RETURN,PARM) ; retrieve a valueset based on PARM("oid")
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
 S RETURN("valueset",1,"oid")=OID
 S RETURN("valueset",1,"oidDisplayName")=OIDDISP
 S RETURN("valueset",1,"oidIen")=OIDIEN
 N MEACNT S MEACNT=0
 I $G(PARM("filter"))'="codes" D  ; filter code means no measure info
 . N MEAIEN S MEAIEN=""
 . F  S MEAIEN=$O(^C0QVS(176.801,OIDIEN,4,"B",MEAIEN)) Q:MEAIEN=""  D  ;
 . . S MEACNT=MEACNT+1
 . . N MEADISP,NQF,CMS,GUID,VERSION
 . . S MEADISP=$$GET1^DIQ(176.802,MEAIEN_",",.01)
 . . S NQF=$$GET1^DIQ(176.802,MEAIEN_",",.03)
 . . S CMS=$$GET1^DIQ(176.802,MEAIEN_",",2.2)
 . . S GUID=$$GET1^DIQ(176.802,MEAIEN_",",.02)
 . . S VERSION=$$GET1^DIQ(176.802,MEAIEN_",",.04)
 . . S RETURN("measure",MEACNT,"measureDisplayName")=MEADISP
 . . S RETURN("measure",MEACNT,"nqf")=NQF
 . . S RETURN("measure",MEACNT,"cmsId")=CMS
 . . S RETURN("measure",MEACNT,"guid")=GUID
 . . S RETURN("measure",MEACNT,"measureDisplayName")=MEADISP
 . . S RETURN("measure",MEACNT,"version")=VERSION
 . . S RETURN("measure",MEACNT,"measureIen")=MEAIEN
 ;
 ; return codes if filter is not set to measure
 ;
 N CDCNT S CDCNT=0
 I $G(PARM("filter"))'="measures" D  ; filter code means no measure info
 . N CDIEN,CODE S CODE=""
 . F  S CODE=$O(^C0QVS(176.801,OIDIEN,2,"B",CODE)) Q:CODE=""  D  ;
 . . S CDCNT=CDCNT+1
 . . N ONECD
 . . D ONECODE(.ONECD,OIDIEN,CODE) ; get values for one code
 . . M RETURN("code",CDCNT)=ONECD
 Q
 ;
ONECODE(RCD,OIDIEN,CODE) ; retrieve one code
 S CDIEN=$O(^C0QVS(176.801,OIDIEN,2,"B",CODE,""))
 N CDDISP,CDSYS,SYSOID,SYSVER
 S CDDISP=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.02)
 S CDSYS=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.04)
 S SYSOID=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.05)
 S SYSVER=$$GET1^DIQ(176.8011,CDIEN_","_OIDIEN_",",.06)
 S RCD("displayName")=CDDISP
 S RCD("code")=CODE
 S RCD("system")=CDSYS
 S RCD("systemOid")=SYSOID
 S RCD("systemVersion")=SYSVER
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
wsCODE(OUT,PARM)
 N OIDIEN,CODE
 S CODE=$G(PARM("code"))
 Q:CODE=""
 S OIDIEN=$O(^C0QVS(176.801,"CODE",CODE,""))
 Q:'OIDIEN
 N RETURN,RTN
 S OUT=$NA(^TMP("KBAIVS",$J))
 K @OUT
 D ONECODE(.RTN,OIDIEN,CODE)
 M RETURN("code",1)=RTN
 S HTTPRSP("mime")="text/xml"
 D ADDTO(OUT,"<result>")
 D FORMXML(OUT,.RETURN,"code")
 N OID
 S OID=$$GET1^DIQ(176.801,OIDIEN_",",.02)
 S PARM("oid")=OID
 S PARM("filter")="measures"
 D GETVS(.RETURN,.PARM)
 D ADDTO(OUT,"<valuesets>")
 D FORMXML(OUT,.RETURN,"valueset")
 D ADDTO(OUT,"<measures>")
 D FORMXML(OUT,.RETURN,"measure")
 D ADDTO(OUT,"</measures>")
 D ADDTO(OUT,"</valuesets>")
 D ADDTO(OUT,"</result>")
 D ADDCRLF^VPRJRUT(.OUT) 
 Q
 ;
GETCODE(RTN,CODE,PARMS) ; retrieves a code that is used in Quality Measures
 ; returns the valuesets containing the code and the measures using the 
 ;   valuesets
 N OIDIEN S OIDIEN=""
 F  S OIDIEN=$O(^C0QVS(176.801,"CODE",CODE,OIDIEN)) Q:OIDIEN=""  D  ;
 . N RTN1
 . D ONECODE(.RTN1,OIDIEN,CODE)
 . M RTN("code",1)=RTN1
 . N OID
 . S OID=$$GET1^DIQ(176.801,OIDIEN_",",.02)
 . S PARM("oid")=OID
 . S PARM("filter")="measures"
 . D GETVS(.RTN,.PARM)
 Q
 ;