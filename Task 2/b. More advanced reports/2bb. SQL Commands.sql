--b. More advanced reports:
--b1). What are the monthly average satisfactory rate for swappers in each state of Australia going to different destination countries?
select sl.state swapper_state, dl.country dest_country, year || '_' || month year_month, 
round(sum(totalsatisfrate) / sum(f.numofcompswaps + f.numoffailswaps), 2) AvgSatisRate
from swapsfact f, hlocationdim sl, hlocationdim dl
where f.slocid = sl.hlocid and f.dlocid = dl.hlocid 
and sl.country = 'Australia'
group by sl.state, dl.country, year||'_'||month
order by swapper_state, dest_country, year_month;

--New query
select  * from (
select /*+ no_merge  */ sl.state swapper_state, dl.country dest_country, year || '_' || month year_month, 
round(sum(totalsatisfrate) / sum(f.numofcompswaps + f.numoffailswaps), 2) AvgSatisRate
from swapsfact f, hlocationdim sl, hlocationdim dl
where f.slocid = sl.hlocid and f.dlocid = dl.hlocid and sl.country = 'Australia'
group by sl.state, dl.country, year||'_'||month )
order by swapper_state, dest_country, year_month;

--b2). What are the average rental saving of swaps based on house type, distance to large city, 
--house size, natural location and actual swap length?
select decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.largecitydist), 1, 'Any Distance', f.largecitydist) citydist, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(l.locdesc), 1, 'Any Location', l.locdesc) destloc, 
decode(grouping(f.swaplength), 1, 'All Periods', f.swaplength) swaplength, 
round(sum(f.TotalRentalSaving * g.weight_factor) / sum(f.numofcompswaps + f.numoffailswaps)) avgrentalsaving
from swapsfact f, housetypedim t, housesizedim s, naturallocgroup g, bridg_naturallocation b, naturallocationdim l
where f.housetypeid = t.housetypeid and f.housesize = s.housesize and f.nlocgroupid = g.nlocgroupid
and g.nlocgroupid = b.nlocgroupid and b.nlocid = l.nlocid
group by rollup (t.typedesc, f.largecitydist, f.housesize, l.locdesc, f.swaplength);

--New query
select /*+ ordered USE_NL (s t)*/decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.largecitydist), 1, 'Any Distance', f.largecitydist) citydist, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(l.locdesc), 1, 'Any Location', l.locdesc) destloc, 
decode(grouping(f.swaplength), 1, 'All Periods', f.swaplength) swaplength, 
round(sum(f.TotalRentalSaving * g.weight_factor) / sum(f.numofcompswaps + f.numoffailswaps)) avgrentalsaving
from housetypedim t, housesizedim s, swapsfact f, naturallocgroup g, bridg_naturallocation b, naturallocationdim l
where f.housetypeid = t.housetypeid and f.housesize = s.housesize and f.nlocgroupid = g.nlocgroupid
and g.nlocgroupid = b.nlocgroupid and b.nlocid = l.nlocid
group by rollup (t.typedesc, f.largecitydist, f.housesize, l.locdesc, f.swaplength);

--b3). What are the monthly total numbers of completed and failed swaps in each country of past years?
select l.country, f.year, f.month, sum(f.numofcompswaps) totalcompswaps,
sum(f.numoffailswaps) totalfailswaps
from swapsfact f, Hlocationdim l where f.slocid = l.hlocid
group by l.country, f.year, f.month
order by country, year, month;

--New query
select * from (
select /*+ no_merge */ l.country, f.year, f.month, sum(f.numofcompswaps) totalcompswaps,
sum(f.numoffailswaps) totalfailswaps
from swapsfact f, Hlocationdim l where f.slocid = l.hlocid
group by l.country, f.year, f.month)
order by country, year, month;