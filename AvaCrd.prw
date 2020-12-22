#Include "Totvs.ch"

#Include "topconn.ch"

#INCLUDE "TBICONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±
ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ
»±±
±±ºPrograma  ³AVACRED   ºAutor  ³Paulo Estraich      º Data ³  08/12/14   º
±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±
±
±±ºDesc.     ³ Função de Schedule que executa e passa liberando os pedidosº±±
±±º 
         ³ incluidos via MAE                                          º±±
±±
ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
±±
±±ºUso       ³ AP                                                        º±±
±±
ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User function AvaCrd()
  

Local cQuery 	:= " "
  
local cNumPed 	:= " "
  Local lPedAtu 	:= .F.
  
local aValor  	:= {}
  
local aBloqueio	:= {}
  
local nVal 		:= 0
  
local cCliente  := ""

  local cLoja		:= ""

  

cQuery := " SELECT C5_NUM num, C5_CLIENTE cliente, C5_LOJACLI loja, SC6.C6_ITEM ITEM, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SC6.C6_VALOR valor,SC6.R_E_C_N_O_ recno, SC6.C6_NUMORC ORC,SC6.C6_QTDLIB,SC6.C6_QTDENT , SC6.C6_QTDVEN FROM " + RetSqlName("SC5") + " SC5"
cQuery += " INNER JOIN " + RetSqlName ("SC6") + "  SC6  ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName ("SC9") + " SC9 ON SC9.C9_FILIAL     = SC6.C6_FILIAL AND SC9.C9_PEDIDO  =  SC6.C6_NUM AND SC9.C9_PRODUTO   = SC6.C6_PRODUTO AND SC9.D_E_L_E_T_ <> '*' AND SC9.C9_BLCRED <> ' '  "
cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' AND SC5.C5_LMAE = 'S' AND SC6.C6_QTDVEN > SC6.C6_QTDENT AND SC6.C6_BLQ <> 'R' AND SC5.C5_FILIAL = '"+xfilial("SC5")+"' "
cQuery += " AND NOT EXISTS (SELECT SCC.C9_BLEST FROM " + RetSqlName ("SC9") + " SCC WHERE SCC.C9_PEDIDO = SC6.C6_NUM AND SCC.C9_PRODUTO = SC6.C6_PRODUTO AND SCC.D_E_L_E_T_ <>'*' AND SCC.C9_BLCRED IN '  ')  "
cQuery += " ORDER BY C5_NUM "
TcQuery cQuery New Alias "LB1"

DbSelectArea("LB1")
DbGoTop()
IF LB1->(Eof())
	return
endif
// soma os totais por pedido


_cPedAnt := LB1->num  // memoriza o primeiro antes de comecar
nVal     := 0        // zera a variavel do  valor

While LB1->(!Eof())  // vai comecar o loop
	
	
	if LB1->num == _cPedAnt  // se o que esta posicionado dentro do loop for igual ao memorizado antes , dai armazena e soma o vaLlor
		
		cNumPed  := LB1->num
		cCliente := LB1->cliente
		cLoja	 := LB1->loja
		nVal     += LB1->valor
		cOrc	 := substr(LB1->ORC,1,6)
		cItem	 := LB1->ITEM
	elseif LB1->num != _cPedAnt  // se o que esta posicionado dentro do loop for diferente do memorizado antes, dai transfere para o array , memoriza o novo pego dentro do loop, zera o valor
		//  e o COMANDO LOOP garante que volte no (if LB1->num == _cPedAnt ) sem pular de registro	
		AADD(aValor,{nVal,cNumPed,cCliente,cLoja,cOrc,cItem} )
		
		_cPedAnt := LB1->num
		
		nVal := 0
		LOOP
		
	endif
	
	
	LB1->(dbSkip())
	
Enddo

IF nVal > 0  // ADICIONA NO ARRAY
	
	AADD(aValor,{nVal,cNumPed,cCliente,cLoja,cOrc,cItem} )
	nVal := 0
ENDIF

DBCLOSEAREA()



// FIM soma itens por pedido
//Memowrite("c:\smsti\aValor.html",varinfo("aValor",aValor))

for i := 1 to len (aValor)
	
	//	AADD(aBloqueio,{aValor[i][3],aValor[i][4],aValor[i][1],aValor[i][2]}) // adiciona cliente, loja, valor pedido, num. pedido
	//		Caso o cliente não tenha credito / cria a SC9 do pedido como bloq. credito e salva os dados dos pedidos bloqueados em um array
	DBselectarea("SC5") // posiciona na SC5 para ver se o pedido existe.
	DBSETORDER(1)
	IF SC5->(MSSEEK(xFilial("SC5")+aValor[i][2]))
		dbclosearea()
		
		DBselectarea("SC9")
		DBSETORDER(1)
		if MsSeek(xFilial("SC9")+aValor[i][2]+aValor[i][6]) // FAZ UM SEEK NA SC9 PARA VER SE EXISTE LIBERAÇÃO,
			
			If (SC9->C9_BLCRED <> "10" .And. SC9->C9_BLEST <> "10" .And. SC9->C9_BLCRED <> "ZZ" .And. SC9->C9_BLEST <> "ZZ") //SE EXISTIR LIBERAÇÃO E N ESTIVER FATURADO, ESTORNA E FAZ NOVAMENTE
				Begin Transaction
				a460Estorna(.T.)
				End Transaction
			EndIf
		ENDIF
		
		dbclosearea()
		DBselectarea("SC5") // FAZ OUTRO SEEK NA SC5 PARA REMOVER O BLOQUEIO MAE
		DBSETORDER(1)
		MSSEEK(xFilial("SC5")+aValor[i][2])
		reclock ("SC5",.F.)//RECLOCK NA SC5
		SC5->C5_BLQ := "" //LIMPA O CAMPO BLOQUEIO MAE
		MSUNLOCK ()
		
		Ma410LbNfs(2,,) // ESTA FUNÇÃO FAZ A LIBERAÇÃO DOS ITENS DA NF
		// faz um novo seek na SC9 para ver o status dos pedidos, se bloqueado ou liberado por credito.
		if MsSeek(xFilial("SC9")+aValor[i][2]+aValor[i][6])
			
			if SC9->C9_BLCRED <> ' ' // SE DIFERENTE DE VAZIO (BLOQUEADO).
				
				Dbselectarea("Z95")    // FAZ UM RECLOCK NA Z95 E ADICIONA O STATUS DOS PEDIDOS BLOQUEADOS
				RECLOCK ("Z95",.T.)
				Z95->Z95_FILIAL := cFilAnt
				Z95->Z95_CLI	:= aValor[i][3]
				Z95->Z95_LOJA 	:= aValor[i][4]
				Z95->Z95_PED	:= aValor[i][2]
				Z95->Z95_DATA	:= DATE()
				Z95->Z95_HORA	:= Left(Time(),5)    
				Z95->Z95_EVENTO	:= "5"
				Z95->Z95_ACAO	:= "Pedido Bloqueado Crédito"
				Z95->Z95_ORC	:= 	aValor[i][5]
				msunlock()
				
				
			ELSE // CASO ESTEJA LIBERADO GRAVA O STATUS LIBERADO
				
				DBCLOSEAREA()
				DBSELECTAREA("Z95")
				RECLOCK ("Z95",.T.)
				Z95->Z95_FILIAL := cFilAnt
				Z95->Z95_CLI	:= aValor[i][3]
				Z95->Z95_LOJA 	:= aValor[i][4]
				Z95->Z95_PED	:= aValor[i][2]
				Z95->Z95_DATA	:= DATE()
				Z95->Z95_HORA	:= Left(Time(),5) 
				Z95->Z95_EVENTO	:= "7"
				Z95->Z95_ACAO	:= "Pedido Liberado Crédito"
				Z95->Z95_ORC	:= aValor[i][5]
				msunlock()
				
				DBCLOSEAREA()
				
				Dbselectarea("SC9")
				
				dbsetorder(1) // FAZ O SET FITER E SETA COMO BLOQUEADO ESTOQUE
				SET FILTER TO C9_FILIAL == cFilAnt .AND. C9_PEDIDO == aValor[i][2]
				Dbgotop()
				while !EOF()
					RecLock("SC9",.F.)
					C9_BLEST := "02"
					MsUnlock()
					dbskip()
				ENDDO
			endif
		ENDIF // FIM SEEK DA VERIFICAÇÃO DO BLOQUEIO
	ENDIF // FIM DO SEEK DA LINHA 99
	DBCLOSEAREA()
NEXT
return

