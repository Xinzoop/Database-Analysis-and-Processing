--Dimensions
--House Location (composed of Region, State and Country)
create table HLocationDim as select distinct region, state, country from house;
alter table HLocationDim add(HLocID number);
update HLocationDim set HLocID = rownum;

--Natural Location (Beach/Coastal, Mountain/Ranges, etc.)
create table NaturalLocationDim as select distinct locationid nlocid, locationdesc locdesc from location;

--Type of House (House, Apartment, etc)
create table HouseTypeDim as select distinct * from housetype;

--House size based on number of bedrooms, baths and sleeps [small (1 bedroom or 2 sleeps), medium
--(2 bedrooms or 3-4 sleeps), large (more than 3 bedrooms or more than 2 baths, more than 5 sleeps)]
create table HouseSizeDim (HouseSize varchar2(20) not null, HouseSizeDesc varchar2(100));
insert into HouseSizeDim values ('Small', '1 bedroom or 2 sleeps');
insert into HouseSizeDim values ('Medium', '2 bedrooms or 3-4 sleeps');
insert into HouseSizeDim values ('Large', 'more than 3 bedrooms or more than 2 baths, more than 5 sleeps');
insert into HouseSizeDim values ('Other', 'other size');

--Actual Swap Length [Short (less than 2 months), Medium (2-6 months), Long (greater than 6 months)]
Create table ActualSwapLengthDim (SwapLengthType varchar2(10) not null, SwapLengthDesc varchar2(50));
insert into ActualSwapLengthDim values ('Short', 'less than 2 months');
insert into ActualSwapLengthDim values ('Medium', '2-6 months');
insert into ActualSwapLengthDim values ('Long', 'greater than 6 months');

--Member Profile
create table MemberProfileDim as select distinct profile ProfDesc from swapper;
alter table MemberProfileDim add (ProfID number);
update MemberProfileDim set ProfID = rownum;

--Yearly Swaps
create table YearDim as select distinct to_char(dateto, 'YYYY') year from swaps;

--Monthly Swaps
create table MonthDim as select distinct to_char(dateto, 'MM') month from swaps;

--Swaps by Time Session
create table TimeSessionDim (TimeSessionID number, TimeSession varchar2(10) not null, TimeSessionDesc varchar2(20));
insert into TimeSessionDim values (1, 'Spring', '0901-1131');
insert into TimeSessionDim values (2, 'Summer', '1201-0231');
insert into TimeSessionDim values (3, 'Autumn', '0301-0531');
insert into TimeSessionDim values (4, 'Winter', '0601-0831');

--Destination Location (Actual destinations i.e. the swapee¡¯s house location)
--Same as swapper location dimension

--Nearest Major Airport [close (less than 20 km), far (21-40 km), very far (greater than 40 km)].
create table MajorAirportDistDim (MajorAirportDist varchar2(10) not null, MajorAirportDistDesc varchar2(50));
insert into MajorAirportDistDim values ('Unknown', 'Unknown');
insert into MajorAirportDistDim values ('Close', 'less than 20 km');
insert into MajorAirportDistDim values ('Far', '21-40 km');
insert into MajorAirportDistDim values ('Very far', 'greater than 40 km');

--Nearest Large City [inside city (less than 10), close (11-20 km), far (21-40 km), very far (greater than 40 km)]
create table LargeCityDistDim (LargeCityDist varchar2(32) not null, LargeCityDistDesc varchar2(50));
insert into LargeCityDistDim values ('Unknown', 'Unknown');
insert into LargeCityDistDim values ('Inside city', 'less than 10');
insert into LargeCityDistDim values ('Close', '11-20 km');
insert into LargeCityDistDim values ('Far', '21-40 km');
insert into LargeCityDistDim values ('Very far', 'greater than 40 km');

--Is Open to Any Destination (Y/N)
create table OpenToAnyDestDim as select distinct opentoanydest from swapper;

--House Amenities by type (Basic Amenities, Extra Amenities, Entertainment, Security)
create table AmenityTypeDim (AmenityTypeID varchar2(5) not null, AmenityType varchar2(32));
insert into AmenityTypeDim values ('1', 'Basic Amenities');
insert into AmenityTypeDim values ('2', 'Extra Amenities');
insert into AmenityTypeDim values ('3', 'Entertainment');
insert into AmenityTypeDim values ('4', 'Security');

--Temp Local Activity Dim
create table TempLocalActivityDim as select distinct * from templocalactivity;

--House Amenity BRIDG
create table HouseAmenityTypeTemp as 
select distinct houseid, case 
when amenityid in (27,1,5,8,11,12,15,16,20,21,3) then '1' 
when amenityid in (22,24,29,2,4,9,10,13,14) then '2' 
when amenityid in (23,28,30,31,6,7,17,18,19) then '3' 
when amenityid in (25,26) then '4' 
end as AmenityTypeID from provides;

create table HouseAmenityTypeGroupTemp as
select houseid, listagg(amenitytypeid, '_') within group (order by amenitytypeid) AmenityTypeGroupList
from HouseAmenityTypeTemp group by houseid;

create table HouseAmenityTypeGroupIDTemp as
select rownum AmenityTypeGroupID, AmenityTypeGroupList from
(select distinct AmenityTypeGroupList from HouseAmenityTypeGroupTemp);

create table AmenityTypeGroup as
select AmenityTypeGroupID, i.AmenityTypeGroupList, Weight_factor from HouseAmenityTypeGroupIDTemp i, 
(select AmenityTypeGroupList, 1 / count(AmenityTypeID) Weight_factor from
(select distinct AmenityTypeGroupList, AmenityTypeID from HouseAmenityTypeGroupTemp g, HouseAmenityTypeTemp y where g.houseid  = y.houseid)
group by AmenityTypeGroupList) f where i.AmenityTypeGroupList = f.AmenityTypeGroupList;

create table BRIDG_AmenityType as
select distinct AmenityTypeGroupID, AmenityTypeID
from HouseAmenityTypeTemp t, HouseAmenityTypeGroupTemp g, HouseAmenityTypeGroupIDTemp i
where g.houseid = t.houseid and g.AmenityTypeGroupList = i.AmenityTypeGroupList;

drop table HouseAmenityTypeTemp;
drop table HouseAmenityTypeGroupTemp;
drop table HouseAmenityTypeGroupIDTemp;

--Natural Location BRIDG
create table HouseNLocGroupTemp as
select houseid, listagg(locationid, '_') within group (order by locationid) NLocGroupList
from islocated group by houseid;

create table HouseNLocGroupIDTemp as
select rownum NLocGroupID, NLocGroupList from
(select distinct NLocGroupList from HouseNLocGroupTemp);

create table NaturalLocGroup as
select NLocGroupID, i.NLocGroupList, Weight_factor from HouseNLocGroupIDTemp i,
(select NLocGroupList, 1 / count(Locationid) weight_factor from
(select distinct NLocGroupList, Locationid from HouseNLocGroupTemp g, islocated i where g.houseid = i.houseid)
group by NLocGroupList) f where i.NLocGroupList = f.NLocGroupList;

create table BRIDG_NaturalLocation as
select distinct NLocGroupID, locationid NLocID
from housenlocgrouptemp g, HouseNLocGroupIDTemp i, islocated l
where g.houseid = l.houseid and g.NLocGroupList = i.NLocGroupList;

drop table housenlocgrouptemp;
drop table HouseNLocGroupIDTemp;

--Temp local activity BRIDG
create table LocActGroupTemp as 
select houseid, LISTAGG(activityid, '_') within group (order by activityid) LocActGroupList 
from hasaccessto group by houseid;

create table LocActGroupIDTemp as
select rownum LocActGroupID, locactgrouplist from
(select distinct locactgrouplist from locactgrouptemp);

create table LocalActivityGroup as
select i.LocActGroupID, i.locactgrouplist, f.weight_factor from LocActGroupIDTemp i,
(select locactgrouplist, 1 / count(activityid) weight_factor from
(select distinct locactgrouplist, activityid from locactgrouptemp t, hasaccessto h where t.houseid = h.houseid)
group by locactgrouplist) f
where i.locactgrouplist = f.locactgrouplist;

create table BRIDG_TempLocAct as
select distinct i.LocActGroupID, a.activityid
from LocActGroupIDTemp i, locactgrouptemp h, hasaccessto a
where i.LocActGroupList = h.LocActGroupList and h.houseid = a.houseid;

drop table locactgrouptemp;
drop table LocActGroupIDTemp;

--Swaps Fact
--Temp Fact
create table SwapsFactTemp as
select distinct
--House ID used temporarily
h.houseid,
--Member Profile
er.profile ProfDesc,
--Actual Swap Length
dateto - datefrom SwapDays, 
--Year
to_char(dateto, 'YYYY') year,
--Month
to_char(dateto, 'MM') month, 
--Time Session
case 
when to_char(dateto, 'MMdd') between '0301' and '0531' then 3
when to_char(dateto, 'MMdd') between '0601' and '0831' then 4
when to_char(dateto, 'MMdd') between '0901' and '1131' then 1
else 2 end TimeSessionID,
--Nearest Major Airport Distance
case
when h.nearestmajorairport is null then 'Unknown'
when h.majorairportdistance < 20 then 'Close'
when h.majorairportdistance between 21 and 40 then 'Far'
else 'Very far' end MajorAirportDist, 
--Nearest Large City Distance
case
when h.nearestlargecity is null then 'Unknown'
when h.largecitydistance < 10 then 'Inside city'
when h.largecitydistance between 11 and 20 then 'Close'
when h.largecitydistance between 21 and 40 then 'Far'
else 'Very far' end LargeCityDist, 
--Is Open to Any Destination
er.opentoanydest, 
--House Size
case
when h.noofbedrooms = 1 or h.noofsleeps = 2 then 'Small'
when h.noofbedrooms = 3 or h.noofsleeps between 3 and 4 then 'Medium'
when h.noofbedrooms > 3 or h.noofbathrooms > 3 or h.noofsleeps > 5 then 'Large'
else 'Other' end HouseSize,
--House Type
h.HouseTypeID,
--Swapper Location
h.region, h.state, h.country,
--Destination Location
d.region dregion, d.state dstate, d.country dcountry,
--Completed
completed,
--Satisfaction Rate = (FeedbackDest + FeedBackOwn)/2
(feedbackdest + feedbackown) /2 satisRate,
--Rent Per Week
h.rentperweek

from swapper er, swaps s, house h, Swapper ee, house d
where er.houseid = h.houseid and s.swapperid = er.swapperid and s.swapeeid = ee.swapperid and ee.houseid = d.houseid
;

--Add Fields
alter table SwapsFactTemp add (ProfID number, SLocID number, DLocID number, 
NLocGroupID number, LocActGroupID number, AmenityTypeGroupID number, SwapLength varchar2(10));

--House Amenity Type Temp
create table HouseAmenityTypeTemp as select distinct houseid, case 
when amenityid in (27,1,5,8,11,12,15,16,20,21,3) then '1' 
when amenityid in (22,24,29,2,4,9,10,13,14) then '2' 
when amenityid in (23,28,30,31,6,7,17,18,19) then '3' 
when amenityid in (25,26) then '4' 
end as AmenityTypeID from provides;

--Update Temp Fact
update SwapsFactTemp set 
  --Update Member Profile ID
  ProfID = (select ProfID from MemberProfileDim p where p.ProfDesc = SwapsFactTemp.ProfDesc),
  --Update Swap Length
  SwapLength = case when SwapDays / 30 < 2 then 'Short' when SwapDays / 30 between 2 and 6 then 'Medium'
    when SwapDays / 30 > 6 then 'Long' end,
  --Update Swapper Location ID (Region/State/Country)
  SLocID = (select HLocID from HLocationDim h where h.Region = SwapsFactTemp.Region 
    and h.State = SwapsFactTemp.State and h.Country = SwapsFactTemp.Country),
  --Update Destination Location ID (Region/State/Country)
  DLocID = (select HLocID from HLocationDim h where h.Region = SwapsFactTemp.dRegion 
    and h.State = SwapsFactTemp.dState and h.Country = SwapsFactTemp.dCountry),
  --Update Natural Location Group ID
  NLocGroupID = (select NLocGroupID from NaturalLocGroup g,
    (select houseid, listagg(locationid, '_') within group (order by locationid) NLocGroupList
    from islocated group by houseid) i where g.NLocGroupList = i.NLocGroupList and i.houseid = SwapsFactTemp.houseid),
  --Update Local Activity Group ID
  LocActGroupID = (select LocActGroupID from LocalActivityGroup g,
    (select houseid, listagg(activityid, '_') within group (order by activityid) LocActGroupList
    from hasaccessto group by houseid) i where g.LocActGroupList = i.LocActGroupList and i.houseid = SwapsFactTemp.houseid),
  --Update Amenity Type Group ID
  AmenityTypeGroupID = (select AmenityTypeGroupID from AmenityTypeGroup g,
    (select houseid, listagg(AmenityTypeID, '_') within group (order by AmenityTypeID) AmenityTypeGroupList
    from HouseAmenityTypeTemp group by houseid) i where g.AmenityTypeGroupList = i.AmenityTypeGroupList 
    and i.houseid = SwapsFactTemp.houseid)
  ;
  
drop table HouseAmenityTypeTemp;

--Swaps Fact
create table SwapsFact as select 
sum(case when completed = 'Y' then 1 else 0 end) NumofCompSwaps,
sum(case when completed = 'N' then 1 else 0 end) NumofFailSwaps,
sum(satisRate) TotalSatisfRate,
sum(rentperweek * swapdays / 7) TotalRentalSaving,
NLocGroupID, LocActGroupID, AmenityTypeGroupID, HouseTypeID, SLocID, DLocID, ProfID, SwapLength, Year, Month, TimeSessionID,
MajorAirportDist, LargeCityDist, OpenToAnyDest, HouseSize
from SwapsFactTemp group by 
NLocGroupID, LocActGroupID, AmenityTypeGroupID, HouseTypeID, SLocID, DLocID, ProfID, SwapLength, Year, Month, TimeSessionID,
MajorAirportDist, LargeCityDist, OpenToAnyDest, HouseSize;

select * from swapsfact;
