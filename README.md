# Sitecore TDS to SCS

Motivated by Aaron Bickle's [script](https://gist.github.com/bic742/f77783c643420b704535d88fcbb5b18e), I have created my own.
This powershell script can be used to read the _*.scproj_ TDS project files and create corresponding _*.module.json_ files which will be used in Sitecore Content Serialization.

## How to use

### NOTE: Do not test this on your existing realtime project. Instead, clone it to another folder and ten execute this script for the cloned project and heck if it works for you.

1. Declare the values for these variables in the _Get-ModuleJsonFromTdsProjects.ps1_ script file. The description for each variable is specified in the script file

   - _$global:tdsProjectsSourceFolderPath_
   - _$global:commaSeparatedTDSProjectPaths_
   - _$global:cliJsonModulesDirectory_
  
2. Execute the script
3. Test ([Courtesy: Converting a TDS project to Sitecore Content Serialization (SCS)](https://community.sitecore.com/community?id=community_Blog&sys_id=9390c8a91b76359438a46421b24bcb40))
   - **Run a validation of your config:** The _sitecore ser validate_ command can be used to look for any problems in your config. If any are found, you can then run _sitecore ser validate –fix_ to fix common problems. See the [docs on validation](https://doc.sitecore.com/xmc/en/developers/xm-cloud/validate-serialized-content-items.html). 
   - **Get a sync explanation report:** By using the sitecore ser explain command, you can get detailed information on why certain paths are included in the sync. See the docs on the explain [subcommand](https://doc.sitecore.com/xmc/en/developers/xm-cloud/the-cli-serialization-command.html#the-explain-subcommand). 

4. Scenarios to test after deployment: ([Courtesy: Converting a TDS project to Sitecore Content Serialization (SCS)](https://community.sitecore.com/community?id=community_Blog&sys_id=9390c8a91b76359438a46421b24bcb40))

   - Adding new content that should be deployed. 
   - Adding new content that should NOT be deployed. 
   - Making a change to content that should override the target version. 
   - Making a change to content that should NOT override the target version. 
   - Deleting a piece of content from all environments. 

## PROS
1. Generates the *.module.json files in a few mintues.

### CONS
1. The generated json file will not have the _"references"_ & "alias" properties.
   
![image](https://github.com/joinsukesh/Sitecore_TDS_To_SCS/assets/24619393/64f35abf-bf8e-4fd5-a747-f82bc55ad8ca)




![image](https://github.com/joinsukesh/Sitecore_TDS_To_SCS/assets/24619393/272b027f-4350-41e8-b47a-864652fcab92)




The _"reference"_ property is used by the SCS system to determine if it should process any other json file before the current one. You need to add these properties manually for each generated file or can ignore if not needed.

2. These are the _allowedPushOperations_ options that will be added to each _"include"_ block in the generated file - _CreateOnly_, _CreateUpdateAndDelete_.
If for any item, it should be _CreateAndUpdate_, you need to update this manually in the generated file(s).

4. These are the _scope_ options that will be added to each _"include"_ block in the generated file - _SingleItem_, _ItemAndDescendants_.
If for any item, it should be _ItemAndChildren_ or _DescendantsOnly_, you need to update this manually in the generated file(s).
   
