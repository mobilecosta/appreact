#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL041
Descricao: Serviço API Rest Evento Catalogos

@author Alexandre Venâncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL041()
Return

// Servico.
WsRestFul Catalogs DESCRIPTION "API REST - EVENTO CATALOGOS | PORTAL ROBSOL " 
	
    WSDATA CLIENTE As String

	WsMethod GET Description "Retorna os catalogos disponiveis para visualizacao" WSSYNTAX "/catalogs " 

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
WsMethod GET WsReceive CLIENTE WsService Catalogs

	
	Local cCliente 	:= Self:CLIENTE
	Local aArea		:= GetArea()
	Local nCont		:= 0
	Local cVirg		:= ""
	Local aAux		:= {}
    Local cPage     := '1'
    Local cPathc    := '' 


	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
    cPathc := GETMV("TI_PATHCAT",.F.,"C:\TOTVS\PROTHEUS_DATA")
    
	conout("chegou aqui PRTL041")

	DbSelectArea("Z41")
	Z41->(DBSetOrder(1))
	Z41->(DBGoTOP())

    ::SetResponse('{')
    ::SetResponse('"items": [')
    
    cQuery := "SELECT TOP(100) * 
    cQuery += " FROM(
    cQuery += "	SELECT TOP("+If(!Empty(cPage),cvaltochar(val(cPage)*100),'100')+")"

    cQuery += " Z41_CODIGO,Z41_DESCRI,Z41_ARQUIV"
    cQuery += " FROM "+RetSQLName("Z41")+ " Z41"
    
    cQuery += " WHERE Z41.D_E_L_E_T_=' ' AND Z41_DATAIN<='"+dtos(ddatabase)+"'"
    
    cQuery += " AND (Z41_DATAFI>='"+dtos(ddatabase)+"' OR Z41_DATAFI=' ')"
    
    cQuery += "		ORDER BY Z41_CODIGO ) TMP"
    
    cQuery += " ORDER BY Z41_CODIGO DESC"

    conout(cQuery)

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
        Aadd(aAux,{	TRB->Z41_CODIGO,TRB->Z41_DESCRI,;
                    TRB->Z41_ARQUIV})
        Dbskip()
    ENDDO

    Asort(aAux,,,{|x,y| x[1] < y[1]})

    For nCont := 1 to len(aAux)
        conout(aAux[nCont,01])
        ::SetResponse(cVirg+'{')
        ::SetResponse('"codigo":"'+aAux[nCont,01]+'",')
        ::SetResponse('"descricao":"'+Alltrim(aAux[nCont,02])+'",')
        ::SetResponse('"localizacao":"'+Alltrim(aAux[nCont,03])+'"')
        ::SetResponse('}')
        cVirg := ','
    Next nCont
    

    ::SetResponse(']')
    ::SetResponse('}')


	RestArea(aArea)

	
Return lRet
