--2f Reports with partitions
--R1:  What are the yearly average rental savings for different house types 
--in each country? (Partition over country)
select l.country,
decode(grouping(f.year), 1, 'All Years', f.year) year,
decode(grouping(t.typedesc), 1, 'All Types', t.typedesc) housetype,
round(sum(totalrentalsaving) / sum(numofcompswaps + numoffailswaps)) avgrentalsaving
from swapsfact f, housetypedim t, hlocationdim l
where f.housetypeid = t.housetypeid and f.slocid = l.hlocid
group by l.country, rollup(f.year, t.typedesc)
order by country, year, housetype;

--New query
select * from (
select l.country,
decode(grouping(f.year), 1, 'All Years', f.year) year,
decode(grouping(t.typedesc), 1, 'All Types', t.typedesc) housetype,
round(sum(totalrentalsaving) / sum(numofcompswaps + numoffailswaps)) avgrentalsaving
from swapsfact f, housetypedim t, hlocationdim l
where f.housetypeid = t.housetypeid and f.slocid = l.hlocid
group by l.country, rollup(f.year, t.typedesc))
order by country, year, housetype;

--R2: What are the average satisfactory rate and rank of different 
--member profiles going to different countries in each year? (Partition over year)
select f.year, p.profdesc, l.country,
round(sum(totalsatisfrate) / sum(numofcompswaps + numoffailswaps), 2) avgsatisfrate,
rank() over (partition by year,profdesc order by (sum(totalsatisfrate) / sum(numofcompswaps + numoffailswaps)) desc) rank
from swapsfact f, hlocationdim l, memberprofiledim p
where f.dlocid = l.hlocid and f.profid = p.profid
group by f.year, p.profdesc, l.country
order by f.year, p.profdesc;

--New query
alter table hlocationdim add constraint location_pk primary key (hlocid);
select f.year, p.profdesc, l.country,
round(sum(totalsatisfrate) / sum(numofcompswaps + numoffailswaps), 2) avgsatisfrate,
rank() over (partition by year,profdesc order by (sum(totalsatisfrate) / sum(numofcompswaps + numoffailswaps)) desc) rank
from swapsfact f, hlocationdim l, memberprofiledim p
where f.dlocid = l.hlocid and f.profid = p.profid
group by f.year, p.profdesc, l.country
order by f.year, p.profdesc;

--Restore the table
alter table hlocationdim drop constraint location_pk;