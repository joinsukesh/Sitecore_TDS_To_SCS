# Sitecore TDS to SCS

Motivated by Aaron Bickle's [script](https://gist.github.com/bic742/f77783c643420b704535d88fcbb5b18e), I have created my own.
This powershell script can be used to read the _*.scproj_ TDS project files and create corresponding _*.module.json_ files which will be used in Sitecore Content Serialization.

## How to use
1. Declare the values for these variables in the _Get-ModuleJsonFromTdsProjects.ps1_ script file. The description for each variable is specified in the script file

   - _$global:tdsProjectsSourceFolderPath_
   - _$global:commaSeparatedTDSProjectPaths_
   - _$global:cliJsonModulesDirectory_
  
2. Execute the script

## PROS
1. Generates the *.module.json files in a few mintues.

### CONS
1. The generated json file will not have the _"references"_ & "alias" properties.
   
![image](https://github.com/joinsukesh/Sitecore_TDS_To_SCS/assets/24619393/14ea1fa6-b533-40ff-9a67-c4ba2b498fe4)



![image](https://github.com/joinsukesh/Sitecore_TDS_To_SCS/assets/24619393/2515ec6b-58f7-434c-aa54-cc4640859930)



The _"reference"_ property is used by the SCS system to determine if it should process any other json file before the current one. You need to add these properties manually for each generated file or can ignore if not needed.

2. These are the _allowedPushOperations_ options that will be added to each _"include"_ block in the generated file - _CreateOnly_, _CreateUpdateAndDelete_.
If for any item, it should be _CreateAndUpdate_, you need to update this manually in the generated file(s).

4. These are the _scope_ options that will be added to each _"include"_ block in the generated file - _SingleItem_, _ItemAndDescendants_.
If for any item, it should be _ItemAndChildren_ or _DescendantsOnly_, you need to update this manually in the generated file(s).
   
