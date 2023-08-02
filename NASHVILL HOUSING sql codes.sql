create database project;
use project;
show tables;

-- data cleaning:

set sql_safe_updates=0;
alter table `nashville housing data for data cleaning` rename housing;
select * from housing;
update housing
set SaleDate= str_to_date(SaleDate,'%M %d, %Y');
alter table housing
modify column SaleDate date;
alter table housing
modify column OwnerAddress varchar(50);
select *  from housing
order by parcelid;
select UniqueID, count(ParcelID) from housing
group by UniqueID
order by count(ParcelID) desc;

-- so we dont have duplicates in uniqueID

select ParcelID, count(UniqueID) from housing
group by ParcelID
order by count(UniqueID) desc;

-- we have duplicates in parcelID

delete t1 FROM housing t1
INNER  JOIN housing t2
WHERE
    t1.UniqueID < t2.UniqueID AND
    t1.ParcelID = t2.ParcelID ;
    
select ParcelID, count(*)
from housing
group by ParcelID
having count(*)>1;
-- lets seperate the address from the city 

select PropertyAddress from housing ;

select  substring_index(PropertyAddress,',',1) address, PropertyAddress,
right(PropertyAddress,
 length(PropertyAddress)-position(',' in PropertyAddress)) city
from housing;

-- lets add the prev. made columns into the table

alter table housing
add address varchar(255);

update housing
set address= substring_index(PropertyAddress,',',1);

alter table housing
add city text;

update housing
set city= right(PropertyAddress,
 length(PropertyAddress)-position(',' in PropertyAddress));
 
 select length(substring_index(OwnerAddress,',',2)),substring_index(OwnerAddress,',',2) from housing;
 
 select OwnerAddress , substring_index(OwnerAddress,',',1) owner_add, 
 right(OwnerAddress,length(OwnerAddress)-(length(substring_index(OwnerAddress,',',2))+1)) owner_state
 ,right(left( OwnerAddress,length(substring_index(OwnerAddress,',',2))),length(left( OwnerAddress,length(substring_index(OwnerAddress,',',2))))-(length(substring_index(OwnerAddress,',',1))+1))
 owner_city
 from housing;
  
  alter table housing
  add owner_add varchar(225);
  
  update housing 
  set owner_add=substring_index(OwnerAddress,',',1);
  
  alter table housing
  add owner_state text;
  
  update housing
  set owner_state= right(OwnerAddress,length(OwnerAddress)-(length(substring_index(OwnerAddress,',',2))+1));
 
 alter table housing 
 add owner_city text;
 
 update housing
 set owner_city= right(left( OwnerAddress,length(substring_index(OwnerAddress,',',2))),length(left( OwnerAddress,length(substring_index(OwnerAddress,',',2))))-(length(substring_index(OwnerAddress,',',1))+1));
 
 select * from housing;
 
 -- lets change SoldAsVacant column to Y and N
 
 select distinct SoldAsVacant from housing;
 
 select SoldAsVacant,case when SoldAsVacant in ('No','N') then 'N'
 else 'Y'
 end 
 from housing;
 
 update housing
 set SoldAsVacant=case when SoldAsVacant in ('No','N') then 'N'
 else 'Y'
 end ;
 
 -- lets delete unuseful columns:
  select * from housing;
  
  alter table housing
  drop column HalfBath,
  drop column  OwnerAddress,
  drop column TaxDistrict,
  drop column PropertyAddress,
  drop column LegalReference ;
  
  -- lets change some columns name:
  alter table housing
  change column address property_adress varchar(225);
  
    alter table housing
  change column city property_city varchar(225); 
   
   -- analyzing the data: 
   
   -- how lands are being used?
   select LandUse, count(*) from housing
   group by LandUse;
    
    -- how many houses were vacant and how many were not?
    select SoldAsVacant, count(*) from housing
    group by SoldAsVacant;
    
    -- how is the selling through the years?
   select SaleDate, date_format(SaleDate,'%Y') year_of_sale
   from housing;

     -- what is the disrtibution of bedrooms in our buildings?
   select Bedrooms, count(*)
   from housing
   group by Bedrooms;
   
   -- what is the average of Acreage, SalePrice, TotalValue?
   select round(avg(Acreage),2) avg_acreage , avg(SalePrice) avg_saleprice, avg(TotalValue) avg_TotalValue
   from housing;
   
   -- how many clients do we have?
   select  count(UniqueID)
   from housing;
   