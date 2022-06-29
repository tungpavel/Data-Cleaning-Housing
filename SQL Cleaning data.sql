-- Cleaning data in SQL Queries



--SELECT SaleDateConverted = convert(date,saledate)
Select *
FROM [Project 3 Data cleaning].dbo.NashvilleHousing




--Standardise Date Format
SELECT Saledate, convert(date,saledate)
FROM [Project 3 Data cleaning].dbo.NashvilleHousing

update NashvilleHousing
Set SaleDate = convert(date,saledate)

Alter table nashvillehousing
Add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted = convert(date,saledate)





--Populate property address data
SELECT *
FROM [Project 3 Data cleaning].dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

SELECT a.parcelID, a.propertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM [Project 3 Data cleaning].dbo.NashvilleHousing a
JOIN [Project 3 Data cleaning].dbo.NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.propertyaddress is NULL

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM [Project 3 Data cleaning].dbo.NashvilleHousing a
JOIN [Project 3 Data cleaning].dbo.NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress is NULL




--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM [Project 3 Data cleaning].dbo.NashvilleHousing
--Where PropertyAddress is NULL
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, --Charindeex is a number -> -1 to remove the comma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [Project 3 Data cleaning].dbo.NashvilleHousing

Alter table nashvillehousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table nashvillehousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
FROM [Project 3 Data cleaning].dbo.NashvilleHousing



-- Change the OwnerAddress
Select OwnerAddress
FROM [Project 3 Data cleaning].dbo.NashvilleHousing

Select 
PARSENAME(Replace(ownerAddress, ',','.') , 3), --PARSENAME looks for PERIODS, need to replace commas wiht periods
PARSENAME(Replace(ownerAddress, ',','.') , 2),
PARSENAME(Replace(ownerAddress, ',','.') , 1)
FROM [Project 3 Data cleaning].dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(ownerAddress, ',','.') , 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(ownerAddress, ',','.') , 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(ownerAddress, ',','.') , 1) --can do columns first and then updates



-- Charge Y and N to YES and NO in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(soldasvacant)
FROM [Project 3 Data cleaning].dbo.NashvilleHousing
Group BY SoldAsVacant
Order by 2

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Project 3 Data cleaning].dbo.NashvilleHousing

update NashvilleHousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' -- =!!!
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Project 3 Data cleaning].dbo.NashvilleHousing



-- Remove Duplicates (What is a window function?

WITH RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
									   
FROM [Project 3 Data cleaning].dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
-- Order BY PropertyAddress


-- DELETE unused columns
SELECT *
FROM [Project 3 Data cleaning].dbo.NashvilleHousing

Alter table [Project 3 Data cleaning].dbo.NashvilleHousing
DROP COLUMN ownersplitc