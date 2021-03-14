[CmdletBinding()]
param(
	#SAS Access token
	#If a file, read token from file!
	$Token
	
	,#Storage account name
		$StorageAccount
	 
	,#Container name
		$ContainerName
	
	,#Local files directory
	 $LocalDirectory
	
	,[switch]$NoExitCode
	
	,$PrefixRegex = $null
	,[int[]]$PrefixRegexMatches = @(0)
	
	,$CacheBlobsTime = $null
	
	
	,#Input files to compare!
	$Files = $null
	
	,$SummaryRegex
	,$SummaryMap
	
)
$ErrorActionPreference = "Stop";


import-module Az.Storage;

#Function to allow summary!
function SummaryObject {
	#Prefix string
	param(
		$regex
		,$map
		,$o
		,$prop
	)	

	#Lets get list of all properties!
	$UserProps = @($map.keys);

	#Lets build a table of ou match index.
	#The tale will be indexes by integer index representation.
		$MatchIndexTable = @{}
		$NumericIndexes = @();
		@($map.Values) | %{
			$MatchIndex = $_;

			#index can be numeric or a string in format index:DateFormat to allow user format date values!
			if ( $MatchIndex -is [string] ){
				$Parts 		= $MatchIndex -split ':';
				$IndexNum 	= [int]$Parts[0]
				$DateFormat	= $Parts[1]
			} else {
				$IndexNum 	= $MatchIndex;
				$DateFormat	= $null
			}
			
			$NumericIndexes += $IndexNum;
			$MatchIndexTable[$MatchIndex] = @{
					IndexNum	= $IndexNum
					DateFormat 	= $DateFormat
				}
		}
		#The ordered indexes contains all indexes num ordered!
		$OrderedMatchIndexes = @($NumericIndexes) | sort;


	#This is our full object property!
		$ObjectProps  = $map + @{
				Count = 1
				_index = $null
			}

	#This is object index. 
	#Used to find other object!
	$Index = @{};

	#For each object, lest evaluate regex...
	$o | ? {   $_.$prop -match $regex } | %{
		$UserMatches = $matches;
		
		#Get all evaluations in order of matched index!
		$KeyValues 	= @($UserMatches[$OrderedMatchIndexes])
		
		#Calculate index value...
		$IndexValue = $KeyValues -Join "/";
		
		#Try find the object by index...
		$CurrentO = $Index[$IndexValue];
		
		#If found, then just increment counters!
		if($CurrentO){
			$CurrentO.Count += 1;
			return;
		}
		
		#Not found, creae new object with our skeleton properties...
		$NewObject = New-Object PSObject -Prop $ObjectProps;
		$NewObject._index = $IndexValue;
		
		#For each property specified by user...
		$UserProps | %{
		
			#Find the index mapped to this property...
			$MatchIndex 	= $ObjectProps[$_];
			
			#Get the match info!
			$MatchIndexInfo = $MatchIndexTable[$MatchIndex];
			
			#Get the index value...
			$MatchedValue 	= $UserMatches[$MatchIndexInfo.IndexNum]
			 
			
			if($MatchIndexInfo.DateFormat){
				$FinalValue =  [datetime]::parseexact($MatchedValue, $MatchIndexInfo.DateFormat, $null);
			} else {
				$FinalValue = $MatchedValue;
			}
		
			#Assign to the object property...
			$NewObject.$_ = $FinalValue
			
			
		}
		
		#Add to the index!
		$Index[$IndexValue] = $NewObject;
	}


	return ($Index.Values);
}


if(!$Token){
	throw "NO_TOKEN";
}

if(Test-Path $Token){
	$Token = Get-Content $Token -Raw;
}

if($Files){
	$LocalFiles = $Files;
} else {
	if(!$LocalDirectory -or -not(Test-Path $LocalDirectory)){
		throw "INVALID_LOCALDIRECTORY: $LocalDirectory"
	}
	
	write-host "Getting local files..."
	$LocalFiles = gci $LocalDirectory -recurse ;
}

#Remove directories and add BlobName property!
write-host "Adding blobname..."
$LocalFiles = $LocalFiles | ?{!$_.PsIsContainer} | Add-Member -Force -Type Noteproperty -Name BlobName -Value $null -PassThru | %{
	$_.BlobName =   $_.FullName.replace("$LocalDirectory\",'').replace('\','/');
	$_;
};

$Context 	= New-AzStorageContext -SasToken $Token -StorageAccountName $StorageAccount

$CachedBlobs = $null
if($CacheBlobsTime){
	#Get...
	$BlobCache = $Global:CompareAzure_CachedBlobs;
	
	if($BlobCache){
		$ElapsedTime = ((Get-Date) - $BlobCache.LastCacheTime).TotalSeconds;
		
		if($ElapsedTime -ge $CacheBlobsTime){
			#Invalidate cache!
			$CachedBlobs = $null;
		} else {
			$CachedBlobs = $BlobCache;
		}
	}
	
}

if($CachedBlobs){
	write-host "Getting blobs from cache..."
	$Blobs = $CachedBlobs 
} else {

	if($PrefixRegex){
		$AllPrefixes = $LocalFiles | ?{
							$_.BlobName -match $PrefixRegex 
					} | %{  -Join $matches[$PrefixRegexMatches] 
					} | sort -Unique;
	}
	


	write-host "Getting blobs..."
	if($AllPrefixes){
		write-verbose "$($AllPrefixes | Out-String)"
		$RawBlobs	= $AllPrefixes  | %{
							Get-AzStorageBlob -Context $Context -Container $ContainerName -Prefix $_
						}
	} else {
		$RawBlobs	= Get-AzStorageBlob -Context $Context -Container $ContainerName
	}
	

	write-host "Indexing blobs..."
	$BlobIndex = @{};
	$RawBlobs | %{
		$BlobIndex[$_.Name] = $_;
	}

	$Blobs = @{
			Blobs 			= $RawBlobs
			BlobIndex		= $BlobIndex
			LastCacheTime	= (Get-Date)
		};
		
	$Global:CompareAzure_CachedBlobs =  $Blobs 
}

write-host "	Count:" $Blobs.Blobs.count;


	


write-host "	LocalFiles:" $LocalFiles.count;
$Stats = @{
	NotSync 		= @()
	Sync			= @()
	NotSyncSummary	= $null
}

$LocalFiles  | %{
	$LocalBlobName = $_.BlobName;
	$LocalLength = $_.Length;
	
	#Find the correspodiing
	$Corresponding = $Blobs.BlobIndex[$LocalBlobName];
	
	if($Corresponding -and $Corresponding.Length -eq $LocalLength){
		$Stats.Sync += $_;
	} else {
		$Stats.NotSync += $_;
	}
}


if($SummaryRegex){
	$Stats.NotSyncSummary = SummaryObject -regex $SummaryRegex -map $SummaryMap -o $Stats.NotSync -prop 'BlobName'
}


return $Stats;

