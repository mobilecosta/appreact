#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"
#include "fileio.ch"
#include "rwmake.ch"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL047
Descricao: Servico API Rest Evento upload de PDFs

@author Felipe Mayer
@since 27/09/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL047()
Return

// Servico.
WsRestFul PRTL047 DESCRIPTION "API REST - Upload de PDFs | PORTAL ROBSOL " 
	
	WsMethod POST Description "API REST - Upload de PDFs - METODO POST "  WsSyntax "PRTL047"

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
WsMethod POST WsReceive RECEIVE WsService PRTL047

	Local cCode			As Character 
	Local cMessage		As Character
	Local cCode64		As Character
	Local cNome			As Character
	Local cPedido		As Character
	Local cEmail		As Character
	Local cEmp			As Character
	Local cFil			As Character
	Local cGeraNov		As Character
	Local lRet			As Logical 
	Local oBody			As J

	cCode	:= ''
	cMessage	:= ''
	lRet	:= .T.

	conout("chegou aqui PRTL047")

	oBody  := JsonObject():New()

	If ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 		:= "#500"
		cMessage	:= "Formato Json nao reco`nhecido. Revisar a estrutura e layout informado."
		lRet		:= .F.
	Else
		cEmp := '01'
		cFil := '0103'

		cCode64 := oBody:getJsonText("CODE64")
		cNome	:= cFil+oBody:getJsonText("NOME")
		cPedido := oBody:getJsonText("PEDIDO")
		cEmail  := oBody:getJsonText("EMAIL")
		cGeraNov:= oBody:getJsonText("GERANOV")
		cVend	:= oBody:getJsonText("VEND")
		cNVend	:= oBody:getJsonText("NVEND")

		If Alltrim(cGeraNov) == 'S'
			cMessage := fTextoHtml(cPedido,cVend,cNVend)
		Else

			If !ExistDir("\clientes\cnpj\updpdf")
				MakeDir("\clientes\cnpj\updpdf")
			EndIf

			oFWriter := FWFileWriter():New("\clientes\cnpj\updpdf\"+cNome, .T.)

			If oFWriter:Create()
				oFWriter:Write(Decode64(cCode64))
				oFWriter:Close()
			EndIf

			sleep(3000)

			RpcSetType(3)
			RPCSetEnv(cEmp,cFil)

			GERHTML(cPedido,GetSrvProfString("Startpath","")+"clientes\cnpj\updpdf\"+cNome,/*cEmail*/'cnoculos@hotmail.com')

			cMessage := "Enviado e-mail com a copia do pedido"
		EndIf

		cCode 	 := "#200"
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


Static Function GERHTML(cPedido,cArq,cEmail)

Default cEmail := 'alexandre.venancio@avsipro.com.br'

Local cHtml 	:= ''
Local cRemete   := "Marketing Robsol <marketing@robsol.com.br>"                               
Local cSubject	:=	"Pedido de Venda"
Local aArquivos := {}           
Local cDestino	:=	cEmail
Local lEnviar	:=	.F.

cHtml := '<h1 style="color: #5e9ca0;">Pedido de Venda Gerado!</h1>'
cHtml += '<h2 style="color: #2e6c80;">Seu pedido foi gerado com sucesso!!!</h2>
cHtml += '<p>Seu pedido foi gerado em nossa base e logo estaremos realizando o atendimento para realiza&ccedil;&atilde;o da entrega das mercadorias.</p>
cHtml += '<h2 style="color: #2e6c80;">Informa&ccedil;&otilde;es do pedido: Pedido numero '+cPedido+'</h2>
cHtml += '<table class="editorDemoTable" style="width: 544px; height: 72px;">
cHtml += '<thead>
cHtml += '<tr style="height: 18px;">
cHtml += '<td style="width: 148.188px; height: 18px;">Produto</td>
cHtml += '<td style="width: 231.95px; height: 18px;">Descri&ccedil;&atilde;o</td>
cHtml += '<td style="width: 60.575px; height: 18px;">Qtd</td>
cHtml += '<td style="width: 77.2875px; height: 18px;">Valor</td>
cHtml += '</tr>
cHtml += '</thead>
cHtml += '<tbody>

DbSelectArea("SC6")
DbSetOrder(1)
If Dbseek(xFilial("SC6")+AvKey(cPedido,"C6_NUM"))
	While !EOF() .And. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cPedido
		cHtml += '<tr style="height: 18px;">
		cHtml += '<td style="width: 148.188px; height: 18px;">'+ALLTRIM(SC6->C6_PRODUTO)+'</td>'
		cHtml += '<td style="width: 231.95px; height: 18px;">'+ALLTRIM(SC6->C6_DESCRI)+'</td>'
		cHtml += '<td style="width: 60.575px; height: 18px;">'+TRANSFORM(SC6->C6_QTDVEN,"@E 9999")+'</td>'
		cHtml += '<td style="width: 77.2875px; height: 18px;">'+TRANSFORM(SC6->C6_PRCVEN,"@E 999,999,999.99")+'</td>'
		cHtml += '</tr>'
		lEnviar := .T.
		Dbskip()
	EndDo
endif

cHtml += '</tbody>
cHtml += '</table>
cHtml += '<p><strong>&nbsp;</strong></p>
cHtml += '<p>&nbsp;</p>'

If lEnviar
	Aadd(aArquivos,{cArq,''})
	U_robmail(cRemete,cDestino,cSubject,cHtml,aArquivos,.T.)
EndIf 

Return 




Static Function fTextoHtml(cCode,cVend,cNVend)

	RpcSetType(3)
	RPCSetEnv("01",'0103')

	cTextHtml := ""
	top := 1.76
	topNext := top
	nTotal := 0
	nDesct := 0
	nQuant := 0
	cItems := ''
	cCabNext := ''

	DbSelectArea("SC5")
	SC5->(DBSetOrder(1))
	SC5->(DBGoTOP())
	
	DbSelectArea("SC6")
	SC6->(DBSetOrder(1))
	SC6->(DBGoTOP())

	If SC5->(DBSeek(cCode))
		SC6->(DBSeek(SC5->C5_FILIAL+SC5->C5_NUM))
		
		While !EoF() .And. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM

			cItem := '<div style="position:absolute;top:'+cValToChar(top)+'in;left:0.41in;width:1.00in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">'+Alltrim(SC6->C6_PRODUTO)+'</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:1.85in;width:2.59in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">'+Alltrim(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC"))+'</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:4.73in;width:0.20in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">'+Alltrim(SC6->C6_UM)+'</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:5.26in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:5.94in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">'+cvaltochar(SC6->C6_QTDVEN)+'</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:6.62in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:7.23in;width:0.33in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">'+Transform(SC6->C6_PRUNIT,"@E 999,999,999.99")+'</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:7.83in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">'+Transform(SC6->C6_VALDESC,"@E 999,999,999.99")+'</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			cItem += '<div style="position:absolute;top:'+cValToChar(top)+'in;left:8.45in;width:0.33in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">'+Transform(SC6->C6_VALOR,"@E 999,999,999.99")+'</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			
			top += 0.15
			nTotal += SC6->C6_VALOR
			nDesct += SC6->C6_VALDESC
			nQuant += SC6->C6_QTDVEN
			
			If nQuant == 70
				topNext := top + 1
				cCabNext += '          <img style="position:absolute;top:'+cValToChar(topNext+1.33)+'in;left:0.41in;width:8.48in;height:0.23in" src="http://portal.robsol.com.br/PDF/vi_7.png" /> '+CRLF
				cCabNext += '          <img style="position:absolute;top:'+cValToChar(topNext+1.33)+'in;left:0.41in;width:8.49in;height:0.23in" src="http://portal.robsol.com.br/PDF/vi_8.png" /> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.36)+'in;left:4.01in;width:1.33in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Pedido de Venda:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:0.41in;width:1.08in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">C&oacute;d.Prod. No.Lote</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:1.85in;width:0.60in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Descri&ccedil;&atilde;o</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:4.73in;width:0.79in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Unid. </span></SPAN><br/></div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:4.73in;width:0.79in;line-height:0.17in;"> '+CRLF
				cCabNext += '             <DIV style="position:relative; left:0.37in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Embal.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
				cCabNext += '          </div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:5.79in;width:0.41in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Quant.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:6.36in;width:0.52in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Qtd Cxs.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:7.12in;width:0.97in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Unit. </span></SPAN><br/></div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:7.12in;width:0.97in;line-height:0.17in;"> '+CRLF
				cCabNext += '             <DIV style="position:relative; left:0.48in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Desc.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
				cCabNext += '          </div> '+CRLF
				cCabNext += '          <div style="position:absolute;top:'+cValToChar(topNext+1.64)+'in;left:8.32in;width:0.46in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Total</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
			
				top += 2.8
			EndIf

			cItems += cItem
			DBSkip()
		EndDo

		If !Empty(cCabNext)
			cItems += cCabNext
		EndIf
	
		cTextHtml += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"> '+CRLF
		cTextHtml += '    <html> '+CRLF
		cTextHtml += '       <head> '+CRLF
		cTextHtml += '          <link rel="stylesheet" type="text/css" href="style.css"/> '+CRLF
		cTextHtml += '       </head> '+CRLF
		cTextHtml += '       <body> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:0.12in;left:0.41in;width:4.05in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_1.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:0.12in;left:0.41in;width:4.05in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_2.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:0.35in;left:0.41in;width:4.05in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_3.png" /> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.14in;left:0.48in;width:0.74in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Emitente:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:0.39in;left:0.48in;width:0.82in;height:0.82in" src="http://portal.robsol.com.br/PDF/ri_1.png" /> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.36in;left:1.39in;width:1.72in;line-height:0.13in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Empresa: </span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">ROB SOL INDUSTRIA LTDA</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.47in;left:1.39in;width:1.22in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">CNPJ: </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.57in;left:1.39in;width:0.38in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cidade:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.57in;left:1.85in;width:0.79in;line-height:0.13in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">SAO PAULO / SP</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.68in;left:1.39in;width:0.79in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">CEP: </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.68in;left:1.39in;width:0.79in;line-height:0.13in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.30in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">03021-060</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.79in;left:1.39in;width:1.01in;line-height:0.13in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Telefone: </span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">1150821955</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.00in;left:1.39in;width:1.37in;line-height:0.13in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">E-Mail: </span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">pedidos@robsol.com.br</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.10in;left:1.39in;width:1.69in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Home Page: </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.10in;left:1.39in;width:1.69in;line-height:0.13in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.61in;"><a href="http://www.robsol.com.br"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">http://www.robsol.com.br</span></a> '+CRLF
		cTextHtml += '                <span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN> '+CRLF
		cTextHtml += '             </DIV> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:0.12in;left:4.55in;width:4.35in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_4.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:0.12in;left:4.54in;width:4.35in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_5.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:0.35in;left:4.54in;width:4.35in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_6.png" /> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.14in;left:4.62in;width:0.61in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Pedido:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.21in;left:5.26in;width:3.51in;line-height:0.13in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:1.97in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">No. '+SC5->C5_NUM+ ' - Emiss&atilde;o:  '+cValToChar(SC5->C5_EMISSAO) +'</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></DIV> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.03in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">'+SC5->C5_CLIENTE+ ' - '+ Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")) +'</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
		cTextHtml += '             <span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">'+Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_END"))+ ' - Bairro: '+ Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_BAIRRO")) +'</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.36in;left:4.62in;width:0.38in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cliente:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.47in;left:4.62in;width:0.49in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Endere&ccedil;o:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '         <div style="position:absolute;top:0.57in;left:4.62in;width:2.20in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cidade: </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.57in;left:4.62in;width:2.20in;line-height:0.13in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.39in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">'+Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MUN"))+ ' - CEP: '+ Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_CEP")) +'</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.68in;left:4.62in;width:1.25in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">CNPJ: </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.68in;left:4.62in;width:1.25in;line-height:0.13in;"> '+CRLF

		cCgcAux := Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_CGC"))

		If Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_PESSOA")) != "F"
			cCgcAux := Alltrim(Transform(cCgcAux, "@R 99.999.999/9999-99"))
		Else
			cCgcAux := Alltrim(Transform(cCgcAux, "@R 999.999.999-99"))
		EndIf

		cTextHtml += '             <DIV style="position:relative; left:0.36in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">'+cCgcAux+'</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF		
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.79in;left:4.62in;width:0.45in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Telefone:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.79in;left:5.29in;width:1.85in;line-height:0.13in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">' + " (" +Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_DDD")) + ") " + Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_TEL"))+ ' - Contato: '+ Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_CONTATO")) +'</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:0.89in;left:4.62in;width:0.36in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Tabela:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.00in;left:4.62in;width:1.76in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Vendedor: </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.00in;left:4.62in;width:1.76in;line-height:0.13in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.55in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">'+cVend+' '+cNVend+'</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.10in;left:4.62in;width:1.30in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cond.Pagto.: </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.10in;left:4.62in;width:1.30in;line-height:0.13in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.67in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">'+SC5->C5_CONDPAG+' - '+Alltrim(Posicione("SE4",1,xFilial('SE4')+SC5->C5_CONDPAG,'E4_DESCRI')) +'</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:1.33in;left:0.41in;width:8.48in;height:0.23in" src="http://portal.robsol.com.br/PDF/vi_7.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:1.33in;left:0.41in;width:8.49in;height:0.23in" src="http://portal.robsol.com.br/PDF/vi_8.png" /> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.36in;left:4.01in;width:1.33in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Pedido de Venda:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:0.41in;width:1.08in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">C&oacute;d.Prod. No.Lote</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:1.85in;width:0.60in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Descri&ccedil;&atilde;o</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:4.73in;width:0.79in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Unid. </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:4.73in;width:0.79in;line-height:0.17in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.37in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Embal.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:5.79in;width:0.41in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Quant.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:6.36in;width:0.52in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Qtd Cxs.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:7.12in;width:0.97in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Unit. </span></SPAN><br/></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:7.12in;width:0.97in;line-height:0.17in;"> '+CRLF
		cTextHtml += '             <DIV style="position:relative; left:0.48in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Desc.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV> '+CRLF
		cTextHtml += '          </div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:1.64in;left:8.32in;width:0.46in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Total</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          '+cItems+' '
		cTextHtml += '          <img style="position:absolute;top:'+cValToChar(top+0.33)+'in;left:0.41in;width:8.48in;height:0.68in" src="http://portal.robsol.com.br/PDF/vi_9.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:'+cValToChar(top+0.33)+'in;left:0.41in;width:8.49in;height:0.68in" src="http://portal.robsol.com.br/PDF/vi_10.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:'+cValToChar(top+0.55)+'in;left:0.41in;width:8.49in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_11.png" /> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.34)+'in;left:0.48in;width:0.55in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Totais:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.56)+'in;left:0.48in;width:1.10in;line-height:0.11in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor do Frete:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Percentual de Desconto :</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Peso.L&iacute;q.:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Peso.Bru:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.56)+'in;left:2.87in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.56)+'in;left:6.09in;width:1.11in;line-height:0.11in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor Total dos Produtos:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor Desconto:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Total de Itens:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor Total do Pedido:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.56)+'in;left:8.37in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">'+Transform((nTotal+nDesct),"@E 999,999,999.99")+'</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.66)+'in;left:'+Iif(nDesct > 0,'2.82','2.87')+'in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">'+Alltrim(Transform((Round(nDesct/(nTotal+nDesct),2))*100, "@E 999,999,999.99"))+'</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.66)+'in;left:'+Iif(nDesct >= 1000,'8.40',Iif(nDesct >= 10000,'8.37','8.48'))+'in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">'+Transform(nDesct,"@E 999,999,999.99")+'</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.77)+'in;left:2.77in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,0000</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.77)+'in;left:8.48in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">'+cValToChar(nQuant)+'</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.88)+'in;left:2.77in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,0000</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+0.88)+'in;left:8.37in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">'+Transform((nTotal),"@E 999,999,999.99")+'</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:'+cValToChar(top+1.38)+'in;left:0.41in;width:8.48in;height:0.08in" src="http://portal.robsol.com.br/PDF/vi_12.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:'+cValToChar(top+1.38)+'in;left:0.41in;width:8.49in;height:0.08in" src="http://portal.robsol.com.br/PDF/vi_13.png" /> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:'+cValToChar(top+1.60)+'in;left:0.41in;width:8.49in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_14.png" /> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+1.42)+'in;left:0.48in;width:0.87in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Duplicatas:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+1.64)+'in;left:0.48in;width:0.82in;line-height:0.13in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">001, no dia   /  /    :</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <div style="position:absolute;top:'+cValToChar(top+1.64)+'in;left:2.87in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div> '+CRLF
		cTextHtml += '          <img style="position:absolute;top:'+cValToChar(top+9.50)+'in;left:0.41in;width:8.49in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_15.png" /> '+CRLF
		cTextHtml += '          </body> '+CRLF
		cTextHtml += '    </html>
		
	Else
		conout('Pedido nao encontrado')
	EndIf

Return cTextHtml
