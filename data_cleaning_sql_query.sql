/*
Cleaning Data in SQL Queries
*/


Select *
From portfolio_project.dbo.nashvillehousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From portfolio_project.dbo.nashvillehousing


Update nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE nashvillehousing
Add SaleDateConverted Date;

Update nashvillehousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From portfolio_project.dbo.nashvillehousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project.dbo.nashvillehousing a
JOIN portfolio_project.dbo.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project.dbo.nashvillehousing a
JOIN portfolio_project.dbo.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From portfolio_project.dbo.nashvillehousing
--Where PropertyAddress is null
--order by ParcelID
-- data separated by comma is called deliminater
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
--charindex gives the position of comma so to remove comma from end of each line we subtract 1

From portfolio_project.dbo.nashvillehousing


ALTER TABLE nashvillehousing
Add propertysplitaddress Nvarchar(255);

Update nashvillehousing
SET propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From portfolio_project.dbo.nashvillehousing



Select OwnerAddress
From portfolio_project.dbo.nashvillehousing

select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)  ----parsename separates fromm backword at desired number of word and position
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From portfolio_project.dbo.nashvillehousing


ALTER TABLE nashvillehousing
Add ownerpropertysplitaddress Nvarchar(255);

Update nashvillehousing
SET ownerpropertysplitaddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


ALTER TABLE nashvillehousing
Add ownerPropertySplitCity Nvarchar(255);

Update nashvillehousing
SET ownerPropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE nashvillehousing
Add ownerpropertysplitstate Nvarchar(255);

Update nashvillehousing
SET ownerpropertysplitstate = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Select *
From portfolio_project.dbo.nashvillehousing

--change Y and N to yes and no in "sold as vacant" field
Select distinct(SoldAsVacant), count(SoldAsVacant)
From portfolio_project.dbo.nashvillehousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
       when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end
From portfolio_project.dbo.nashvillehousing


Update nashvillehousing
SET SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
       when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end
From portfolio_project.dbo.nashvillehousing

--removing duplicates
with RowNumCTE as(
select *,
      ROW_NUMBER() over (
	  partition by ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
	  order by UniqueID
	  ) row_num
From portfolio_project.dbo.nashvillehousing
)
select *
from RowNumCTE
where row_num >1
order by PropertyAddress

--to delete duplicate rows in place of select type delete 
-- again type select and run and see the results
with RowNumCTE as(
select *,
      ROW_NUMBER() over (
	  partition by ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
	  order by UniqueID
	  ) row_num
From portfolio_project.dbo.nashvillehousing
)
delete
from RowNumCTE
where row_num >1
--order by PropertyAddress


---delete unused columns
alter table portfolio_project.dbo.nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
From portfolio_project.dbo.nashvillehousing














	   














