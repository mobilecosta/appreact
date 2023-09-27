#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL010
Descricao: Serviço API Rest Evento Produtos

@author Alexandre Venâncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL010()
Return

// ServiÃƒÂ§o.
WsRestFul Products DESCRIPTION "API REST - EVENTO PRODUTOS | PORTAL ROBSOL " 
	
	WSDATA CODIGO As String 
	WSDATA PAGE As String
	WSDATA pageSize As String
	WSDATA DESCRICAO As String
	WSDATA MARCA As String
	WSDATA GENERO As String
	WSDATA LINHA As String
	WSDATA MATERIAL As String
	WSDATA COR As String
	WSDATA FORMATO As String
	WSDATA VENDEDOR As String
	WSDATA SALDO As String
	 	
	//WsMethod POST Description "API REST - EVENTO PRODUTOS - METODO POST "  WsSyntax "PRTL010"
	WsMethod GET Description "Retorna o Produto especifico ou cadastro todo" WSSYNTAX "/Products || /Products/{CODIGO} || /Products/{CODIGOPAGE}" 

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantação 
Descricao: 	Serviço Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venâncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod GET WsReceive CODIGO,PAGE,pageSize,DESCRICAO,MARCA,GENERO,LINHA,MATERIAL,COR,FORMATO,VENDEDOR,SALDO WsService Products

	Local cCode 	:= Self:CODIGO
	Local cPage		:= Self:PAGE
	Local cPagSiz	:= Self:pageSize
	Local cDescr 	:= Self:DESCRICAO
	Local MARCA 	:= Self:MARCA 
	Local GENERO 	:= Self:GENERO 
	Local LINHA 	:= Self:LINHA
	Local MATERIAL  := Self:MATERIAL
	Local cCor		:= Self:COR
	Local cFormato	:= Self:FORMATO
	Local cVendedor := Self:VENDEDOR
	Local cSaldo    := Self:SALDO

	Local aArea		:= GetArea()
	Local cVirg		:= ''
	Local nCont		:= 0
	Local cQuery
	Local aAux		:= {}
	Local aMala 	:= {}
	Local aPrcTab	:= {}
	Local cMalasV	:=	''
	Local cUrlPrd	:=	'http://portal.robsol.com.br/fotos/'

	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0103")
	
	conout("chegou aqui PRTL010")
	conout('codigo '+If(valtype(cCode)=="C",cCode,""))
	conout('descricao '+If(valtype(cDescr)=="C",cDescr,""))
	conout('marca '+If(valtype(MARCA)=="C",MARCA,""))
	conout('genero '+If(valtype(GENERO)=="C",GENERO,""))
	conout('linha '+If(valtype(LINHA)=="C",LINHA,""))
	conout('material '+If(valtype(MATERIAL)=="C",MATERIAL,""))
	conout('cor '+If(valtype(cCor)=="C",cCor,""))
	conout('formato '+If(valtype(cFormato)=="C",cFormato,""))
	conout('vendedor '+If(valtype(cVendedor)=="C",cVendedor,""))
	conout('Pagina '+ cPage)
	conout('Qtd por Pagina '+cPagSiz)

	DbSelectArea("SB1")
	SB1->(DBSetOrder(1))
	SB1->(DBGoTOP())
	
	If !Empty(cDescr) .Or. !Empty(MARCA) .Or. !Empty(GENERO) .Or. !Empty(LINHA) .Or. !Empty(MATERIAL) .Or. !Empty(cCor).Or. !Empty(cFormato)
		cCode := ""
	ENDIF

	If !Empty(cCode) .And. Empty(cPage)
		If SB1->(DBSeek(xFilial("SB1")+cCode))
			::SetResponse('{')
			::SetResponse('"codigo":"'+cCode+'",')
			::SetResponse('"descricao":"'+SB1->B1_DESC+'",')
			::SetResponse('"um":"'+SB1->B1_UM+'",')
			::SetResponse('"tipo":"'+SB1->B1_TIPO+'",')
			::SetResponse('"grupo":"'+Alltrim(Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))+'",')

			::SetResponse('"cor":"'+SB1->B1_XCORES+'",')
			::SetResponse('"formato":"'+SB1->B1_XFORMAT+'",')

			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek('0103'+SB1->B1_COD+SB1->B1_LOCPAD)

			::SetResponse('"saldo":"'+If(SaldoSB2(.T.) >= 10,'Disponivel','Indisponivel')+'",')
			::SetResponse('"ncm":"'+SB1->B1_POSIPI+'",')
			::SetResponse('"ean":"'+SB1->B1_CODBAR+'",')
			::SetResponse('"imagem":"'+STRTRAN(Alltrim(SB1->B1_XURLIMG),' ','%20')+'",')
			::SetResponse('"id":"'+cvaltochar(Recno())+'"')
			::SetResponse('}')
		Else
			::SetResponse('{"codigo":"'+cCode+'","Erro":"Produto nao encontrado"}')
		EndIf
	ELSE
		If !Empty(cVendedor)
			aMala := BuscaMala(cVendedor)
		EndIf

		/*If !Empty(cDescr) .Or. !Empty(MARCA) .Or. !Empty(GENERO) .Or. !Empty(LINHA) .Or. !Empty(MATERIAL) .Or. !Empty(cCor).Or. !Empty(cFormato) //.Or. !Empty(cVendedor)
			cQuery := "SELECT *"
			cQuery += " FROM ( SELECT "
		Else*/
			
			cQuery := "SELECT TOP("+cPagSiz+") *"
			cQuery += " FROM ( SELECT TOP("+If(!Empty(cPage),cvaltochar(val(cPage)*val(cPagSiz)),cPagSiz)+")"
		//ENDIF

		cQuery += " COUNT(B1_FILIAL) OVER (PARTITION BY ' ') TOTREG, B1_COD,B1_DESC,B2_QATU-B2_RESERVA AS SALDO,B1_XURLIMG,Z03_DESGRI,Z04_DESGEN,"
		cQuery += " Z05_DESLIN,Z06_DESMAT,B1_XCORES,B1_XFORMAT,Z03_CODGRI,B1.R_E_C_N_O_ AS RECB1,B2_FILIAL,B2_LOCAL"
		cQuery += " FROM "+RetSQLName("SB1")+" B1"
		cQuery += " INNER JOIN "+RetSQLName("SBM")+" BM ON BM_FILIAL=B1_FILIAL AND BM_GRUPO=B1_GRUPO AND BM.D_E_L_E_T_=' '"
		cQuery += " INNER JOIN "+RetSQLName("Z03")+" Z3 ON Z03_FILIAL=BM_FILIAL AND Z03_CODGRI=BM_XMODELO AND Z3.D_E_L_E_T_=' '"
		
		If !Empty(MARCA)
			cQuery += " AND Z03_DESGRI LIKE '%"+UPPER(MARCA)+"%'"
		EndIf

		IF len(aMala) > 0
			cMalasV := ""
			nCont   := 0
			cVirgula:= ""
			For nCont := 1 to len(aMala)
				cMalasV += cVirgula + aMala[nCont]
				cVirgula := "','"

			Next nCont
			cQuery += " AND Z03_CODGRI IN('"+cMalasV+"')"
		ENDIF

		cQuery += " INNER JOIN "+RetSQLName("Z04")+" Z4 ON Z04_FILIAL=BM_FILIAL AND Z04_CODGEN=BM_XCATEGO AND Z4.D_E_L_E_T_=' '"
		
		If !Empty(GENERO)
			cQuery += " AND Z04_DESGEN LIKE '%"+UPPER(GENERO)+"%'"
		EndIf
		
		cQuery += " LEFT JOIN "+RetSQLName("Z05")+" Z5 ON Z05_FILIAL=BM_FILIAL AND Z05_CODLIN=BM_XLINHA AND Z5.D_E_L_E_T_=' '"
		
		If !Empty(LINHA)
			cQuery += " AND Z05_DESLIN LIKE '%"+UPPER(LINHA)+"%'"
		EndIf

		cQuery += " INNER JOIN "+RetSQLName("Z06")+" Z6 ON Z06_FILIAL=BM_FILIAL AND Z06_CODMAT=BM_XMATERI AND Z6.D_E_L_E_T_=' '"
	
		If !Empty(MATERIAL)
			cQuery += " AND Z06_DESMAT LIKE '%"+UPPER(MATERIAL)+"%'"
		EndIf 

		cQuery += " LEFT JOIN "+RetSQLName("SB2")+ " B2 ON B2_FILIAL='0103' AND B2_COD=B1_COD AND B2_LOCAL='101' AND B2.D_E_L_E_T_=' '"
		
		cQuery += " WHERE B1.D_E_L_E_T_=' ' AND B1_MSBLQL <> '1' AND B1_GRUPO LIKE '11%' AND B1_FILIAL='"+xFilial("SB1")+"'"
		
		If !Empty(cCode) 
			cQuery += " AND B1_COD LIKE '%"+UPPER(Alltrim(cCode))+"%'"
		EndIf 
		
		If !Empty(cDescr)
			cQuery += " AND B1_DESC LIKE '%"+UPPER(cDescr)+"%'"
		EndIf

		If !Empty(cCor)
			cQuery += " AND B1_XCORES LIKE '%"+UPPER(cCor)+"%'"
		EndIf

		If !Empty(cFormato)
			cQuery += " AND B1_XFORMAT LIKE '%"+UPPER(cFormato)+"%'"
		EndIf

		/*If !Empty(cDescr) .Or. !Empty(MARCA) .Or. !Empty(GENERO) .Or. !Empty(LINHA) .Or. !Empty(MATERIAL) .Or. !Empty(cCor).Or. !Empty(cFormato) .Or. !Empty(cVendedor)
			cQuery += " ) TMP"
		ELSE*/
			cQuery += " ORDER BY B1_COD ASC) TMP"
		//ENDIF

		cQuery += " ORDER BY B1_COD desc"

		//conout(cquery)

		If Select('TRB') > 0
			dbSelectArea('TRB')
			dbCloseArea()
		EndIf

		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

		DbSelectArea("TRB")

		If cSaldo == '2' //Somente Disponiveis
			cSaldoAux := 'Disponivel'
		ElseIf cSaldo == '3' //Somente Indisponiveis
			cSaldoAux := 'Indisponivel'
		Else //todos
			cSaldoAux := 'Todos'
		EndIf

		While !EOF()

			nTextSld := ''
			nTextSld := If(TRB->SALDO >= 10,'Disponivel','Indisponivel')
			
			If cSaldoAux == 'Todos' .Or. cSaldoAux == nTextSld
				Aadd(aAux,{;
					TRB->B1_COD,Alltrim(TRB->B1_DESC)+' / Saldo '+nTextSld,TRB->Z03_DESGRI,;
					TRB->Z04_DESGEN,TRB->Z05_DESLIN,;
					TRB->Z06_DESMAT,TRB->B1_XCORES,;
					TRB->B1_XFORMAT,0,;
					cUrlPrd+Alltrim(TRB->B1_COD)+'.JPG',;
					nTextSld,TRB->RECB1;
				})
			EndIf
			Dbskip()
		ENDDO

		aPrcTab := Tabelas(cMalasV)

		If len(aPrcTab) > 0
			For nCont := 1 to len(aPrcTab)
				nPos := Ascan(aAux,{|x| Alltrim(x[1]) == Alltrim(aPrcTab[nCont,01])})
				If nPos > 0
					aAux[nPos,09] := aPrcTab[nCont,03]
				EndIf	 
			Next nCont
		EndIf 

		Asort(aAux,,,{|x,y| x[1] < y[1]})
		cJsonRet := '{'
		cJsonRet += '"hasNext": true,'
		cJsonRet += '"items": ['
		
		::SetResponse('{')
		::SetResponse('"hasNext": true,')
		::SetResponse('"items": [')
		
		For nCont := 1 to len(aAux)
			//If aAux[nCont,09] > 0
				::SetResponse(cVirg+'{')
				::SetResponse('"codigo":"'+	Alltrim(aAux[nCont,01])+'",')
				::SetResponse('"descricao":"'+Capital(Alltrim(aAux[nCont,02]))+'",')
				::SetResponse('"marca":"'+Capital(Alltrim(aAux[nCont,03]))+'",')
				::SetResponse('"genero":"'+Capital(Alltrim(aAux[nCont,04]))+'",')
				::SetResponse('"linha":"'+Capital(Alltrim(aAux[nCont,05]))+'",')
				::SetResponse('"material":"'+Capital(Alltrim(aAux[nCont,06]))+'",')
				::SetResponse('"cor":"'+Capital(Alltrim(aAux[nCont,07]))+'",')
				::SetResponse('"formato":"'+Capital(Alltrim(aAux[nCont,08]))+'",')
				::SetResponse('"preco":"'+Transform(aAux[nCont,09],"@E 9,999.99")+'",')
				::SetResponse('"imagem":"'+STRTRAN(Alltrim(aAux[nCont,10]),' ','%20')+'",')
				::SetResponse('"saldo":"'+cvaltochar(aAux[nCont,11])+'",')
				::SetResponse('"id":"'+cvaltochar(aAux[nCont,12])+'"')
				::SetResponse('}')

				cJsonRet += cVirg+'{'
				cJsonRet += '"codigo":"'+	Alltrim(aAux[nCont,01])+'",'
				cJsonRet += '"descricao":"'+Capital(Alltrim(aAux[nCont,02]))+'",'
				cJsonRet += '"marca":"'+Capital(Alltrim(aAux[nCont,03]))+'",'
				cJsonRet += '"genero":"'+Capital(Alltrim(aAux[nCont,04]))+'",'
				cJsonRet += '"linha":"'+Capital(Alltrim(aAux[nCont,05]))+'",'
				cJsonRet += '"material":"'+Capital(Alltrim(aAux[nCont,06]))+'",'
				cJsonRet += '"cor":"'+Capital(Alltrim(aAux[nCont,07]))+'",'
				cJsonRet += '"formato":"'+Capital(Alltrim(aAux[nCont,08]))+'",'
				cJsonRet += '"preco":"'+Transform(aAux[nCont,09],"@E 9,999.99")+'",'
				cJsonRet += '"imagem":"'+STRTRAN(Alltrim(aAux[nCont,10]),' ','%20')+'",'
				cJsonRet += '"saldo":"'+cvaltochar(aAux[nCont,11])+'",'
				cJsonRet += '"id":"'+cvaltochar(aAux[nCont,12])+'"'
				cJsonRet += '}'
			//EndIf
			cVirg := ','
		Next nCont
				
		::SetResponse(']')
		::SetResponse('}')
		cJsonRet += ']'
		cJsonRet += '}'
		//conout(cJsonRet)
	EndIf

	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} BuscaMala()
	(long_description)
	@type  Static Function
	@author user
	@since 18/12/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
STATIC Function BuscaMala(cVendedor)

Local aArray := {}
Local aAux   := {}
Local cQuery
Local nCont  := 0

cQuery := "SELECT Z30_MALA FROM "+RetSQLName("Z30")
cQuery += " WHERE Z30_CODVEN='"+cVendedor+"'"

If Select('TRB') > 0
	dbSelectArea('TRB')
	dbCloseArea()
EndIf

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

DbSelectArea("TRB")

While !EOF()
	aAux := Strtokarr(Alltrim(TRB->Z30_MALA),"/")
	For nCont := 1 to len(aAux)
		Aadd(aArray,aAux[nCont])
	Next nCont
	Dbskip()
EndDo
	
Return(aArray)

/*/{Protheus.doc} Tabelas
	(long_description)
	@type  Static Function
	@author user
	@since 08/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function Tabelas(cMalasV)
	
Local aArea	:=	GetArea()
Local cQuery 
Local aRet	:=	{}

cQuery := "SELECT DISTINCT DA1_CODTAB,DA1_CODPRO,DA1_PRCVEN"
cQuery += " FROM "+RetSQLName("DA1")+" DA1"
cQuery += " INNER JOIN "+RetSQLName("DA0")+" DA0 ON DA0_FILIAL=DA1_FILIAL AND DA0_CODTAB=DA1_CODTAB AND DA0_ATIVO='1' AND DA0.D_E_L_E_T_=' '"
cQuery += " AND (DA0_DATATE=' ' OR DA0_DATATE>='"+dtos(ddatabase)+"')"
cQuery += " INNER JOIN "+RetSQLName("SB1")+" B1 ON B1_FILIAL=DA1_FILIAL AND B1_COD=DA1_CODPRO AND B1_GRUPO LIKE '11%' AND B1.D_E_L_E_T_=' '"
cQuery += " INNER JOIN "+RetSQLName("SBM")+" BM ON BM_FILIAL=B1_FILIAL AND BM_GRUPO=B1_GRUPO AND BM.D_E_L_E_T_=' '"
cQuery += " INNER JOIN "+RetSQLName("Z03")+" Z03 ON Z03_FILIAL=BM_FILIAL AND Z03_CODGRI=BM_XMODELO AND Z03.D_E_L_E_T_=' '"
cQuery += " AND Z03_CODGRI IN('"+cMalasV+"')"
cQuery += " WHERE DA1.D_E_L_E_T_=' '"
cQuery += " ORDER BY DA1_CODPRO,DA1_CODTAB DESC"

//CONOUT(cQuery)

If Select('TRB') > 0
	dbSelectArea('TRB')
	dbCloseArea()
EndIf

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

DbSelectArea("TRB")

While !EOF()
	Aadd(aRet,{TRB->DA1_CODPRO,TRB->DA1_CODTAB,TRB->DA1_PRCVEN})
	Dbskip()
EndDo

RestArea(aArea)

Return(aRet)
