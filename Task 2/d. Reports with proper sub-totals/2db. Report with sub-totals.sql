--2d. Reports with proper sub-totals:
--R1: What are the total successful and failed swap numbers based on different house types, size, 
--distance to major airport and large city in Australia?
explain plan for
select 
decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(f.majorairportdist), 1, 'Any Airport Distance', f.majorairportdist) majorairportdist, 
decode(grouping(f.largecitydist), 1, 'Any Large City Distance', f.largecitydist) largecitydist,
sum(f.numofcompswaps) totalcompswaps, sum(f.numoffailswaps) totalfailswaps
from swapsfact f, housesizedim s, housetypedim t
where f.housesize = s.housesize and f.housetypeid = t.housetypeid
group by rollup(t.typedesc, f.housesize, f.majorairportdist, f.largecitydist);

select * from table(dbms_xplan.display);

--New query
select /*+ use_nl (s t)*/
decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(f.majorairportdist), 1, 'Any Airport Distance', f.majorairportdist) majorairportdist, 
decode(grouping(f.largecitydist), 1, 'Any Large City Distance', f.largecitydist) largecitydist,
sum(f.numofcompswaps) totalcompswaps, sum(f.numoffailswaps) totalfailswaps
from swapsfact f, housesizedim s, housetypedim t
where f.housesize = s.housesize and f.housetypeid = t.housetypeid
group by rollup(t.typedesc, f.housesize, f.majorairportdist, f.largecitydist);

--R2: What are the yearly average rental saving of different house types, house size and amenity types?
select 
decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(a.amenitytype), 1, 'Any Amenity Type', a.amenitytype) amenitytype,
round(sum(totalrentalsaving * g.weight_factor) / sum(numofcompswaps + numoffailswaps),2) avgRentalSaving
from swapsfact f, housetypedim t, amenitytypegroup g, bridg_amenitytype b, amenitytypedim a
where f.housetypeid = t.housetypeid and f.amenitytypegroupid = g.amenitytypegroupid
and g.amenitytypegroupid = b.amenitytypegroupid and b.amenitytypeid = a.amenitytypeid
group by rollup(t.typedesc, f.housesize, a.amenitytype); 

--New query
select /*+ ordered */
decode(grouping(t.typedesc), 1, 'Any Type', t.typedesc) housetype, 
decode(grouping(f.housesize), 1, 'Any Size', f.housesize) housesize, 
decode(grouping(a.amenitytype), 1, 'Any Amenity Type', a.amenitytype) amenitytype,
round(sum(totalrentalsaving * g.weight_factor) / sum(numofcompswaps + numoffailswaps),2) avgRentalSaving
from swapsfact f, housetypedim t, amenitytypegroup g, bridg_amenitytype b, amenitytypedim a
where f.housetypeid = t.housetypeid and f.amenitytypegroupid = g.amenitytypegroupid
and g.amenitytypegroupid = b.amenitytypegroupid and b.amenitytypeid = a.amenitytypeid
group by rollup(t.typedesc, f.housesize, a.amenitytype); 

--R3: What are average satisfactory rate of swaps for different types of member profile in each country?
select 
decode(grouping(l.country), 1, 'Any Country', l.country) country,
decode(grouping(p.profdesc), 1, 'Any Profile', p.profdesc) profile, 
decode(grouping(f.year), 1, 'Any Year', f.year) year,
round(sum(totalsatisfRate) / sum(numofcompswaps + numoffailswaps), 2) avgsatisrate
from swapsfact f, memberprofiledim p, hlocationdim l
where f.profid = p.profid and f.slocid = l.hlocid
group by cube(l.country, p.profdesc, f.year);


--New query
alter table memberprofiledim add constraint Memberprofile_PK PRIMARY KEY(profid);
select
decode(grouping(l.country), 1, 'Any Country', l.country) country,
decode(grouping(p.profdesc), 1, 'Any Profile', p.profdesc) profile, 
decode(grouping(f.year), 1, 'Any Year', f.year) year,
round(sum(totalsatisfRate) / sum(numofcompswaps + numoffailswaps), 2) avgsatisrate
from swapsfact f, memberprofiledim p, hlocationdim l
where f.profid = p.profid and f.slocid = l.hlocid
group by cube(l.country, p.profdesc, f.year);

--Restore the table
alter table memberprofiledim drop constraint Memberprofile_PK;
