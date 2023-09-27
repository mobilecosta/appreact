#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL040
Descricao: Serviço API Rest Evento Comissoes

@author Alexandre Venâncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL040()
Return

// Serviço.
WsRestFul Commission DESCRIPTION "API REST - EVENTO Comissoes | PORTAL ROBSOL " 
	
	WSDATA VENDEDOR As String
    WSDATA ID As String
    WSDATA PAGINA As String
	WSDATA RAZAO_SOCIAL As String
	WSDATA VALOR_PEDIDO As String
	WSDATA PORCENTAGEM As String
	WSDATA VALOR_COMISSAO As String
	WSDATA DATA_PEDIDO As String
	WSDATA MARCA As String
	WSDATA DATA_STATUS As String
	WSDATA QUANTIDADE As String
	WSDATA NOME_FANTASIA As String
	WSDATA DESCONTO As String
	WSDATA COND_PAGTO As String
	WSDATA NUMERO_NF As String
	WSDATA STATUS As String

	WsMethod GET Description "Retorna o Cliente especifico ou cadastro todo" WSSYNTAX "/commission || /commission/{VENDEDOR} " 

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantação 
Descricao: 	Serviço Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod GET WsReceive PAGINA,ID,VENDEDOR WsService commission

	Local cPage			:= Self:PAGINA
    Local cVendedor 	:= Self:VENDEDOR
    Local cID   		:= Self:ID
    Local cRazao		:= Self:RAZAO_SOCIAL
    Local cValorPed		:= Self:VALOR_PEDIDO
    Local cPercentual	:= Self:PORCENTAGEM
    Local cValorCom		:= Self:VALOR_COMISSAO
    Local cDatPed		:= Self:DATA_PEDIDO
    Local cMarca		:= Self:MARCA
    Local cDtStat		:= Self:DATA_STATUS
    Local cQuant		:= Self:QUANTIDADE
    Local cNFantas		:= Self:NOME_FANTASIA
    Local cDescont		:= Self:DESCONTO
    Local cCondPgt		:= Self:COND_PAGTO
    Local cNota			:= Self:NUMERO_NF
    Local cStatus		:= Self:STATUS
	Local aArea			:= GetArea()
	Local nCont			:= 0
	Local cVirg			:= ""
	Local aAux			:= {}
	Local lComLib 		:=	.F.
	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	lComLib := SuperGetMV("TI_COMLIB",,.F.)

	conout("chegou aqui PRTL040")
    conout("Vendedor "+cVendedor)

	DbSelectArea("Z40")
	Z40->(DBSetOrder(1))
	Z40->(DBGoTOP())
	
	If !Empty(cRazao) .or. !Empty(cValorPed) .or. !Empty(cPercentual) .or. ;
		!Empty(cValorCom) .or. !Empty(cDatPed) .or. !Empty(cMarca) .or. ;
		!Empty(cDtStat) .or. !Empty(cQuant) .or. !Empty(cNFantas) .or. ;
		!Empty(cDescont) .or. !Empty(cCondPgt) .or. !Empty(cNota) .or. !Empty(cStatus)
		cID := ""
	EndIf

	If lComLib
		If !Empty(cID)
			If Z40->(DBSeek(xFilial("Z40")+cID))
				::SetResponse('{')
				::SetResponse('"id":"'+cID+'",')
				::SetResponse('"razao_social":"'+Alltrim(Posicione("SA1",1,xFilial("SA1")+Z40->Z40_CLIENT+Z40->Z40_LOJA,"A1_NOME"))+'",')
				::SetResponse('"valor_pedido":"'+Transform(Z40->Z40_VLRPED,"@E 999,999,999.99")+'",')
				::SetResponse('"porcentagem":"'+Transform(Z40->Z40_PRCCOM,"@R 99.99")+'",')
				::SetResponse('"valor_comissao":"'+Transform(Z40->Z40_VLRCOM,"@E 999,999,999.99")+'",')
				::SetResponse('"data_pedido":"'+cvaltochar(Z40->Z40_DTPEDI)+'",')
				::SetResponse('"marca":"'+Alltrim(Posicione("Z03",1,xFilial("Z03")+Z40->Z40_MARCA,"Z03_DESGRI"))+'",')
				::SetResponse('"data_status":"'+cvaltochar(Z40->Z40_DTFATU)+'",')
				::SetResponse('"quantidade":"'+Transform(Z40->Z40_QTDITM,"@R 999,999.99")+'",')
				::SetResponse('"nome_fantasia":"'+Alltrim(Posicione("SA1",1,xFilial("SA1")+Z40->Z40_CLIENT+Z40->Z40_LOJA,"A1_NREDUZ"))+'",')
				::SetResponse('"desconto":"'+Transform(Z40->Z40_DESCON,"@R 999,999.99")+'",')
				::SetResponse('"cond_pagto.":"'+Alltrim(Posicione("SE4",1,xFilial("SE4")+Z40->Z40_CONDPG,"E4_DESCRI"))+'",')
				::SetResponse('"numero_nf":"'+Z40->Z40_NOTA+'",')
				::SetResponse('"status":"'+Z40->Z40_COMPAG+'",')
				::SetResponse('"id":"'+Z40->(Recno())+'"')
				::SetResponse('}')
			Else
				::SetResponse('{"codigo":"'+cID+'","Erro":"Titulo nao encontrado"}')
			EndIf
		ELSE
			::SetResponse('{')
			::SetResponse('"items": [')
			
			If !Empty(cRazao) .or. !Empty(cValorPed) .or. !Empty(cPercentual) .or. ;
				!Empty(cValorCom) .or. !Empty(cDatPed) .or. !Empty(cMarca) .or. ;
				!Empty(cDtStat) .or. !Empty(cQuant) .or. !Empty(cNFantas) .or. ;
				!Empty(cDescont) .or. !Empty(cCondPgt) .or. !Empty(cNota) .or. !Empty(cStatus)
				
				cQuery := "SELECT *"
				cQuery += " FROM ( SELECT "
			Else

				cQuery := "SELECT TOP(50) * 
				cQuery += " FROM(
				cQuery += "	SELECT TOP("+If(!Empty(cPage),cvaltochar(val(cPage)*50),'50')+")"
			EndIf

			cQuery += " Z40_IDCALC,Z40_CLIENT,Z40_LOJA,"
			cQuery += " Z40_VLRPED,Z40_PRCCOM,Z40_VLRCOM,Z40_DTPEDI,Z03_DESGRI,Z40_DTFATU,Z40_QTDITM,A1_NOME,A1_NREDUZ,"
			cQuery += " Z40_DESCON,E4_DESCRI,Z40_NOTA,Z40_COMPAG,Z40.R_E_C_N_O_ AS RECZ40"
			cQuery += " FROM "+RetSQLName("Z40")+ " Z40"
			cQuery += " INNER JOIN "+RetSQLName("SA1")+" A1 ON A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD=Z40_CLIENT AND A1_LOJA=Z40_LOJA AND A1.D_E_L_E_T_=' '"

			If !Empty(cRazao)
				cQuery += " AND A1_NOME LIKE '%"+Alltrim(cRazao)+"%'"
			EndIf

			If !Empty(cNFantas)
				cQuery += " AND A1_NREDUZ LIKE '%"+Alltrim(cNFantas)+"%'"
			EndIf 

			cQuery += " INNER JOIN "+RetSQLName("Z03")+" Z03 ON Z03_FILIAL='"+xFilial("Z03")+"' AND Z03_CODGRI=Z40_MARCA AND Z03.D_E_L_E_T_=' '"

			If !Empty(cMarca)
				cQuery += " AND Z03_DESGRI LIKE '%"+UPPER(cMarca)+"%'"
			ENDIF

			cQuery += " INNER JOIN "+RetSQLName("SE4")+" E4 ON E4_FILIAL='"+xFilial("SE4")+"' AND E4_CODIGO=Z40_CONDPG AND E4.D_E_L_E_T_=' '"

			If !Empty(cCondPgt)
				cQuery += " AND E4_DESCRI LIKE '%"+cCondPgt+"%'"
			EndIf

			cQuery += " WHERE Z40.D_E_L_E_T_=' ' AND Z40_VENDED='"+cVendedor+"' " 

			iF !Empty(cValorPed)
				cQuery += " AND Z40_VLRPED="+cValorPed
			EndIf

			If !Empty(cPercentual)
				cQuery += " AND Z40_PRCCOM="+cPercentual
			EndIf

			If !Empty(cValorCom)
				cQuery += " AND Z40_VLRCOM="+cPercentual
			EndIf

			If !Empty(cDatPed)
				cQuery += " AND Z40_DTPEDI="+dtos(ctod(cPercentual))
			EndIf

			If !Empty(cDtStat)
				cQuery += " AND Z40_DTFATU="+dtos(ctod(cDtStat))
			EndIf

			If !Empty(cQuant)
				cQuery += " AND Z40_QTDITM="+cQuant
			EndIf

			If !Empty(cDescont)
				cQuery += " AND Z40_DESCON="+cDescont
			EndIf

			If !Empty(cNota)
				cQuery += " AND Z40_NOTA='"+cNota+"'"
			EndIf

			If !Empty(cStatus)
				cQuery += " AND Z40_COMPAG='"+cStatus+"'"
			EndIf

			If !Empty(cRazao) .or. !Empty(cValorPed) .or. !Empty(cPercentual) .or. ;
				!Empty(cValorCom) .or. !Empty(cDatPed) .or. !Empty(cMarca) .or. ;
				!Empty(cDtStat) .or. !Empty(cQuant) .or. !Empty(cNFantas) .or. ;
				!Empty(cDescont) .or. !Empty(cCondPgt) .or. !Empty(cNota) .or. !Empty(cStatus)
				cQuery += " ) TMP"
			Else
				cQuery += "		ORDER BY Z40_IDCALC ) TMP"
			EndIf

			cQuery += " ORDER BY Z40_IDCALC DESC"

			If Select('TRB') > 0
				dbSelectArea('TRB')
				dbCloseArea()
			EndIf

			DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

			DbSelectArea("TRB")

			While !EOF()
				Aadd(aAux,{	TRB->Z40_IDCALC,TRB->A1_NOME,TRB->Z40_VLRPED,;
							TRB->Z40_PRCCOM,TRB->Z40_VLRCOM,TRB->Z40_DTPEDI,;
							TRB->Z03_DESGRI,TRB->Z40_DTFATU,TRB->Z40_QTDITM,;
							TRB->A1_NREDUZ,TRB->Z40_DESCON,TRB->E4_DESCRI,;
							TRB->Z40_NOTA,TRB->Z40_COMPAG,TRB->RECZ40})
				Dbskip()
			ENDDO

			Asort(aAux,,,{|x,y| x[1] < y[1]})

			For nCont := 1 to len(aAux)
				::SetResponse(cVirg+'{')
				::SetResponse('"id":"'+aAux[nCont,01]+'",')
				::SetResponse('"razao_social":"'+Alltrim(aAux[nCont,02])+'",')
				::SetResponse('"valor_pedido":"'+Transform(aAux[nCont,03],"@E 999,999,999.99")+'",')
				::SetResponse('"porcentagem":"'+Transform(aAux[nCont,04],"@R 99.99")+'",')
				::SetResponse('"valor_comissao":"'+Transform(aAux[nCont,05],"@E 999,999,999.99")+'",')
				::SetResponse('"data_pedido":"'+cvaltochar(stod(aAux[nCont,06]))+'",')
				::SetResponse('"marca":"'+Alltrim(aAux[nCont,07])+'",')
				::SetResponse('"data_status":"'+cvaltochar(stod(aAux[nCont,08]))+'",')
				::SetResponse('"quantidade":"'+Transform(aAux[nCont,09],"@R 999,999.99")+'",')
				::SetResponse('"nome_fantasia":"'+Alltrim(aAux[nCont,10])+'",')
				::SetResponse('"desconto":"'+Transform(aAux[nCont,11],"@R 999,999.99")+'",')
				::SetResponse('"cond_pagto.":"'+Alltrim(aAux[nCont,12])+'",')
				::SetResponse('"numero_nf":"'+aAux[nCont,13]+'",')
				::SetResponse('"status":"'+aAux[nCont,14]+'",')
				::SetResponse('"id":"'+cvaltochar(aAux[nCont,15])+'"')
				::SetResponse('}')
				cVirg := ','
			Next nCont
			

			::SetResponse(']')
			::SetResponse('}')
		EndIf
	ELSE
		::SetResponse('[]')
	EndIf

	RestArea(aArea)

	
Return lRet
