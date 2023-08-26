/*

1) Pokazać dane podstawowe osoby, w jakim mieście mieszka i w jakim to jest województwie

2) Pokazać wszystkie etaty gdzie id_firmy zaczyna się na literę M i kończy na X lub Y
(jeżeli nie macie takowych to wybierzcie takie warunki - inną literę początkową i inne 2 końcowe aby wybrały się takie M%I lub takie M%Y)
które mają pensje pomiędzy 3000 a 5000 (też możecie zmienić jeżeli macie głownie inne zakresy)
mieszkające w województwie o kodzie XX (proszę wybrać dowolne)
(wystarczą dane z tabel etaty, firmy, osoby , miasta - w miastach jest kod_woj)

3) Pokazać kto ma najdłuższe imie w bazie
(najpierw szukamy MAX z LEN(imie) a potem pokazujemy te osoby z taką długością imienia)

4) Policzyć liczbę miast w wybranym WOJ (tu daję Wam wybór - w którym WOJ macie najwięcej)*/

/*1)*/
/*Wyświetlamy dane osoby z tabeli OSOBY, wraz z miastem z tabeli MIASTA, któremy odpowiada id_miasta w OSOBY,
	i województwem z tabeli WOJ, któremu odpowiada id_woj w MIASTA */
SELECT o.id_osoby AS id_osoby,
		CONVERT(nvarchar(30), o.imie) AS imie
		,CONVERT(nvarchar(30), o.nazwisko) AS nazwisko
		,CONVERT(nvarchar(30), w.nazwa) AS wojewodztwo
		,CONVERT(nvarchar(30), m.nazwa) AS miasto
FROM OSOBY o
join MIASTA m on (o.id_miasta = m.id_miasta)
join WOJ w on (m.kod_woj = w.kod_woj)

/*
id_osoby    imie                           nazwisko                       wojewodztwo                    miasto
----------- ------------------------------ ------------------------------ ------------------------------ ------------------------------
1           jacek                          korytkowski                    MAZOWIECKIE                    Warszawa
2           alan                           sawicki                        MAZOWIECKIE                    Lipsko
3           marcin                         kowalski                       PODLASKIE                      Suwałki
4           fryderyk                       adamski                        MAZOWIECKIE                    Siedlce
5           robert                         laskowski                      PODLASKIE                      Kolno
6           olga                           kozłowska                      PODLASKIE                      Białystok
7           iza                            kalinowska                     MAZOWIECKIE                    Piaseczno
8           alicja                         wysocka                        MAZOWIECKIE                    Lipsko
9           grzegorz                       adamski                        PODLASKIE                      Sejny
10          amelia                         lis                            MAZOWIECKIE                    Warszawa
11          gabriela                       piotrowska                     MAZOWIECKIE                    Siedlce
12          wioletta                       kołodziej                      PODLASKIE                      Kolno
13          agata                          szczepańska                    MAZOWIECKIE                    Warszawa
14          kinga                          ostrowska                      MAZOWIECKIE                    Piaseczno

(14 rows affected)
*/

/*2)*/

SELECT	CONVERT(nvarchar(30), e.id_firmy) AS id_firmy
	,	STR(e.pencja, 5,0)	AS pensja
	,	CONVERT(nchar(6), e.od, 112) 
							AS od_mies
	,	CONVERT(nchar(6), e.do, 112) 
							AS do_mies
	,	convert(nvarchar(20)
			, LEFT(o.imie,1)+N'.'+LEFT(o.nazwisko,17))
							AS osoba
	,	LEFT(mO.nazwa,15)	AS [miasto osoby]
	,	LEFT(mO.kod_woj,15)	AS [województwo osoby]
	,	CONVERT(nvarchar(60), f.nazwa) AS firma
	,	LEFT(mF.nazwa,15)	AS [miasto firmy]
	FROM ETATY e
	join OSOBY o ON (o.id_osoby = e.id_osoby)
	join firmy f ON (e.id_firmy = f.nazwa_skr)
	join miasta mO
				ON (mO.id_miasta = o.id_miasta)
	join miasta mF 
				ON (f.id_miasta = mF.id_miasta)
				/*W mojej tabeli nie ma firm, zaczynających się na jedną literę i kończoncych się na różne,
				 więc poszukuję firm ze wspólnym znakiem końcowym i różnymi literami na początku*/
	WHERE ((e.id_firmy like N'N%.') OR (e.id_firmy like N'K%.')) 
			/*Pensja od 5000 zł. do 9000 zł.*/
	AND (e.pencja >= 5000) AND (e.pencja <= 9000)
			/*Osoba mieszka w województwie Podlaskim o kodzie POD*/
	AND (mO.kod_woj = N'POD')
/*
id_firmy                       pensja od_mies do_mies osoba                miasto osoby    województwo osoby firma                                                        miasto firmy
------------------------------ ------ ------- ------- -------------------- --------------- ----------------- ------------------------------------------------------------ ---------------
Kredyt 4You Sp. z.o.o.          8500  199903  201005  m.kowalski           Suwałki         POD               Kredyt 4You Spółka z ograniczoną odpowiedzialnością          Lipsko
NBC Sp. z.o.o.                  6000  201204  NULL    o.kozłowska          Białystok       POD               NBC Spółka z ograniczoną odpowiedzialnością                  Siedlce
Netiology Sp. z.o.o.            8000  200102  200510  g.adamski            Sejny           POD               Netiology Spółka z ograniczoną odpowiadzelnością             Białystok
NBC Sp. z.o.o.                  5500  200607  201112  o.kozłowska          Białystok       POD               NBC Spółka z ograniczoną odpowiedzialnością                  Siedlce

(4 rows affected)
*/

/*3)*/
/*Wybieramy z tabeli OSOBY rekordy ludzi, długość imienia których jest równa maksymalnej długości imienia w tabeli*/

SELECT o.id_osoby, o.imie, o.nazwisko
FROM OSOBY o
WHERE LEN(o.imie) = (SELECT MAX(LEN(OSOBY.imie)) FROM OSOBY)

/*
id_osoby    imie                                               nazwisko
----------- -------------------------------------------------- --------------------------------------------------
4           fryderyk                                           adamski
9           grzegorz                                           adamski
11          gabriela                                           piotrowska
12          wioletta                                           kołodziej

(4 rows affected)
*/

/*4)*/
/*Wyświetlamy liczbę miast, które są przypisane do województwa o kodzie MAZ*/

select count(m.kod_woj) as [Liczba miast w województwie MAZ]
FROM MIASTA m WHERE m.kod_woj = N'MAZ'
/*
Liczba miast w województwie MAZ
-------------------------------
5

(1 row affected)
*/

/*Lista miast w województwie MAZ*/
select * from MIASTA m WHERE m.kod_woj = N'MAZ'

/*
id_miasta   kod_woj nazwa
----------- ------- --------------------------------------------------
1           MAZ     Warszawa
4           MAZ     Siedlce
6           MAZ     Piaseczno
8           MAZ     Serpc
9           MAZ     Lipsko

(5 rows affected)
*/