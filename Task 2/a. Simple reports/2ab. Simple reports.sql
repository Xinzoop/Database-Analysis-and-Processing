--2ab. Simple reports

--a1).Show the monthly top 5 states in Australia which have most completed swaps based on house type.
select * from(
select f.year||f.Month as Year_Month, t.typedesc, h.state,  sum(f.NUMOFCOMPSWAPS)as completed,
rank() over(partition by f.year, f.Month, t.typedesc order by sum(f.NUMOFCOMPSWAPS) desc) as Num_rank
from swapsfact f, hlocationdim h, housetypedim t
where h.HLOCID = f.SLOCID and f.housetypeid = t.housetypeid and h.country = 'Australia'
group by f.year, f.Month, t.typedesc, h.STATE)
where Num_rank<=5
order by Year_Month, typedesc, num_rank;

explain plan for
select f.year||f.Month as Year_Month, t.typedesc, h.state,  sum(f.NUMOFCOMPSWAPS)as completed,
rank() over(partition by f.year, f.Month, t.typedesc order by sum(f.NUMOFCOMPSWAPS) desc) as Num_rank
from swapsfact f, hlocationdim h, housetypedim t
where h.HLOCID = f.SLOCID and f.housetypeid = t.housetypeid and h.country = 'Australia'
group by f.year, f.Month, t.typedesc, h.STATE;

select * from table(dbms_xplan.display);

select * from(
select /*+ ordered no_merge */ f.year||f.Month as Year_Month, t.typedesc, h.state,  sum(f.NUMOFCOMPSWAPS)as completed,
rank() over(partition by f.year, f.Month, t.typedesc order by sum(f.NUMOFCOMPSWAPS) desc) as Num_rank
from swapsfact f, housetypedim t, hlocationdim h
where h.HLOCID = f.SLOCID and f.housetypeid = t.housetypeid and h.country = 'Australia'
group by f.year, f.Month, t.typedesc, h.STATE
order by Year_Month, typedesc, num_rank)
where Num_rank<=5;


--a2). Show what kinds of swaps have the top 40% average satisfaction rate based on member profile, house type and size in Australia 2011. 
select * from(
select m.profdesc, T.Typedesc, f.housesize , round (sum(f.Totalsatisfrate)/(sum(f.Numofcompswaps + F.Numoffailswaps)),2) as AveSwSatif,
round (cume_dist() over (order by (sum(f.Totalsatisfrate)/sum(f.Numofcompswaps + F.Numoffailswaps))),2) as rankpct
from swapsfact f, memberprofiledim m, hlocationdim h, Housetypedim t
where f.YEAR = '2011' and h.HLOCID = f.SLOCID and h.country = 'Australia' and t.housetypeid = F.Housetypeid and f.profid = m.profid
group by m.profdesc, t.Typedesc, f.Housesize) 
where rankpct >=0.8
order by aveswsatif desc;

--New query
select * from(
select /*+ use_nl (m t) */ m.profdesc, T.Typedesc, f.housesize , round (sum(f.Totalsatisfrate)/(sum(f.Numofcompswaps + F.Numoffailswaps)),2) as AveSwSatif,
round (cume_dist() over (order by (sum(f.Totalsatisfrate)/sum(f.Numofcompswaps + F.Numoffailswaps))),2) as rankpct
from swapsfact f, memberprofiledim m, hlocationdim h, Housetypedim t
where f.YEAR = '2011' and h.HLOCID = f.SLOCID and h.country = 'Australia' and t.housetypeid = F.Housetypeid and f.profid = m.profid
group by m.profdesc, t.Typedesc, f.Housesize) 
where rankpct >=0.8
order by aveswsatif desc;
  
--a3). What are the yearly failed swaps in each state of Australia?
select l.state,f.year,  sum(f.numoffailswaps) totalfailswaps
from swapsfact f, hlocationdim l
where f.slocid = l.hlocid and l.country = 'Australia'
group by l.state, f.year
order by l.state, f.year;

select * from(
select /*+no_merge */l.state,f.year,  sum(f.numoffailswaps) totalfailswaps
from swapsfact f, hlocationdim l
where f.slocid = l.hlocid and l.country = 'Australia'
group by l.state, f.year)
order by state, year;

select * from table(dbms_xplan.display);