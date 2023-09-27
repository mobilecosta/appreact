#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


USER Function PRTL048()
Return

WsRestFul Faturamento DESCRIPTION "API REST - EVENTO TITULOS | PORTAL ROBSOL " 

	WSDATA CODIGO As String
	WSDATA VENDEDOR As String

	WsMethod GET Description "Retorna o Cliente especifico ou cadastro todo" WSSYNTAX "/Faturamento || /Faturamento/{CLIENTE} || /Faturamento/{PAGINA}" 

End WsRestFul


WsMethod GET WsReceive CODIGO,VENDEDOR WsService Faturamento

	Local cCliente 	:= Self:CODIGO
	Local cVendedor := Self:VENDEDOR 
	Local aArea		:= GetArea()
	Local cVirg		:= ""
	Local cPasta  	:= 'C:\TOTVS\protheus_data\clientes\cnpj\'

	::SetContentType("application/json")

	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	conout("chegou aqui PRTL048")
	conout("Cliente "+cvaltochar(cCliente))
	conout("Vendedor "+cvaltochar(cVendedor))
	If Empty(cCliente)
		cCliente := strtran(cVendedor,"?CODIGO=")
		cVendedor := ''
	EndIf 

	DbSelectArea("SE1")
	SE1->(DBSetOrder(1))
	SE1->(DBGoTOP())

	::SetResponse('{')
	::SetResponse('"items": [')
	
	If !empty(cVendedor) .or. !empty(cCliente)
		cQuery := " SELECT DISTINCT SF2.R_E_C_N_O_ RECF2,SF2.*,SC5.*  "
		cQuery += " FROM " + RetSQLName("SF2") + " SF2 "
		cQuery += " INNER JOIN "+RetSQLName("SD2")+" SD2 ON D2_FILIAL=F2_FILIAL AND D2_DOC=F2_DOC"
		cQuery += "  AND D2_SERIE=F2_SERIE AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA=F2_LOJA AND SD2.D_E_L_E_T_=' '"
		cQuery += " INNER JOIN "+RetSQLName("SC6")+" SC6 ON C6_FILIAL=D2_FILIAL AND C6_NUM=D2_PEDIDO"
		cQuery += "  AND C6_ITEM=D2_ITEMPV AND SC6.D_E_L_E_T_=' '"
		cQuery += " INNER JOIN " + RetSQLName("SC5") + " SC5   " 
		cQuery += " 	ON C5_FILIAL = C6_FILIAL  " 
		cQuery += " 	AND C5_CLIENTE = C6_CLI  " 
		cQuery += " 	AND C5_LOJACLI = C6_LOJA  " 
		cQuery += " 	AND C5_NUM = C6_NUM "
		cQuery += " 	AND SC5.D_E_L_E_T_=''  " 
		cQuery += " WHERE SF2.D_E_L_E_T_=' '  "
		cQuery += " AND F2_FILIAL BETWEEN ' ' AND 'ZZ' AND F2_DOC BETWEEN ' ' AND 'ZZ' AND F2_SERIE BETWEEN ' ' AND 'ZZ'"

		If !Empty(cCliente)
			cQuery += " 	AND F2_CLIENTE = '"+cvaltochar(cCliente)+"'  "
		EndIf

		If !Empty(cVendedor)
			cQuery += " 	AND C5_VEND1 = '"+cVendedor+"'  "
		EndIf

		conout(cQuery)
		
		If Select('TRB') > 0
			dbSelectArea('TRB')
			dbCloseArea()
		EndIf

		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )
		DbSelectArea("TRB")

		While !EoF()

			cPathweb := 'http://portal.robsol.com.br/'+Alltrim(Posicione('SA1',1,xFilial('SA1')+TRB->F2_CLIENTE+TRB->F2_LOJA,'A1_CGC'))+'/'
			::SetResponse(cVirg+'{')

			If File(cPasta+Alltrim(Posicione('SA1',1,xFilial('SA1')+TRB->F2_CLIENTE+TRB->F2_LOJA,'A1_CGC'))+"\"+Alltrim(TRB->F2_DOC)+".PDF")
				::SetResponse('"boleto_gerado":"S",')
			else
				::SetResponse('"boleto_gerado":"N",')
			EndIf

			If ValType(TRB->F2_EMISSAO) == 'D'
				cEmissao := DToC(TRB->F2_EMISSAO)
			Else
				cEmissao := DToC(SToD(TRB->F2_EMISSAO))
			EndIf

			::SetResponse('"filial":"'+Alltrim(TRB->F2_FILIAL)+'",')
			::SetResponse('"documento":"'+Alltrim(TRB->F2_DOC)+'",')
			::SetResponse('"serie":"'+Alltrim(TRB->F2_SERIE)+'",')
			::SetResponse('"cliente":"'+Alltrim(Posicione('SA1',1,xFilial('SA1')+TRB->F2_CLIENTE+TRB->F2_LOJA,'A1_NREDUZ'))+'",')
			::SetResponse('"emissao":"'+cEmissao+'",')
			::SetResponse('"valor":"'+Transform(TRB->F2_VALBRUT,"@E 999,999,999.99")+'",')
			::SetResponse('"etiqueta":"'+Alltrim(TRB->C5_XETIQUE)+'",')
			::SetResponse('"boleto":"'+cPathweb+'Boleto_'+Alltrim(TRB->F2_DOC)+'.pdf",')
			::SetResponse('"danfe":"'+cPathweb+Alltrim(TRB->F2_DOC)+'.pdf",')
			::SetResponse('"xml":"'+cPathweb+Alltrim(TRB->F2_DOC)+'.xml",')

			If !Empty(TRB->C5_XETIQUE)
				::SetResponse('"rastro":"'+fGetRastro(Alltrim(TRB->C5_XETIQUE))+'",')
			EndIf

			::SetResponse('"id":"'+cvaltochar(TRB->RECF2)+'"')
			::SetResponse('}')
			cVirg := ','
			

			Dbskip()
		EndDo
	Endif 
	
	::SetResponse(']')
	::SetResponse('}')

	RestArea(aArea)

	
Return .T.


/*/{Protheus.doc} fGetRastro
    @long_description Consulta o rastro
    @type User Function
    @author Felipe Mayer
    @since 13/12/2022
    @version 1
/*/
Static Function fGetRastro(cEtiqueta)

Local aHeader  := {}
Local aResult  := {}
Local aAux     := {}
Local nX       := 0
Local cRastro  := ''
Local oRest    := FWRest():New("https://api.correios.com.br/srorastro/")
Local jJSON    := JsonObject():New()
   
    AAdd(aHeader, "Content-Type: application/json")
    AAdd(aHeader, "Authorization: Bearer "+fGeraToken())

    oRest:setPath("v1/objetos/"+cEtiqueta+"?resultado=T")

    If oRest:Get(aHeader)
        jJSON:fromJSON(oRest:GetResult())

        aAux := jJSON['objetos'][1]['eventos']
        
        If aAux == Nil
            aResult := {}
            cRastro := jJSON['objetos'][1]['mensagem']
        Else
            aResult := aClone(aAux)
            cRastro := ''
        EndIf


		For nX := 1 To Len(aResult)

			If aResult[nX]['unidade'] != nil
				cRastro += aResult[nX]['descricao']+'\r\n'+'\r\n'
				cRastro += 'de: ' + aResult[nX]['unidade']['tipo']+','
				cRastro += aResult[nX]['unidade']['endereco']['cidade'] + ' - '+ aResult[nX]['unidade']['endereco']['uf']+'\r\n'
			EndIf

			If aResult[nX]['unidadeDestino'] != nil
				cRastro += 'para: ' + aResult[nX]['unidadeDestino']['tipo']+','
				cRastro += aResult[nX]['unidadeDestino']['endereco']['cidade'] + ' - '+ aResult[nX]['unidadeDestino']['endereco']['uf']+'\r\n'
			EndIf

			If nX < Len(aResult)
				cRastro += '\r\n'+'\r\n'+'\r\n'
			EndIf
		Next nX
	EndIf

	cRastro := fRemoveCarc(cRastro)

Return cRastro


/*/{Protheus.doc} fGeraToken
    @long_description Gera o Token para consulta do rastro
    @type User Function
    @author Felipe Mayer
    @since 13/12/2022
    @version 1
/*/
Static Function fGeraToken()

Local cURI      := "https://api.correios.com.br/token"           // URI DO SERVIÇO REST
Local cResource := "/v1/autentica/cartaopostagem"                // RECURSO A SER CONSUMIDO
Local oRest     := FwRest():New(cURI)                            // CLIENTE PARA CONSUMO REST
Local aHeader   := {}                                            // CABEÇALHO DA REQUISIÇÃO
Local bObject   := {|| JsonObject():New()}
Local oJson     := Eval(bObject)
Local jJSON     := JsonObject():New()
Local cToken    := ''

    AAdd(aHeader, "Content-Type: application/json")
    AAdd(aHeader, "Authorization: Basic cm9ic29sODg4OnJvYnNvbDEyMw==")

    oJson["numero"] := StrTokArr(SuperGetMV("TI_CONTCOR",.F.,"9912446282/0077203780"),'/')[2]

    oRest:SetPath(cResource)
    oRest:SetPostParams(oJson:ToJson())

    If (oRest:Post(aHeader))
        jJSON:fromJSON(oRest:GetResult())
        cToken := jJSON['token']
    Else
        ConOut("POST Error: " + oRest:GetLastError())
    EndIf

Return cToken



Static Function fRemoveCarc(cWord)

    cWord := FwNoAccent(cWord)
    cWord := FwCutOff(cWord)
    cWord := strtran(cWord,"ã","a")
    cWord := strtran(cWord,"º"," ")
    cWord := strtran(cWord,"%"," ")
    cWord := strtran(cWord,"*"," ")     
    cWord := strtran(cWord,"&"," ")
    cWord := strtran(cWord,"$"," ")
    cWord := strtran(cWord,"#"," ")
    cWord := strtran(cWord,"§"," ") 
    cWord := strtran(cWord,"ä","a")
    cWord := strtran(cWord,","," ")
    cWord := strtran(cWord,"."," ")
    cWord := StrTran(cWord, "'", " ")
    cWord := StrTran(cWord, "#", " ")
    cWord := StrTran(cWord, "%", " ")
    cWord := StrTran(cWord, "*", " ")
    cWord := StrTran(cWord, "&", "E")
    cWord := StrTran(cWord, "!", " ")
    cWord := StrTran(cWord, "@", " ")
    cWord := StrTran(cWord, "$", " ")
    cWord := StrTran(cWord, "(", " ")
    cWord := StrTran(cWord, ")", " ")
    cWord := StrTran(cWord, "_", " ")
    cWord := StrTran(cWord, "+", " ")
    cWord := StrTran(cWord, "{", " ")
    cWord := StrTran(cWord, "}", " ")
    cWord := StrTran(cWord, "[", " ")
    cWord := StrTran(cWord, "]", " ")
    cWord := StrTran(cWord, ".", " ")
    cWord := StrTran(cWord, "|", " ")
    cWord := StrTran(cWord, ";", " ")
    cWord := StrTran(cWord, '"', '')
    cWord := StrTran(cWord, '°', '')
    cWord := StrTran(cWord, 'ª', '')
    cWord := strtran(cWord,""+'"'+""," ")
    cWord := RTrim(cWord)
Return cWord
