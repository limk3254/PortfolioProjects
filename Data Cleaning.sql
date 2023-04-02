/*

Cleaning Data in SQL Queries

*/

SELECT*
FROM 
	PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------


-- Standardize Date Format

SELECT
	SaleDateConverted, CONVERT(Date, SaleDate) 
FROM 
	PortfolioProject..NashvilleHousing

UPDATE
	NashvilleHousing
SET 
	SaleDate = Convert(Date, SaleDate)


ALTER TABLE NashvilleHousing
	Add SaleDateConverted Date;

UPDATE 
	NashvilleHousing
SET
	SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------------------


-- Populate Property Address data where Property Address is null

SELECT*
				
FROM 
	PortfolioProject..NashvilleHousing
--WHERE
--	PropertyAddress IS NULL
ORDER BY ParcelID


SELECT 
	a.ParcelID, a.PropertyAddress, b.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)				
FROM
	PortfolioProject..NashvilleHousing a
JOIN
	PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE
	a.PropertyAddress IS NULL


UPDATE 
	a
SET
	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)				
FROM
	PortfolioProject..NashvilleHousing a
JOIN
	PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE
	a.PropertyAddress IS NULL


-----------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
	PropertyAddress
FROM 
	PortfolioProject..NashvilleHousing
--WHERE
--	PropertyAddress IS NULL
--ORDER BY 
--	ParcelID


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM 
	PortfolioProject..NashvilleHousing

ALTER TABLE 
	NashvilleHousing
	add PropertySplitAddress Nvarchar(255);


UPDATE 
	NashvilleHousing
SET
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE 
	NashvilleHousing
	add PropertySplitCity Nvarchar(255);


UPDATE 
	NashvilleHousing
SET
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT
	OwnerAddress
FROM 
	PortfolioProject..NashvilleHousing


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM
	PortfolioProject..NashvilleHousing

ALTER TABLE 
	NashvilleHousing
	add OwnerSplitAddress Nvarchar(255);


UPDATE 
	NashvilleHousing
SET
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE 
	NashvilleHousing
	add OwnerSplitCity Nvarchar(255);


UPDATE 
	NashvilleHousing
SET
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

SELECT*
FROM 
	PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT
	Distinct (SoldAsVacant), Count(SoldAsVacant)
FROM
	PortfolioProject..NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 
	2


SELECT
	SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM
	PortfolioProject..NashvilleHousing

UPDATE 
	NashvilleHousing
SET
	SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


-----------------------------------------------------------------------------------------------------


-- Remove Duplicates


WITH RowNumCTE AS(
SELECT*
	,ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY
		UniqueID)
			row_num
FROM 
	PortfolioProject..NashvilleHousing
--ORDER BY 
--	ParcelID
)
SELECT*
FROM
	RowNumCTE
WHERE row_num > 1
ORDER BY 
	PropertyAddress


-----------------------------------------------------------------------------------------------------


-- Delete Unused Columns


SELECT*
FROM
	PortfolioProject..NashvilleHousing


ALTER TABLE
	PortfolioProject..NashvilleHousing
DROP COLUMN
	OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

