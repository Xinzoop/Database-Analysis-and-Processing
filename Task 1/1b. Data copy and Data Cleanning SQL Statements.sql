--Swapper
create table swapper as select * from dw_swapper.swapper;
update swapper set profile = 'Unknown' where profile = 'Swap';

--Amenity
create table amenity as select * from DW_SWAPPER.amenity ;
update amenity set amenitydesc = 'Highchair' where amenityid = 4;

--House
create table house as select * from DW_SWAPPER.house;
update house set country = 'United Kingdom' where country = 'International';
update house set country = 'Reunion' where country = 'R?union';
update house set region = 'Auckland' where houseid = 1429;
update house set region = 'Russell' where houseid = 1425;
update house set region = 'San Pedro deAlcantara' where houseid = 1006;
update house set region = 'Singapore' where houseid = 1552;
update house set region = 'Singapore' where houseid = 1742;
update house set region = 'Melbourne' where houseid = 1691;
update house set region = 'East Redfern/Surry Hills' where houseid = 208;
update house set region = 'Victor Harbor' where houseid  = 1386;
update house set region='Williamstown' where houseid = 1227;
update house set region='Coochiemudlo Island' where houseid = 144;
update house set region='Newcastle/Lake Macquarie' where houseid = 455;
update house set region='Williamstown' where houseid = 1227;
update house set region='Bendigo/Daylesford' where houseid = 78;
update house set region='Richmond' where houseid = 205;
update house set region='Northcote' where houseid = 1245;
update house set region='Lewisham' where houseid = 1227;
update house set region='Wilston' where houseid = 528;
update house set region='Coffs Harbour' where houseid = 110;
update house set region='Lane Cove' where houseid = 122;
update house set region='Zetland' where houseid = 150;
--Housetype
create table housetype as select * from dw_swapper.housetype;

--Swaps
create table swaps as select * from DW_SWAPPER.swaps;

--Location
create table location as select * from dw_swapper.location;

--IsLocated
create table islocated as select * from dw_swapper.islocated;

--Provides
create table provides as select * from DW_SWAPPER.provides;

--LocalActivity
create table localactivity as select * from DW_SWAPPER.localactivity;

--HasAccessTo
create table hasaccessto as select * from dw_swapper.hasaccessto;

--TempLocalActivity
create table templocalactivity as select * from DW_SWAPPER.templocalactivity;