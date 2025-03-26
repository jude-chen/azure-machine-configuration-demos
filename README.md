# azure-machine-configuration-demos

## Pre-setup

1. On a Windows workstation, [install PowerShell 7.x](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)

2. Install required modules

    ```powershell
    Install-Module GuestConfiguration
    Install-Module PSDscResources
    Install-Module ComputerManagementDsc
    ```

3. Log in Azure and select the proper demo subscription in PowerShell (may need to install the Az PowerShell module first)

4. Log in Azure and select the proper demo subscription in Azure CLI (for running Terraform code)

## Demo Steps

1. Compile the DSC configuration, this will generate a mof file (`.\SetTimeZoneCST\localhost.mof`)

    ```powershell
    cd dsc_configurations\timezone
    .\01_TimeZoneConfig.ps1
    ```

2. Package the configuration, this will generate a zip file (`.\SetTimeZoneCST.zip`)

    ```powershell
    .\02_TimeZonePackage.ps1
    ```

3. (Optional) Test the configuration package by uploading the zip file to a test server and run the commands in `03_TimeZoneTest.ps1`.

4. Deploy Terraform code located in the `terraform` folder, this will deploy the required Azure infrastructure in a resource group `machineconfig-demo-rg` for publishing configuration package and the rest of the demo

    ```bash
    cd terraform
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    ```

5. Publish the package (.zip file) to the storage account

    ```powershell
    cd dsc_configuration\timezone
    .\04_TimeZonePublish.ps1
    ```

6. Generate and deploy the policy definition and assign it to the resource group, this will generate an Azure Policy custom definition in the `.\policies\deployIfNotExists` folder.
    Open up `05_TimeZonePolicy.ps1` and update the value of the `$UserManagedIdentityResourceId` variable with the resource ID you get from your actual environment. Save and run the script.

    ```powershell
    .\05_TimeZonePolicy.ps1
    ```

7. Monitor the policy compliance status and when necessary, run a remediation task to apply the configuration.

*** Alternatively, if you want to install the GuestConfiguration extension and deploy the `SetTimeZoneCST` configuration using Terraform instead of policies, then do not run `05_TimeZonePolicy.ps1`, comment out the related policy assignments and role assignments in `main.tf`, and uncomment the GuestConfiguration extension and guest configuraiton assignment blocks in `testvm.tf`.

## Clean up

1. Destroy the Terraform code deployment

    ```powershell
    cd terraform
    terraform destroy -auto-approve
    ```

2. Run the cleanup script

    ```powershell
    cd dsc_configurations\timezone
    .\cleanup.ps1
    ```
