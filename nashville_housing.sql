/*

Cleaning Data in SQL Queries

*/

SELECT * FROM nashville_housing

-------------------------------------------------------------------------------------
--Standardize Sale Date format


--selects column from sale date
SELECT saledate FROM nashville_housing

--Preview of desired change to sale date
SELECT saledate, CONVERT(DATE,saledate) 
FROM nashville_housing

--Implement saledate format update
UPDATE nashville_housing
SET saledate = CONVERT(date,saledate)

--ADD a copy of converted "Saledate" column 

ALTER TABLE nashville_housing
ADD saledate_update date;

--add converted date values
UPDATE nashville_housing
SET saledate_update = CONVERT(date,saledate);

--remove previous column
ALTER TABLE nashville_housing
DROP COLUMN saledate;

--rename column
EXEC sp_rename 'nashville_housing.saledate_update', 'saledate';

-------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT * FROM nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--if parcel id mathces the preceding row and property address is present in current row but not in preceding row
--populate with copy of address

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress 
FROM nashville_housing a
JOIN nashville_housing b
--WHERE PropertyAddress IS NULL
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
--WHERE PropertyAddress IS NULL
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL