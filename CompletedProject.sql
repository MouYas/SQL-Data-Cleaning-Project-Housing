/*
Housing Data Cleaning

Skills used: Self Joins, CTE's, Windows Functions, Creating Tables, Altering Tables, Updating Tables, Converting Data Types

*/



SELECT * 
FROM data_cleaning_project_housing.dbo.housing;

-- CREATING A NEW DUPLICATED TABLE


SELECT *
INTO cleanedTable
FROM data_cleaning_project_housing.dbo.housing;

SELECT * 
FROM data_cleaning_project_housing.dbo.cleanedTable;


-- CORRECTING SALEDATE COLUMN


SELECT SaleDate, CAST(SaleDate AS date)
FROM data_cleaning_project_housing.dbo.cleanedTable;

ALTER TABLE data_cleaning_project_housing.dbo.cleanedTable
ALTER COLUMN SaleDate DATE;


---- POPULATE PROPERTY ADDRESS

SELECT t1.[UniqueID ],t1.ParcelID,t1.PropertyAddress,
t2.[UniqueID ],t2.ParcelID,t2.PropertyAddress, 
isnull(t1.PropertyAddress,t2.PropertyAddress)
FROM data_cleaning_project_housing.dbo.cleanedTable AS t1
JOIN data_cleaning_project_housing.dbo.cleanedTable AS t2
ON t1.ParcelID= t2.ParcelID
WHERE t1.PropertyAddress IS NULL 
AND t2.PropertyAddress IS NOT NULL
ORDER BY t1.ParcelID;

UPDATE t1
SET PropertyAddress = isnull(t1.PropertyAddress,t2.PropertyAddress)
FROM data_cleaning_project_housing.dbo.cleanedTable AS t1
JOIN data_cleaning_project_housing.dbo.cleanedTable AS t2
ON t1.ParcelID= t2.ParcelID
WHERE t1.PropertyAddress IS NULL 
AND t2.PropertyAddress IS NOT NULL;


--BREAKING OUT PROPERTY ADDRESS


SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM data_cleaning_project_housing.dbo.cleanedTable;

ALTER TABLE data_cleaning_project_housing.dbo.cleanedTable
ADD PropertyAddress1 nvarchar(255);


ALTER TABLE data_cleaning_project_housing.dbo.cleanedTable
ADD PropertyAddress2 nvarchar(255);

UPDATE data_cleaning_project_housing.dbo.cleanedTable
SET PropertyAddress1 = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE data_cleaning_project_housing.dbo.cleanedTable
SET PropertyAddress2 = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--BREAKING OUT OWNER ADDRESS

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM data_cleaning_project_housing.dbo.cleanedTable;

ALTER TABLE data_cleaning_project_housing.dbo.cleanedTable
ADD OwnerSplitAddress nvarchar(255);


ALTER TABLE data_cleaning_project_housing.dbo.cleanedTable
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE data_cleaning_project_housing.dbo.cleanedTable
ADD OwnerSplitState nvarchar(255);

UPDATE data_cleaning_project_housing.dbo.cleanedTable
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


--STANDARDIZE SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' then 'No'
     WHEN SoldAsVacant = 'Y' then 'Yes'
     ELSE SoldAsVacant END
 FROM data_cleaning_project_housing.dbo.cleanedTable
 WHERE SoldAsVacant IN ('N','Y');


 UPDATE data_cleaning_project_housing.dbo.cleanedTable
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' then 'No'
     WHEN SoldAsVacant = 'Y' then 'Yes'
     ELSE SoldAsVacant END



-- REMOVE DUPLICATES


WITH DupCTE AS(
SELECT *,
Row_Number () OVER (PARTITION BY 
                          ParcelID,
                          PropertyAddress,
                          SaleDate,
                          LegalReference, 
                          SalePrice,
                          OwnerName,
                          YearBuilt
                          ORDER BY UniqueID) AS dup
FROM data_cleaning_project_housing.dbo.cleanedTable)

DELETE
FROM DupCTE 
WHERE dup > 1;


-- REMOVING UNWANTED COLUMNS

ALTER TABLE data_cleaning_project_housing.dbo.cleanedTable
DROP COLUMN PropertyAddress,OwnerAddress;

