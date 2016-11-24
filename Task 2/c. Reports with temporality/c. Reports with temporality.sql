--c. Reports with temporality
--c1). What are the average rental saving of swaps based on house type, house size, temporary activities?
select decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(a.activitydesc), 1, 'Any Activity', a.activitydesc) tempactivity,
round(sum(f.TotalRentalSaving * g.weight_factor) / sum(f.numofcompswaps + f.numoffailswaps)) avgrentalsaving
from swapsfact f, housetypedim t, housesizedim s,  Localactivitygroup g, BRIDG_TEMPLOCACT B, TEMPLOCALACTIVITYDIM A
where f.housetypeid = t.housetypeid and f.housesize = s.housesize and f.locactgroupid = g.locactgroupid
and g.locactgroupid = b.locactgroupid and b.activityid = a.activityid
group by rollup (t.typedesc, f.housesize, a.activitydesc)
order by housetype, housesize, tempactivity;
select /*+use_nl (t s a) ordered */decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(a.activitydesc), 1, 'Any Activity', a.activitydesc) tempactivity,
round(sum(f.TotalRentalSaving * g.weight_factor) / sum(f.numofcompswaps + f.numoffailswaps)) avgrentalsaving
from  housetypedim t, housesizedim s, TEMPLOCALACTIVITYDIM A, swapsfact f, Localactivitygroup g, BRIDG_TEMPLOCACT B
where f.housetypeid = t.housetypeid and f.housesize = s.housesize and f.locactgroupid = g.locactgroupid
and g.locactgroupid = b.locactgroupid and b.activityid = a.activityid
group by rollup (t.typedesc, f.housesize, a.activitydesc)
order by housetype, housesize, tempactivity;
explain plan for


c2). Show the top 5 most popular activities (involed in most completed swaps) each season.
select * from (
select t.timesession, a.activitydesc, 
sum(f.numofcompswaps) totalcompswaps,
rank() over (partition by t.timesession order by sum(f.numofcompswaps) desc) actrank
from TEMPLOCALACTIVITYDIM A, swapsfact f, Localactivitygroup g, BRIDG_TEMPLOCACT B, timesessiondim t
where f.locactgroupid = g.locactgroupid and g.locactgroupid = b.locactgroupid and b.activityid = a.activityid
and f.timesessionid = t.timesessionid
group by t.timesession, a.activitydesc)
where actrank <5;

explain plan for
select * from (
select /* + ORDERED */ t.timesession, a.activitydesc, 
sum(f.numofcompswaps) totalcompswaps,
rank() over (partition by t.timesession order by sum(f.numofcompswaps) desc) actrank
from TEMPLOCALACTIVITYDIM A,  timesessiondim t, swapsfact f, Localactivitygroup g, BRIDG_TEMPLOCACT B
where f.locactgroupid = g.locactgroupid and g.locactgroupid = b.locactgroupid and b.activityid = a.activityid
and f.timesessionid = t.timesessionid
group by t.timesession, a.activitydesc)
where actrank <5;




select * from table(dbms_xplan.display);