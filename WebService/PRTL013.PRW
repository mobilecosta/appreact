#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL013
Descricao: Servico API Rest Evento Condicoes de Pagamento

@author Alexandre Venancio
@since 04/02/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL013()
Return

// Servico.
WsRestFul CondPgto DESCRIPTION "API REST - EVENTO Condicoes de Pagamento | PORTAL ROBSOL " 
	
    WSDATA VENDEDOR As String

	WsMethod GET Description "Retorna os Condicoes de Pagamento disponiveis para visualizacao" WSSYNTAX "/CondPgto " 

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Servico Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 04/02/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod GET WsReceive VENDEDOR WsService CondPgto

	
	Local cVENDEDOR := Self:VENDEDOR
	Local aArea		:= GetArea()
	Local nCont		:= 0
	Local cVirg		:= ""
	Local aAux		:= {}
    

	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
    conout("chegou aqui PRTL013")

	::SetResponse('{')
    ::SetResponse('"items": [')
    
    cQuery := "	SELECT "

    cQuery += " E4_CODIGO,E4_DESCRI,E4_COND,R_E_C_N_O_ AS RECE4"
    
    cQuery += " FROM "+RetSQLName("SE4")+ " SE4"
    
    cQuery += " WHERE SE4.D_E_L_E_T_=' ' AND E4_TIPO='1' AND E4_MSBLQL<>'1'"
    
    cQuery += " ORDER BY E4_CODIGO"

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
        Aadd(aAux,{TRB->E4_CODIGO,TRB->E4_DESCRI,TRB->E4_COND,TRB->RECE4})
        Dbskip()
    ENDDO

    Asort(aAux,,,{|x,y| x[1] < y[1]})

    For nCont := 1 to len(aAux)
        ::SetResponse(cVirg+'{')
        ::SetResponse('"codigo":"'+aAux[nCont,01]+'",')
        ::SetResponse('"descricao":"'+Alltrim(aAux[nCont,02])+'",')
        ::SetResponse('"forma":"'+Alltrim(aAux[nCont,03])+'",')
        ::SetResponse('"id":"'+cvaltochar(aAux[nCont,04])+'"')
        ::SetResponse('}')
        cVirg := ','
    Next nCont
    

    ::SetResponse(']')
    ::SetResponse('}')


	RestArea(aArea)

	
Return lRet
