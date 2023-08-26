/*

Z5.1 - Pokazać miasta wraz ze średnią aktualna
pensją w nich z firm tam się mieszczących
Używając UNION, rozważyć opcję ALL
jak nie ma etatów to 0 pokazujemy
(czyli musimy obsłużyć miasta bez etatów AKT firm)

id_miasta, nazwa (z miasta), avg(pensja) lub 0
jak brak etatow firmowych w danym miescie

Z5.2 - to samo co w Z5.1
Ale z wykorzystaniem LEFT OUTER

Z5.3 Napisać procedurę pokazującą średnią pensję w
osób z miasta - parametr procedure @id_miasta
WYNIK:
id_osoby, imie, nazwisko, avg(pensja)
czyli srednie pensje osob z wszystkich etatow
osob mieszkajacych w danym miescie
*/

/* 1) */

SELECT f.id_miasta, m.nazwa as nazwa_miasta, X.srednia_pensja	/*Wybieram miasta i srędnią pensję*/
	FROM FIRMY f
	join MIASTA m ON (m.id_miasta = f.id_miasta)				/*z firm, znajdujących się w tym miescie*/
	join (SELECT e.id_firmy , AVG(e.pencja) AS srednia_pensja
			FROM ETATY e							/*z etatów, które są*/
			WHERE e.do IS NULL						/*aktywne*/
			GROUP BY e.id_firmy			
		) X ON (X.id_firmy= f.nazwa_skr)		/*należą do tej firmy*/
UNION ALL												/*Dołączam firmy, w których nie ma żadnych etatów*/
SELECT wf.id_miasta, wm.nazwa as nazwa_miasta, CONVERT(money, null) AS XX
	FROM FIRMY wf
	join MIASTA wm ON (wm.id_miasta = wf.id_miasta)
	WHERE NOT EXISTS (SELECT 1 FROM etaty eW WHERE eW.id_firmy = wf.nazwa_skr AND eW.do is null)
	ORDER BY 1, 2
/*
id_miasta   nazwa_miasta                                       srednia_pensja
----------- -------------------------------------------------- ---------------------
1           Warszawa                                           NULL
2           Kolno                                              NULL
3           Suwałki                                            NULL
4           Siedlce                                            6000,00
5           Białystok                                          14000,00
6           Piaseczno                                          9500,00
7           Sejny                                              8000,00
9           Lipsko                                             NULL

(8 row(s) affected)
*/
/* 2) */
SELECT f.id_miasta, m.nazwa as nazwa_miasta, X.srednia_pensja  
	FROM FIRMY f
	join MIASTA m ON (m.id_miasta = f.id_miasta)
	left outer
	join (SELECT e.id_firmy , AVG(e.pencja) AS srednia_pensja
			FROM ETATY e
			WHERE e.do IS NULL
			GROUP BY e.id_firmy
		) X ON (X.id_firmy= f.nazwa_skr)
	ORDER BY f.id_miasta, m.nazwa

/*
id_miasta   nazwa_miasta                                       srednia_pensja
----------- -------------------------------------------------- ---------------------
1           Warszawa                                           NULL
2           Kolno                                              NULL
3           Suwałki                                            NULL
4           Siedlce                                            6000,00
5           Białystok                                          14000,00
6           Piaseczno                                          9500,00
7           Sejny                                              8000,00
9           Lipsko                                             NULL

(8 row(s) affected)
*/

/* 3) */

CREATE PROCEDURE P1(@id_miasta int)
AS
	SELECT o.id_osoby,LEFT(o.imie,10) AS imię, LEFT(o.nazwisko,12) AS nazwisko, X.srednia_pensja
		FROM osoby o
		join (SELECT e.id_osoby, AVG(e.pencja) AS srednia_pensja		/*Dołączam etaty*/
			FROM etaty e
			GROUP BY e.id_osoby								
			) X ON (X.id_osoby = o.id_osoby)							/*które należą do danej osoby*/
		WHERE o.id_miasta = @id_miasta
		ORDER BY o.nazwisko, o.imie
GO

EXEC P1 1
GO

/*
id_osoby    imię       nazwisko     srednia_pensja
----------- ---------- ------------ ---------------------
1           jacek      korytkowski  5000,00
10          amelia     lis          7500,00

(2 row(s) affected)

*/

EXEC P1 6
GO

/*
id_osoby    imię       nazwisko     srednia_pensja
----------- ---------- ------------ ---------------------
7           iza        kalinowska   8750,00
14          kinga      ostrowska    16000,00

(2 row(s) affected)

*/
/*
Tabela z osobami i ich id_miasta dla sprawdzenia poprawności:

select *  
from OSOBY o

id_osoby    id_miasta   imie                                               nazwisko
----------- ----------- -------------------------------------------------- --------------------------------------------------
1           1           jacek                                              korytkowski
2           9           alan                                               sawicki
3           3           marcin                                             kowalski
4           4           fryderyk                                           adamski
5           2           robert                                             laskowski
6           5           olga                                               kozłowska
7           6           iza                                                kalinowska
8           9           alicja                                             wysocka
9           7           grzegorz                                           adamski
10          1           amelia                                             lis
11          4           gabriela                                           piotrowska
12          2           wioletta                                           kołodziej
13          1           agata                                              szczepańska
14          6           kinga                                              ostrowska

(14 row(s) affected)
*/