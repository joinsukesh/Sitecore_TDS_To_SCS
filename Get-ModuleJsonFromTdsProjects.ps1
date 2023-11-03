# DECLARE VARIABLES
<# 1. $tdsProjectsSourceFolderPath: Add the Visual Studio Solution's source folder path which contains all the TDS projects.
      Specify this path only if you want the program to read all TDS projects.
      However, if you want the program to read only one or few specified TDS projects, then keep this variable field empty.
      You can specify such paths in the 2nd variable below ($commaSeparatedTDSProjectPaths). 
      The program will consider  only the first non-empty variable in this order - $tdsProjectsSourceFolderPath, $commaSeparatedTDSProjectPaths
      e.g.: $tdsProjectsSourceFolderPath = "D:\Projects\MyProject\src"
#>
$global:tdsProjectsSourceFolderPath = ""; 

<# 2. Add comma separated TDS project paths. 
      The program will consider this variable value if $tdsProjectsSourceFolderPath is empty.
      e.g.: $commaSeparatedTDSProjectPaths = "D:\Projects\MyProject\src\Feature\MyProject.Feature.Accounts.Master\MyProject.Feature.Accounts.Master.scproj,D:\Projects\MyProject\src\Feature\MyProject.Feature.Navigation.Master\MyProject.Feature.Navigation.Master.scproj"
#>
$global:commaSeparatedTDSProjectPaths = "";

<# 3. Specify the destination folder path where the CLI Json module files should be created.
       e.g.: $cliJsonModulesDirectory = "D:\Projects\MyProject\src\SCS\Modules"
#>
$global:cliJsonModulesDirectory = "";

<# $exclusionList: This is a list of items, if found in any of the TDS projects, will not be added to the module.json.
#>
$global:exclusionList = [System.Collections.ArrayList]@(
    # master items
    "sitecore/layout.item",
    "sitecore/layout/Layouts.item",
    "sitecore/layout/Layouts/Foundation.item",
    "sitecore/layout/Layouts/Feature.item",
    "sitecore/layout/Layouts/Project.item",
    "sitecore/layout/Placeholder Settings.item",
    "sitecore/layout/Placeholder Settings/Foundation.item",
    "sitecore/layout/Placeholder Settings/Feature.item",
    "sitecore/layout/Placeholder Settings/Project.item",
    "sitecore/layout/Renderings.item",
    "sitecore/layout/Renderings/Foundation.item",
    "sitecore/layout/Renderings/Feature.item",
    "sitecore/layout/Renderings/Project.item",
    "sitecore/media library.item",
    "sitecore/media library/Foundation.item",
    "sitecore/media library/Feature.item",
    "sitecore/media library/Project.item",
    "sitecore/media library/Themes.item",
    "sitecore/media library/Base Themes.item",
    "sitecore/media library/Images.item",
    "sitecore/system.item",
    "sitecore/system/Dictionary.item",
    "sitecore/system/Settings.item",
    "sitecore/system/Modules.item",
    "sitecore/system/Publishing targets.item",
    "sitecore/system/Languages.item",
    "sitecore/system/Tasks.item",
    "sitecore/system/Tasks/Commands.item",
    "sitecore/system/Tasks/Schedules.item",
    "sitecore/system/Workflows.item",
    "sitecore/system/Settings/Foundation.item",
    "sitecore/system/Settings/Feature.item",
    "sitecore/system/Settings/Project.item",
    "sitecore/system/Settings/Validation Rules.item",
    "sitecore/system/Settings/Validation Rules/Field Rules.item",
    "sitecore/templates.item",
    "sitecore/templates/Branches.item",
    "sitecore/templates/Branches/Foundation.item",
    "sitecore/templates/Branches/Feature.item",
    "sitecore/templates/Branches/Project.item",
    "sitecore/templates/Foundation.item",
    "sitecore/templates/Feature.item",
    "sitecore/templates/Project.item",
    "sitecore/templates/System.item",

    # Core items
    "sitecore/content/Applications.item",
    "sitecore/content/Applications/WebEdit.item",
    "sitecore/content/Applications/WebEdit/Default Rendering Buttons.item",
    "sitecore/content/Applications/Content Editor.item",
    "sitecore/content/Applications/Content Editor/Ribbons.item",
    "sitecore/content/Applications/Content Editor/Ribbons/Chunks.item",
    "sitecore/content/Applications/Content Editor/Ribbons/Ribbons.item",
    "sitecore/content/Applications/Content Editor/Ribbons/Ribbons/Default.item",
    "sitecore/content/Applications/Content Editor/Ribbons/Strips.item",
    "sitecore/content/Documents and settings.item",
    "sitecore/client/Applications.item",
    "sitecore/client/Applications/FormsBuilder.item",
    "sitecore/client/Applications/FormsBuilder/Components.item",
    "sitecore/client/Applications/FormsBuilder/Components/Layouts.item",
    "sitecore/client/Applications/FormsBuilder/Components/Layouts/Actions.item",
    "sitecore/system.item",
    "sitecore/system/Field types.item",
    "sitecore/system/Field types/Link Types.item",
    "sitecore/system/Field types/Link Types/General Link.item",
    "sitecore/system/Field types/Link Types/General Link/WebEdit Buttons.item",
    "sitecore/system/Field types/Link Types/Droptree.item",
    "sitecore/system/Field types/Link Types/Droptree/WebEdit Buttons.item",
    "sitecore/system/Field types/Simple Types.item",
    "sitecore/system/Field types/Simple Types/Image.item",
    "sitecore/system/Field types/Simple Types/Image/WebEdit Buttons.item",
    "sitecore/system/Settings.item",
    "sitecore/system/Settings/Html Editor Profiles.item",
    "sitecore/system/Settings/Html Editor Profiles/Rich Text Default.item",
    "sitecore/system/Settings/Html Editor Profiles/Rich Text Default/WebEdit Buttons.item"
)


<#Builds and returns the content of a json module#>
function Get-JsonFileContent {    
    param(
        [String]$tdsProjectFilePath,
        [System.Collections.ArrayList]$tdsSitecoreItemObjects
    )
    Write-Host "Generating Module.Json content..." -ForegroundColor White;
    $includeBlocks = [System.Collections.ArrayList]@();
    $namespace = (Get-Item $tdsProjectFilePath).Name;
    $namespace = $namespace.Replace(".scproj", "").Replace("Sitecore.", "");

    if ($null -ne $tdsSitecoreItemObjects -and $tdsSitecoreItemObjects.ToString() -ne '' -and $tdsSitecoreItemObjects.psobject.properties.count -gt 0) {
        foreach ($obj in $tdsSitecoreItemObjects) {            
            if ($null -ne $obj -and $null -ne $obj.Name -and $obj.Name.Trim() -ne '' -and $obj.Name.Length -gt 0) {
                
                $include = @"
                {
                    "name": "$($obj.Name)",
                    "path": "$($obj.Path)",
                    "database": "$($obj.Database)",
                    "scope": "$($obj.Scope)",
                    "allowedPushOperations": "$($obj.AllowedPushOperations)"                                        
                }
"@
                $includeBlocks.Add($include) | out-null;
            }            
        }
    } 
    $content = @"
    {
        "namespace": "$namespace",        
        "items": {
            "includes": [
                $($includeBlocks -join ",")
            ]
        }
    }
"@
    return $content;
}


<# Creates the Json module file for the specified project with content.
The file will be created in the path declared in $global:cliJsonModulesDirectory
#>
function GenerateJsonModule {
    param (
        [String]$tdsProjectFilePath,
        [System.Collections.ArrayList]$tdsSitecoreItemObjects
    )
    
    $fileName = (Get-Item $tdsProjectFilePath).Name;
    $fileName = $fileName.Replace('.scproj', '.json');
    $targetFilePath = $global:cliJsonModulesDirectory + "\" + $fileName;
    
    if (-not (Test-Path $global:cliJsonModulesDirectory)) {
        New-Item -ItemType Directory -Force -Path $global:cliJsonModulesDirectory
    }

    $jsonFileContent = Get-JsonFileContent -tdsProjectFilePath $tdsProjectFilePath -tdsSitecoreItemObjects $tdsSitecoreItemObjects;
    Write-Host "Creating Module.json file..." -ForegroundColor White;
    Set-Content -Force -Path "$targetFilePath" -Value $jsonFileContent;
}

<#Get-UniqueIncludesName: For each include block in the module.json file, the name property should be unique.
This method creates a name using the following logic.
1. Get the item path and split it into array of strings.
2. For each fragment, get the first character of each word, except the last fragment.
3. For the last fragment, use the word as is by removing spaces and with a leading underscore.
For example, if the item path is /sitecore/content/Some Brand/Home/About Us, then the name would be scSBH_AU
#>
function Get-UniqueIncludeName {
    param (
        [String]$itemPath
    )
    #Removing the leading "/" from item path
    $itemPath = $itemPath.Substring(1);    
    $array = $itemPath.Split("/");    
    $uniqueName = "";
    
    if ($null -ne $array) {        
        $arrayLength = $array.Length;
        for ($i = 0; $i -lt $arrayLength; $i++) {
            $pathFragment = $array[$i];
            $pathFragment = $pathFragment.Trim();
            if ($pathFragment -ne '') {                
                if ($i -eq $arrayLength - 1) {                    
                    $uniqueName += "_" + $pathFragment.Replace(' ', '');                                    
                }
                else {
                    $arrFragment = $pathFragment.Split(' ');
                    foreach ($str in $arrFragment) {
                        $uniqueName += $str.Substring(0, 1);
                    }
                }                
            }
        }        
    }
    
    return $uniqueName;
}

<#For each item node in the TDS project, this method creates an object with properties similar to those in the "include" block of CLI json module#>
function Get-ModuleIncludeBlockObjectsFromTdsProject {
    param (
        [String]$tdsProjectFilePath
    )
    Write-Host "Preparing Module Include blocks..." -ForegroundColor White;
    $tdsSitecoreItemObjects = [System.Collections.ArrayList]@();
    
    # The namespace included in the project breaks the default XML methods. 
    # We don't need the namespace, since these files are ultimately going away
    # So, strip the namespace and convert to XML!
    
    $fileContent = Get-Content $tdsProjectFilePath;
    $fileContent = $fileContent.Replace("xmlns=`"http://schemas.microsoft.com/developer/msbuild/2003`"", "");
    $xmlContent = [xml]$fileContent;

    $items = $xmlContent.SelectNodes("//SitecoreItem")
    
    foreach ($item in $items) {
        # This is likely to be an OOTB Sitecore item, which can be excluded
        if ($item.ItemDeployment -ne "NeverDeploy") {
            $path = $item.Include.Replace('\', '/')        

            if (-not ($exclusionList -ilike $path)) {
                $dotItem = ".item";
                $lastIndex = $path.LastIndexOf($dotItem);
                $path = "/" + $path.Substring(0, $lastIndex) + $path.Substring($lastIndex + $dotItem.Length);
                $path = $path.ToLower();

                $name = Get-UniqueIncludeName -itemPath $path ;
                
                switch ($item.ItemDeployment) {
                    "DeployOnce" { $allowedPushOperations = "CreateOnly" }
                    "AlwaysUpdate" { $allowedPushOperations = "CreateUpdateAndDelete" }
                    default { throw (New-Object System.Exception "Could not analyze this AllowedPushOperations - $($item.ItemDeployment) for this item -  $($path)") }
                }

                switch ($item.ChildItemSynchronization) {
                    "NoChildSynchronization" { $scope = "SingleItem" }
                    "KeepAllChildrenSynchronized" { $scope = "ItemAndDescendants" }
                    default { throw (New-Object System.Exception "Could not analyze this Scope - $($item.ItemDeployment) for this item -  $($path)") }
                }

                $database = "master";

                if ($tdsProjectFilePath.Name -like "*.Core.*") {
                    $database = "core"
                }
                
                $objTdsSitecoreItem = New-Object PSObject;
                $objTdsSitecoreItem | Add-Member -MemberType NoteProperty -Name "Name" -Value $name;
                $objTdsSitecoreItem | Add-Member -MemberType NoteProperty -Name "Path" -Value $path;
                $objTdsSitecoreItem | Add-Member -MemberType NoteProperty -Name "Database" -Value $database;
                $objTdsSitecoreItem | Add-Member -MemberType NoteProperty -Name "Scope" -Value $scope;
                $objTdsSitecoreItem | Add-Member -MemberType NoteProperty -Name "AllowedPushOperations" -Value $allowedPushOperations;                
                $tdsSitecoreItemObjects.Add($objTdsSitecoreItem);                 
            }
        }
    }    
    
    return $tdsSitecoreItemObjects;
}

<# Get-TDSProjectPaths: Returns a string array of unique TDS project file paths.
The source list is taken from the declared variable.
#>
function Get-TDSProjectFilePaths {
    Write-Host "`nFetching TDS project file paths..." -ForegroundColor White;
    $arrPaths = New-Object System.Collections.Generic.List[string];
    $arrPathsTemp = $commaSeparatedTDSProjectPaths.Split(",");

    if ([string]::IsNullOrEmpty($tdsProjectsSourceFolderPath) -and [string]::IsNullOrEmpty($commaSeparatedTDSProjectPaths)) {
        Write-Host "`nNO TDS PROJECT PATHS SPECIFIED. PLEASE ENTER VALUES FOR EITHER $tdsProjectsSourceFolderPath or $commaSeparatedTDSProjectPaths" -ForegroundColor Red
    }
    else {
        if ($tdsProjectsSourceFolderPath -ne "") {
            $tdsProjects = Get-ChildItem -Path $tdsProjectsSourceFolderPath -Recurse -Filter *.scproj;

            if ($null -ne $tdsProjects) {
                foreach ($tdsProject in $tdsProjects) {
                    $arrPaths.Add($tdsProject.FullName);
                }
            }
        }
        else {
            foreach ($path in $arrPathsTemp) {
                $path = $path.Trim();

                if ($null -ne $path -and $path -ne "" -and $arrPaths -notcontains $path) {
                    $arrPaths.Add($path);
                }
            }
        }
    }
        
    return $arrPaths;
}

function Execute_Main {
    try {        
        Clear-Host;    
        Write-Host "PROCESS STARTED" -ForegroundColor White;
        $tdsProjectFilePaths = Get-TDSProjectFilePaths;

        if ($null -ne $tdsProjectFilePaths -and $tdsProjectFilePaths.Length -gt 0) {
            foreach ($path in $tdsProjectFilePaths) {
                Write-Host "`nProcessing $($path) ..." -ForegroundColor Yellow; 
                $tdsSitecoreItemObjects = Get-ModuleIncludeBlockObjectsFromTdsProject -tdsProjectFilePath $path;                
                GenerateJsonModule -tdsProjectFilePath $path -tdsSitecoreItemObjects $tdsSitecoreItemObjects;               
            }  
        }  
        else {
            Write-Host "`nNO TDS PROJECT FILE PATHS FOUND" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Execute_Main
Write-Host "`nPROCESS COMPLETE" -ForegroundColor Green;