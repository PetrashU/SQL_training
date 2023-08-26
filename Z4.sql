/*
Z4.1 - pokazać firmy z województwa o kodzie X, w których nigdy
nie pracowały / nie pracują (ignorujemy kolumny OD i DO) osoby mieszkające w mieście o kodzie id_miasta=Y

Czyli jak FIRMA PW ma 2 etaty i jeden
osoby mieszkającej w mieście o ID= X
a drugi etat osoby mieszkającej w mieście o ID=Y
to takiej FIRMY NIE POKOZUJEMY !!!
A nie, że pokażemy jeden etat a drugi nie

Z4.2 - pokazać liczbę miast w WOJ. Ale tylko takie mające więcej jak jedno miasto

Z4,3 - pokazać średnią pensję w MIASTA
ale tylko tych posiadających więcej ja jednego mieszkańca

1 wariant -> etaty -> osoby -> miasta
teraz złaczamy wynik tego zapytania z osoby->miasta (grupowane po ID_MIASTA z HAVING)
2 wariant -> (średnia z firm o danym id_miasta) a liczba mieszkańców z OSOBY
(czyli średnia wyliczana z tabel Etaty -> Firmy -> Miasta) -> do tab #tymcz
(łaczymy tabelę #tymczas z osoby -> miasta z grupowaniem poprzez ID_MIASTA)
*/


/*4.1*/
/*Pokazujemy informację o firmie, jeżeli miasto, w którym firma się znajduje, jest w województwie MAZ i nie istnieje etatu, na którym pracowałaby osoba z miasta w województwie POD*/
SELECT f.nazwa_skr
	,f.nazwa
	,f.id_miasta
	,f.kod_pocztowy
	,f.ulica
	FROM FIRMY f 
	join MIASTA m ON (f.id_miasta = m.id_miasta)
	WHERE	
	m.kod_woj = N'Maz' AND
	NOT EXISTS 
	(SELECT 1 FROM ETATY e 
	join OSOBY o ON (e.id_osoby = o.id_osoby)
	join MIASTA mf ON (o.id_miasta = mf.id_miasta)
	WHERE e.id_firmy = f.nazwa_skr
	AND mf.kod_woj = N'POD')
/*
nazwa_skr                                          nazwa                                                                                                id_miasta   kod_pocztowy ulica
-------------------------------------------------- ---------------------------------------------------------------------------------------------------- ----------- ------------ --------------------------------------------------
P.H.DREXPOL                                        P.H.DREXPOL - Wiesław Zuch                                                                           1           02-031       Orkana 2

(1 row(s) affected)
*/

/*4.2*/
/*Wybiera województwa, w których po grupowaniu po nazwie województwa będą więcej, niż 1 miasto*/
select w.nazwa
	,COUNT(distinct m.id_miasta) AS [liczba miast]
from WOJ w
	join MIASTA m ON (m.kod_woj = w.kod_woj)
GROUP BY w.nazwa
HAVING COUNT(distinct m.id_miasta) > 1
/*
nazwa                                              liczba miast
-------------------------------------------------- ------------
MAZOWIECKIE                                        5
PODLASKIE                                          4

(2 row(s) affected)
*/

/*4.3 1 wariant*/
select AVG(e.pencja) as [srednia pensja]
	,m.id_miasta
	,m.nazwa
from ETATY e
join OSOBY o ON (o.id_osoby = e.id_osoby)	/*osoba, która pracuje na tym etacie*/
join MIASTA m ON (o.id_miasta = m.id_miasta)	/*miasto, w którym mieszka osoba*/
GROUP BY m.id_miasta, m.nazwa
HAVING COUNT(DISTINCT o.id_osoby)>1
/*Zauważymy, że powyższy przykład pokazuje śrędnią pensję ludzi, mieszkających w tym mieście, a nie firm tam znajdujących się*/

/*Wynik:
srednia pensja        id_miasta   nazwa
--------------------- ----------- --------------------------------------------------
6250,00               1           Warszawa
13833,3333            2           Kolno
8000,00               4           Siedlce
12375,00              6           Piaseczno
8833,3333             9           Lipsko

(5 rows affected)
*/

/*Poniższy przykład pokazuje średnią pensję w firmach, znajdujących się w tym mieście*/
select AVG(e.pencja) as [srednia pensja]
	,m.id_miasta
	,m.nazwa
from ETATY e
join FIRMY f on (e.id_firmy = f.nazwa_skr)	
join MIASTA m ON (f.id_miasta = m.id_miasta)	/*miasto, w którym jest ta firma*/
join OSOBY o ON (o.id_miasta = m.id_miasta)		/*osoby, które mieszkają w tym mieście*/
GROUP BY m.id_miasta, m.nazwa
HAVING COUNT(DISTINCT o.id_osoby)>1
/*Wynik:
srednia pensja        id_miasta   nazwa
--------------------- ----------- --------------------------------------------------
6625,00               4           Siedlce
12250,00              6           Piaseczno
8000,00               9           Lipsko

(3 rows affected)
*/

/*4.3 2 wariant*/
/*Zapisujemy do tabeli #T średnie pensje wszystkich firm*/
select AVG(e.pencja) as [srednia pensja]
		,f.id_miasta
		,m.nazwa
INTO #T
from etaty e
join FIRMY f ON (f.nazwa_skr = e.id_firmy)	/*firma, do której przypisany etat*/
join MIASTA m ON (m.id_miasta = f.id_miasta)	/*miasto, w którym znajduje się firma*/
GROUP BY f.id_miasta, m.nazwa

/*Do tabeli #T zapiano:
srednia pensja        id_miasta   nazwa
--------------------- ----------- --------------------------------------------------
11750,00              3           Suwałki
6625,00               4           Siedlce
10100,00              5           Białystok
12250,00              6           Piaseczno
9166,6666             7           Sejny
8000,00               9           Lipsko

(6 rows affected)
*/

/*Wybieramy z tabeli #T tylko te rekordy, które odnosza się do miast, w którym jest >1 osób*/

select t.[srednia pensja],
	t.id_miasta
	,t.nazwa
from #T t
join osoby o ON (o.id_miasta = t.id_miasta)		/*osoba, miaszkająca w tym miescie*/
Group by t.[srednia pensja], t.id_miasta, t.nazwa
HAVING COUNT(DISTINCT o.id_osoby)>1

/*Wynik:
srednia pensja        id_miasta   nazwa
--------------------- ----------- --------------------------------------------------
6625,00               4           Siedlce
8000,00               9           Lipsko
12250,00              6           Piaseczno

(3 rows affected)
*/

/*Polecenie dla sprawdzenia liczby osób w mieście:
	select count(distinct o.id_osoby) as [ile osób]
		,m.nazwa,
		m.id_miasta
	from miasta m
	join osoby o On (o.id_miasta = m.id_miasta)
	group by m.nazwa, m.id_miasta

Wynik:
ile osób    nazwa                                              id_miasta
----------- -------------------------------------------------- -----------
3           Warszawa                                           1
2           Kolno                                              2
1           Suwałki                                            3
2           Siedlce                                            4
1           Białystok                                          5
2           Piaseczno                                          6
1           Sejny                                              7
2           Lipsko                                             9

(8 rows affected)
*/