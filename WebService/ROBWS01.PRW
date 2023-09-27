#INCLUDE "RPTDEF.CH"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} ROBWS01
Efetua a consuta de fretes na API da Braspress.
@author AVSI Pro
@since 23/11/2021
@version 1
@param clUserID, C , Usuário da API
@param clPassword, C , Senha da API 
@return aRet , A , Array com o modelo a gravar 
@example
(examples)
@see (links_or_references)
/*/
User Function ROBWS01(cJson)

Local aHeader   :=  {}
Local cRetorno  :=  ""
Local oJson     := JsonObject():New()  

Local cUrlInt	:=	Alltrim(SuperGetmv('TI_APIBRAS',.F.,"https://hml-api.braspress.com")) 
//homologação - https://hml-api.braspress.com/
//produção - https://api.braspress.com/

Local cPath     :=  Alltrim(SuperGetmv('TI_ENDPBRA',.F.,"/v1/cotacao/calcular/json"))
Local cUsrId    :=  Alltrim(SuperGetmv('TI_USRBRAS',.F.,"ROBSOL_PRD:yb#Q8SIw%PriW%#8"))

Local nTimeOut := 120
Local cHeadRet := ""

/*
homologação
CNPJ: 23824405000140
USUARIO: ROBSOL_HML
SENHA: z%rOB&2q5M6A&P%%
BASE64: Uk9CU09MX0hNTDp6JXJPQiYycTVNNkEmUCUl

produção
CNPJ: 23824405000140
USUARIO: ROBSOL_PRD
SENHA: yb#Q8SIw%PriW%#8
BASE64: Uk9CU09MX1BSRDp5YiNROFNJdyVQcmlXJSM4

homologação
CNPJ: 23824405000220
USUARIO: ROBSOL0220_HML
SENHA: m&%vkS9z4I8%m1eM
BASE64: Uk9CU09MMDIyMF9ITUw6bSYldmtTOXo0STglbTFlTQ==

produção
CNPJ: 23824405000220
USUARIO: ROBSOL0220_PRD
SENHA: DdWrFHB8XW
BASE64: Uk9CU09MMDIyMF9QUkQ6RGRXckZIQjhYVw==
*/

aadd(aHeader,'Content-Type: application/json')
aadd(aHeader,'Authorization: Basic ' + Encode64(cUsrId))


sPostRet := HttpPost(cUrlInt+cPath,"",cJson,nTimeOut,aHeader,@cHeadRet)
if !empty(sPostRet) .And. !'<statusCode>500' $ sPostRet .AND. !'"statusCode":500' $ sPostRet .AND. !"502 Bad Gateway" $ sPostRet .And. !"403" $ sPostRet
    //ret := oJson:FromJson(sPostRet)
    FWJsonDeserialize(sPostRet,@oJson)
    cRetorno := cvaltochar(oJson:ID) + ";" + cvaltochar(oJson:PRAZO) + ";" + cvaltochar(oJson:TOTALFRETE)
else
    cRetorno := "1;ERRO_TENTAR_NOVAMENTE;0"
endif

Return(cRetorno)
