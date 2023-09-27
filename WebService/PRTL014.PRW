#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL014
Descricao: Serviço API Rest Evento Saldos em estoque

@author Alexandre Venâncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL014()
Return

// Servico.
WsRestFul Saldos DESCRIPTION "API REST - EVENTO Saldos | PORTAL ROBSOL " 
	
    WSDATA PRODUTO As String

	WsMethod GET Description "Retorna os saldos em estoque do produto" WSSYNTAX "/Saldos " 

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
WsMethod GET WsReceive PRODUTO WsService Saldos

	
	Local cProd 	:= Self:PRODUTO
	Local aArea		:= GetArea()
	
	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
    conout("chegou aqui PRTL014")
    conout("Produto "+cProd)

    ::SetResponse('{')
    ::SetResponse('"items": [')
    
	DbSelectArea("SB1")
	SB1->(DBSetOrder(1))
    Dbseek(xFilial("SB1")+cProd)
	DbSelectArea("SB2")
	SB2->(DBSetOrder(1))
	If Dbseek(xFilial("SB2")+Avkey(cProd,"B2_COD")+SB1->B1_LOCPAD)

        nSaldo := SB2->B2_QATU-SB2->B2_RESERVA
        If nSaldo - 10 > 0
            nSaldo := nSaldo - 10
        else
            nSaldo := 0
        ENDIF
        
        ::SetResponse('"codigo":"'+SB1->B1_COD+'",')
        ::SetResponse('"assunto":"'+Alltrim(SB1->B1_DESC)+'",')
        ::SetResponse('"saldo":"'+cvaltochar(nSaldo)+'",')
        ::SetResponse('"id":"'+cvaltochar(Recno())+'"')
        ::SetResponse('}')
        
    ELSE
        ::SetResponse('"codigo":"410",')
        ::SetResponse('"descricao":"Produto nao encontrado",')
        ::SetResponse('"saldo":"0",')
        ::SetResponse('"id":"0"')
        ::SetResponse('}')
    ENDIF
    

    ::SetResponse(']')
    ::SetResponse('}')


	RestArea(aArea)

	
Return lRet
