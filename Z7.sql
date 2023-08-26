/* stworzyć bibliotekę (uproszczoną)
**
** Tabela Ksiazka (tytul, autor, id_ksiazki, stan_bibl, stan_dostepny - dom stan_bibl)
** Skorzystać z tabeli OSOBY którą macie
** Tabela WYP (id_osoby, id_ksiazki, liczba, data, id_wyp PK)
** Tabela ZWR (id_osoby, id_ksiazki, liczba, data, id_zwr PK (int not null IDENTITY))
** Napisać triggery aby:
** dodanie rekordow do WYP powodowalo aktualizację Ksiazka (stan_dostepny)
** UWAGA zakladamy ze na raz mozna dodawac wiele rekordow
** w tym dla tej samej osoby, z tym samym id_ksiazki
*/
/*
Zwrot zwiększa stan_dostepny
** UWAGA
** Zrealizować TRIGERY na kasowanie z WYP lub ZWR
**
** Zrealizować triggery, ze nastapiła pomyłka czyli UPDATE na WYP lub ZWR
** Wydaje mi sie, ze mozna napisac po jednym triggerze na WYP lub ZWR na
** wszystkie akcje INSERT / UPDATE / DELETE
**
** Testowanie: stworzcie procedurę, która pokaze wszystkie ksiązki,
** dane ksiązki, stan_bibl, stan_dost + SUM(liczba) z ZWR - SUM(liczba) z WYP =>
** ISNULL(SUM(Liczba),0)
** te dwie kolumny powiny być równe
** po wielu dzialaniach w bazie
** dzialania typu kasowanie rejestrowac w tabeli skasowane
** (rodzaj (wyp/zwr), id_os, id_ks, liczba)
** osobne triggery na DELETE z WYP i ZWR które będą rejestrować skasowania
** opisać pełną historie wyp i zwr (łaczniem z kasowaniem) i ze po wszystkim stan OK
**jak ktoś chce sprawdzać czy stan_dostepny nie jest <0 lub >stan_bibl 
**to zamiast sprawdzać w każdym triggerze wystarczy zrobić trigger
** na ksiazka na UPDATE na kolumnę stan_dost i jka nie spełnia to 
** if exists (select 1 from inserted i WHERE (i.stan_dostepny < 0) OR (i.stan_dost > i.stan_bibl))  
** BEGIN
**RAISERROR(N'PRZEKROCZENIE STANÓW - BŁĄD', 16, 3)
**ROLLBACK TRAN
**END	
*/

IF OBJECT_ID(N'ZWR') IS NOT NULL
	DROP TABLE ZWR
GO
IF OBJECT_ID(N'WYP') IS NOT NULL
	DROP TABLE WYP
GO
IF OBJECT_ID(N'KSIAZKA') IS NOT NULL
	DROP TABLE KSIAZKA
GO


CREATE TABLE dbo.KSIAZKA
(	tytul nvarchar(50)	NOT NULL
,	autor nvarchar(50)	NOT NULL
,	id_ksiazki int NOT NULL IDENTITY	CONSTRAINT PK_KSIAZKI PRIMARY KEY
,	stan_bibl int
,	stan_dostepny int
)
GO

CREATE TABLE dbo.WYP
(	id_osoby int not null CONSTRAINT FK_WYP_OSOBY FOREIGN KEY REFERENCES OSOBY(id_osoby)
,	id_ksiazki int not null CONSTRAINT FK_WYP_KSIAZKA FOREIGN KEY REFERENCES KSIAZKA(id_ksiazki)
,	liczba int NOT NULL
,	data date NOT NULL
,	id_wyp int NOT NULL IDENTITY CONSTRAINT PK_WYP PRIMARY KEY
)
GO

CREATE TABLE dbo.ZWR
(	id_osoby int not null CONSTRAINT FK_ZWR_OSOBY FOREIGN KEY REFERENCES OSOBY(id_osoby)
,	id_ksiazki int not null CONSTRAINT FK_ZWR_KSIAZKA FOREIGN KEY REFERENCES KSIAZKA(id_ksiazki)
,	liczba int NOT NULL
,	data date NOT NULL
,	id_zwr int NOT NULL IDENTITY CONSTRAINT PK_ZWR PRIMARY KEY
)
GO

IF OBJECT_ID(N'TR_ksiazka_ins') IS NOT NULL
	DROP TRIGGER TR_ksiazka_ins
GO


				/*Triger na ustawienie wartości stan_dostępny domyślnie jako stan_biblioteczny*/
CREATE TRIGGER dbo.TR_ksiazka_ins ON KSIAZKA INSTEAD of INSERT
AS
	INSERT INTO KSIAZKA(tytul, autor ,stan_bibl, stan_dostepny)
	SELECT i.tytul,i.autor, i.stan_bibl, ISNULL(i.stan_dostepny,i.stan_bibl)
	From inserted i
GO


IF OBJECT_ID(N'TR_wyp_ins') IS NOT NULL
	DROP TRIGGER TR_wyp_ins
GO

GO
CREATE TRIGGER dbo.TR_wyp_ins ON WYP for INSERT		/*triger na zmniejszenie stan_dostępny przy dodaniu rekordów do WYP*/
AS
	UPDATE KSIAZKA SET stan_dostepny = stan_dostepny - X.wzieto
		FROM KSIAZKA
		join (SELECT i.id_ksiazki, SUM(i.liczba) AS wzieto		/*sumujemy liczby wypożyczeń tej książki*/
				FROM inserted i 
				GROUP BY i.id_ksiazki
			) X ON (X.id_ksiazki = KSIAZKA.id_ksiazki)

GO

IF OBJECT_ID(N'TR_zwr_ins') IS NOT NULL
	DROP TRIGGER TR_zwr_ins
GO
GO
CREATE TRIGGER dbo.TR_zwr_ins ON ZWR for INSERT			/*triger na zwiększenie stan_dostępny przy dodaniu rekordów do ZWR*/
AS
	UPDATE ksiazka SET stan_dostepny = stan_dostepny + X.oddano
		FROM ksiazka 
		join (SELECT i.id_ksiazki, SUM(i.liczba) AS oddano		/*sumujemy liczby zwrotów tej książki*/
				FROM inserted i 
				GROUP BY i.id_ksiazki
			) X ON (X.id_ksiazki = ksiazka.id_ksiazki)

GO

IF OBJECT_ID(N'TR_wyp_del') IS NOT NULL
	DROP TRIGGER TR_wyp_del
GO
GO
CREATE TRIGGER dbo.TR_wyp_del ON WYP for DELETE			/*triger na zwiększenie stan_dostepny przy usunięciu rekordu z WYP*/
AS
	UPDATE ksiazka SET stan_dostepny = stan_dostepny + X.wzieto		
		FROM ksiazka 
		join (SELECT d.id_ksiazki, SUM(d.liczba) AS wzieto			/*liczy sumę wypożyczeń danej książki z rekordów usuniętych*/
				FROM deleted  d 
				GROUP BY d.id_ksiazki
			) X ON (X.id_ksiazki = KSIAZKA.id_ksiazki)

GO

IF OBJECT_ID(N'TR_zwr_del') IS NOT NULL
	DROP TRIGGER TR_zwr_del
GO
GO
CREATE TRIGGER dbo.TR_zwr_del ON ZWR for DELETE			/*triger na zmniejszenie stan_dostepny przy usunięciu rekordu z ZWR*/
AS

	UPDATE ksiazka SET stan_dostepny = stan_dostepny - X.oddano
		FROM ksiazka 
		join (SELECT d.id_ksiazki, SUM(d.liczba) AS oddano		/*liczy sumę zwrotów danej książki z rekordów usuniętych*/
				FROM deleted  d 
				GROUP BY d.id_ksiazki
			) X ON (X.id_ksiazki = KSIAZKA.id_ksiazki)

GO

IF OBJECT_ID(N'TR_wyp_upd') IS NOT NULL
	DROP TRIGGER TR_wyp_upd
GO

GO
CREATE TRIGGER dbo.TR_wyp_upd ON WYP for UPDATE		/*triger na pomyłkę przy próbie zmiany liczby wypożyczonych książek na taką samą*/
AS
IF UPDATE(liczba)
	BEGIN
		IF EXISTS 
		(	SELECT 1 FROM inserted i join deleted d ON (i.id_wyp = d.id_wyp)	/*jeżeli liczba z rekordu usuniętego(przed zmianą) */ 
				WHERE (i.liczba = d.liczba)										/*jest równa liczbie z rekodu nowego (po zmianie)*/
		)
		BEGIN			
			ROLLBACK TRAN
			RAISERROR(N'Nie można zmieniać liczbę wypożyczonych książek na tę samą', 16,3)		/*Otrzymujemy błąd*/
			RETURN 
		END
	END
GO

IF OBJECT_ID(N'TR_zwr_upd') IS NOT NULL
	DROP TRIGGER TR_zwr_upd
GO

GO
CREATE TRIGGER dbo.TR_zwr_upd ON ZWR for UPDATE		/*triger na pomyłkę przy próbie zmiany liczby wypożyczonych książek na taką samą*/
AS
IF UPDATE(liczba)
	BEGIN
		IF EXISTS 
		(	SELECT 1 FROM inserted i join deleted d ON (i.id_zwr = d.id_zwr)
				WHERE (i.liczba = d.liczba)  
		)
		BEGIN			
			ROLLBACK TRAN
			RAISERROR(N'Nie można zmieniać liczbę zwróconych książek na tę samą', 16,3)
			RETURN 
		END
	END
GO


IF OBJECT_ID(N'SKASOWANE') IS NOT NULL
	DROP TABLE SKASOWANE
GO

CREATE TABLE dbo.SKASOWANE (
	rodzaj nvarchar(30) NOT NULL
,	id_osoby int not null
,	id_ksiazki int not null
,	liczba int NOT NULL
	)
GO

IF OBJECT_ID(N'TR_wyp_skas') IS NOT NULL
	DROP TRIGGER TR_wyp_skas
GO

GO
CREATE TRIGGER dbo.TR_wyp_skas ON WYP for DELETE		/*trigery na dodawanie do tabeli SKASOWANE usuniętych rekordów*/
AS
	INSERT INTO SKASOWANE(rodzaj,id_osoby, id_ksiazki, liczba) 
	SELECT N'Wypożyczenie', d.id_osoby, d.id_ksiazki, d.liczba
	From deleted d
GO

IF OBJECT_ID(N'TR_zwr_skas') IS NOT NULL
	DROP TRIGGER TR_zwr_skas
GO

GO
CREATE TRIGGER dbo.TR_zwr_skas ON ZWR for DELETE
AS
	INSERT INTO SKASOWANE(rodzaj,id_osoby, id_ksiazki, liczba)
	SELECT N'Zwrot', d.id_osoby, d.id_ksiazki, d.liczba
	From deleted d
GO

IF OBJECT_ID(N'TR_ksiazka_upd') IS NOT NULL
	DROP TRIGGER TR_ksiazka_upd
GO

GO
CREATE TRIGGER dbo.TR_ksiazka_upd ON KSIAZKA for UPDATE		/*triger na negatywną liczbę w stan_dost, lub większą niż stan_bibl*/
AS
	IF UPDATE(stan_dostepny)
	BEGIN 
		IF EXISTS 
		( SELECT 1 FROM inserted i 
		WHERE (i.stan_dostepny < 0) OR (i.stan_dostepny > i.stan_bibl))
			BEGIN
				ROLLBACK TRAN
				RAISERROR(N'Przekroczenie stanów - błąd', 16,3)
				RETURN 
		END
	END
GO

IF OBJECT_ID(N'TEST') IS NOT NULL
	DROP PROCEDURE TEST
GO
GO
CREATE PROCEDURE dbo.TEST		/*Procedura, która pokaże liczbę książek dostępnych + wydanych - zwróconych */
AS
	SELECT k.id_ksiazki, k.autor, k.tytul, k.stan_bibl, CAST(k.stan_dostepny as varchar(3)) + '+' + 
								CAST(ISNULL(X.wzieto,0) as varchar(3)) + '-' + CAST(ISNULL(Y.oddano,0) as varchar(3)) AS [w bibl + wydano - zwrócono]
	FROM KSIAZKA k
	left outer join (SELECT w.id_ksiazki, SUM(w.liczba) AS wzieto
				FROM WYP w
				GROUP BY w.id_ksiazki
			) X ON (X.id_ksiazki = k.id_ksiazki)
	left outer join (SELECT z.id_ksiazki, SUM(z.liczba) AS oddano
				FROM ZWR z
				GROUP BY z.id_ksiazki
			) Y ON (Y.id_ksiazki = k.id_ksiazki)
GO

			/*Sprawdzimy triger na ustawienie domyślniej wartości stan_dostepny = stan_bibl*/
INSERT INTO KSIAZKA(tytul, autor, stan_bibl) VALUES (N'Jaś i Małgosia', N'Braci Grimm',15)
INSERT INTO KSIAZKA(tytul, autor, stan_bibl, stan_dostepny) VALUES (N'Pan Tadeusz', N'Adam Mickiewicz',20, 20)
exec test
/*
id_ksiazki  autor                                              tytul                                              stan_bibl   w bibl + wydano - zwrócono
----------- -------------------------------------------------- -------------------------------------------------- ----------- --------------------------
1           Braci Grimm                                        Jaś i Małgosia                                     15          15+0-0
2           Adam Mickiewicz                                    Pan Tadeusz                                        20          20+0-0
*/

			/*Sprawdzimy triger na zmniejszenie liczby stan_dostepny przy dodawaniu rekordów do WYP*/
insert into WYP (id_osoby,id_ksiazki,liczba, data) VALUES (2,1,1, '2003-05-20'), (3,2,3,'2003-06-01')
exec test
/*
id_ksiazki  autor                                              tytul                                              stan_bibl   w bibl + wydano - zwrócono
----------- -------------------------------------------------- -------------------------------------------------- ----------- --------------------------
1           Braci Grimm                                        Jaś i Małgosia                                     15          14+1-0
2           Adam Mickiewicz                                    Pan Tadeusz                                        20          17+3-0
*/

			/*Sprawdzimy triger na zwiększenie liczby stan_dostepny przy dodawaniu rekordów do ZWR*/
insert into ZWR (id_osoby,id_ksiazki,liczba, data) VALUES (2,1,1, '2003-05-29'), (3,2,1,'2003-06-06')
exec test
/*
id_ksiazki  autor                                              tytul                                              stan_bibl   w bibl + wydano - zwrócono
----------- -------------------------------------------------- -------------------------------------------------- ----------- --------------------------
1           Braci Grimm                                        Jaś i Małgosia                                     15          15+1-1
2           Adam Mickiewicz                                    Pan Tadeusz                                        20          18+3-1
*/

			/*Sprawdzimy trigery na dodanie rekordów do SKASOWANE i zmianę stan_dost przy usunięciu rekordów z ZWR */
delete from ZWR where id_ksiazki = 2
SELECT * from SKASOWANE
exec test
/*
rodzaj                         id_osoby    id_ksiazki  liczba
------------------------------ ----------- ----------- -----------
Zwrot                          3           2           1

id_ksiazki  autor                                              tytul                                              stan_bibl   w bibl + wydano - zwrócono
----------- -------------------------------------------------- -------------------------------------------------- ----------- --------------------------
1           Braci Grimm                                        Jaś i Małgosia                                     15          15+1-1
2           Adam Mickiewicz                                    Pan Tadeusz                                        20          17+3-0
*/

		/*Spróbuję zmienić liczbę wypożyczonych książek w rekordzie na tę samą*/
UPDATE WYP Set liczba = 3 where id_wyp = 2
/*
Msg 50000, Level 16, State 3, Procedure TR_wyp_upd, Line 11
Nie można zmieniać liczbę wypożyczonych książek na tę samą
Msg 3609, Level 16, State 1, Line 1
The transaction ended in the trigger. The batch has been aborted.
*/

		/*liczbę zwróconych książek w rekordzie na tę samą*/
UPDATE ZWR Set liczba = 1 where id_zwr = 1
/*
Msg 50000, Level 16, State 3, Procedure TR_zwr_upd, Line 11
Nie można zmieniać liczbę zwróconych książek na tę samą
Msg 3609, Level 16, State 1, Line 1
The transaction ended in the trigger. The batch has been aborted.
*/

		/*Próba dodania rekordu, która sprawi, że liczba stan_dostepny będzie ujemna*/

insert into WYP (id_osoby,id_ksiazki,liczba, data) VALUES (4,1,16, '2003-06-17')
/*
Msg 50000, Level 16, State 3, Procedure TR_ksiazka_upd, Line 10
Przekroczenie stanów - błąd
Msg 3609, Level 16, State 1, Procedure TR_wyp_ins, Line 3
The transaction ended in the trigger. The batch has been aborted.
*/
		/*Próba usunięcia rekordu, która sprawi, że stan_dostepny będzie większy za stan_bibl   (15+1-1)->(16+0-1)*/
delete from WYP where id_ksiazki = 1
/*
Msg 50000, Level 16, State 3, Procedure TR_ksiazka_upd, Line 10 [Batch Start Line 347]
Przekroczenie stanów - błąd
Msg 3609, Level 16, State 1, Procedure TR_wyp_del, Line 3 [Batch Start Line 347]
The transaction ended in the trigger. The batch has been aborted.
*/