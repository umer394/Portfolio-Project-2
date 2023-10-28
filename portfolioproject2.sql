--cleaning data in sql queries

select *
from PortfolioProject.dbo.NashvilleHousing
order by 2,3

-----------------------------------------------------------------------------------------------
--standardize  data format


select Saleconverteddate,CONVERT(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

Alter Table NashvilleHousing
Add Saleconverteddate date;

Update NashvilleHousing
set Saleconverteddate=CONVERT(date,SaleDate)

-----------------------------------------------------------------------------------------------
--Populate property address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
order by 2,3


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------

--Breaking out address into individual coloumns(Address,city,state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID



SELECT
SUBSTRING (PropertyAddress,1,CHARINDEX(',',	PropertyAddress) -1) as Address
,SUBSTRING (PropertyAddress,CHARINDEX(',',	PropertyAddress) + 1, LEN(PropertyAddress)) as Address
--,CHARINDEX(',',	PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',	PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',	PropertyAddress) + 1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing
order by 2,3



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select 
ParseName(Replace(OwnerAddress,',','.'),3)
,ParseName(Replace(OwnerAddress,',','.'),2)
,ParseName(Replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress=ParseName(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity=ParseName(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState=ParseName(Replace(OwnerAddress,',','.'),1)


select *
from PortfolioProject.dbo.NashvilleHousing
order by 2,3


--------------------------------------------------------------------------------------------------

--change Y and N to Yes and No in "sold as vacant" field


select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant=case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
--------------------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
Delete
from RowNumCTE
Where row_num > 1
--Order by PropertyAddress


With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
select *
from RowNumCTE
Where row_num > 1
--Order by PropertyAddress

----------------------------------------------------------------------------------------------------

--Delete Unused Coloumn


select *
from PortfolioProject.dbo.NashvilleHousing
order by 2,3


Alter table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

Alter table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate