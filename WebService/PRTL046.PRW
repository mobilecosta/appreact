#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"
#include "fileio.ch"
#include "rwmake.ch"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL046
Descricao: Servico API Rest Evento upload de imagem

@author Felipe Mayer
@since 27/09/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL046()
Return

// Servico.
WsRestFul PRTL046 DESCRIPTION "API REST - Upload de Imagens | PORTAL ROBSOL " 
	
	WsMethod POST Description "API REST - Upload de Imagens - METODO POST "  WsSyntax "PRTL046"

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Servico Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Felipe Mayer
@since 27/09/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod POST WsReceive RECEIVE WsService PRTL046

	Local cCode			As Character 
	Local cMessage		As Character
	Local cImage		As Character
	Local cNome			As Character
	Local cChamad		As Character
	Local lRet			As Logical 
	Local oBody			As J 

	cCode	:= ''
	cMessage	:= ''
	lRet	:= .T.

	conout("chegou aqui PRTL046")

	// recupera o body da requisicao
	oBody  := JsonObject():New()

	If ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 		:= "#500"
		cMessage	:= "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet		:= .F.
	Else
		cImage := oBody:getJsonText("IMAGE")
		cNome  := fRemoveCarc(oBody:getJsonText("NIMAGE"))
		cChamad:= "chamado_"+oBody:getJsonText("CHAMADO")+"\"
		
		cImage 	 := SubStr(cImage, At(";base64,", cImage) + Len(';base64,'))

		If !ExistDir("\updchamados\"+cChamad)
			MakeDir("\updchamados\"+cChamad)
		EndIf

		oFWriter := FWFileWriter():New("\updchamados\"+cChamad+cNome, .T.)

		If oFWriter:Create()
			oFWriter:Write(Decode64(cImage))
			oFWriter:Close()
		EndIf

		cCode 	 := "#200"
		cMessage := "Upload de Imagens realizado com sucesso"
		lRet 	 := .T.

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


Static Function fRemoveCarc(cWord)

    cWord := strtran(cWord,"ã","a")
	cWord := strtran(cWord,"á","a")
	cWord := strtran(cWord,"à","a")
	cWord := strtran(cWord,"ä","a")
    cWord := strtran(cWord,"º","")
    cWord := strtran(cWord,"%","")
    cWord := strtran(cWord,"*","")     
    cWord := strtran(cWord,"&","")
    cWord := strtran(cWord,"$","")
    cWord := strtran(cWord,"#","")
    cWord := strtran(cWord,"§","") 
    cWord := strtran(cWord,",","")
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
    cWord := StrTran(cWord, "\", "")
    cWord := StrTran(cWord, "|", "")
    cWord := StrTran(cWord, ":", "")
    cWord := StrTran(cWord, ";", "")
    cWord := StrTran(cWord, '"', '')
    cWord := StrTran(cWord, '°', '')
    cWord := StrTran(cWord, 'ª', '')
    cWord := Alltrim(cWord)
Return cWord
