.DATA
;Sta�e u�ywane do obliczania warto�ci koloru piksela 
	RRedFactor	DD 0.393,0.349,0.272		;Tablica warto�ci procentowej do obliczenia R pixela
	RGreenFactor DD 0.769,0.686,0.534		;Tablica warto�ci procentowej do obliczenia G pixela
	RBlueFactor	DD 0.189,0.168,0.131		;Tablica warto�ci procentowej do obliczenia B pixela
	ArrrayByte1 QWORD ?   ; 64-bit			;Zmienna do przechowania obliczonego wyniku
	ArrrayByte2 QWORD ?   ; 64-bit			;Zmienna do przechowania obliczonego wyniku
	ArrrayByte3 QWORD ?   ; 64-bit			;Zmienna do przechowania obliczonego wyniku
	MaxValue	QWORD 255 ; 64-bit			;Zmienna kt�ra przechowuje maksymaln� warto�� jak� mo�e mie� pojedy�czy pixel
.code
SepiaTone proc
xor r8, r8									;wyzerowanie (do przechowywania warto�ci R)
xor r9, r9									;wyzerowanie (do przechowywania warto�ci G)
xor r10, r10								;wyzerowanie (do przechowywania warto�ci B)
movq xmm0, r8								;wyzerowanie rejestru, b�dzie s�u�y� do wyliczenia warto�ci R piksela na wyj�ciu
movq xmm1, r9								;wyzerowanie rejestru, b�dzie s�u�y� do wyliczenia warto�ci G piksela na wyj�ciu
movq xmm2, r10								;wyzerowanie rejestru, b�dzie s�u�y� do wyliczenia warto�ci B piksela na wyj�ciu
mov r8b, [rcx + 0]							;Odczytanie warto�ci R z piksela
mov r9b, [rcx + 1]							;Odczytanie warto�ci G z piksela
mov r10b, [rcx + 2]							;Odczytanie warto�ci B z piksela
;Operacja mno�enia warto�ciach R z piksela
cvtsi2ss xmm1, r8							;Wczytywanie do rejestru inputRedPixel jako zmiennoprzecinkow�
mulss xmm1, [RRedFactor + 0]                ;Pomno�enie Pierwszego inputRedPixel * 0.393
shufps xmm1,xmm1,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm1, r8							;Wczytywanie do rejestru inputRedPixel jako zmiennoprzecinkow�
mulss xmm1, [RRedFactor + 4]				;Pomno�enie Drugiego inputRedPixel * 0.349
shufps xmm1,xmm1,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm1, r8							;Wczytywanie do rejestru inputRedPixel jako zmiennoprzecinkow�
mulss xmm1, [RRedFactor + 8]				;Pomno�enie Trzeciego inputRedPixel * 0.272
shufps xmm1,xmm1,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
shufps xmm1,xmm1,39h						;Przsuni�cie rejestru w prawo jeszcze raz aby na najstarszych bitach by�o 0
;Operacja mno�enia warto�ci na G z pixela
cvtsi2ss xmm2, r9							;Wczytywanie do rejestru inputGreenPixel jako zmiennoprzecinkow�
mulss xmm2,[RGreenFactor + 0]				;Pomno�enie Pierwszego inputGreenPixel * 0.769
shufps xmm2,xmm2,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm2, r9							;Wczytywanie do rejestru inputGreenPixel jako zmiennoprzecinkow�
mulss xmm2,[RGreenFactor + 4]				;Pomno�enie Drugiego inputGreenPixel * 0.686
shufps xmm2,xmm2,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm2, r9                           ;Wczytywanie do rejestru inputGreenPixel jako zmiennoprzecinkow�
mulss xmm2,[RGreenFactor + 8]				;Pomno�enie Trzeciego inputGreenPixel * 0.534
shufps xmm2,xmm2,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
shufps xmm2,xmm2,39h						;Przsuni�cie rejestru w prawo jeszcze raz aby na najstarszych bitach by�o 0
;Operacja mno�enia warto�ci na B z pixela
cvtsi2ss xmm3, r10							;Wczytywanie do rejestru inputBluePixel jako zmiennoprzecinkow�
mulss xmm3, [RBlueFactor + 0]				;Pomno�enie Pierwszego inputBluePixel * 0.189
shufps xmm3,xmm3,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm3, r10							;Wczytywanie do rejestru inputBluePixel jako zmiennoprzecinkow�
mulss xmm3, [RBlueFactor + 4]				;Pomno�enie Drugiego inputBluePixel * 0.168
shufps xmm3,xmm3,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm3, r9							;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
mulss xmm3, [RBlueFactor + 8]				;Pomno�enie Trzeciego inputBluePixel * 0.131
shufps xmm3,xmm3,39h						;Przsuni�cie rejestru w prawo (przesuwa liczbe na najstarsze bity)
shufps xmm3,xmm3,39h						;Przsuni�cie rejestru w prawo jeszcze raz aby na najstarszych bitach by�o 0
addps xmm1,xmm2								;Dodanie wektorowo przeliczonych warto�ci R i G 
addps xmm1,xmm3								;Dodanie wektorowo przeliczonych warto�ci RG i B	
cvttss2si rax, xmm1							;Pobieranie wyniku warto�ci R pixela 
cmp rax, MaxValue							;Por�wnanie czy wynik jest wi�kszy ni� 255
jg RGreaterThan255							;Skok je�li wynik jest wi�kszy ni� 255
End1:
	mov ArrrayByte1, rax					;Wpisuje warto�� do ArrrayByte1 aby zapisa� wynik
shufps xmm1,xmm1,39h						;Przsuni�cie rejestru w prawo
cvttss2si rax, xmm1							;Pobieranie wyniku warto�ci G pixela 
cmp rax, MaxValue							;Por�wnanie czy wynik jest wi�kszy ni� 255
jg GGreaterThan255							;Skok je�li wi�ksze ni� 255
End2:											
	mov ArrrayByte2, rax					;Wpisuje warto�� do ArrrayByte2 aby zapisa� wynik
shufps xmm1,xmm1,39h						;Przsuni�cie rejestru w prawo
cvttss2si rax, xmm1							;Pobieranie wyniku warto�ci B pixela 
cmp rax, MaxValue							;Por�wnanie czy wynik jest wi�kszy ni� 255
jg BGreaterThan255							;skok je�li wi�ksze ni� 255
End3:
	mov ArrrayByte3, rax					;Wpisuje warto�� do ArrrayByte2 aby zapisa� wynik

mov rax,ArrrayByte1							;Przepisuje warto�� R pixela do rax
mov [rcx + 0], rax							;Nadpisuje warto�� R pixela do tabeli byte
mov rax,ArrrayByte2							;Przepisuje warto�� G pixela do rax
mov [rcx + 1], rax							;Nadpisuje warto�� G do tabeli tabeli byte
mov rax,ArrrayByte3							;Przepisuje warto�� B pixela do rax
mov [rcx + 2], rax							;Nadpisuje warto�� B pixela do tabeli bytr
ret

RGreaterThan255:
	mov rax, 255							;Wpisuje do rax warto�� 255
	jmp End1								;Powr�t do p�tli	

GGreaterThan255:
	mov rax, 255		;Wpisuje do rax warto�� 255
	jmp End2			;Powr�t do p�tli

BGreaterThan255:
	mov rax, 255		;Wpisuje do rax warto�� 255
	jmp End3			;Powr�t do p�tli

SepiaTone endp
end