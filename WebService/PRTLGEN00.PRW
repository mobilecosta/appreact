#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

User Function PRTLG01
Local oRest 
Local oJson     :=  ""

Local aHeader   :=  {}
Local cRetorno  :=  ""

Local cUrlInt	:=	Alltrim(SuperGetmv('TM_AWSURLM',.F.,"https://databus-api.totvs.com.br/v1")) 

Local cPath     :=  Alltrim(SuperGetmv('TM_ENDPCUS',.F.,"/customers"))

oRest := FWRest():New(cUrlInt)

oRest:SetPath(cPath)

aadd(aHeader,'Authorization: Bearer ' + cToken)

oRest:SetPostParams(cJson)

If oRest:Post(aHeader)
    If FWJsonDeserialize(oRest:GetResult(),@oJSon)
        cCustomerId := oJson:customerId
        cRequest    := oJson:action
        cRetorno := cCustomerId+";"+cRequest
    EndIf
else
    cRetorno := "_ERRO_"+Alltrim(oRest:cresult)	
EndIF

Return(cRetorno)

User Function PRTLG02

Local aHeader   :=  {}
Local aRet      :=  {}
Local oRest

cParam := "?CODIGOMENU=000011"
cUrl   := "http://200.98.81.201:40160/rest/"
cMetodo:= "MenusPrt/"

RpcSetType(3)
RPCSetEnv("01","0101")

//Monta objeto para consumo
oRest := FWREST():New(cUrl + cMetodo)

//Seta parametros
oRest:SetPath(cParam)

lRet := oRest:Get(aHeader)

//Verifico se existe conteudo de retorno
If oRest:GetResult() == Nil
    aRet[1] := .F.
    aRet[2] := "Falha na conexão com a URL."
Else
    cResult := oRest:GetResult()

    If DecodeUtf8(cResult) <> Nil
        cResult := DecodeUtf8(cResult)
    EndIf
    
EndIf

//Caso tenha sucesso
If lRet
    If lObjJson
        aJsonfields := {}
        lRet := FWJsonDeserialize(cResult,@oJson)
        If ! lRet
            aRet[1] := .F.
        Else
            aRet[2] := oJson
            aRet[1] := .T.
            aRet[3] := cResult
        Endif 
    Else
        oJSon := TJSonParser():New()
        oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )
        aRet[2] := aJSonField
        aRet[1] := .T.
        aRet[3] := cResult
    EndIf 

Else
    aRet[1] := .F.
    aRet[2] := oRest:GetLastError()
    aRet[3] := cResult
EndIf

RETURN
