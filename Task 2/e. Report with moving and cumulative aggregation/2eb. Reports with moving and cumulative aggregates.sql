--e. Reports with moving and cumulative aggregates
--e1. Show the quarterly and total rental saving occurring in states of Australia every year.
select l.state, f.year||'-'||t.timesession quarter, 
to_char(sum(f.totalrentalsaving), '9,999,999,999') Q_RENTAL,
to_char(sum(sum(f.totalrentalsaving)) over 
(partition by l.state, f.year order by l.state, f.year rows unbounded preceding), '9,999,999,999') cum_rental
from swapsfact f, timesessiondim t, hlocationdim l
where f.timesessionid = t.timesessionid and f.slocid = l.hlocid and l.country = 'Australia'
group by l.state, f.year, t.timesession
order by state, quarter;

--New query
select /*+ ordered */ l.state, f.year||'-'||t.timesession quarter, 
to_char(sum(f.totalrentalsaving), '9,999,999,999') Q_RENTAL,
to_char(sum(sum(f.totalrentalsaving)) over 
(partition by l.state, f.year order by l.state, f.year rows unbounded preceding), '9,999,999,999') cum_rental
from swapsfact f, timesessiondim t, hlocationdim l
where f.timesessionid = t.timesessionid and f.slocid = l.hlocid and l.country = 'Australia'
group by l.state, f.year, t.timesession
order by state, quarter;

--e2. Show the every three months' average satisfatory rate over member profile and destination country.
select m.profdesc, l.country, f.year||'-'||f.month year_month,
round(sum(f.totalsatisfrate) / sum(f.numofcompswaps + f.numoffailswaps), 2) avgsatisrate,
round(avg(sum(f.totalsatisfrate)/sum(f.numofcompswaps + f.numoffailswaps))
over (order by m.profdesc, l.country, f.year, f.month rows 2 preceding) ,2) threemonthavg
from swapsfact f, memberprofiledim m, hlocationdim l
where f.profid = m.profid and f.dlocid = l.hlocid
group by m.profdesc, l.country, f.year, f.month
order by profdesc, country, year_month;

--New query
explain plan for
select * from (
select /*+ no_merge */ m.profdesc, l.country, f.year||'-'||f.month year_month,
round(sum(f.totalsatisfrate) / sum(f.numofcompswaps + f.numoffailswaps), 2) avgsatisrate,
round(avg(sum(f.totalsatisfrate)/sum(f.numofcompswaps + f.numoffailswaps))
over (order by m.profdesc, l.country, f.year, f.month rows 2 preceding) ,2) threemonthavg
from swapsfact f, memberprofiledim m, hlocationdim l
where f.profid = m.profid and f.dlocid = l.hlocid
group by m.profdesc, l.country, f.year, f.month)
order by profdesc, country, year_month;

select * from table(dbms_xplan.display);
