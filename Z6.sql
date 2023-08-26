/*
**
** 3 reguły tworzenia TRIGGERA
** R1 - Trigger nie może aktualizować CALEJ tabeli a co najwyżej elementy zmienione
** R2 - Trigger może wywołać sam siebie - uzysamy niesończoną rekurencję == stack overflow
** R3 - Zawsze zakladamy, że wstawiono / zmodyfikowano / skasowano wiecej jak 1 rekord
**
** Z1: Napisać trigger, który będzie usuwał spacje z pola IMIE
** Trigger na INSERT, UPDATE
** UWAGA !! Trigger będzie robił UPDATE na polu IMIE
** To grozi REKURENCJĄ i przepelnieniem stosu
** Dlatego trzeba będzie sprawdzać UPDATE(IMIE) i sprawdzać czy we
** wstawionych rekordach były spacje i tylko takowe poprawiać (ze spacjami w nazwisku)
**
** Z2: Napisać procedurę szukającą miast z paramertrami
** @nazwa_wzor nvarchar(20) = NULL
** @kod_woj_wzor nvarchar(20) = NULL
** @pokaz_zarobki bit = 0
** Procedura ma mieć zmienną @sql nvarchar(1000), którą buduje dynamicznie
** @pokaz_zarobki = 0 => (miasto.nazwa AS Miasto, WOJ.NAZWA AS woj, id_miasta, kod_woj)
** @pokaz_zarobki = 1 => (miasto.nazwa AS Miasto, WOJ.NAZWA AS woj, id_miasta, kod_woj
, śr_z_akt_etatow)
** Mozliwe wywołania: EXEC sz_m @nazw_wzor = N'%WA'
** powinno zbudować zmienną tekstową
** @sql = N'SELECT w.nazwa AS woj, m.* FROM miasta m join woj w "
** + N' ON (m.kod_woj=w.kod_woj) WHERE m.nazwa LIKE N%WA '
** uruchomienie zapytania to EXEC sp_sqlExec @sql
** rekomenduję aby najpierw procedura zwracała zapytanie SELECT @sql
** a dopiero jak będą poprawne uruachamiała je
*/

/*1)*/
GO
CREATE TRIGGER TR_osoby_ch_name ON osoby for INSERT, UPDATE
AS
	IF UPDATE(imie) /* polecenie dotyczy kolumny imie*/
	AND EXISTS (SELECT 1 FROM inserted i WHERE i.imie LIKE N'% %')
		UPDATE osoby SET imie = REPLACE(imie, N' ', N'')	/*zmienia podany tekst na tekst bez spacji*/
		WHERE id_osoby IN			/*aktualizujemy dla osoby o id równym id podanym dla aktualizacji*/
		(	SELECT i.id_osoby 
				FROM inserted i 
				WHERE i.imie LIKE N'% %')
GO

UPDATE osoby SET imie = N'ad am' WHERE id_osoby = 1

select * from osoby where id_osoby = 1	/*Sprawdzimy, jak się zmieniło*/

/*Do przekształacenia:
id_osoby    id_miasta   imie                                               nazwisko
----------- ----------- -------------------------------------------------- --------------------------------------------------
1           1           jacek                                              korytkowski

Po przekształaceniu:
id_osoby    id_miasta   imie                                               nazwisko
----------- ----------- -------------------------------------------------- --------------------------------------------------
1           1           adam                                               korytkowski
*/

/*2)*/
GO
CREATE PROCEDURE FIND_CITY AS
GO
ALTER PROCEDURE FIND_CITY (@nazwa_wzor nvarchar(20) = NULL, @kod_woj_wzor nvarchar(20) = NULL, @pokaz_zarobki bit = 0 )
AS
	SET @nazwa_wzor = LTRIM(RTRIM(@nazwa_wzor))		/*czyścimy nazwy od spacji przed i po*/
	SET @kod_woj_wzor = LTRIM(RTRIM(@kod_woj_wzor))
	BEGIN
		DECLARE @sql nvarchar(1000)			/*zmienna, przechowująca polecenie*/
		IF @pokaz_zarobki = 0				/*polecenia bez średniej pensji*/
		BEGIN
			IF NOT isnull(@nazwa_wzor, '') = ''		/*polecenie dla przypadku podania nazwy miasta*/
			BEGIN											/*wybiera miasto z odpowiednią nazwą*/
			SET @sql = N'SELECT m.nazwa as miasto, w.nazwa AS woj, m.id_miasta, m.kod_woj
			FROM miasta m
			join woj w ON (m.kod_woj=w.kod_woj)
			WHERE m.nazwa = N''' + @nazwa_wzor + '''
			ORDER BY m.id_miasta, m.nazwa'
			END
			IF NOT isnull(@kod_woj_wzor, '') = ''			/*polecenie dla przypadku podania kodu województwa*/
			BEGIN							/*wybiera miasta, należące do województwa o odpowiednim kodzie*/
			SET @sql = N'SELECT m.nazwa as miasto, w.nazwa AS woj, m.id_miasta, m.kod_woj
			FROM miasta m
			join woj w ON (m.kod_woj=w.kod_woj) 
			WHERE m.kod_woj = N''' +@kod_woj_wzor + '''
			ORDER BY m.id_miasta, m.nazwa'
			END
		END
		IF @pokaz_zarobki = 1			/*polecenia ze średnią pensją*/
		BEGIN
			IF not (isnull(@nazwa_wzor, '') = '')		/*polecenie dla przypadku podania nazwy miasta*/
			BEGIN			/*polecenie jest przrobioną formą zadania 2 z Z5*/
			SET @sql = N'SELECT m.nazwa as miasto, w.nazwa AS woj, m.id_miasta, m.kod_woj, X.srednia_pensja
			FROM miasta m
			join woj w ON (m.kod_woj=w.kod_woj) 
			join firmy f ON (m.id_miasta=f.id_miasta)
			left outer
			join (SELECT e.id_firmy , AVG(e.pencja) AS srednia_pensja
			FROM ETATY e
			WHERE e.do IS NULL
			GROUP BY e.id_firmy) X ON (X.id_firmy= f.nazwa_skr)
			WHERE m.nazwa = N''' + @nazwa_wzor + '''
			ORDER BY m.id_miasta, m.nazwa'
			 END
			 IF NOT (isnull(@kod_woj_wzor, '') = '')		/*polecenie dla przypadku podania kodu województwa*/
			 BEGIN			/*polecenie jest przrobioną formą zadania 2 z Z5*/
			 SET @sql = N'SELECT m.nazwa as miasto, w.nazwa AS woj, m.id_miasta, m.kod_woj, X.srednia_pensja
			 FROM miasta m 
			 join woj w ON (m.kod_woj=w.kod_woj)
			 join firmy f ON (m.id_miasta=f.id_miasta)
			 left outer
			 join (SELECT e.id_firmy , AVG(e.pencja) AS srednia_pensja
				FROM ETATY e
				WHERE e.do IS NULL
				GROUP BY e.id_firmy			
				) X ON (X.id_firmy= f.nazwa_skr)
				WHERE m.kod_woj = N''' +@kod_woj_wzor + '''
				ORDER BY m.id_miasta, m.nazwa'
			 END
		END
		--select @sql
		exec sp_sqlExec  @sql	/*wykonujemy polecenie*/
	END
GO

EXEC FIND_CITY @kod_woj_wzor=N'POD', @pokaz_zarobki = 1
/*
miasto                                             woj                                                id_miasta   kod_woj srednia_pensja
-------------------------------------------------- -------------------------------------------------- ----------- ------- ---------------------
Kolno                                              PODLASKIE                                          2           POD     NULL
Suwałki                                            PODLASKIE                                          3           POD     NULL
Białystok                                          PODLASKIE                                          5           POD     14000,00
Sejny                                              PODLASKIE                                          7           POD     8000,00
*/
EXEC FIND_CITY @kod_woj_wzor=N'MAZ'
/*
miasto                                             woj                                                id_miasta   kod_woj
-------------------------------------------------- -------------------------------------------------- ----------- -------
Warszawa                                           MAZOWIECKIE                                        1           MAZ 
Siedlce                                            MAZOWIECKIE                                        4           MAZ 
Piaseczno                                          MAZOWIECKIE                                        6           MAZ 
Serpc                                              MAZOWIECKIE                                        8           MAZ 
Lipsko                                             MAZOWIECKIE                                        9           MAZ 

(5 rows affected)
*/
EXEC FIND_CITY @nazwa_wzor=N'Białystok', @pokaz_zarobki = 1
/*
miasto                                             woj                                                id_miasta   kod_woj srednia_pensja
-------------------------------------------------- -------------------------------------------------- ----------- ------- ---------------------
Białystok                                          PODLASKIE                                          5           POD     14000,00

(1 row affected)
*/
EXEC FIND_CITY @nazwa_wzor=N'Siedlce', @pokaz_zarobki = 0
/*
miasto                                             woj                                                id_miasta   kod_woj
-------------------------------------------------- -------------------------------------------------- ----------- -------
Siedlce                                            MAZOWIECKIE                                        4           MAZ 

(1 row affected)
*/

/*Dla sprawdzenia polecenie z zadania 2 z Z5, z dodaniem kodu województwa:
SELECT f.id_miasta, m.nazwa as nazwa_miasta, m.kod_woj, X.srednia_pensja  
	FROM FIRMY f
	join MIASTA m ON (m.id_miasta = f.id_miasta)
	left outer
	join (SELECT e.id_firmy , AVG(e.pencja) AS srednia_pensja
			FROM ETATY e
			WHERE e.do IS NULL
			GROUP BY e.id_firmy
		) X ON (X.id_firmy= f.nazwa_skr)
	ORDER BY f.id_miasta, m.nazwa

id_miasta   nazwa_miasta                                       kod_woj srednia_pensja
----------- -------------------------------------------------- ------- ---------------------
1           Warszawa                                           MAZ     NULL
2           Kolno                                              POD     NULL
3           Suwałki                                            POD     NULL
4           Siedlce                                            MAZ     6000,00
5           Białystok                                          POD     14000,00
6           Piaseczno                                          MAZ     9500,00
7           Sejny                                              POD     8000,00
9           Lipsko                                             MAZ     NULL

(8 rows affected)
*/