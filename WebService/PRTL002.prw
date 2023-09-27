
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL002
Descricao: Serviço API Rest Evento Menus Portal por usuario

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL002()

Return

// Servico.
WsRestFul MenusPrt DESCRIPTION "API REST - EVENTO MENUS | PORTAL ROBSOL " 
	
	WSDATA CODIGOMENU As String 

	//WsMethod POST Description "API REST - EVENTO PRODUTOS - METODO POST "  WsSyntax "PRTL010"
	WsMethod GET Description "Retorna o Menu do usuario" WSSYNTAX "/MenusPrt/{CODIGOMENU}" 

End WsRestFul

//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Servico Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod GET WsReceive CODIGOMENU WsService MenusPrt

	Local cCode 	:= Self:CODIGOMENU
	Local aArea		:= GetArea()
	Local cJson		:= ''
	Local cVirg		:= ""
	Local cCodBkp	:= ""
	Local cQuery 
	Local lAchou	:=	.F.

	lRet					:= .T.
	
	conout("chegou aqui PRTL002")
	
	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	cQuery := "SELECT AI8_CODMNU,AI8_PORTAL,AI8_CODPAI,AI8_TEXTO,AI8_XWSROB,AI8.R_E_C_N_O_ AS RECAI8"
	cQuery += " FROM "+RetSQLName("AI8")+" AI8"
	cQuery += " WHERE AI8_FILIAL BETWEEN ' ' AND 'ZZZ'"
	cQuery += " AND AI8_PORTAL='"+cCode+"'"
	cQuery += " AND AI8.D_E_L_E_T_=' '"
	cQuery += " ORDER BY AI8_CODMNU,AI8_CODPAI"

	If Select('TRB') > 0
		dbSelectArea('TRB')
		dbCloseArea()
	EndIf

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

	DbSelectArea("TRB")

	
	While !EOF()
	//DbSelectArea("AI8")
	//DbsetOrder(1)
	//If Dbseek(xFilial("AI8")+cCode)
		
		If !lAchou	
			cJson += '['
		EndIf 

		lAchou := .T.
		
		//While !EOF() .and. AI8->AI8_PORTAL == cCode

			If Empty(cCodBkp) .OR. (cCodBkp <> TRB->AI8_CODMNU .And. Empty(TRB->AI8_CODPAI))

				If Empty(TRB->AI8_CODPAI) .And. !Empty(cCodBkp)
					cJson += ']'
					cJson += '},'
				EndIf

				cCodBkp := TRB->AI8_CODMNU

				
				cJson += '{'
				cJson += '"label":"'+Alltrim(TRB->AI8_TEXTO)+'",'
				cJson += '"icon":"",'
				cJson += '"shortLabel":"'+Alltrim(TRB->AI8_TEXTO)+'",'
				cJson += '"subItems": ['

				cVirg := ''
				
			Else
				cJson += cVirg + '{"label":"'+Alltrim(TRB->AI8_TEXTO)+'",'
				cJson += '"link":"'+Alltrim(TRB->AI8_XWSROB)+'",'
				cJson += '"id":"'+cvaltochar(TRB->RECAI8)+'"}'  //Recno()
				cVirg := ','
			EndIf

//			Dbskip()
//		EndDo

		
		Dbskip()	
	EndDo 
	
	If lAchou
		cJson += ']'
		cJson += '}'
		cJson += ']'
	else
		cJson += '{ "codigo":"#400",'
		cJson += '"Erro": "Portal nao encontrado",}'
		
	EndIf
	
	conout(cJson)
	::SetResponse(cJson)

RestArea(aArea)
	
Return lRet

