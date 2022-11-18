select * from project.dbo.data1;

select * from project.dbo.data2;

-- number of rows into our dataset

select count(*) from project..data1
select count(*) from project..data2

-- dataset for jharkhand and bihar

select * from project..data1 where state in ('Jharkhand' ,'Bihar')

-- population of India

select sum(population) as Population from project..data2

-- avg growth 

select state,avg(growth)*100 avg_growth from project..data1 group by state;

-- avg sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc;

-- avg literacy rate
 
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;

-- top 3 state showing highest growth ratio


select state,avg(growth)*100 avg_growth from project..data1 group by state order by avg_growth desc limit 3;


--bottom 3 state showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio from project..data1 group by state order by avg_sex_ratio asc;


-- top and bottom 3 states in literacy state

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union opertor

select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


-- states starting with letter a

select distinct state from project..data1 where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from project..data1 where lower(state) like 'a%' and lower(state) like '%m'

