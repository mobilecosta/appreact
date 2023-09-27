#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL043
Descricao: Servico API Rest Evento Chamados Garantia

@author Felipe Mayer
@since 18/08/2022
@version 1.0

/*/
//-------------------------------------------------------------------
USER Function PRTL043()
Return

WsRestFul PRTL043 DESCRIPTION "API REST - EVENTO CHAMADOS  | PORTAL ROBSOL " 
	
	WsMethod POST Description "API REST - EVENTO CHAMADOS - METODO POST "  WsSyntax "PRTL043"

End WsRestFul

WsMethod POST WsReceive RECEIVE WsService PRTL043

	Local cCode			As Character
	Local cChamado		As Character
	Local cMessage		As Character
	Local cNota			As Character 
	Local cItem			As Character 
	Local cProd			As Character 
	Local cQuant		As Character 
	Local cPreco		As Character 
	Local cEmiss		As Character 
	Local cOpcTr		As Character 
	Local cDescr		As Character
	Local cClie			As Character
	Local cLoja			As Character
	Local cKeyZ50 		As Character 
	Local cTpDefeito	As Character
	Local cDefeito 		As Character
	Local cOutroEnd		As Character
	Local cFilFat		As Character
	Local lRet			As Logical 

	conout("chegou aqui PRTL043")

	oBody  := JsonObject():New()

	If ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 	 := "#500"
		cMessage := "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet	 := .F.

		SetRestFault(400,cMessage)
	Else
		cCode  := "#200"
		cMessage := "Conexao realizada com sucesso"
		lRet   := .T.
		cFilFat:= oBody:getJsonText("Filial_faturamento")
		cNota  := oBody:getJsonText("nota")
		cItem  := oBody:getJsonText("item")
		cProd  := oBody:getJsonText("cod_produto")
		cQuant := oBody:getJsonText("quantidade")
		cPreco := oBody:getJsonText("preco")
		cEmiss := oBody:getJsonText("emissao")
		cOpcTr := oBody:getJsonText("opcTroca")
		cDescr := oBody:getJsonText("descricao")
		cClie  := oBody:getJsonText("cliente")
		cLoja  := oBody:getJsonText("lojacli")
		cDefeito    := oBody:getJsonText("defeito")
		cTpDefeito  := oBody:getJsonText("tipodefeito")
		cOutroEnd	:= oBody:getJsonText("another_address")
		
		RPCSetType(3)
		RpcSetEnv('01','0101',,,,GetEnvServer(),{ })

		DbSelectArea('Z50')
		DbSetOrder(1)

		cKeyZ50  := xFilial('Z50');
			+AvKey(cNota,'Z50_NOTA');
			+AvKey(cClie,'Z50_CODCLI');
			+AvKey(cLoja,'Z50_LOJCLI');
			+AvKey(DToS(CToD(cEmiss)),'Z50_EMISSA');
			+AvKey(cProd,'Z50_PROD');
		
		cChamado := GetSXEnum("Z50","Z50_CODIGO")

		If !Z50->(DbSeek(cKeyZ50))
			RecLock('Z50', .T.)
				Z50->Z50_CODIGO := cChamado
				Z50->Z50_NOTA 	:= fRemoveCarc(cNota)
				Z50->Z50_ITEM 	:= fRemoveCarc(cItem)
				Z50->Z50_PROD 	:= fRemoveCarc(cProd)
				Z50->Z50_CODCLI := fRemoveCarc(cClie)
				Z50->Z50_LOJCLI := fRemoveCarc(cLoja)
				Z50->Z50_EMISSA := CToD(cEmiss)
				Z50->Z50_PRECO  := Val(cPreco)
				Z50->Z50_QUANT  := Val(cQuant)
				Z50->Z50_OPCTRC := Iif(Alltrim(Upper(cOpcTr))=='ALL','1','2')
				Z50->Z50_OBS	:= fRemoveCarc(cDescr)
				Z50->Z50_DTCRIA := Date()
				Z50->Z50_HRCRIA := Time()
				Z50->Z50_STATUS := '1'
				Z50->Z50_DEFEIT := cDefeito
				Z50->Z50_TPDEFE := cTpDefeito
				Z50->Z50_OUTEND := fRemoveCarc(cOutroEnd)
				Z50->Z50_FILPED := If(Valtype("cFilFat")=="C",cFilFat,'0101')
				ConfirmSx8()
			Z50->(MsUnlock())
		Else
			RollbackSx8()
			cChamado := ''
		EndIf

		self:setContentType("application/json")
		self:setResponse(fwJsonSerialize(StatReq(cCode,cChamado,cMessage,cNota,cItem,cProd,cQuant,cPreco,cEmiss,cOpcTr,cDescr,cClie,cLoja)))

		RpcClearEnv()
	EndIf


	Freeobj(oBody)

Return lRet



Static Function StatReq(;
	cCode As Character,;
	cChamado As Character,;
	cMessage As Character,;
	cNota As Character,;
	cItem As Character,;
	cProd As Character,;
	cQuant As Character,;
	cPreco As Character,;
	cEmiss As Character,;
	cOpcTr As Character,;
	cDescr As Character,;
	cClie As Character,;
	cLoja As Character;
) As J

	oJsonRet  := JsonObject():New()
	oJsonRet["stsrequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]        := fRemoveCarc(cCode)
	oJsonBody["chamado"] 	 := fRemoveCarc(cChamado)
	oJsonBody["message"] 	 := fRemoveCarc(cMessage)
	oJsonBody["nota"]   	 := fRemoveCarc(cNota)
	oJsonBody["item"]   	 := fRemoveCarc(cItem)
	oJsonBody["cod_produto"] := fRemoveCarc(cProd)
	oJsonBody["quantidade"]  := fRemoveCarc(cQuant)
	oJsonBody["preco"]   	 := fRemoveCarc(cPreco)
	oJsonBody["emissao"]	 := DToS(CToD(cEmiss))
	oJsonBody["opcTroca"]	 := fRemoveCarc(cOpcTr)
	oJsonBody["descricao"]	 := fRemoveCarc(cDescr)
	oJsonBody["cliente"]	 := fRemoveCarc(cClie)
	oJsonBody["lojacli"]	 := fRemoveCarc(cLoja)

	AAdd( oJsonRet["stsrequest"], oJsonBody )

Return oJsonRet


Static Function fRemoveCarc(cWord)

    cWord := OemToAnsi(cWord)
    cWord := FwNoAccent(cWord)
    cWord := FwCutOff(cWord)
    cWord := strtran(cWord,"ã","a")
    cWord := strtran(cWord,"º","")
    cWord := strtran(cWord,"%","")
    cWord := strtran(cWord,"*","")     
    cWord := strtran(cWord,"&","")
    cWord := strtran(cWord,"$","")
    cWord := strtran(cWord,"#","")
    cWord := strtran(cWord,"§","") 
    cWord := strtran(cWord,"ä","a")
    cWord := strtran(cWord,",","")
    cWord := strtran(cWord,".","")
    cWord := StrTran(cWord, "'", "")
    cWord := StrTran(cWord, "#", "")
    cWord := StrTran(cWord, "%", "")
    cWord := StrTran(cWord, "*", "")
    cWord := StrTran(cWord, "&", "E")
    cWord := StrTran(cWord, ">", "")
    cWord := StrTran(cWord, "<", "")
    cWord := StrTran(cWord, "!", "")
    cWord := StrTran(cWord, "@", "")
    cWord := StrTran(cWord, "$", "")
    cWord := StrTran(cWord, "(", "")
    cWord := StrTran(cWord, ")", "")
    cWord := StrTran(cWord, "_", "")
    cWord := StrTran(cWord, "=", "")
    cWord := StrTran(cWord, "+", "")
    cWord := StrTran(cWord, "{", "")
    cWord := StrTran(cWord, "}", "")
    cWord := StrTran(cWord, "[", "")
    cWord := StrTran(cWord, "]", "")
    cWord := StrTran(cWord, "?", "")
    cWord := StrTran(cWord, ".", "")
    cWord := StrTran(cWord, "\", "")
    cWord := StrTran(cWord, "|", "")
    cWord := StrTran(cWord, ":", "")
    cWord := StrTran(cWord, ";", "")
    cWord := StrTran(cWord, '"', '')
    cWord := StrTran(cWord, '°', '')
    cWord := StrTran(cWord, 'ª', '')
    cWord := strtran(cWord,""+'"'+"","")
    cWord := RTrim(cWord)
Return cWord
