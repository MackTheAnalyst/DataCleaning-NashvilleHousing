/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly

 
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing



-----------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a. [UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a. [UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress is null



-----------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add  PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add  PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress  Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3)

ALTER TABLE NashvilleHousing
Add  OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2)

ALTER TABLE NashvilleHousing
Add  OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)




-----------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing 
Group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END




-----------------------------------------------------------------------------------------------------------------


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 ORDER BY 
							UniqueID
								) row_num

FROM PortfolioProject..NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



-----------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




