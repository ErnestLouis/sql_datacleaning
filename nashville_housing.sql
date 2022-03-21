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


-------------------------------------------------------------------------------------------------

--Seperate Address into Individual Columns (Address,city)

SELECT propertyaddress
FROM nashville_housing

SELECT SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) AS Address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,LEN(PropertyAddress)) AS City
FROM nashville_housing

--Create new address column
ALTER TABLE nashville_housing
ADD separated_propertyaddress NVarchar(255);

UPDATE nashville_housing
SET separated_propertyaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)

--Create new city column
ALTER TABLE nashville_housing
ADD separated_propertycity NVarchar(255);

UPDATE nashville_housing
SET separated_propertycity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,LEN(PropertyAddress))

-------------------------------------------------------------------------------------------------

--Seperate OwnerAddress into Individual Columns (Address,city,state)


SELECT owneraddress FROM nashville_housing

SELECT
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM nashville_housing

--Create new address column
ALTER TABLE nashville_housing
ADD separated_owneraddress NVarchar(255);

UPDATE nashville_housing
SET separated_owneraddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

--Create new city column
ALTER TABLE nashville_housing
ADD separated_ownercity NVarchar(255);

UPDATE nashville_housing
SET separated_ownercity = PARSENAME(REPLACE(owneraddress,',','.'),2)

--Create new state column
ALTER TABLE nashville_housing
ADD separated_ownerstate NVarchar(255);

UPDATE nashville_housing
SET separated_ownerstate = PARSENAME(REPLACE(owneraddress,',','.'),1)

--Change Y and N to Yes and NO in "Sold as Vacant" field

SELECT DISTINCT soldasvacant ,COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY 2


--conversts Y and N to Yes and No

SELECT soldasvacant,
CASE
	WHEN Soldasvacant = 'Y' THEN 'Yes'
	WHEN Soldasvacant = 'N' THEN 'No'
	ELSE Soldasvacant
END
FROM nashville_housing

--Implement conversion update

UPDATE nashville_housing
SET soldasvacant = CASE
	WHEN Soldasvacant = 'Y' THEN 'Yes'
	WHEN Soldasvacant = 'N' THEN 'No'
	ELSE Soldasvacant
END

-------------------------------------------------------------------------------------------------

--Remove duplicates 
--using cte and partition

WITH Rownum_cte AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM nashville_housing
)
DELETE --SELECT *,
FROM Rownum_cte
WHERE row_num > 1


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT * 
FROM nashville_housing

