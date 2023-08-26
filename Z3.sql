/*
Z3.1 - policzyć liczbę etatów w każdym mieście (zapytanie z grupowaniem)
etaty -> firmy (id_miasta)
Najlepiej wynik zapamiętać w tabeli tymczasowej
Z3.2 - korzystając z wyniku Z3,1 - pokazać, które miasto ma największą liczbę etatow
(zapytanie z fa - analogiczne do zadań z Z2)
Z3.3 Pokazać liczbę miast w każdym z województw (czyli grupowanie po kod_woj)
Z3.4 Poazać województwa w których nie ma żadnego miasta
(jak nie ma WOJ w którym nie ma MIAST
to prosze dodać ze 2 takie WOJ )

(suma z3.3 i z3.4 powinna dać nam pełną listę województw -
woj gdzie sa osoby i gdzie ich nie ma to razem powinny byc wszystkie
*/

/*1)*/
	SELECT	COUNT(*)	AS [ile etatów]
		,	COUNT(DISTINCT e.id_osoby) 
						AS [ile osób]
		,	e.id_firmy 
		,	f.nazwa 
		,	f.id_miasta 
	INTO #T
		FROM etaty e
		JOIN firmy f ON (e.id_firmy = f.nazwa_skr)
		GROUP BY e.id_firmy, f.nazwa, f.id_miasta
		ORDER BY 3

/*
Co przechowuje się w tabeli T:
ile etatów  ile osób    id_firmy                                           nazwa                                                                                                id_miasta
----------- ----------- -------------------------------------------------- ---------------------------------------------------------------------------------------------------- -----------
4           4           EVEREST KSIĘGOWY S.C.                              EVEREST KSIĘGOWY Spółka Cywilna                                                                      6
3           3           GOLDI                                              GOLDI Aleksandra Lipińska                                                                            7
2           2           Ideo Sp. z.o.o.                                    Ideo spólka z ograniczoną odpowiedzialnością                                                         3
2           2           Kredyt 4You Sp. z.o.o.                             Kredyt 4You Spółka z ograniczoną odpowiedzialnością                                                  9
4           3           NBC Sp. z.o.o.                                     NBC Spółka z ograniczoną odpowiedzialnością                                                          4
5           5           Netiology Sp. z.o.o.                               Netiology Spółka z ograniczoną odpowiadzelnością                                                     5

(6 row(s) affected)
*/

/*2)*/
	SELECT t.*
	FROM #T t
	WHERE t.[ile etatów] = (SELECT MAX(t.[ile etatów]) FROM #T t)	/*szukamy największą liczbę etatów i wiersz, który jej odpowiada*/
/*
ile etatów  ile osób    id_firmy                                           nazwa                                                                                                id_miasta
----------- ----------- -------------------------------------------------- ---------------------------------------------------------------------------------------------------- -----------
5           5           Netiology Sp. z.o.o.                               Netiology Spółka z ograniczoną odpowiadzelnością                                                     5

(1 row(s) affected)
*/

/*3*/
	SELECT	COUNT(*)	AS [ile miast]
		,	w.kod_woj
		,	w.nazwa AS [nazwa województwa]
		FROM MIASTA m
		JOIN WOJ w ON (m.kod_woj = w.kod_woj)
		GROUP BY w.kod_woj, w.nazwa
		ORDER BY 3
/*
ile miast   kod_woj nazwa województwa
----------- ------- --------------------------------------------------
5           MAZ     MAZOWIECKIE
4           POD     PODLASKIE

(2 row(s) affected)
*/

/*4)*/
	SELECT w.kod_woj
	,	w.nazwa AS [nazwa województwa]
	FROM WOJ w
	WHERE		/*szukam województwa, kody których nie są przypisane do żadnego miasta w tabeli MIASTA*/
	NOT EXISTS 
	(SELECT 1 FROM MIASTA m WHERE m.kod_woj = w.kod_woj)
/*
kod_woj nazwa województwa
------- --------------------------------------------------
DOL     DOLNOŚLĄSKIE
LUB     LUBELSKIE

(2 row(s) affected)
*/

/*Sprawdzę, czy województwa z zadania 3 i 4 stanowią pełną listę województw*/
/*select * from WOJ */
/*
kod_woj nazwa
------- --------------------------------------------------
DOL     DOLNOŚLĄSKIE
LUB     LUBELSKIE
MAZ     MAZOWIECKIE
POD     PODLASKIE

(4 row(s) affected)
*/