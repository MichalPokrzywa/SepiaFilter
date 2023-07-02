.DATA
;Sta³e u¿ywane do obliczania wartoœci koloru piksela 
	RRedFactor	DD 0.393,0.349,0.272		;Tablica wartoœci procentowej do obliczenia R pixela
	RGreenFactor DD 0.769,0.686,0.534		;Tablica wartoœci procentowej do obliczenia G pixela
	RBlueFactor	DD 0.189,0.168,0.131		;Tablica wartoœci procentowej do obliczenia B pixela
	ArrrayByte1 QWORD ?   ; 64-bit			;Zmienna do przechowania obliczonego wyniku
	ArrrayByte2 QWORD ?   ; 64-bit			;Zmienna do przechowania obliczonego wyniku
	ArrrayByte3 QWORD ?   ; 64-bit			;Zmienna do przechowania obliczonego wyniku
	MaxValue	QWORD 255 ; 64-bit			;Zmienna która przechowuje maksymaln¹ wartoœæ jak¹ mo¿e mieæ pojedyñczy pixel
.code
SepiaTone proc
xor r8, r8									;wyzerowanie (do przechowywania wartoœci R)
xor r9, r9									;wyzerowanie (do przechowywania wartoœci G)
xor r10, r10								;wyzerowanie (do przechowywania wartoœci B)
movq xmm0, r8								;wyzerowanie rejestru, bêdzie s³u¿y³ do wyliczenia wartoœci R piksela na wyjœciu
movq xmm1, r9								;wyzerowanie rejestru, bêdzie s³u¿y³ do wyliczenia wartoœci G piksela na wyjœciu
movq xmm2, r10								;wyzerowanie rejestru, bêdzie s³u¿y³ do wyliczenia wartoœci B piksela na wyjœciu
mov r8b, [rcx + 0]							;Odczytanie wartoœci R z piksela
mov r9b, [rcx + 1]							;Odczytanie wartoœci G z piksela
mov r10b, [rcx + 2]							;Odczytanie wartoœci B z piksela
;Operacja mno¿enia wartoœciach R z piksela
cvtsi2ss xmm1, r8							;Wczytywanie do rejestru inputRedPixel jako zmiennoprzecinkow¹
mulss xmm1, [RRedFactor + 0]                ;Pomno¿enie Pierwszego inputRedPixel * 0.393
shufps xmm1,xmm1,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm1, r8							;Wczytywanie do rejestru inputRedPixel jako zmiennoprzecinkow¹
mulss xmm1, [RRedFactor + 4]				;Pomno¿enie Drugiego inputRedPixel * 0.349
shufps xmm1,xmm1,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm1, r8							;Wczytywanie do rejestru inputRedPixel jako zmiennoprzecinkow¹
mulss xmm1, [RRedFactor + 8]				;Pomno¿enie Trzeciego inputRedPixel * 0.272
shufps xmm1,xmm1,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
shufps xmm1,xmm1,39h						;Przsuniêcie rejestru w prawo jeszcze raz aby na najstarszych bitach by³o 0
;Operacja mno¿enia wartoœci na G z pixela
cvtsi2ss xmm2, r9							;Wczytywanie do rejestru inputGreenPixel jako zmiennoprzecinkow¹
mulss xmm2,[RGreenFactor + 0]				;Pomno¿enie Pierwszego inputGreenPixel * 0.769
shufps xmm2,xmm2,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm2, r9							;Wczytywanie do rejestru inputGreenPixel jako zmiennoprzecinkow¹
mulss xmm2,[RGreenFactor + 4]				;Pomno¿enie Drugiego inputGreenPixel * 0.686
shufps xmm2,xmm2,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm2, r9                           ;Wczytywanie do rejestru inputGreenPixel jako zmiennoprzecinkow¹
mulss xmm2,[RGreenFactor + 8]				;Pomno¿enie Trzeciego inputGreenPixel * 0.534
shufps xmm2,xmm2,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
shufps xmm2,xmm2,39h						;Przsuniêcie rejestru w prawo jeszcze raz aby na najstarszych bitach by³o 0
;Operacja mno¿enia wartoœci na B z pixela
cvtsi2ss xmm3, r10							;Wczytywanie do rejestru inputBluePixel jako zmiennoprzecinkow¹
mulss xmm3, [RBlueFactor + 0]				;Pomno¿enie Pierwszego inputBluePixel * 0.189
shufps xmm3,xmm3,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm3, r10							;Wczytywanie do rejestru inputBluePixel jako zmiennoprzecinkow¹
mulss xmm3, [RBlueFactor + 4]				;Pomno¿enie Drugiego inputBluePixel * 0.168
shufps xmm3,xmm3,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
cvtsi2ss xmm3, r9							;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
mulss xmm3, [RBlueFactor + 8]				;Pomno¿enie Trzeciego inputBluePixel * 0.131
shufps xmm3,xmm3,39h						;Przsuniêcie rejestru w prawo (przesuwa liczbe na najstarsze bity)
shufps xmm3,xmm3,39h						;Przsuniêcie rejestru w prawo jeszcze raz aby na najstarszych bitach by³o 0
addps xmm1,xmm2								;Dodanie wektorowo przeliczonych wartoœci R i G 
addps xmm1,xmm3								;Dodanie wektorowo przeliczonych wartoœci RG i B	
cvttss2si rax, xmm1							;Pobieranie wyniku wartoœci R pixela 
cmp rax, MaxValue							;Porównanie czy wynik jest wiêkszy ni¿ 255
jg RGreaterThan255							;Skok jeœli wynik jest wiêkszy ni¿ 255
End1:
	mov ArrrayByte1, rax					;Wpisuje wartoœæ do ArrrayByte1 aby zapisaæ wynik
shufps xmm1,xmm1,39h						;Przsuniêcie rejestru w prawo
cvttss2si rax, xmm1							;Pobieranie wyniku wartoœci G pixela 
cmp rax, MaxValue							;Porównanie czy wynik jest wiêkszy ni¿ 255
jg GGreaterThan255							;Skok jeœli wiêksze ni¿ 255
End2:											
	mov ArrrayByte2, rax					;Wpisuje wartoœæ do ArrrayByte2 aby zapisaæ wynik
shufps xmm1,xmm1,39h						;Przsuniêcie rejestru w prawo
cvttss2si rax, xmm1							;Pobieranie wyniku wartoœci B pixela 
cmp rax, MaxValue							;Porównanie czy wynik jest wiêkszy ni¿ 255
jg BGreaterThan255							;skok jeœli wiêksze ni¿ 255
End3:
	mov ArrrayByte3, rax					;Wpisuje wartoœæ do ArrrayByte2 aby zapisaæ wynik

mov rax,ArrrayByte1							;Przepisuje wartoœæ R pixela do rax
mov [rcx + 0], rax							;Nadpisuje wartoœæ R pixela do tabeli byte
mov rax,ArrrayByte2							;Przepisuje wartoœæ G pixela do rax
mov [rcx + 1], rax							;Nadpisuje wartoœæ G do tabeli tabeli byte
mov rax,ArrrayByte3							;Przepisuje wartoœæ B pixela do rax
mov [rcx + 2], rax							;Nadpisuje wartoœæ B pixela do tabeli bytr
ret

RGreaterThan255:
	mov rax, 255							;Wpisuje do rax wartoœæ 255
	jmp End1								;Powrót do pêtli	

GGreaterThan255:
	mov rax, 255		;Wpisuje do rax wartoœæ 255
	jmp End2			;Powrót do pêtli

BGreaterThan255:
	mov rax, 255		;Wpisuje do rax wartoœæ 255
	jmp End3			;Powrót do pêtli

SepiaTone endp
end