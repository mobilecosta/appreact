#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "ap5mail.ch"
#INCLUDE "fileio.ch"
#INCLUDE "TOPCONN.CH"

/*

    Metas por vendedor para exibição no Portal Robsol

*/

User function ROBMET01(cVend)

Local cQuery
Local aAuxMes := {}
Local dDtCns
Local aMetDia := {}
Local aMetMes := {}
Local aMetQad := {}
Local aDiasAx := {}
Local nPos
Local cMesQ1  := ''
Local cMesQ4  := ''
Local nX
Local nPedMes := 0
Local nComMes := 0
Local nQtdPAn := 0
Local aRet    := {}
Local cJson   := ''

Default cVend   := '000006'


    If Select("SM0") == 0
        RpcSetType(3)
        RPCSetEnv("01","0101")
    EndIf
    
    Aadd(aAuxMes,{'01',1})
    Aadd(aAuxMes,{'02',1})
    Aadd(aAuxMes,{'03',1})
    Aadd(aAuxMes,{'04',2})
    Aadd(aAuxMes,{'05',2})
    Aadd(aAuxMes,{'06',2})
    Aadd(aAuxMes,{'07',3})
    Aadd(aAuxMes,{'08',3})
    Aadd(aAuxMes,{'09',3})
    Aadd(aAuxMes,{'10',4})
    Aadd(aAuxMes,{'11',4})
    Aadd(aAuxMes,{'12',4})

    dDtCns := substr(dtos(ddatabase),5,2)+substr(dtos(ddatabase),1,4)
    dDiaAux := substr(dtos(ddatabase),1,6)+"01"

    nPos := Ascan(aAuxMes,{|x| x[1] == substr(dDtCns,1,2)})
    
    dDtFin := lastday(dDataBase)
    nDias := 0
    dDtIni := firstday(ddatabase)
    dDtAtu := dDtIni
    
    While dDtAtu <= dDtFin
        //Se a data atual for uma data VÃ¡lida
        If dDtAtu == DataValida(dDtAtu) 
            Aadd(aDiasAx,{strzero(day(dDtAtu),2),0,0,0})
            nDias++
        EndIf
         
        dDtAtu := DaySum(dDtAtu, 1)
    EndDo

    //dDiaAux := '20210101'
    //Meta Diaria
    //cQuery := "SELECT Z40_DTFATU AS DIA,Z40_MARCA AS MARCA,A1_EST AS REGIAO,SUM(Z40_VLRNF) AS VLRREAL"
    cQuery := "SELECT Z40_DTFATU AS DIA,SUM(Z40_VLRNF) AS VLRREAL"
    cQuery += " FROM "+RetSQLName("Z40")+" Z40"
    //cQuery += " INNER JOIN "+RetSQLName("SA1")+" A1 ON A1_FILIAL=Z40_FILIAL AND A1_COD=Z40_CLIENT AND A1_LOJA=Z40_LOJA AND A1.D_E_L_E_T_=' '"
    cQuery += " WHERE Z40_FILIAL='"+xFilial("Z40")+"'"
    cQuery += " AND Z40_DTFATU BETWEEN '"+dDiaAux+"' AND '"+dtos(ddatabase)+"'"
    cQuery += " AND Z40_VENDED='"+cVend+"'"
    cQuery += " AND Z40.D_E_L_E_T_=' '"
    //cQuery += " GROUP BY Z40_DTFATU,Z40_MARCA,A1_EST "
    cQuery += " GROUP BY Z40_DTFATU "

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
        //Aadd(aMetDia,{TRB->DIA,TRB->MARCA,TRB->REGIAO,TRB->VLRREAL})
        Aadd(aMetDia,{cvaltochar(day(stod(TRB->DIA))),TRB->VLRREAL,0,0})
        nComMes += TRB->VLRREAL
        Dbskip()
    EndDo

    For nX := 1 to len(aDiasAx)
        If Ascan(aMetDia,{|x| x[1] == aDiasAx[nX,01]}) == 0
            Aadd(aMetDia,aDiasAx[nX])
        EndIf
    Next nX

    ASort(aMetDia,,,{|x,y| x[1] < y[1]})

    //Meta Mensal
    cQuery := "SELECT * FROM "+RetSQLName("Z31")
    cQuery += " WHERE (Z31_MSAN01 LIKE '%"+dDtCns+"%' OR "
    cQuery += " Z31_MSAN02 LIKE '%"+dDtCns+"%' OR "
    cQuery += " Z31_MSAN03 LIKE '%"+dDtCns+"%' OR "
    cQuery += " Z31_MSAN04 LIKE '%"+dDtCns+"%')
    cQuery += " AND Z31_CODVEN='"+cVend+"' AND D_E_L_E_T_=' ' "

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
        /*Aadd(aMetMes,{  TRB->Z31_VLMS01,TRB->Z31_VLMS02,TRB->Z31_VLMS03,TRB->Z31_VLMS04,;
                        TRB->Z31_REGIAO,TRB->Z31_MALA})*/
        If len(aMetMes) < 1 
            cMesQ1 := dtos(ctod('01/'+SUBSTR(TRB->Z31_MSAN01,1,2)+"/"+SUBSTR(TRB->Z31_MSAN01,3)))
            cMesQ4 := dtos(lastday(CTOD('01/'+SUBSTR(TRB->Z31_MSAN04,1,2)+"/"+SUBSTR(TRB->Z31_MSAN04,3))))
            //cMesQ3 := dtos(lastday(CTOD('01/'+SUBSTR(TRB->Z31_MSAN03,1,2)+"/"+SUBSTR(TRB->Z31_MSAN03,3))))
            Aadd(aMetMes,{  TRB->Z31_VLMS01,TRB->Z31_VLMS02,TRB->Z31_VLMS03,TRB->Z31_VLMS04,0,0,0,0})
            //Aadd(aMetMes,{  TRB->Z31_VLMS01,TRB->Z31_VLMS02,TRB->Z31_VLMS03,0,0,0})
        Else
            aMetMes[1,1] += TRB->Z31_VLMS01
            aMetMes[1,2] += TRB->Z31_VLMS02
            aMetMes[1,3] += TRB->Z31_VLMS03
            aMetMes[1,4] += TRB->Z31_VLMS04
        EndIf
        Dbskip()
    EndDo


    cQuery := "SELECT CAST(MONTH(Z40_DTFATU) AS VARCHAR) AS MES,SUM(Z40_VLRNF) AS VLRREAL"
    cQuery += " FROM "+RetSQLName("Z40")+" Z40"
    cQuery += " WHERE Z40_FILIAL='"+xFilial("Z40")+"'"
    cQuery += " AND Z40_DTFATU BETWEEN '"+cMesQ1+"' AND '"+cMesQ4+"'"
    cQuery += " AND Z40_VENDED='"+cVend+"'"
    cQuery += " AND Z40.D_E_L_E_T_=' '"
    cQuery += " GROUP BY MONTH(Z40_DTFATU) "

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
        Aadd(aMetQad,{strzero(val(TRB->MES),2),TRB->VLRREAL,0,0})
        Dbskip()
    EndDo
    
    nTrimAux := aAuxMes[npos,2]

    For nX := 1 to len(aAuxMes)
        If aAuxMes[nX,02] == nTrimAux .And. Ascan(aMetQad,{|x| x[1] == aAuxMes[nX,01]}) == 0
            Aadd(aMetQad,{aAuxMes[nX,01],0,0,0})
        EndIf
    Next nX

    cQuery := "SELECT 'QTDMES' AS TIPO,COUNT(*) AS QTD"
    cQuery += " FROM "+RetSQLName("SC5")
    cQuery += " WHERE C5_FILIAL BETWEEN ' ' AND 'ZZ'
    cQuery += " AND C5_EMISSAO BETWEEN '"+dtos(dDtIni)+"' AND '"+dtos(dDtFin)+"'"
    cQuery += " AND C5_VEND1='"+cVend+"'"
    cQuery += " AND D_E_L_E_T_=' '"
    cQuery += " UNION " 
    cQuery += " SELECT 'QTDANALISE' AS TIPO,COUNT(*) AS QTD"
    cQuery += " FROM "+RetSQLName("SC5")
    cQuery += " WHERE C5_FILIAL BETWEEN ' ' AND 'ZZ'
    cQuery += " AND C5_EMISSAO BETWEEN '"+dtos(dDtIni-365)+"' AND '"+dtos(dDtFin)+"'"
    cQuery += " AND C5_VEND1='"+cVend+"' AND C5_BLQ='3'"
    cQuery += " AND D_E_L_E_T_=' '"

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
        
        If Alltrim(TRB->TIPO) == 'QTDMES'
            nPedMes := TRB->QTD
        Else
            nQtdPAn := TRB->QTD
        EndIf

        Dbskip()
    EndDo

    Aeval(aMetMes,{|x| x[5] := round(x[1] / nDias,2)})
    Aeval(aMetMes,{|x| x[6] := round(x[2] / nDias,2)})
    //Aeval(aMetMes,{|x| x[7] := round(x[3] / nDias,2)})
    //Aeval(aMetMes,{|x| x[8] := round(x[4] / nDias,2)})

    If nPos > 0 .And. len(aMetMes) >=  nPos
        Aeval(aMetDia,{|x| x[3] := aMetMes[nPos,nPos+4]})
        Aeval(aMetDia,{|x| x[4] := round((aMetMes[nPos,nPos+4] / x[2])*100,2)})
    ENDIF

    If len(aMetMes) > 0
        For nX := 1 to len(aMetQad)
            aMetQad[nX,03] := aMetMes[1,nX]
            aMetQad[nX,04] := round(If(aMetQad[nX,03] > aMetQad[nX,02],(aMetQad[nX,03] / aMetQad[nX,02]) * 100,(aMetQad[nX,02] / aMetQad[nX,03]) * 100),2)
        Next nX
    EndIf

    //Aeval(aMetDia,{|x| x[1] := cvaltochar(stod(x[1])),})
    Aeval(aMetDia,{|x| x[2] := Transform(x[2],"@E 999,999,999.99")})
    Aeval(aMetDia,{|x| x[3] := Transform(x[3],"@E 999,999,999.99")})
    Aeval(aMetDia,{|x| x[4] := Transform(x[4],"@E 999.99%")})

    Aeval(aMetQad,{|x| x[2] := Transform(x[2],"@E 999,999,999.99")})
    Aeval(aMetQad,{|x| x[3] := Transform(x[3],"@E 999,999,999.99")})
    Aeval(aMetQad,{|x| x[4] := Transform(x[4],"@E 999,999.99%")})


    //json
    Aadd(aRet,{'{',''})
    Aadd(aRet,{'"items": [',''})
    Aadd(aRet,{'{',''})
    Aadd(aRet,{'"pedidos_analise":','"'+cvaltochar(nQtdPan)+'",'})
    Aadd(aRet,{'"pedidos_mes":','"'+cvaltochar(nPedMes)+'",'})
    Aadd(aRet,{'"comissao_mes":','"'+cvaltochar(nComMes)+'"'})
    Aadd(aRet,{'}',','})
    Aadd(aRet,{"[",""})

    cVirg := ""
    
    For nX := 1 to len(aMetDia)
        Aadd(aRet,{cVirg+'{',''})
        Aadd(aRet,{'"dia":','"'+aMetDia[nX,01]+'",'})
        Aadd(aRet,{'"venda":','"'+aMetDia[nX,02]+'",'})
        Aadd(aRet,{'"meta":','"'+aMetDia[nX,03]+'",'})
        Aadd(aRet,{'"percentual":','"'+aMetDia[nX,04]+'"'})
        Aadd(aRet,{'}',""})
        cVirg := ','
    Next nX

    Aadd(aRet,{']',','})

    cVirg := ""
    Aadd(aRet,{"[",""})
    
    For nX := 1 to len(aMetQad)
        Aadd(aRet,{cVirg+'{',''})
        Aadd(aRet,{'"mes":','"'+aMetQad[nX,01]+'",'})
        Aadd(aRet,{'"venda":','"'+aMetQad[nX,02]+'",'})
        Aadd(aRet,{'"meta":','"'+aMetQad[nX,03]+'",'})
        Aadd(aRet,{'"percentual":','"'+aMetQad[nX,04]+'"'})
        Aadd(aRet,{'}',""})
        cVirg := ','
    Next nX

    Aadd(aRet,{']',''})
    
    Aadd(aRet,{']',''})
    Aadd(aRet,{'}',''})

    cJson := ""
    For nX := 1 to len(aRet)
        cJson += aRet[nX,01]+aRet[nX,02]+CRLF
    Next nX

Return(cJson)
