#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL015
Descricao: Serviço API Rest Evento Filtros Produtos em estoque

@author Alexandre Venâncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL015()
Return

// Servico.
WsRestFul Filter DESCRIPTION "API REST - EVENTO Filtros Produtos | PORTAL ROBSOL " 
	
    //WSDATA PRODUTO As String

	WsMethod GET Description "Retorna os filtros de produtos disponíveis" WSSYNTAX "/Filter " 

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
WsMethod GET WsReceive PRODUTO WsService Filter

	
	Local aArea		:= GetArea()
	Local cQuery 
    Local cVirg     :=  ''
	Local lRet		:= .F.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
    conout("chegou aqui PRTL015")
    
    ::SetResponse('{')
    ::SetResponse('"items": [')

    cQuery := ""
    cQuery += "SELECT 'Z03#'+RTRIM(X2_NOME) AS TABELA,Z03_CODGRI AS CODIGO,Z03_DESGRI AS DESCRICAO"
    cQuery += "  FROM Z03010 Z03"
    cQuery += "  INNER JOIN SX2010 X2 ON X2_CHAVE='Z03' AND X2.D_E_L_E_T_=' '"
    cQuery += "  WHERE Z03.D_E_L_E_T_=' ' AND Z03_MSBLQL<>'1'"
    cQuery += " UNION"
    cQuery += " SELECT 'Z04#'+RTRIM(X2_NOME) AS TABELA,Z04_CODGEN AS CODIGO,Z04_DESGEN AS DESCRICAO"
    cQuery += "  FROM Z04010 Z04"
    cQuery += "  INNER JOIN SX2010 X2 ON X2_CHAVE='Z04' AND X2.D_E_L_E_T_=' '"
    cQuery += "  WHERE Z04.D_E_L_E_T_=' ' AND Z04_MSBLQL<>'1'"
    cQuery += " UNION"
    cQuery += " SELECT 'Z05#'+X2_NOME AS TABELA,Z05_CODLIN AS CODIGO,Z05_DESLIN AS DESCRICAO"
    cQuery += "  FROM Z05010 Z05"
    cQuery += "  INNER JOIN SX2010 X2 ON X2_CHAVE='Z05' AND X2.D_E_L_E_T_=' '"
    cQuery += "  WHERE Z05.D_E_L_E_T_=' ' AND Z05_MSBLQL<>'1'"
    cQuery += " UNION"
    cQuery += " SELECT 'Z06#'+X2_NOME AS TABELA,Z06_CODMAT AS CODIGO,Z06_DESMAT AS DESCRICAO"
    cQuery += "  FROM Z06010 Z06"
    cQuery += "  INNER JOIN SX2010 X2 ON X2_CHAVE='Z06' AND X2.D_E_L_E_T_=' '"
    cQuery += "  WHERE Z06.D_E_L_E_T_=' ' AND Z06_MSBLQL<>'1'"
    cQuery += " UNION"
    cQuery += " SELECT 'Z07#'+X2_NOME AS TABELA,Z07_CDOCOR AS CODIGO,Z07_DESCOR AS DESCRICAO"
    cQuery += "  FROM Z07010 Z07"
    cQuery += "  INNER JOIN SX2010 X2 ON X2_CHAVE='Z07' AND X2.D_E_L_E_T_=' '"
    cQuery += "  WHERE Z07.D_E_L_E_T_=' ' AND Z07_MSBLQL<>'1'"
    cQuery += " SELECT 'Z09#'+X2_NOME AS TABELA,Z09_CODFOR AS CODIGO,Z09_DESFOR AS DESCRICAO"
    cQuery += "  FROM Z09010 Z09"
    cQuery += "  INNER JOIN SX2010 X2 ON X2_CHAVE='Z09' AND X2.D_E_L_E_T_=' '"
    cQuery += "  WHERE Z09.D_E_L_E_T_=' ' AND Z09_MSBLQL<>'1'"

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
	    lRet := .T.
        ::SetResponse(cVirg+'{')
        ::SetResponse('"tabela":"'+Alltrim(TRB->TABELA)+'",')
        ::SetResponse('"codigo":"'+Alltrim(TRB->CODIGO)+'",')
        ::SetResponse('"descricao":"'+strtran(strtran(upper(Alltrim(TRB->DESCRICAO)),"Ç","C"),"Ã","A")+'"')
        ::SetResponse('}')
        cVirg := ','
        Dbskip()
    ENDDO

    If !lret
        ::SetResponse('"codigo":"410",')
        ::SetResponse('"descricao":"Produto nao encontrado",')
        ::SetResponse('"saldo":"0"')
        ::SetResponse('}')
    ENDIF
    

    ::SetResponse(']')
    ::SetResponse('}')


	RestArea(aArea)

	
Return lRet
