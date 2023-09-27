#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL011
Descricao: Servico API Rest Evento Clientes

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL011()
Return

// Serviço.
WsRestFul Customers DESCRIPTION "API REST - EVENTO CLIENTES | PORTAL ROBSOL " 
	
	WSDATA CNPJ As String
	WSDATA PAGE As String
	WSDATA PAGESIZE As String 
	WSDATA RAZAO_SOCIAL As String
	WSDATA NOME_FANTASIA As String
	WSDATA ENDERECO As String
	WSDATA BAIRRO As String
	WSDATA CEP As String
	WSDATA CIDADE As String
	WSDATA TELEFONE As String
	WSDATA UF As String
	WSDATA VENDEDOR As String
	WSDATA ORIGEMAPP As String
	
	WsMethod GET Description "Retorna o Cliente especifico ou cadastro todo" WSSYNTAX "/Customers || /Customers/{CODIGO} || /Customers/{PAGE}" 

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
WsMethod GET WsReceive CNPJ,PAGE,PAGESIZE,RAZAO_SOCIAL,NOME_FANTASIA,ENDERECO,BAIRRO,CEP,CIDADE,TELEFONE,UF,VENDEDOR,ORIGEMAPP WsService Customers

	Local aArea		:= GetArea()
	Local cCode 	:= Self:CNPJ
	Local cPage		:= Self:PAGE
	Local cPagSiz	:= Self:PAGESIZE
	Local cNome 	:= Self:RAZAO_SOCIAL
	Local cNFant	:= Self:NOME_FANTASIA
	Local cEnder	:= Self:ENDERECO
	Local cBairro	:= Self:BAIRRO
	Local cCep		:= Self:CEP
	Local cCidade	:= Self:CIDADE
	Local cTelefone	:= Self:TELEFONE
	Local cUF		:= Self:UF
	Local cVendedor := Self:VENDEDOR
	Local cAppEnv	:= Self:ORIGEMAPP

	Local nCont		:= 0
	Local nX		:= 0
	Local cVirg		:= ""
	Local aAux		:= {}
	Local aRegiao   := {}
	Local cVirg2	:=	''

	lRet					:= .T.

	If cAppEnv == NIL
		cAppEnv := 'N'
	EndIf 

	If cPagSiz == NIL
		cPagSiz := 500
	EndIf

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	conout("chegou aqui PRTL011")
	conout('codigo '+If(valtype(cCode)=="C",cCode,""))
	conout('RAZAO '+If(valtype(cNome)=="C",cNome,""))
	conout('nome fantasia '+If(valtype(cNFant)=="C",cNFant,""))
	conout('endereco '+If(valtype(cEnder)=="C",cEnder,""))
	conout('bairro '+If(valtype(cBairro)=="C",cBairro,""))
	conout('cep '+If(valtype(cCep)=="C",cCep,""))
	conout('cidade '+If(valtype(cCidade)=="C",cCidade,""))
	conout('telefone '+If(valtype(cTelefone)=="C",cTelefone,""))
	conout('estado '+If(valtype(cUF)=="C",cUF,""))
	conout('vendedor '+If(valtype(cVendedor)=="C",cVendedor,""))
	conout('Origem APPA '+cAppEnv)
	//conout('Pagina '+cPage)
	//conout('Qtd por pagina '+cPagSiz)

	DbSelectArea("SA1")
	SA1->(DBSetOrder(3))
	SA1->(DBGoTOP())
	
	If !Empty(cNome) .Or. !Empty(cNFant) .Or. !Empty(cEnder) .Or. !Empty(cBairro);
		.Or. !Empty(cCep) .Or. !Empty(cCidade) .Or. !Empty(cTelefone) .Or. !Empty(cUF)
		cCode := ""
	EndIf

	If !Empty(cCode)
		If SA1->(DBSeek(xFilial("SA1")+cCode))
			conout('CNPJ encontrado '+SA1->A1_CGC)
			::SetResponse('{')
			::SetResponse('"cnpj":"'+SA1->A1_CGC+'",')
			::SetResponse('"codigo":"'+SA1->A1_COD+'",')
			::SetResponse('"insc_estadual":"'+SA1->A1_INSCR+'",')
			::SetResponse('"filial":"'+Alltrim(SA1->A1_LOJA)+'",')
			::SetResponse('"razao_social":"'+Alltrim(SA1->A1_NOME)+'",')
			::SetResponse('"nome_fantasia":"'+Alltrim(SA1->A1_NREDUZ)+'",')
			::SetResponse('"endereco":"'+Alltrim(SA1->A1_END)+'",')
			::SetResponse('"complemento":"'+Alltrim(SA1->A1_COMPLEM)+'",')
			::SetResponse('"bairro":"'+Alltrim(SA1->A1_BAIRRO)+'",')
			::SetResponse('"cidade":"'+Alltrim(SA1->A1_MUN)+'",')
			::SetResponse('"uf":"'+Alltrim(SA1->A1_EST)+'",')
			::SetResponse('"cep":"'+Alltrim(SA1->A1_CEP)+'",')
			::SetResponse('"contato":"'+Alltrim(SA1->A1_CONTATO)+'",')
			::SetResponse('"email":"'+Alltrim(SA1->A1_EMAIL)+'",')
			::SetResponse('"celular":"'+Alltrim(ALLTRIM(SA1->A1_DDD)+SA1->A1_TEL)+'",')
			::SetResponse('"fone2":"'+Alltrim(ALLTRIM(SA1->A1_XDDD)+SA1->A1_XTELEFO)+'",')
			::SetResponse('"ultima_compra":"'+cvaltochar(SA1->A1_ULTCOM)+'",')
			::SetResponse('"primeira_compra":"'+cvaltochar(SA1->A1_PRICOM)+'",')
			::SetResponse('"risco":"'+SA1->A1_RISCO+'",')
			::SetResponse('"limite_credito":"'+transform(SA1->A1_LC,"@E 999,999.99")+'",')
			::SetResponse('"saldo":"'+transform(SA1->(A1_LC-A1_SALDUP),"@E 999,999.99")+'",')
			::SetResponse('"maior_compra":"'+transform(SA1->A1_MCOMPRA,"@E 999,999.99")+'",')
			::SetResponse('"qtd_compras":"'+transform(SA1->A1_NROCOM,"@R 99999")+'",')
			::SetResponse('"saldo_dupl_aberto":"'+transform(SA1->A1_SALDUP,"@E 999,999.99")+'",')
			::SetResponse('"qtd_atrasos":"'+transform(SA1->A1_ATR,"@R 9999")+'",')
			::SetResponse('"maior_atraso":"'+transform(SA1->A1_MATR,"@R 9999")+'",')
			::SetResponse('"qtd_pagto_atraso":"'+transform(SA1->A1_PAGATR,"@R 9999")+'",')
			::SetResponse('"bloqueado":"'+Iif(Alltrim(SA1->A1_MSBLQL) == '1','sim','nao')+'",')
			::SetResponse('"id":"'+cvaltochar(Recno())+'"')

			If cAppEnv == "SSS"
				aTitAx := buscatit(SA1->A1_COD,SA1->A1_LOJA)
				conout(len(aTitAx))
				If len(aTitAx) > 0
					cVirg2 := ''
					::SetResponse(',"titulos": [')
					For nX := 1 to len(aTitAx)
						::SetResponse(cVirg2+'{')
						::SetResponse('"prefixo":"'+aTitAx[nX,1]+'",')
						::SetResponse('"titulo":"'+aTitAx[nX,2]+'",')
						::SetResponse('"parcela":"'+aTitAx[nX,3]+'",')
						::SetResponse('"tipo":"'+aTitAx[nX,4]+'",')
						::SetResponse('"emissao":"'+cvaltochar(stod(aTitAx[nX,5]))+'",')
						::SetResponse('"vencimento":"'+cvaltochar(stod(aTitAx[nX,6]))+'",')
						::SetResponse('"valor":"'+transform(aTitAx[nX,7],"@E 999,999.99")+'",')		
						::SetResponse('}')
						cVirg2 := ','
					Next nX
					::SetResponse(']')
					//::SetResponse('}')
				EndIf
			endIf

			::SetResponse('}')
		Else
			::SetResponse('{"codigo":"'+cCode+'","Erro":"Cliente nao encontrado"}')
			conout('CNPJ não encontrado '+cCode)
		EndIf
	ELSE

		If !Empty(cVendedor)
			aRegiao := BuscaRegiao(cVendedor)
		ENDIF

		
		
		If !Empty(cNome) .Or. !Empty(cNFant) .Or. !Empty(cEnder) .Or. !Empty(cBairro);
		.Or. !Empty(cCep) .Or. !Empty(cCidade) .Or. !Empty(cTelefone) .Or. !Empty(cUF)
			nQtdPg := If(valtype(cPagSiz)=="C",val(cPagSiz),cPagSiz) //If(cAppEnv=="S",'5000','50')
			If nQtdPg > 0
				cQuery := "SELECT TOP "+cvaltochar(nQtdPg)+" *"
				cQuery += " FROM ( SELECT "
			Else
				cQuery := "SELECT *"
				cQuery += " FROM ( SELECT "
			EndIf 
		Else
			nQtdPg := cPagSiz //If(cAppEnv=="S",'5000','50')
			cQuery := "SELECT TOP("+nQtdPg+") * 
			cQuery += " FROM(
			cQuery += "	SELECT TOP("+If(!Empty(cPage),cvaltochar(val(cPage)*val(nQtdPg)),nQtdPg)+")"
		EndIf

		cQuery += " A1_CGC,A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_END,A1_COMPLEM,A1_BAIRRO,A1_MUN,"
		cQuery += " A1_EST,A1_DDD,A1_TEL,A1_CEP,A1_CONTATO,A1_EMAIL,A1_ULTCOM,A1_XDDD,"
		cQuery += " A1_MCOMPRA,A1_NROCOM,A1_SALDUP,A1_ATR,A1_MATR,A1_PAGATR,A1_XTELEFO,"
		cQuery += " A1_RISCO,A1_LC,A1_LC-A1_SALDUP AS SALDO,A1_PRICOM,A1_INSCR,A1_MSBLQL,A1.R_E_C_N_O_ AS RECA1"
		cQuery += " FROM "+RetSQLName("SA1")+" A1"
		cQuery += " WHERE D_E_L_E_T_=' ' "//AND A1_MSBLQL<>'1'" 
		
		If !Empty(cNome)
			cQuery += " AND A1_NOME LIKE '%"+upper(cNome)+"%'"
		EndIf

		if !Empty(cNFant)
			cQuery += " AND A1_NREDUZ LIKE '%"+upper(cNFant)+"%'"
		EndIf

		If !Empty(cEnder)
			cQuery += " AND A1_END LIKE '%"+upper(cEnder)+"%'"
		EndIf

		If !Empty(cBairro)
			cQuery += " AND A1_BAIRRO LIKE '%"+upper(cBairro)+"%'"
		EndIf

		If !Empty(cCep)
			cQuery += " AND A1_CEP LIKE '%"+cCep+"%'"
		ENDIF

		If !Empty(cCidade)
			cQuery += " AND A1_MUN LIKE '%"+upper(cCidade)+"%'"
		EndIf
		
		If !Empty(cTelefone)
			cQuery += " AND A1_TEL LIKE '%"+cTelefone+"%'"
		EndIf

		If !Empty(cUF)
			cQuery += " AND A1_EST LIKE '%"+upper(cUF)+"%'"
		EndIf

		IF len(aRegiao) > 0
			cRegiao := ""
			nCont   := 0
			cVirgula:= ""
			For nCont := 1 to len(aRegiao)
				cRegiao += cVirgula + aRegiao[nCont]
				cVirgula := "','"
				
			Next nCont
			cQuery += " AND A1_EST IN('"+upper(cRegiao)+"')"
		EndIf

		If !Empty(cNome) .Or. !Empty(cNFant) .Or. !Empty(cEnder) .Or. !Empty(cBairro);
		.Or. !Empty(cCep) .Or. !Empty(cCidade) .Or. !Empty(cTelefone) .Or. !Empty(cUF)
			cQuery += " ) TMP"
		Else
			cQuery += "		ORDER BY A1_COD ) TMP"
		EndIf

		cQuery += " ORDER BY A1_COD desc"

		conout(cquery)
		
		CONOUT(CVALTOCHAR(TIME()))

		If Select('TRB') > 0
			dbSelectArea('TRB')
			dbCloseArea()
		EndIf

		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

		DbSelectArea("TRB")

		While !EOF()
			Aadd(aAux,{	TRB->A1_CGC,;
						TRB->A1_COD,;
						TRB->A1_NOME,;
						TRB->A1_NREDUZ,;
						TRB->A1_END,;
						TRB->A1_BAIRRO,;
						TRB->A1_MUN,;
						TRB->A1_EST,;
						ALLTRIM(TRB->A1_DDD)+ALLTRIM(TRB->A1_TEL),;
						TRB->A1_CEP,;
						TRB->A1_CONTATO,;
						TRB->A1_EMAIL,;
						TRB->A1_LOJA,;
						TRB->A1_ULTCOM,;
						TRB->A1_PRICOM,;
						TRB->A1_RISCO,;
						TRB->A1_LC,;
						TRB->SALDO,;
						TRB->A1_MCOMPRA,;
						TRB->A1_NROCOM,;
						TRB->A1_SALDUP,;
						TRB->A1_ATR,;
						TRB->A1_MATR,;
						TRB->A1_PAGATR,;
						TRB->A1_INSCR,;
						TRB->RECA1,;
						ALLTRIM(TRB->A1_XDDD)+ALLTRIM(TRB->A1_XTELEFO),;
						Iif(Alltrim(TRB->A1_MSBLQL) == '1','sim','nao'),;
						TRB->A1_COMPLEM; //29
					})
			Dbskip()
		ENDDO

		CONOUT(CVALTOCHAR(TIME()))
		

		Asort(aAux,,,{|x,y| x[2] < y[2]})

		If len(aAux) > 0
			::SetResponse('{')
			::SetResponse('"hasNext": true,')
			::SetResponse('"items": [')
			
			For nCont := 1 to len(aAux)
				::SetResponse(cVirg+'{')
				//If cAppEnv == 'S'
					::SetResponse('"cnpj":"'+aAux[nCont,01]+'",')
					::SetResponse('"codigo":"'+aAux[nCont,02]+'",')
					::SetResponse('"insc_estadual":"'+aAux[nCont,25]+'",')
					::SetResponse('"filial":"'+Alltrim(aAux[nCont,13])+'",')
					::SetResponse('"razao_social":"'+Alltrim(FwCutOff(aAux[nCont,03],.F.))+'",')
					::SetResponse('"nome_fantasia":"'+Alltrim(FwCutOff(aAux[nCont,04],.F.))+'",')
					::SetResponse('"endereco":"'+Alltrim(FwCutOff(aAux[nCont,05],.F.))+'",')
					::SetResponse('"complemento":"'+Alltrim(FwCutOff(aAux[nCont,29],.F.))+'",')
					::SetResponse('"bairro":"'+Alltrim(FwCutOff(aAux[nCont,06],.F.))+'",')
					::SetResponse('"cidade":"'+Alltrim(FwCutOff(aAux[nCont,07],.F.))+'",')
					::SetResponse('"uf":"'+Alltrim(aAux[nCont,08])+'",')
					::SetResponse('"cep":"'+Alltrim(aAux[nCont,10])+'",')
					::SetResponse('"contato":"'+Alltrim(FwCutOff(aAux[nCont,11],.F.))+'",')
					::SetResponse('"email":"'+Alltrim(FwCutOff(aAux[nCont,12],.F.))+'",')
					::SetResponse('"celular":"'+Alltrim(aAux[nCont,09])+'",')
					::SetResponse('"fone2":"'+Alltrim(aAux[nCont,27])+'",')
					::SetResponse('"ultima_compra":"'+cvaltochar(stod(aAux[nCont,14]))+'",')
					::SetResponse('"primeira_compra":"'+cvaltochar(stod(aAux[nCont,15]))+'",')
					::SetResponse('"risco":"'+aAux[nCont,16]+'",')
					::SetResponse('"limite_credito":"'+transform(aAux[nCont,17],"@E 999,999.99")+'",')
					::SetResponse('"saldo":"'+transform(aAux[nCont,18],"@E 999,999.99")+'",')
					::SetResponse('"maior_compra":"'+transform(aAux[nCont,19],"@E 999,999.99")+'",')
					::SetResponse('"qtd_compras":"'+transform(aAux[nCont,20],"@R 99999")+'",')
					::SetResponse('"saldo_dupl_aberto":"'+transform(aAux[nCont,21],"@E 999,999.99")+'",')
					::SetResponse('"qtd_atrasos":"'+transform(aAux[nCont,22],"@R 9999")+'",')
					::SetResponse('"maior_atraso":"'+transform(aAux[nCont,23],"@R 9999")+'",')
					::SetResponse('"qtd_pagto_atraso":"'+transform(aAux[nCont,24],"@R 9999")+'",')
					::SetResponse('"bloqueado":"'+aAux[nCont,28]+'",')
					::SetResponse('"id":"'+cvaltochar(aAux[nCont,26])+'"')
				/*Else
					::SetResponse('"cnpj":"'+aAux[nCont,01]+'",')
					::SetResponse('"razao_social":"'+Alltrim(aAux[nCont,03])+'",')
					::SetResponse('"nome_fantasia":"'+Alltrim(aAux[nCont,04])+'",')
					::SetResponse('"cidade":"'+Alltrim(aAux[nCont,07])+'",')
					::SetResponse('"uf":"'+Alltrim(aAux[nCont,08])+'",')
					::SetResponse('"contato":"'+Alltrim(aAux[nCont,11])+'"')
				EndIf	
*/
				/*
				If cAppEnv == "S"
					aTitAx := buscatit(aAux[nCont,2],aAux[nCont,13])
					conout(len(aTitAx))
					If len(aTitAx) > 0
						cVirg2 := ''
						::SetResponse(',"titulos": [')
						For nX := 1 to len(aTitAx)
							::SetResponse(cVirg2+'{')
							::SetResponse('"prefixo":"'+aTitAx[nX,1]+'",')
							::SetResponse('"titulo":"'+aTitAx[nX,2]+'",')
							::SetResponse('"parcela":"'+aTitAx[nX,3]+'",')
							::SetResponse('"tipo":"'+aTitAx[nX,4]+'",')
							::SetResponse('"emissao":"'+cvaltochar(stod(aTitAx[nX,5]))+'",')
							::SetResponse('"vencimento":"'+cvaltochar(stod(aTitAx[nX,6]))+'",')
							::SetResponse('"valor":"'+transform(aTitAx[nX,7],"@E 999,999.99")+'",')		
							::SetResponse('}')
							cVirg2 := ','
						Next nX
						::SetResponse(']')
						//::SetResponse('}')
					EndIf
				endIf
				*/

				::SetResponse('}')
				cVirg := ','
			Next nCont
			
			::SetResponse(']')
			::SetResponse('}')
		else
			::SetResponse('{"codigo":"'+cCode+'","Erro":"Cliente nao encontrado"}')
		EndIf
		CONOUT(CVALTOCHAR(TIME()))
		
	EndIf

	RestArea(aArea)

	
Return lRet

/*/{Protheus.doc} BuscaRegiao()
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
STATIC Function BuscaRegiao(cVendedor)

Local aArray := {}
Local aAux   := {}
Local cQuery
Local nCont  := 0

cQuery := "SELECT Z30_REGIAO FROM "+RetSQLName("Z30")
cQuery += " WHERE Z30_CODVEN='"+cVendedor+"'"

If Select('TRB') > 0
	dbSelectArea('TRB')
	dbCloseArea()
EndIf

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

DbSelectArea("TRB")

While !EOF()
	aAux := Strtokarr(Alltrim(TRB->Z30_REGIAO),"/")
	For nCont := 1 to len(aAux)
		Aadd(aArray,aAux[nCont])
	Next nCont
	Dbskip()
EndDo
	
Return(aArray)

/*/{Protheus.doc} Buscatit
	(long_description)
	@type  Static Function
	@author user
	@since 23/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function Buscatit(cCliente,cLoja)

Local aArea	:=	GetArea()
Local aRet 	:=	{}
Local cQuery 

cQuery := "SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VENCREA,E1_VALOR"
cQuery += " FROM "+RetSQLName("SE1")+" E1"
cQuery += " WHERE E1_FILIAL BETWEEN ' ' AND 'ZZ'"
cQuery += " AND E1_CLIENTE='"+cCliente+"' AND E1_LOJA='"+cLoja+"' AND E1_SALDO>0 AND D_E_L_E_T_=' '"

If Select('TRB') > 0
	dbSelectArea('TRB')
	dbCloseArea()
EndIf

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

DbSelectArea("TRB")

While !EOF()
	Aadd(aRet,{	TRB->E1_PREFIXO,TRB->E1_NUM,TRB->E1_PARCELA,;
				TRB->E1_TIPO,TRB->E1_EMISSAO,TRB->E1_VENCREA,TRB->E1_VALOR})
	Dbskip()
EndDo
RestArea(aArea)
	
Return(aRet)
