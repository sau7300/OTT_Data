---- Data cleaning -------

--1. Remove Foreign character ---
-- by using nvarchar() inplace of varchar
select * from netflix where show_id = 's5023'


--2 . remove duplicates ----

select show_id , trim(value) as director into netflix_director from netflix  cross apply string_split(director , ',')
select show_id , trim(value) as country into netflix_country from netflix  cross apply string_split(country , ',')
select show_id , trim(value) as genre into netflix_genre from netflix  cross apply string_split(listed_in , ',')
select show_id , trim(value) as cast into netflix_cast from netflix  cross apply string_split(cast , ',')


----missing values in country , duration 
insert into netflix_country
select show_id, m.country from netflix n inner join (
select director , country from netflix_country inner join netflix_director on netflix_country.show_id = netflix_director.show_id group by country , director
)m on m.director = n.director
where n.country is null

--------------------------------------------------

select * , (case when duration is null then rating else duration end) as duration from netflix 


-----new table clean data -----------
with cte as(
select * , row_number() over(partition by title , type order by show_id ) as rn
from netflix 
)
select show_id , type , cast(date_added as date) as date_added , release_year , rating , (case when duration is null then rating else duration end) as duration , description 
into netflix_stg
from cte where rn=1



------data analayze----------

--- --- highest comedy movies in countries  -----

select  top 1 nc.country , COUNT(distinct ng.show_id) as Total_country from netflix_stg ns 
inner join netflix_genre ng on ns.show_id = ng.show_id
inner join netflix_country nc on nc.show_id = ng.show_id 
where genre = 'Comedies' and type = 'Movie'
group by nc.country
order by COUNT(nc.country) desc

-- --- each director count the no of movies and tv shows

select nd.director 
,COUNT(distinct case when n.type='Movie' then n.show_id end) as no_of_movies
,COUNT(distinct case when n.type='TV Show' then n.show_id end) as no_of_tvshow
from netflix n
inner join netflix_director nd on n.show_id=nd.show_id
group by nd.director
having COUNT(distinct n.type)>1

---- max count of movies released by director for each year 

with cte as (
select nd.director as Director ,YEAR(date_added) as year ,count(ns.show_id) as Count_movies
from netflix_stg ns
join netflix_director nd on ns.show_id=nd.show_id
where type='Movie'
group by nd.director,YEAR(date_added)
)
, cte1 as (
select *
, ROW_NUMBER() over(partition by year order by Count_movies desc, director) as rank
from cte
)
select Director , year   from cte1 where rank =1


---- list of director who have created horror and comedy movies both.-----

select nd.director as Director,
COUNT(case when genre = 'Comedies' then 1 else 0 end) as Comedy_Movies,
COUNT(case when genre = 'Horror Movies' then 1 else 0 end) as Horror_Movies
from 
netflix_stg ns join netflix_genre ng on ns.show_id = ng.show_id
join netflix_director nd on nd.show_id = ns.show_id
where ng.genre in ('Comedies' , 'Horror Movies')
group by nd.director 
having COUNT(distinct ng.genre)=2
order by Comedy_Movies desc , Horror_Movies desc


----- average duration of movies ----------

select ng.genre , AVG(cast(replace(duration , 'min','') as int)) as avg_duration from 
netflix_stg ns join netflix_genre ng on ns.show_id = ng.show_id
where type = 'Movie'
group by genre














