#include 'protheus.ch'
 
User Function M486OWSCOL()
 
    Local cSerieDoc := PARAMIXB[1] //Serie
    Local cNumDoc   := PARAMIXB[2] //Número de Documento
    Local cCodCli   := PARAMIXB[3] //Código de Cliente
    Local cCodLoj   := PARAMIXB[4] //Código de la Tienda
    Local oXML      := PARAMIXB[5] //Objeto del XML
    Local nOpc      := PARAMIXB[6] //1=Nivel documento 2=Nivel detalle
    Local oWS       := PARAMIXB[7] //Objeto de web services
 
    Local nItem     := Val(oXML:_CBC_ID:TEXT)
    Local cCodProd  := ""
    Local cSDITem   := ""
    Local cFilSD    := xFilial("SD2")
    Local oItemOC   
    Local cTesObTr  :=  GetMV("MV_XTSOBTR",,"")

    Local aAreaSF2
    Local nDescTtal := 0
    Local nPrecRefNF:= 0
    Local nTotscNF  := 0
    Local nTotSinINF:= 0
    Local aDescFact :=  {}
    Local nTotalFc  := 0
    Local cFechEmi  := " "
    Local cIdAntic  := " "
    Local cHoraAnt  := " "
 
    If nOpc == 1 //Encabezado
        //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO (Ýndice 1)
        //Clase oWSCliente
        //oWS:oWSCliente:cnombreComercial := "NOMBRE COMERCIAL PE"
        //oWS:cfechaVencimiento   := "2020-08-20"
         aAreaSF2  := SF2->(GetArea())
            DBSelectArea("SF2")
            dbSetOrder(2) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
            IF dbSeek(xFilial("SF2")+cCodCli + cCodLoj +cNumDoc + cSerieDoc+'N'+cEspecie)
               // nDescTtal := SF2->F2_DESCONT  
               nDescTtal := SF2->F2_VALIMP1
               nTotalFc := SF2->F2_VALBRUT
                aDescFact := CantidadProd()
                cFechEmi    := DTOS(SF2->F2_EMISSAO)
                cIdAntic := SF2->F2_DOC
                cHoraAnt := Alltrim(SF2->F2_HORA)
                

            EndIf          


        //Clase oWSterminosEntrega
        //oWS:oWSterminosEntrega := Service_TerminosDeEntrega():New()
        //oWS:oWSterminosEntrega:ccostoTransporte:= "18.00"
       /* oWS:oWSordenDeCompra :=  Service_ArrayOfOrdenDeCompra():New()
        oWSordenDeCompra    :=  Service_ORDENDECOMPRA():New()
        
        oWSordenDeCompra:cnumeroPedido:= "112233"
        oWSordenDeCompra:cnumeroOrden:= "3343222"
        oWSordenDeCompra:cfecha:= "2020-05-15 00:00:00"
        aAdd(oWS:oWSordenDeCompra:oWSordenDeCompra,oWSordenDeCompra)*/
       
    ElseIf nOpc == 2 //Detalle del documento
       //oWS:cmuestragratis   := "1"
       //oWS:cprecioreferencia   := "1000000.00"
       //oWS:cprecioTotal   := "0.00"
        cCodProd := Padr(oXML:_FE_ITEM:_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT,TamSX3("D2_COD")[1],' ')
        cSDITem := Padl(oXML:_CBC_ID:TEXT,TamSX3("D2_ITEM")[1],'0')
        IF (ALLTRIM(cEspecie)=='NF' .OR. ALLTRIM(cEspecie)=='NDC') 
        dbSelectArea("SD2")
        SD2->(dbSetOrder(3)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
 
        If SD2->(dbSeek( cFilSD + cNumDoc + cSerieDoc + cCodCli + cCodLoj + cCodProd + cSDITem))
            If Alltrim(SD2->D2_TES) $ Alltrim(cTesObTr)
               oWS:cmuestragratis   := "1"
                oWS:cprecioreferencia  := CvALTOcHAR(D2_TOTAL)
                oWS:cprecioTotalSinImpuestos       := CvALTOcHAR(0.00)
                oWS:cprecioTotal       := CvALTOcHAR(0.00)
                oWS:csecuencia   := "1"
                oWs:cPrecioventaunitario := CvALTOcHAR(0.00)
                
              
            EndIf

        
     If oWS:cmuestragratis = "1"
         /*   oWS:oWScargosDescuentos := Service_ArrayOfCargosDescuentos():New()
            oWSDesDtl := Service_CargosDescuentos():NEW()
            oWSDesDtl:ccodigo := "00"
            oWSDesDtl:cdescripcion := "Descuento por iva"
            oWSDesDtl:cindicador := "0"
            oWSDesDtl:cmonto := formatValEnv(D2_TOTAL,2)
            oWSDesDtl:cmontoBase := formatValEnv(SD2->D2_VALIMP1,2)
            oWSDesDtl:cporcentaje := formatValEnv(99,2)
            oWSDesDtl:csecuencia := "1"
            aAdd(oWS:oWScargosDescuentos:oWScargosDescuentos,oWSDesDtl)  
            */
        EndIf
    
         ELSEIF (ALLTRIM(cEspecie)=='NCC')       // Notas de cr�dito


         Endif
            //Clase oWSextras (Factura_Detalle)
          /*  oWS:oWSextras := Service_ArrayOfExtras():New()
            oWSDesDtl := Service_Extras():NEW()
            oWSDesDtl:ccontrolInterno1 := "NO. lote"
            oWSDesDtl:cnombre := "1"
            oWSDesDtl:cpdf := "1"
            oWSDesDtl:cvalor := SD2->D2_LOTECTL
            oWSDesDtl:cxml := "1"
            aAdd(oWS:oWSextras:oWSextras,oWSDesDtl)  */
        EndIf

    EndIf

        cFechEmi    := LEFT( Alltrim(cFechEmi), 4 )+"-"+ SUBSTR(Alltrim(cFechEmi),5,2) + "-" + RIGHT(  Alltrim(cFechEmi), 2 ) + " 00:00:00"
        iF LEN(aDescFact)> 0
         //If nDescTtal > 0 
            nPrecRefNF  := aDescFact[1][6]
            nTotscNF    := aDescFact[1][5]
            oWS:oWScargosDescuentos := Service_ArrayOfCargosDescuentos():New()
            oWSDesDtl := Service_CargosDescuentos():NEW()
            oWSDesDtl:ccodigo := "00"
            oWSDesDtl:cdescripcion := "Descuento por iva"
            oWSDesDtl:cindicador := "0"
            oWSDesDtl:cmonto := formatValEnv(nPrecRefNF,2)
            oWSDesDtl:cmontoBase := formatValEnv(nPrecRefNF,2)
            oWSDesDtl:cporcentaje := formatValEnv(99.99,2)
            oWSDesDtl:csecuencia := "1"
            aAdd(oWS:oWScargosDescuentos:oWScargosDescuentos,oWSDesDtl) 
            Ows:ctotalDescuentos :=  formatValEnv(nTotscNF,2)
            //oWs:ctotalAnticipos     := cValtochar(nDescTtal)
            // Cargar atributo totalMonto
            oWs:ctotalMonto         := cValtochar(0.00)//(nTotalFc+nDescTtal)-nDescTtal)
            // Cargar arreglo de la clase anticipo
          /*  oWS:oWSanticipos := Service_ArrayOfAnticipos ():New()
            oWSExtDet := Service_Anticipos():NEW()
            oWSExtDet:cfechaDeRecibido  := Alltrim(Left(cFechEmi,10))
            oWSExtDet:cid               := cIdAntic
            oWSExtDet:choraDePago       := cHoraAnt
            oWSExtDet:cinstrucciones    := "Pago Anticipado"
            oWSExtDet:cmontoPagado      := cValtochar(nDescTtal)// Alltrim(transform(nValReten,"@E 999999999"))
            aAdd(oWS:oWSanticipos:oWSanticipos,oWSExtDet)*/
        //EndIf
        ENDiF
 
Return Nil


 /*/{Protheus.doc} formatValEnv
    (long_description)
    @type  Function
    @author user
    @since 02/07/2020
    @version version
    @param nValFormat, num, recibe numero sin formato
    @return return_var, return_type String, retorna string formato 999,999,999.99 Para coincidir con formato de The factory.
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function formatValEnv(nValFormat,tpformat)
Local cValformatado     := " "

DEFAULT nValFormat := 0

cValformatado   := transform(nValFormat,"@E 999,999,999,999.99") 

cValformatado   := STRTRAN(cValformatado, ".", ";")
cValformatado   := STRTRAN(cValformatado, ",", ".")
If tpformat = 1
    cValformatado   := STRTRAN(cValformatado, ";", ",")
Else
    cValformatado   := STRTRAN(cValformatado, ";", "")
EndIf
cValformatado := Alltrim(cValformatado)
Return cValformatado


Static function	CantidadProd()
Local aCantPdt	:= {}
Local cQuery1   := ""
Local cAliasQry := GetNextAlias()
Local cTesObTr  :=  GetMV("MV_XTSOBTR",,"")

cTesObTr    :=  STRTRAN(cTesObTr, "|", "','")
cTesObTr    := "('"+cTesObTr+"')"

If (ALLTRIM(cEspecie)=='NF' .OR. ALLTRIM(cEspecie)=='NDC')
    cQuery1 :=   " SELECT SUM(D2_QUANT) CANTIDAD, SUM(D2_DESCON) DESCTOT, SUM(D2_TOTAL) PRCTOT, AVG(D2_DESC) PORCENTJ,SUM(D2_VALIMP1) VALIVA ,SUM(D2_BASIMP1) BASIVA "
    cQuery1 +=   " FROM "+RetSqlName("SD2")
    cQuery1 +=   " WHERE D2_FILIAL  = '"+xFilial("SD2")+"'"
    cQuery1 +=   " AND D2_ESPECIE   = 'NF'"
    cQuery1 +=   " AND D2_DOC       = '"+ PARAMIXB[2]+"'"
    cQuery1 +=   " AND D2_SERIE     = '"+ PARAMIXB[1]+"'"
    cQuery1 +=   " AND D2_CLIENTE   = '"+ PARAMIXB[3]+"'"
    cQuery1 +=   " AND D2_LOJA      = '"+ PARAMIXB[4]+"'"
    cQuery1 +=   " AND D_E_L_E_T_   <> '*'"
    cQuery1 +=   " AND D2_TES  IN  "+ cTesObTr+""
    cQuery1 +=   " GROUP BY D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA"

ELSEIF (ALLTRIM(cEspecie)=='NCC')
    cQuery1 :=   " SELECT SUM(D1_QUANT) CANTIDAD, SUM(D1_VALDESC) DESCTOT, SUM(D1_TOTAL) PRCTOT, AVG(D1_DESC) PORCENTJ,SUM(D1_VALIMP1) VALIVA,SUM(D2_BASIMP1) BASIVA   "
    cQuery1 +=   " FROM "+RetSqlName("SD1")
    cQuery1 +=   " WHERE D1_FILIAL  = '"+xFilial("SD1")+"'"
    cQuery1 +=   " AND D1_ESPECIE   = 'NCC'"
    cQuery1 +=   " AND D1_DOC       = '"+ PARAMIXB[2]+"'"
    cQuery1 +=   " AND D1_SERIE     = '"+ PARAMIXB[1]+"'"
    cQuery1 +=   " AND D1_FORNECE   = '"+ PARAMIXB[3]+"'"
    cQuery1 +=   " AND D1_LOJA      = '"+ PARAMIXB[4]+"'"
    cQuery1 +=   " AND D_E_L_E_T_ <> '*'"
    cQuery1 +=   " AND D1_TES  IN  "+ cTesObTr+""
    cQuery1 +=   " GROUP BY D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA"

ENDIF
cQuery1 := ChangeQuery(cQuery1)
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery1), cAliasQry, .F., .T.)

dbSelectArea(cAliasQry)
dbGoTop()

While (cAliasQry)->(!Eof())// 1             2                       3               4                   5                   6   
	aAdd(aCantPdt,{(cAliasQry)->CANTIDAD,(cAliasQry)->DESCTOT,(cAliasQry)->PRCTOT,(cAliasQry)->PORCENTJ,(cAliasQry)->VALIVA,(cAliasQry)->BASIVA})
	(cAliasQry)->(dbSkip())
Enddo

//aCantPdt := If(Empty(aCantPdt),0,aCantPdt) 

Return aCantPdt
