# azure-machine-configuration-demos

## Pre-setup
1. On a Windows workstation, [install PowerShell 7.x](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
2. Install required modules
    ```
    Install-Module GuestConfiguration
    Install-Module PSDscResources
    Install-Module ComputerManagementDsc
    ```
3. Log in Azure and select the proper demo subscription in PowerShell (may need to install the Az PowerShell module first)

## Demo Steps
1. Compile the DSC configuration, this will generate a mof file
    ```
    cd dsc_configurations\timezone
    .\01_TimeZoneConfig.ps1
    ```
2. Package the configuration, this will generate a zip file
    ```
    .\02_TimeZonePackage.ps1
    ```
3. Test the configuration package by uploading the zip file to a test server and run the commands in `03_TimeZoneTest.ps1`.
4. Deploy Terraform code located in the `terraform` folder, this will deploy the required Azure infrastructure in a resource group `machineconfig-demo-rg` for publishing configuration package and the rest of the demo
    ```
    cd terraform
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    ```
5. Publish the package (.zip file) to the storage account
    ```
    cd dsc_configuration\timezone
    .\04_TimeZonePublish.ps1
    ```
6. Deploy the policy definition and assign it to the resource group
    ```
    .\05_TimeZonePolicy.ps1
    ```
7. Monitor the policy compliance status and when necessary, run a remediation task to apply the configuration.

## Clean up
1. Destroy the Terraform code deployment
    ```
    cd terraform
    terraform destroy -auto-approve
    ```
2. Run the cleanup script
    ```
    cd dsc_configurations\timezone
    .\cleanup.ps1
    ```
