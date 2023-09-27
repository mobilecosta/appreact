#Include "TOTVS.ch"

/*/{Protheus.doc} ROBWS04
    WS SOAP Correios - Impressao de Etiquetas
    @type User Function
    @author Felipe Mayer
    @since 25/08/2022
/*/

User Function ROBWS04(nVolume, nRecF2, nPeso, cTpFrete, aMedidas)

Local oWS01, oWS02, oWS03, oWS04
Local xRet
Local cError    := ""
Local cWarning  := ""
Local cResp     := ""
Local lContinua := .T.
Local nX,nY     := 0
Local nPosIni   := 0
Local nPosFim   := 0
Local nLeitura  := 0
Local cUser     := SuperGetMV("TI_USERCOR",.F.,"23824405")
Local cPass     := SuperGetMV("TI_PASSCOR",.F.,"8yeu3r")
Local cIdContr  := strtokarr(SuperGetMV("TI_CONTCOR",.F.,"9912446282/0074256874"),'/')[1]
Local cIdCrtPst := strtokarr(SuperGetMV("TI_CONTCOR",.F.,"9912446282/0074256874"),'/')[2]
Local aEtiqueta := {}
Local cEtiqueta := ''
Local cIdResp   := ''
Local cUrl      := "https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl "
Local cCNPJ     := ''
Local aEtiRet   := {}
Local cAlt      := ''
Local cLrg      := ''
Local cCmp      := ''

Default nVolume  := 1
Default aMedidas := {}

    If Empty(FunName())
        RpcSetType(3)
        RPCSetEnv("01","0101")
    EndIf

    oWS01 := TWsdlManager():New()
    oWS01:lSSLInsecure := .T.

    If xRet := ! oWS01:ParseURL( cUrl )
        MsgInfo( "Erro Parse: " + oWS01:cError )
        lContinua := .F.
    EndIf

    If lContinua 
        xRet := !oWS01:SetOperation( "buscaCliente" )

        cMsgWs := '<soap:Envelope'
        cMsgWs += '    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
        cMsgWs += '    xmlns:cli="http://cliente.bean.master.sigep.bsb.correios.com.br/">
        cMsgWs += '    <soap:Header/>
        cMsgWs += '    <soap:Body>
        cMsgWs += '       <cli:buscaCliente>
        cMsgWs += '           <idContrato>'+AllTrim(cIdContr)+'</idContrato>
        cMsgWs += '           <idCartaoPostagem>'+Alltrim(cIdCrtPst)+'</idCartaoPostagem>
        cMsgWs += '            <usuario>'+Alltrim(cUser)+'</usuario>
        cMsgWs += '           <senha>'+Alltrim(cPass)+'</senha>
        cMsgWs += '        </cli:buscaCliente>
        cMsgWs += '    </soap:Body>
        cMsgWs += '</soap:Envelope>

        xRet     := oWS01:SendSoapMsg(cMsgWs)
        cResp    := oWS01:GetParsedResponse()
        cRespost := oWS01:GetSoapResponse()
        oXml     := XmlParser( cRespost, "_", @cError, @cWarning )

        aRespId := {}
        aAuxId  := {}

        If Empty(cError) .And. !Empty(cRespost)
            If At("<soap:Fault>",  cRespost) > 0
                MsgAlert(oWS01:cFaultString, "Erro!")
                RETURN({})
            Else
                aAuxId := oXML:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_BUSCACLIENTERESPONSE:_RETURN:_CONTRATOS:_CARTOESPOSTAGEM:_SERVICOS
                cCNPJ  := oXML:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_BUSCACLIENTERESPONSE:_RETURN:_CNPJ:TEXT

                If Len(aAuxId) > 0
                    For nX := 1 To Len(aAuxId)
                        Aadd(aRespId, {AllTrim(aAuxId[nX]:_CODIGO:TEXT),AllTrim(aAuxId[nX]:_ID:TEXT)})
                    Next nX

                    nPosId := aScan(aRespId, {|x| AllTrim(x[1]) == cTpFrete})
                    
                    If nPosId > 0
                        cIdResp := aRespId[nPosId,2]
                    EndIf

                    //codigo adm
                    nPosIni  := At("<codigoAdministrativo>",  cRespost) + Len('<codigoAdministrativo>')
                    nPosFim  := Rat("</codigoAdministrativo>", cRespost)
                    nLeitura := nPosFim - nPosIni

                    cCodAdm := SubStr(cRespost, nPosIni, nLeitura)
                EndIf
            EndIf

        EndIf
    EndIf

    If !Empty(cIdResp) .And. !Empty(cCNPJ)
        oWS02 := TWsdlManager():New()
        oWS02:lSSLInsecure := .T.

        If xRet := ! oWS02:ParseURL( cUrl )
            MsgInfo( "Erro Parse: " + oWS02:cError )
            lContinua := .F.
        EndIf

        If lContinua
            xRet := !oWS02:SetOperation( "solicitaEtiquetas" )

            cMsgWs := '<soap:Envelope
            cMsgWs += '    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
            cMsgWs += '    xmlns:cli="http://cliente.bean.master.sigep.bsb.correios.com.br/">
            cMsgWs += '    <soap:Header/>
            cMsgWs += '    <soap:Body>
            cMsgWs += '        <cli:solicitaEtiquetas>
            cMsgWs += '            <tipoDestinatario>C</tipoDestinatario>
            cMsgWs += '           <identificador>'+Alltrim(cCNPJ)+'</identificador>
            cMsgWs += '           <idServico>'+Alltrim(cIdResp)+'</idServico>
            cMsgWs += '           <qtdEtiquetas>'+cValToChar(nVolume)+'</qtdEtiquetas>
            cMsgWs += '           <usuario>'+Alltrim(cUser)+'</usuario>
            cMsgWs += '           <senha>'+Alltrim(cPass)+'</senha>
            cMsgWs += '       </cli:solicitaEtiquetas>
            cMsgWs += '   </soap:Body>
            cMsgWs += '</soap:Envelope>

            xRet     := oWS02:SendSoapMsg(cMsgWs)
            cResp    := oWS02:GetParsedResponse()
            cRespost := oWS02:GetSoapResponse()
            oXml1    := XmlParser( cRespost, "_", @cError, @cWarning )

            nPosIni  := At("<return>",  cRespost) + Len('<return>')
            nPosFim  := At("</return>", cRespost)
            nLeitura := nPosFim - nPosIni
            
            If Empty(cError) .And. !Empty(cRespost)
                cEtiqueta := SubStr(cRespost, nPosIni, nLeitura)
                aEtiqueta := strtokarr(cEtiqueta,',')
            EndIf
        EndIf
    EndIf

    If Len(aEtiqueta) > 0

        oWS03 := TWsdlManager():New()
        oWS03:lSSLInsecure := .T.

        If xRet := ! oWS03:ParseURL( cUrl )
            MsgInfo( "Erro Parse: " + oWS03:cError )
            lContinua := .F.
        EndIf

        If lContinua
            xRet := !oWS03:SetOperation( "geraDigitoVerificadorEtiquetas" )

            cMsgWs := '<soap:Envelope
            cMsgWs += '    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
            cMsgWs += '    xmlns:cli="http://cliente.bean.master.sigep.bsb.correios.com.br/">
            cMsgWs += '    <soap:Header/>
            cMsgWs += '    <soap:Body>
            cMsgWs += '        <cli:geraDigitoVerificadorEtiquetas>
            
            aAux := {}
            For nX := 1 To nVolume
                If nX == 1
                    cEtiAux := aEtiqueta[1]
                Else
                    cEtiAux := strtokarr(StrTran(cEtiAux,' ',','),',')[1] //etiqueta
                    cDigAux := strtokarr(StrTran(aEtiqueta[2],' ',','),',')[2] //digito

                    cEtiAux := SubsTr(cEtiAux,0,Len(cEtiAux)-8)+Soma1(Right(cEtiAux,8))+' '+cDigAux
                EndIf

                Aadd(aAux, cEtiAux)
                cMsgWs += '<etiquetas>'+Alltrim(cEtiAux)+'</etiquetas>
            Next nX

            cMsgWs += '            <usuario>'+Alltrim(cUser)+'</usuario>
            cMsgWs += '            <senha>'+Alltrim(cPass)+'</senha>
            cMsgWs += '        </cli:geraDigitoVerificadorEtiquetas>
            cMsgWs += '    </soap:Body>
            cMsgWs += '</x:Envelope>

            xRet     := oWS03:SendSoapMsg(cMsgWs)
            cResp    := oWS03:GetParsedResponse()
            cRespost := oWS03:GetSoapResponse()
            oXml2    := XmlParser( cRespost, "_", @cError, @cWarning )

            nPosIni  := At("<return>",  cRespost) + Len('<return>')
            nPosFim  := Rat("</return>", cRespost)
            nLeitura := nPosFim - nPosIni

            If nPosFim > 0 .And. !Empty(cRespost)

                aResp := strtokarr(StrTran(StrTran(StrTran(Alltrim(SubStr(cRespost, nPosIni, nLeitura)),'</return>',','),'<return>',','),',,',','),',')
                aEtiqueta := {}

                For nY := 1 To Len(aAux)
                    Aadd(aEtiqueta, StrTran(aAux[nY],' ',aResp[nY]))
                Next nY
            Else
                aEtiqueta := {}
            EndIf
        EndIf

        If len(aEtiqueta) > 0
            oWS04 := TWsdlManager():New()
            oWS04:lSSLInsecure := .T.

            If xRet := ! oWS04:ParseURL( cUrl )
                MsgInfo( "Erro Parse: " + oWS04:cError )
                lContinua := .F.
            EndIf

            If lContinua 
                xRet := !oWS04:SetOperation( "fechaPlpVariosServicos" )

                DbSelectArea('SF2')
                DbGotop()
                DbGoto(nRecF2)

                DbSelectArea("SA1")
                DbSetOrder(1)
                
                SA1->(DbSeek(xFilial('SA1')+SF2->(F2_CLIENTE+F2_LOJA)))

                For nX := 1 To len(aAux)
                                
                    cMsgWs := CRLF + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cli="http://cliente.bean.master.sigep.bsb.correios.com.br/">
                    cMsgWs += CRLF + '    <soap:Header />
                    cMsgWs += CRLF + '    <soap:Body>
                    cMsgWs += CRLF + '       <cli:fechaPlpVariosServicos>
                    cMsgWs += CRLF + '          <xml><![CDATA[<?xml version="1.0" encoding="ISO-8859-1" ?>
                    cMsgWs += CRLF + '             <correioslog>
                    cMsgWs += CRLF + '                <tipo_arquivo>Postagem</tipo_arquivo>
                    cMsgWs += CRLF + '                <versao_arquivo>2.3</versao_arquivo>
                    cMsgWs += CRLF + '                <plp>
                    cMsgWs += CRLF + '                   <id_plp />
                    cMsgWs += CRLF + '                   <valor_global />
                    cMsgWs += CRLF + '                   <mcu_unidade_postagem />
                    cMsgWs += CRLF + '                   <nome_unidade_postagem />
                    cMsgWs += CRLF + '                   <cartao_postagem>'+Alltrim(cIdCrtPst)+'</cartao_postagem>
                    cMsgWs += CRLF + '                </plp>
                    cMsgWs += CRLF + '                <remetente>
                    cMsgWs += CRLF + '                   <numero_contrato>'+AllTrim(cIdContr)+'</numero_contrato>
                    cMsgWs += CRLF + '                   <numero_diretoria>10</numero_diretoria>
                    cMsgWs += CRLF + '                   <codigo_administrativo>'+Alltrim(cCodAdm)+'</codigo_administrativo>
                    cMsgWs += CRLF + '                   <nome_remetente>'+Alltrim(SM0->M0_NOMECOM)+'</nome_remetente>
                    cMsgWs += CRLF + '                   <logradouro_remetente>'+strtokarr(Alltrim(SM0->M0_ENDENT),',')[1]+'</logradouro_remetente>
                    cMsgWs += CRLF + '                   <numero_remetente>'+PadL(AllTrim(strtokarr(SM0->M0_ENDENT,',')[2]), 5, '0')+'</numero_remetente>
                    cMsgWs += CRLF + '                   <complemento_remetente>'+SubStr(Alltrim(SM0->M0_COMPENT), 1, 30)+'</complemento_remetente>
                    cMsgWs += CRLF + '                   <bairro_remetente>'+Alltrim(SM0->M0_BAIRENT)+'</bairro_remetente>
                    cMsgWs += CRLF + '                   <cep_remetente>'+Alltrim(SM0->M0_CEPENT)+'</cep_remetente>
                    cMsgWs += CRLF + '                   <cidade_remetente>'+Alltrim(SM0->M0_CIDENT)+'</cidade_remetente>
                    cMsgWs += CRLF + '                   <uf_remetente>'+Alltrim(SM0->M0_ESTENT)+'</uf_remetente>
                    cMsgWs += CRLF + '                   <telefone_remetente>'+Alltrim(SM0->M0_TEL)+'</telefone_remetente>
                    cMsgWs += CRLF + '                   <fax_remetente />
                    cMsgWs += CRLF + '                   <email_remetente />
                    cMsgWs += CRLF + '                   <celular_remetente />
                    cMsgWs += CRLF + '                   <cpf_cnpj_remetente>'+Alltrim(SM0->M0_CGC)+'</cpf_cnpj_remetente>
                    cMsgWs += CRLF + '                   <ciencia_conteudo_proibido>S</ciencia_conteudo_proibido>
                    cMsgWs += CRLF + '                </remetente>
                    cMsgWs += CRLF + '                <forma_pagamento />
                    cMsgWs += CRLF + '                <objeto_postal>

                    cMsgWs += CRLF + '                  <numero_etiqueta>'+aEtiqueta[nX]+'</numero_etiqueta>
                    cMsgWs += CRLF + '                  <sscc />

                    cMsgWs += CRLF + '                  <codigo_objeto_cliente />
                    cMsgWs += CRLF + '                  <codigo_servico_postagem>'+cTpFrete+'</codigo_servico_postagem>
                    cMsgWs += CRLF + '                  <cubagem>0,00</cubagem>
                    cMsgWs += CRLF + '                  <peso>'+CValToChar(nPeso)+'</peso>
                    cMsgWs += CRLF + '                  <rt1 />
                    cMsgWs += CRLF + '                  <rt2 />
                    cMsgWs += CRLF + '                  <restricao_anac>S</restricao_anac>
                    cMsgWs += CRLF + '                  <destinatario>
                    cMsgWs += CRLF + '                     <nome_destinatario>'+StrTran(AllTrim(SA1->A1_NOME), "&", "E")+'</nome_destinatario>
                    cMsgWs += CRLF + '                     <telefone_destinatario>'+StrTran(Alltrim(SA1->A1_DDD)+Alltrim(SA1->A1_TEL),'-','')+'</telefone_destinatario>
                    cMsgWs += CRLF + '                     <celular_destinatario />
                    cMsgWs += CRLF + '                     <email_destinatario />
                    cMsgWs += CRLF + '                     <logradouro_destinatario>'+strtokarr(Alltrim(SA1->A1_END),',')[1]+'</logradouro_destinatario>
                    cMsgWs += CRLF + '                     <complemento_destinatario>'+SubStr(AllTrim(SA1->A1_COMPENT), 1, 30)+'</complemento_destinatario>
                    cMsgWs += CRLF + '                     <numero_end_destinatario>'+PadL(AllTrim(strtokarr(SA1->A1_END,',')[2]), 5,'0')+'</numero_end_destinatario>
                    cMsgWs += CRLF + '                     <cpf_cnpj_destinatario>'+AllTrim(SA1->A1_CGC)+'</cpf_cnpj_destinatario>
                    cMsgWs += CRLF + '                  </destinatario>
                    cMsgWs += CRLF + '                  <nacional>
                    cMsgWs += CRLF + '                     <bairro_destinatario>'+AllTrim(SA1->A1_BAIRRO)+'</bairro_destinatario>
                    cMsgWs += CRLF + '                     <cidade_destinatario>'+Alltrim(SA1->A1_MUN)+'</cidade_destinatario>'
                    cMsgWs += CRLF + '                     <uf_destinatario>'+AllTrim(SA1->A1_EST)+'</uf_destinatario>
                    cMsgWs += CRLF + '                     <cep_destinatario>'+AllTrim(SA1->A1_CEP)+'</cep_destinatario>
                    cMsgWs += CRLF + '                     <codigo_usuario_postal />
                    cMsgWs += CRLF + '                     <centro_custo_cliente />
                    cMsgWs += CRLF + '                     <numero_nota_fiscal>'+AllTrim(SF2->F2_DOC)+'</numero_nota_fiscal>
                    cMsgWs += CRLF + '                     <serie_nota_fiscal />
                    cMsgWs += CRLF + '                     <valor_nota_fiscal />
                    cMsgWs += CRLF + '                     <natureza_nota_fiscal />
                    cMsgWs += CRLF + '                     <descricao_objeto />
                    cMsgWs += CRLF + '                     <valor_a_cobrar>0,0</valor_a_cobrar>
                    cMsgWs += CRLF + '                  </nacional>
                    cMsgWs += CRLF + '                  <servico_adicional>
                    cMsgWs += CRLF + '                     <codigo_servico_adicional>025</codigo_servico_adicional>
                    //cMsgWs += CRLF + '                     <codigo_servico_adicional>001</codigo_servico_adicional>
                    //cMsgWs += CRLF + '                     <codigo_servico_adicional>019</codigo_servico_adicional>
                    // cMsgWs += CRLF + '                     <valor_declarado>'+Alltrim(TRANSFORM(SF2->F2_VALBRUT,'@E 999,999,999.99'))+'</valor_declarado>
                    cMsgWs += CRLF + '                     <valor_declarado />
                    cMsgWs += CRLF + '                  </servico_adicional>
                    cMsgWs += CRLF + '                  <dimensao_objeto>
                    cMsgWs += CRLF + '                     <tipo_objeto>002</tipo_objeto>
                    
                    If len(aMedidas) > 0
                        cAlt := cValToChar(aMedidas[1])
                        cLrg := cValToChar(aMedidas[2])
                        cCmp := cValToChar(aMedidas[3])
                    EndIf

                    cMsgWs += CRLF + '                     <dimensao_altura>'+Iif(!Empty(cAlt),cAlt,'0')+'</dimensao_altura>
                    cMsgWs += CRLF + '                     <dimensao_largura>'+Iif(!Empty(cLrg),cLrg,'0')+'</dimensao_largura>
                    cMsgWs += CRLF + '                     <dimensao_comprimento>'+Iif(!Empty(cCmp),cCmp,'0')+'</dimensao_comprimento>

                    cMsgWs += CRLF + '                     <dimensao_diametro>0,0</dimensao_diametro>
                    cMsgWs += CRLF + '                  </dimensao_objeto>
                    cMsgWs += CRLF + '                  <data_postagem_sara />
                    cMsgWs += CRLF + '                  <status_processamento>0</status_processamento>
                    cMsgWs += CRLF + '                  <numero_comprovante_postagem />
                    cMsgWs += CRLF + '                  <valor_cobrado />
                    cMsgWs += CRLF + '               </objeto_postal>
                    cMsgWs += CRLF + '            </correioslog>]]></xml>
                    cMsgWs += CRLF + '         <idPlpCliente>0</idPlpCliente>
                    cMsgWs += CRLF + '         <cartaoPostagem>'+Alltrim(cIdCrtPst)+'</cartaoPostagem>

                    cMsgWs += CRLF + '         <listaEtiquetas>'+StrTran(aAux[nX],' ','')+'</listaEtiquetas>

                    cMsgWs += CRLF + '         <usuario>'+Alltrim(cUser)+'</usuario>
                    cMsgWs += CRLF + '         <senha>'+Alltrim(cPass)+'</senha>
                    cMsgWs += CRLF + '      </cli:fechaPlpVariosServicos>
                    cMsgWs += CRLF + '   </soap:Body>
                    cMsgWs += CRLF + '</soap:Envelope>

                    xRet     := oWS04:SendSoapMsg(cMsgWs)
                    cResp    := oWS04:GetParsedResponse()
                    cRespost := oWS04:GetSoapResponse()
                    oXml     := XmlParser( cRespost, "_", @cError, @cWarning )

                    nPosIni  := At("<return>",  cRespost) + Len('<return>')
                    nPosFim  := At("</return>", cRespost)
                    nLeitura := nPosFim - nPosIni
                    
                    If Empty(cError) .And. !Empty(cRespost) .And. At("<soap:Fault>",  cRespost) == 0
                        Aadd(aEtiRet, {aEtiqueta[nX], SubStr(cRespost, nPosIni, nLeitura) })

                        DbSelectArea("Z51")
                        Z51->(DbSetOrder(1))
                        If Z51->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
                            Reclock("Z51",.F.)
                            Z51->Z51_XMLENV   := cMsgWs
                            Z51->(MsUnlock())
                        EndIf
                    EndIf

                Next nX

            EndIf

        EndIf
    EndIf
 
Return aEtiRet

// Static Function geraDV(cNumEti)
    
//     Local cPrefixo := SubStr(cNumEti, 1, 2)
//     Local cNumero := SubStr(cNumEti, 3, 10)
//     Local cSufixo := AllTrim(SubStr(cNumEti, 12))
//     Local cRet := ''
//     Local cDv := ''
//     Local aMulti := {8, 6, 4, 2, 3, 5, 9, 7}
//     Local nSoma := 0
//     Local cZeros := ''
//     Local nDiferenca := 0
//     Local nX := 0
//     Local nResto := 0
//     Local nY := 0

//     if len(cNumEti) < 12
//         cRet := 'Erro'

//     elseif len(cNumero) < 8 .AND. len(cNumEti) == 12
//         nDiferenca := 8 - len(cNumero)
        
//         for nX := 0 to nDiferenca
//             cZeros += '0'
//         next nX

//         cRet := cZeros + cNumero

//     else 
//         cRet := SubStr(cNumero, 1, 9)
//     endif

//     nY := 0
//     for nX := 1 to 8
//         nSoma += val(SubStr(cRet, nY, nY+1)) * aMulti[nX]
//         nY++
//     next nX

//     nResto := nSoma % 11

//     if nResto == 0
//         cDv := '5'
    
//     elseif nResto == 1
//         cDv := '0'

//     else
//         cDv := CValToChar(11-nResto)

//     endif

//     cRet += cDv
//     cRet := cPrefixo + cRet + cSufixo

// Return cRet
