/* ID_OSOBY w OSOBY i ID_MIASTA w MIASTA samonumerujące IDENTITY
** to jedyne kolumny typu INT (jak i klucze obce do nich)
** OD i DO to DATETIME, PENSJA to MONEY, wszystkie pozostałe 
** nchar i nvarchar. Jedyna typu NULL to DO w ETATY, pozostałe NOT NULL
*/
IF OBJECT_ID(N'ETATY') IS NOT NULL
	DROP TABLE ETATY
GO
IF OBJECT_ID(N'OSOBY') IS NOT NULL
	DROP TABLE OSOBY
GO
IF OBJECT_ID(N'FIRMY') IS NOT NULL
	DROP TABLE FIRMY
GO
IF OBJECT_ID(N'MIASTA') IS NOT NULL
	DROP TABLE MIASTA
GO
IF OBJECT_ID(N'WOJ') IS NOT NULL
	DROP TABLE WOJ
GO
CREATE TABLE dbo.WOJ 
(	kod_woj nchar(4)	NOT NULL CONSTRAINT PK_WOJ PRIMARY KEY
,	nazwa	nvarchar(50) NOT NULL
)
GO
CREATE TABLE dbo.MIASTA
(	id_miasta	int				not null IDENTITY CONSTRAINT PK_MIASTA PRIMARY KEY
,	kod_woj		nchar(4)		NOT NULL 
	CONSTRAINT FK_MIASTA_WOJ FOREIGN KEY REFERENCES WOJ(kod_woj)
,	nazwa		nvarchar(50)	NOT NULL
/* klucz obcy to powiązanie do lucza głownego w innej tabelce
** typy kolumn muszą się zgadzac - nazwy nie muszą */ 
)
GO
CREATE TABLE dbo.OSOBY
(	id_osoby int NOT NULL IDENTITY	CONSTRAINT PK_OSOBY PRIMARY KEY
,	id_miasta	int				not null CONSTRAINT FK_OSOBY_MIASTA FOREIGN KEY
		REFERENCES MIASTA(id_miasta)
,	imie		nvarchar(50)	NOT NULL
,	nazwisko	nvarchar(50)	NOT NULL 	
/* klucz obcy to powiązanie do lucza głownego w innej tabelce
** typy kolumn muszą się zgadzac - nazwy nie muszą */ 
)
GO
CREATE TABLE dbo.FIRMY
(	nazwa_skr nchar(50) NOT NULL CONSTRAINT PK_FIRMY PRIMARY KEY,	
id_miasta int not null CONSTRAINT FK_FIRMY_MIASTA FOREIGN KEY REFERENCES MIASTA(id_miasta),
nazwa nvarchar(100) NOT NULL, 
kod_pocztowy nchar(6) NOT NULL,
ulica nvarchar(50) NOT NULL
)
GO
CREATE TABLE dbo.ETATY
(	id_osoby int not null CONSTRAINT FK_ETATY_OSOBY FOREIGN KEY REFERENCES OSOBY(id_osoby),
id_firmy nchar(50) not null CONSTRAINT FK_ETATY_FIRMY FOREIGN KEY REFERENCES FIRMY(nazwa_skr),
stanowisko nvarchar(50) not null,
pencja money not null,
od date not null,
do date null,
id_etatu int not null IDENTITY CONSTRAINT PK_ETATY PRIMARY KEY
)
GO

/*Wypełniam tabelę WOJ*/
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'MAZ', N'MAZOWIECKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'LUB', N'LUBELSKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'DOL', N'DOLNOŚLĄSKIE')
INSERT INTO WOJ (kod_woj, nazwa) VALUES (N'POD', N'PODLASKIE')

/*Zmienne do identyfikatorów miast id_miasta z tabeli MIASTA*/
DECLARE @id_wa int, @id_ko int, @id_su int, @id_sie int, @id_bia int, @id_pia int, @id_sej int, @id_ser int, @id_lip int

/* Wypełniam tabelę MIASTA*/
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Warszawa', N'MAZ')
SET @id_wa = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Kolno', N'POD')
SET @id_ko = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Suwałki', N'POD')
SET @id_su = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Siedlce', N'MAZ')
SET @id_sie = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Białystok', N'POD')
SET @id_bia = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Piaseczno', N'MAZ')
SET @id_pia = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Sejny', N'POD')
SET @id_sej = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Serpc', N'MAZ')
SET @id_ser = SCOPE_IDENTITY()
INSERT INTO MIASTA (nazwa, kod_woj)VALUES (N'Lipsko', N'MAZ')
SET @id_lip = SCOPE_IDENTITY()

/*Zmienne do identyfikatorów osób id_osoby z tabeli OSOBY*/
DECLARE @id_jk int, @id_as int, @id_mk int, @id_fa int, @id_rl int, @id_ok int, @id_ik int, @id_aw int, @id_ga int, @id_al int, @id_gp int, @id_wk int, @id_ags int, @id_kos int

/*Wypełniam tabelę OSOBY*/
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_wa, N'jacek' , N'korytkowski')
SET @id_jk = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_lip, N'alan' , N'sawicki')
SET @id_as = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_su, N'marcin' , N'kowalski')
SET @id_mk = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_sie, N'fryderyk' , N'adamski')
SET @id_fa = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_ko, N'robert' , N'laskowski')
SET @id_rl = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_bia, N'olga' , N'kozłowska')
SET @id_ok = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_pia, N'iza' , N'kalinowska')
SET @id_ik = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_lip, N'alicja' , N'wysocka')
SET @id_aw = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_sej, N'grzegorz' , N'adamski')
SET @id_ga = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_wa, N'amelia' , N'lis')
SET @id_al = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_sie, N'gabriela' , N'piotrowska')
SET @id_gp = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_ko, N'wioletta' , N'kołodziej')
SET @id_wk = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_wa, N'agata' , N'szczepańska')
SET @id_ags = SCOPE_IDENTITY()
INSERT INTO OSOBY (id_miasta, imie, nazwisko) VALUES (@id_pia, N'kinga' , N'ostrowska')
SET @id_kos = SCOPE_IDENTITY()

/*Zmienne do skróconych nazw firm nazwa_skr z tabeli FIRMY*/
DECLARE @id_drex nvarchar(50), @id_ideo nvarchar(50), @id_hussar nvarchar(50), @id_kredyt nvarchar(50), @id_nbc nvarchar(50), @id_everest nvarchar(50), @id_net nvarchar(50), @id_goldi nvarchar(50)

/*Wypełniam tabelę FIRMY*/
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'P.H.DREXPOL', @id_wa, N'P.H.DREXPOL - Wiesław Zuch', N'02-031', N'Orkana 2')
SET @id_drex = N'P.H.DREXPOL'
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'Ideo Sp. z.o.o.', @id_su, N'Ideo spólka z ograniczoną odpowiedzialnością', N'16-400', N'Krakowska 16')
SET @id_ideo = N'Ideo Sp. z.o.o.'
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'HUSSAR GRUPPA S.A.', @id_ko, N'HUSSAR GRUPPA Spółka akcyjna', N'18-500', N'Pileskiego 23')
SET @id_hussar = N'HUSSAR GRUPPA S.A.'
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'Kredyt 4You Sp. z.o.o.', @id_lip,N'Kredyt 4You Spółka z ograniczoną odpowiedzialnością', N'27-300', N'Sosnowiecka 45')
SET @id_kredyt = N'Kredyt 4You Sp. z.o.o.'
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'NBC Sp. z.o.o.', @id_sie, N'NBC Spółka z ograniczoną odpowiedzialnością', N'53-508', N'Prosta 36')
SET @id_nbc = N'NBC Sp. z.o.o.'
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'EVEREST KSIĘGOWY S.C.', @id_pia, N'EVEREST KSIĘGOWY Spółka Cywilna', N'13-682', N'Hoża 86')
SET @id_everest = N'EVEREST KSIĘGOWY S.C.'
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'Netiology Sp. z.o.o.', @id_bia, N'Netiology Spółka z ograniczoną odpowiadzelnością', N'61-896', N'Towarowa 2')
SET @id_net = N'Netiology Sp. z.o.o.'
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (N'GOLDI', @id_sej, N'GOLDI Aleksandra Lipińska', N'34-300', N'Okrzei 12')
SET @id_goldi = N'GOLDI'

/*Wypełniam tabelę ETATY*/
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_as, @id_goldi, N'Administrator serwerów', '10000', '2003-06-23', '2006-02-12')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_mk, @id_kredyt, N'Asystent handlowy', '8500', '1999-03-15', '2010-05-13')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_rl, @id_everest, N'Notariusz', '15000', '2010-09-19', '2021-03-30')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_fa, @id_ideo, N'Hydraulik', '8500', '1999-03-15', '2010-05-13')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_jk, @id_nbc, N'Ochroniarz', '5000', '2003-12-14', '2004-04-23')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_ik, @id_net, N'Manager', '7500', '2001-04-23', '2007-08-10')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_aw, @id_net, N'HR Manager', '7000', '2004-05-16', '2010-08-23')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od) VALUES (@id_ok, @id_nbc, N'Monter', '6000', '2012-04-28')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_al, @id_kredyt, N'Pracownik biurowy', '7500', '2008-11-13', '2012-04-17')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od) VALUES (@id_wk, @id_everest, N'Programista PHP', '9500', '2020-06-10')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_kos, @id_ideo, N'Prezes', '15000', '2015-10-07', '2022-02-23')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od) VALUES (@id_gp, @id_goldi, N'Redaktor techniczny', '8000', '2001-02-10')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_ga, @id_net, N'Researczer', '8000', '2001-02-20', '2005-10-15')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od) VALUES (@id_mk, @id_net, N'Inspektor nadzoru', '11000', '2010-06-10')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_fa, @id_everest, N'Laborant', '7500', '1998-03-27', '1998-11-16')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_ik, @id_nbc, N'Manager', '10000', '2008-01-22', '2019-10-26')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_aw, @id_goldi, N'Diagnosta', '9500', '2012-05-18', '2022-03-09')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_kos, @id_everest, N'Dyrektor Marketu', '17000', '2004-06-13', '2015-08-25')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od) VALUES (@id_rl, @id_net, N'Notariusz', '17000', '2022-01-24')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES (@id_ok, @id_nbc, N'Monter', '5500', '2006-07-18', '2011-12-17')

select * from WOJ
/*
kod_woj nazwa
------- --------------------------------------------------
DOL     DOLNOŚLĄSKIE
LUB     LUBELSKIE
MAZ     MAZOWIECKIE
POD     PODLASKIE

(4 rows affected)
*/
select * from MIASTA
/*
id_miasta   kod_woj nazwa
----------- ------- --------------------------------------------------
1           MAZ     Warszawa
2           POD     Kolno
3           POD     Suwałki
4           MAZ     Siedlce
5           POD     Białystok
6           MAZ     Piaseczno
7           POD     Sejny
8           MAZ     Serpc
9           MAZ     Lipsko

(9 rows affected)
*/
select * from FIRMY
/*
nazwa_skr                                          id_miasta   nazwa                                                                                                kod_pocztowy ulica
-------------------------------------------------- ----------- ---------------------------------------------------------------------------------------------------- ------------ --------------------------------------------------
EVEREST KSIĘGOWY S.C.                              6           EVEREST KSIĘGOWY Spółka Cywilna                                                                      13-682       Hoża 86
GOLDI                                              7           GOLDI Aleksandra Lipińska                                                                            34-300       Okrzei 12
HUSSAR GRUPPA S.A.                                 2           HUSSAR GRUPPA Spółka akcyjna                                                                         18-500       Pileskiego 23
Ideo Sp. z.o.o.                                    3           Ideo spólka z ograniczoną odpowiedzialnością                                                         16-400       Krakowska 16
Kredyt 4You Sp. z.o.o.                             9           Kredyt 4You Spółka z ograniczoną odpowiedzialnością                                                  27-300       Sosnowiecka 45
NBC Sp. z.o.o.                                     4           NBC Spółka z ograniczoną odpowiedzialnością                                                          53-508       Prosta 36
Netiology Sp. z.o.o.                               5           Netiology Spółka z ograniczoną odpowiadzelnością                                                     61-896       Towarowa 2
P.H.DREXPOL                                        1           P.H.DREXPOL - Wiesław Zuch                                                                           02-031       Orkana 2

(8 rows affected)
*/
select * from OSOBY
/*
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

(14 rows affected)
*/
select * from ETATY
/*
id_osoby    id_firmy                                           stanowisko                                         pencja                od         do         id_etatu
----------- -------------------------------------------------- -------------------------------------------------- --------------------- ---------- ---------- -----------
2           GOLDI                                              Administrator serwerów                             10000,00              2003-06-23 2006-02-12 1
3           Kredyt 4You Sp. z.o.o.                             Asystent handlowy                                  8500,00               1999-03-15 2010-05-13 2
5           EVEREST KSIĘGOWY S.C.                              Notariusz                                          15000,00              2010-09-19 2021-03-30 3
4           Ideo Sp. z.o.o.                                    Hydraulik                                          8500,00               1999-03-15 2010-05-13 4
1           NBC Sp. z.o.o.                                     Ochroniarz                                         5000,00               2003-12-14 2004-04-23 5
7           Netiology Sp. z.o.o.                               Manager                                            7500,00               2001-04-23 2007-08-10 6
8           Netiology Sp. z.o.o.                               HR Manager                                         7000,00               2004-05-16 2010-08-23 7
6           NBC Sp. z.o.o.                                     Monter                                             6000,00               2012-04-28 NULL       8
10          Kredyt 4You Sp. z.o.o.                             Pracownik biurowy                                  7500,00               2008-11-13 2012-04-17 9
12          EVEREST KSIĘGOWY S.C.                              Programista PHP                                    9500,00               2020-06-10 NULL       10
14          Ideo Sp. z.o.o.                                    Prezes                                             15000,00              2015-10-07 2022-02-23 11
11          GOLDI                                              Redaktor techniczny                                8000,00               2001-02-10 NULL       12
9           Netiology Sp. z.o.o.                               Researczer                                         8000,00               2001-02-20 2005-10-15 13
3           Netiology Sp. z.o.o.                               Inspektor nadzoru                                  11000,00              2010-06-10 NULL       14
4           EVEREST KSIĘGOWY S.C.                              Laborant                                           7500,00               1998-03-27 1998-11-16 15
7           NBC Sp. z.o.o.                                     Manager                                            10000,00              2008-01-22 2019-10-26 16
8           GOLDI                                              Diagnosta                                          9500,00               2012-05-18 2022-03-09 17
14          EVEREST KSIĘGOWY S.C.                              Dyrektor Marketu                                   17000,00              2004-06-13 2015-08-25 18
5           Netiology Sp. z.o.o.                               Notariusz                                          17000,00              2022-01-24 NULL       19
6           NBC Sp. z.o.o.                                     Monter                                             5500,00               2006-07-18 2011-12-17 20

(20 rows affected)
*/

/*Próbuję dodać do tabeli ETATY id_osoby = 15, choć w tabeli OSOBY mamy tylko 14 osób 
INSERT INTO ETATY(id_etatu, id_osoby, id_firmy, stanowisko, pencja, od, do) VALUES ('21', 15 , N'NBC Sp. z.o.o.', N'Monter', '5500', '2006-07-18', '2011-12-17')

Msg 547, Level 16, State 0, Line 164
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_ETATY_OSOBY". The conflict occurred in database "b_323625", table "dbo.OSOBY", column 'id_osoby'.
The statement has been terminated.*/

/*Próbuję usunąć z tabeli MIASTA miasto o nazwie Warszawa, do której są przypisane osoby i firmy
DELETE FROM MIASTA WHERE nazwa=N'Warszawa'
Msg 547, Level 16, State 0, Line 179
The DELETE statement conflicted with the REFERENCE constraint "FK_OSOBY_MIASTA". The conflict occurred in database "b_323625", table "dbo.OSOBY", column 'id_miasta'.
The statement has been terminated.*/

/*Próbuję usunąć tabelę OSOBY, do której odnosi się tabela ETATY
DROP TABLE OSOBY
Msg 3726, Level 16, State 1, Line 185
Could not drop object 'OSOBY' because it is referenced by a FOREIGN KEY constraint.*/
