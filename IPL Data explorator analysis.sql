# --creating database 

create database IPL;
CREATE TABLE ipl.matches (
id integer, season integer, city varchar(20), date date, team_1 varchar(50), team_2 varchar(50),
toss_winner varchar(50), toss_decision varchar(50), result varchar(20), DL_applied integer, 
winner varchar(50), won_by_runs integer, won_by_wickets integer, player_of_the_match varchar(50), 
venue varchar(50), umpire_1 varchar(50), umpire_2 varchar(50)
);

CREATE TABLE ipl.deliveries (
match_id integer, innings integer, batting_team varchar(50), bowling_team varchar(50), 
overc integer, batsman varchar(20), non_striker varchar(20), bowler varchar(20),
is_super_over varchar(10), wide_runs integer, by_runs integer, legby_runs integer,
noball_runs integer, penanlty_runs integer, batsman_runs integer, extra_runs integer, 
totoal_runs integer, player_dissmissed varchar(50), dissimissal_type varchar(20), 
fielder varchar(50)
);

CREATE TABLE ipl.players (
player_name varchar(20), DOB date, batting_hand varchar(10), bowling_skills varchar(20),
country varchar(10), strike_rate integer, economy integer)
;

CREATE TABLE ipl.runs (
batsman_name varchar(20), total_runs integer, highest_score integer, 
number_of_balls integer, average integer, strike_rate integer
);

CREATE TABLE ipl.teams (
team_name varchar(100)
);

CREATE TABLE ipl.team_wins (
team_name varchar(50), home_win integer, away_win integer, home_matches integer,
away_matches integer, home_win_percentage integer, away_win_percentage integer
);

use ipl;

show databases; 
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';
SET GLOBAL local_infile = 1;


select *
from ipl.matches;

select * 
from ipl.deliveries;

alter table players
rename column player_name to name;

alter table deliveries
rename column batsman to name;

#--shape of data
select count(*) as number_of_rows
from ipl.deliveries;

select count(*) as 'No of Columns'
from information_schema.columns 
where table_name = "deliveries";

select *
from information_schema.tables;

#viewing data
select *
from deliveries;

select batting_team, bowling_team
from deliveries;

select *
from matches;

# --view selected columns
select season, date, team_1, team_2, winner
from matches;

# --viewing distinct values
select distinct count(*)
from ipl.matches;

select distinct season, count(*)
from matches
group by season;

select *
from ipl.matches
order by season asc;

# --finding the season winner for each season 
select * from ipl.matches;

select max(date), season, winner
from ipl.matches
group by season
order by date asc;

# --finding venue of 10 most recently played matches
select * from ipl.matches;

select venue, max(date)
from ipl.matches
group by venue
order by 2 desc
limit 10;

# --case (4, 6, single, 0)
select *
from ipl.deliveries;

select distinct batsman, bowler, 
case when total_runs=6 then "six"
	 when total_runs=4 then "four"
     when total_runs=1 then "single"
     when total_runs=0 then "duck"
     else "no run"
     end as "run in word"
from ipl.deliveries;

# --Data Aggregation
select winner,win_by_wickets,max(win_by_runs) from ipl.matches
#where winner='Mumbai Indians'
group by winner
order by 3 desc;

# --How many extra runs have been conceded in ipl
select distinct bowler,sum(extra_runs) from ipl.deliveries
group by bowler
having sum(extra_runs)>0;

# --On an average, teams won by how many runs in ipl
select winner,avg(win_by_runs) from ipl.matches
group by winner
having avg(win_by_runs)>0
order by 2 desc;

# --How many extra runs were conceded in ipl by SK Warne
select bowler,sum(extra_runs) from ipl.deliveries
where bowler='SK Warne'
group by bowler;

# --How many boundaries (4s or 6s) have been hit in ipl
select m.winner, d.total_runs,count(d.total_runs) from ipl.deliveries 
inner join ipl.matches  on m.id=d.matchid
where d.total_runs in (4,6)
and m.winner='Mumbai Indians';


# --How many balls did SK Warne bowl to batsman SR Tendulkar
select batsman,bowler, count(ball) from ipl.deliveries
where bowler='SK Warne' and batsman='SR Tendulkar'
group by batsman,bowler;

# --How many matches were played in the month of April
select count(*) from ipl.matches
where month(date)='4';
select count(*) from ipl.matches
where extract(month from date)=4;

# --How many matches were played in the March and June
select count(*) from ipl.matches
where month(date) in ('3','6');

# --Total number of wickets taken in ipl (count not null values)
select count(player_dismissed) as 'Wicket' 
from ipl.deliveries
where player_dismissed <>"";

# --Pattern Match ( Like operators % _ )
select Distinct player_of_the_match from ipl.matches 
where player_of_the_match
like '%M%';
select Distinct player_of_the_match from ipl.matches 
where player_of_the_match
like 'JJ %';
select distinct player_of_the_match from ipl.matches 
where player_of_the_match
like 'K_ P%';

# --How many teams have word royal in it (could be anywhere in the team name, anycase)
SELECT distinct team1 
FROM ipl.matches 
where lower(team1) like lower('%Royal%');

# --Maximum runs by which any team won a match per season
select season,max(win_by_runs) from ipl.matches
group by season
order by 1;

# --Create score card for each match Id
select batting_team,batsman,sum(batsman_runs) from ipl.deliveries
group by batting_team,batsman
order by 3 desc;

# --Top 10 players with max boundaries (4 or 6)
select DISTINCT batsman,count(total_runs) from ipl.deliveries
where total_runs in (4,6)
group by batsman
order by 2 desc
limit 10;

# --Top 10 bowlers who conceded highest extra runs
select bowler,sum(extra_runs) as 'highest extra runs' from ipl.deliveries
group by bowler
order by 2 desc
limit 10;

# --Top 10 wicket takers
select bowler,count(player_dissmissed) as NoWicket_Taken,dissimissal_type from
ipl.deliveries
where dissimissal_type <>""
group by bowler
order by NoWicket_Taken desc
limit 10;

# --Name and number of wickets by bowlers who have taken more than or equal to 100 wickets in ipl
select bowler,count(player_dissmissed) as NoWicket_Taken,dissimissal_type from
ipl.deliveries
where dissimissal_type <>""
group by bowler
having count(player_dissmissed) >=100
order by NoWicket_Taken desc
limit 10;

# Top 2 player_of_the_match for each season
select season, player_of_the_match, CNT from
(
select row_number() over (partition by season) as
rn,season,player_of_the_match,Cnt
from (
select season,player_of_the_match, count(player_of_the_match)
as Cnt
from ipl.matches
group by season,player_of_the_match
order by 1 asc,3 desc
 ) rw
) Temp
where Temp.rn<3;

# --Window Functions - (CTE) -- Combine column date from matches with table deliveries to get data by year

with
t1 as (select id,season,date,team_1,team_2,winner from ipl.matches),
 t2 as (select matchid,batting_team,bowling_team from ipl.deliveries)
select distinct
t1.season,t1.date,t1.city,t1.team_1,t1.team_2,t2.batting_team,t2.bowling_team,
t1.winner
 from t1 inner join t2 on t1.id=t2.matchid;
















