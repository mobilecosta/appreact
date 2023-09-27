#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL044
Descricao: Servico API Rest Evento Envia Chamados
@author Felipe Mayer
@since 22/08/2022
@version 1.0

/*/
//-------------------------------------------------------------------
USER Function PRTL044()
Return

WsRestFul EnvChamdo DESCRIPTION "API REST - EVENTO Envia Chamados | PORTAL ROBSOL " 
	
    WSDATA COD_CLIENTE As String
	WSDATA LOJA_CLIENTE As String

	WsMethod GET Description "Retorna os chamados do cliente" WSSYNTAX "/EnvChamdo " 

End WsRestFul


WsRestFul UpdChamdo DESCRIPTION "API REST - EVENTO Envia Chamados | PORTAL ROBSOL " 

	WsMethod POST Description "Interacao no chamado "  WsSyntax "/UpdChamdo"

End WsRestFul

WsRestFul chamadoNotific DESCRIPTION "API REST - EVENTO Notifica Chamados | PORTAL ROBSOL " 

	WsMethod POST Description "Notifica Chamados"  WsSyntax "/chamadoNotific"

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento ImplantaÃ§Ã£o 
Descricao: 	Servico Rest contendo o Metodo POST do evento de Envia Chamados
@author Felipe Mayer
@since 22/08/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod GET WsReceive COD_CLIENTE,LOJA_CLIENTE WsService EnvChamdo

    Local cCliente 	:= Self:COD_CLIENTE
	Local cLojCli 	:= Self:LOJA_CLIENTE
	Local aArea		:= GetArea()
	Local cVirg		:= ''

	::SetContentType("application/json charset=iso-8859-1")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	conout("chegou aqui PRTL044")

	::SetResponse('{')
	::SetResponse('"items": [')

	cQuery := " SELECT * FROM "+RetSQLName("Z50")+" "
	cQuery += " WHERE Z50_CODCLI='"+cCliente+"' AND Z50_LOJCLI='"+cLojCli+"'"
	cQuery += " AND D_E_L_E_T_=' '"
	
	conout(cQuery)

	If Select('TRB') > 0
		dbSelectArea('TRB')
		dbCloseArea()
	EndIf

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

	DbSelectArea("TRB")

	While !EoF()
		::SetResponse(cVirg+'{')
		::SetResponse('"chamado":"' +AllTrim(TRB->Z50_CODIGO)+'",')
		::SetResponse('"nota":"' +AllTrim(TRB->Z50_NOTA)+'",')
		::SetResponse('"item":"'+AllTrim(TRB->Z50_ITEM)+'",')
		::SetResponse('"emissao":"'+cvaltochar(stod(TRB->Z50_EMISSA))+'",')
		::SetResponse('"produto":"'+AllTrim(TRB->Z50_PROD)+'",')
		::SetResponse('"descricao":"'+AllTrim(Posicione("SB1",1,xFilial("SB1")+TRB->Z50_PROD,"B1_DESC"))+'",')
		::SetResponse('"quantidade":"'+Alltrim(cValToChar(TRB->Z50_QUANT))+'",')
		::SetResponse('"defeito":"'+fComboDefeito(1,TRB->Z50_DEFEIT)+'",')
		::SetResponse('"tipodefeito":"'+fComboDefeito(2,TRB->Z50_TPDEFE)+'",')
		::SetResponse('"preco":"'+Alltrim(transform(TRB->Z50_PRECO,"@E 999,999,999.99"))+'",')
		::SetResponse('"pedido":"'+AllTrim(TRB->Z50_PEDVEN)+'",')

		Z50->(DbSetOrder(1))
		If Z50->(DbSeek(xFilial('Z50')+TRB->Z50_NOTA+TRB->Z50_CODCLI+TRB->Z50_LOJCLI+TRB->Z50_EMISSA+TRB->Z50_PROD))
			::SetResponse('"obsatend":"'+fRemoveCarc(StrTran(Z50->Z50_OBSATD,CRLF,'\r\n'))+'",')
		EndIf

		SC5->(DbSetOrder(3))
		If SC5->(DbSeek(xFilial('SC5');
			+AvKey(TRB->Z50_CODCLI,'C5_CLIENTE');
			+AvKey(TRB->Z50_LOJCLI,'C5_LOJACLI');
			+AvKey(TRB->Z50_PEDVEN,'C5_NUM')))

			cRast := Iif(!Empty(Alltrim(SC5->C5_XETIQUE)),'"'+Alltrim(SC5->C5_XETIQUE)+'"','" "')

			::SetResponse('"rastreio":'+cRast+',')
		Else
			::SetResponse('"rastreio":" ",')
		EndIf

		oFile := FWFileReader():New('\updchamados\chamado_'+AllTrim(TRB->Z50_CODIGO)+'\notification.txt')

		cNotif := 'visualizou'

		If (oFile:Open())
			If !(oFile:EoF())
				cNotif := oFile:FullRead()
			EndIf
			
			oFile:Close()
		EndIf

		::SetResponse('"notification":"'+AllTrim(cNotif)+'",')
		::SetResponse('"status":"'+AllTrim(TRB->Z50_STATUS)+'"')
		::SetResponse('}')

		cVirg := ','
		Dbskip()
	EndDo
	
	::SetResponse(']')
	::SetResponse('}')

	RestArea(aArea)
	
Return .T.



WsMethod POST WsReceive RECEIVE WsService UpdChamdo

	Local cCode			As Character 
	Local cMessage		As Character
	Local cResponse		As Character
	Local lRet			As Logical 
	Local oBody			As J 

	cCode	:= ''
	cMessage	:= ''
	lRet	:= .T.

	conout("chegou aqui UpdChamdo")

	// recupera o body da requisicao
	oBody  := JsonObject():New()

	If ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 		:= "#500"
		cMessage	:= "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet		:= .F.
	Else
		cResponse := oBody:getJsonText("TEXT")
		cUsuario  := oBody:getJsonText("USUARIO")

		If !Empty(cResponse)

			RpcSetType(3)
			RPCSetEnv("01","0101")

			cEmissao := oBody:getJsonText("EMISSAO")
			cEmissao := '20'+SubsTr(cEmissao,7,2)+SubsTr(cEmissao,4,2)+SubsTr(cEmissao,1,2)

			cZ50Ind := xFilial('Z50');
				+AvKey(oBody:getJsonText("NOTA"),'Z50_NOTA');
				+AvKey(oBody:getJsonText("CLIENTE"),'Z50_CODCLI');
				+AvKey(oBody:getJsonText("LOJA"),'Z50_LOJCLI');
				+AvKey(cEmissao,'Z50_EMISSA');
				+AvKey(oBody:getJsonText("PRODUTO"),'Z50_PROD')

			Z50->(DbSetOrder(1))
			If Z50->(DbSeek(cZ50Ind))
				cObsOld := Alltrim(Z50->Z50_OBSATD)+CRLF+'-------------'

				cMsgGrv := 'Data '+cvaltochar(Date())+' Hora '+cvaltochar(time())+CRLF
				cMsgGrv += 'Usuário '+cUsuario+CRLF 
				cMsgGrv += 'Observações anotadas '+cResponse

				RecLock('Z50', .F.)
					Z50->Z50_OBSATD := cObsOld + CRLF + Alltrim(cMsgGrv)
				Z50->(MsUnlock())

				cCode 	 := "#200"
				cMessage := "Interacao realizada com sucesso!"
				lRet 	 := .T.

			Else
				cCode 	 := "#500"
				cMessage := "Erro ao consultar indice Z50 "+cZ50Ind
				lRet 	 := .F.
			EndIf

		Else
			cCode 	 := "#500"
			cMessage := "Necessario descrever interacao!"
			lRet 	 := .F.
		EndIf

	EndIf

	//-> Mensagem de Retorno da requisicao
	self:setContentType("application/json")
	self:setResponse(fwJsonSerialize(StatReq(cCode,cMessage)))

	// Realiza o fechamento do Ambiente
	RpcClearEnv()
	Freeobj(oBody)

Return lRet



WsMethod POST WsReceive RECEIVE WsService chamadoNotific

	Local cCode			As Character 
	Local cMessage		As Character
	Local cChamado		As Character
	Local lRet			As Logical 
	Local oBody			As J 

	cCode		:= ''
	cMessage	:= ''
	lRet		:= .T.

	conout("chegou aqui chamadoNotific")

	// recupera o body da requisicao
	oBody  := JsonObject():New()

	If ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 		:= "#500"
		cMessage	:= "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet		:= .F.
	Else
		cChamado := oBody:getJsonText("CHAMADO")

		If !Empty(cChamado)
			cCode 	 := "#200"
			lRet 	 := .T.

			cMessage := 'visualizou'
			nHandle	 := FCREATE('\updchamados\chamado_'+Alltrim(cChamado)+'\notification.txt')

			If nHandle = -1
				conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			Else
				FWrite(nHandle, 'visualizou')
				FClose(nHandle)
			EndIf
			
		Else
			cCode 	 := "#500"
			lRet 	 := .F.
		EndIf

	EndIf

	//-> Mensagem de Retorno da requisicao
	self:setContentType("application/json")
	self:setResponse(fwJsonSerialize(StatReq(cCode,cMessage)))

	// Realiza o fechamento do Ambiente
	RpcClearEnv()
	Freeobj(oBody)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} StatReq
Descricao: 	Realiza o Tratamento para envio de Mensagem de Retorno 
				da API 

@author Felipe Mayer
@since 27/09/2022
@version 1.0

@Param: 
	cCode 	= 	Codigo do Erro que sera informado no Retorno da API
	cMessage	= 	Mensagem de Retorno que sera informado no Retorno 
					da API

/*/
//-------------------------------------------------------------------
Static Function StatReq(cCode As Character, cMessage As Character) As J

	Local oJsonBody	As J
	Local oJsonRet 	As J

	Default cCode		:= ''
	Default cMessage	:= ''

	//Cria o Objeto de Retono da RequisiÃ§Ã£o.
	oJsonRet  := JsonObject():New()
	oJsonRet["statusrequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]      := cCode
	oJsonBody["message"]   := cMessage

	AAdd( oJsonRet["statusrequest"], oJsonBody )

Return oJsonRet



Static Function fComboDefeito(nTipo,cProp)

Local cRet := ''

// 1-Defeito / 2-Tipo Defeito
If nTipo == 1
	If cProp == '1'
		cRet := 'Frontal'
	ElseIf cProp == '2'
		cRet := 'Hastes'
	ElseIf cProp == '3'
		cRet := 'Charneiras'
	ElseIf cProp == '4'
		cRet := 'Lentes'
	EndIf
Else
	If cProp == 'A'
		cRet := 'DESCASCANDO'
	ElseIf cProp == 'B'
		cRet := 'TRINCADO'
	ElseIf cProp == 'C'
		cRet := 'OXIDAÇÃO'
	ElseIf cProp == 'D'
		cRet := 'RISCADA'
	ElseIf cProp == 'E'
		cRet := 'QUEBRADA'
	ElseIf cProp == 'F'
		cRet := 'QUEBRADA NA SOLDA'
	ElseIf cProp == 'G'
		cRet := 'SOLTA'
	ElseIf cProp == 'H'
		cRet := 'PARAFUSO ESPANADO'
	ElseIf cProp == 'I'
		cRet := 'DEFEITO NA PONTEIRA'
	ElseIf cProp == 'J'
		cRet := 'TONALIDADES DIFERENTES'
	ElseIf cProp == 'L'
		cRet := 'MANCHADA'
	ElseIf cProp == 'M'
		cRet := 'DEFEITO NA MOLA'
	ElseIf cProp == 'N'
		cRet := 'SUPORTE DE PLAQUETAS'
	EndIf
EndIf


Return cRet



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
    cWord := StrTran(cWord, "+", "")
    cWord := StrTran(cWord, "{", "")
    cWord := StrTran(cWord, "}", "")
    cWord := StrTran(cWord, "[", "")
    cWord := StrTran(cWord, "]", "")
    cWord := StrTran(cWord, ".", "")
    cWord := StrTran(cWord, "|", "")
    cWord := StrTran(cWord, ";", "")
    cWord := StrTran(cWord, '"', '')
    cWord := StrTran(cWord, '°', '')
    cWord := StrTran(cWord, 'ª', '')
    cWord := strtran(cWord,""+'"'+"","")
    cWord := RTrim(cWord)
Return cWord
