KBAISID ; GPL - NLM Valueset Short ID generator  ; 4/6/13 4:51pm
 ;;0.1;C0Q;nopatch;noreleasedate;Build 7
 ;Copyright 2013 George Lilly.  Licensed Apache 2
 ;
 Q
 ;
SID(ZNAME,ZOID,WHERE) ; extrinsic returns the short ID which is a compressed name with 
 ; 2 digits from the end of the OID
 ; ZNAME and ZOID are passed by value
 ;
 I '$D(WHERE) D  ;
 . S WHERE=$NA(^TMP("KBAIVS","SID"))
 . S @WHERE@(0)=""
 S ZSID=$O(@WHERE@(ZOID,""))
 I ZSID'="" Q ZSID  ; already found
 N ZAP
 S ZAP="abcdefghijklmnopqrstuvwxyz ,/><-()" ; characters to zap
 N ZEXT S ZEXT=$TR(ZOID,".")
 S ZEXT=$E(ZEXT,$L(ZEXT)-1,$L(ZEXT))
 N ZSID
 S ZSID=$TR(ZNAME,ZAP)_ZEXT
 I $D(@WHERE@(ZOID,ZSID)) D  ;
 . W !,"FIXING DUP: ",ZSID
 . S ZSID=ZSID_$R(10)
 . W " WITH: ",ZSID
 S @WHERE@(ZOID,ZSID)=""
 Q ZSID
 ;
