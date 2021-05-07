# Get a reference to the resource group that is the scope of the assignment
$SubID = 'Your Subscription ID'
$Subscription = Get-AzSubscription -SubscriptionID $SubID
 
# Get a reference to the built-in policy definition to assign
$Policy = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'CASG-SecurityRules' }

#Source Value is your ISP assigned Public IP address
$PublicIP = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip

# Create the policy assignment with the built-in definition against your Subscription
New-AzPolicyAssignment `
-Name 'CASG-SecurityRule-100' `
-DisplayName 'CASG-SecurityRule-100' `
-location "EastUS" `
-PolicyDefinition $Policy `
-Scope "/subscriptions/$($Subscription.Id)" `
-ruleNo "100" `
-protocol "Tcp" `
-destinationPortranges "3389", "22" `
-sourcetype "IP Addresses" `
-sourceValue $PublicIP `
-actionValue "Allow" `
-direction "Inbound" `
-AssignIdentity

# Create a remediation task to enforce policy on existing resources. Please allow at least 1 hour for Policy Assignment to run before triggering remediation task
$PolicyID = Get-AzPolicyAssignment -Name 'CASG-SecurityRule-100'
Start-AzPolicyRemediation -Name 'RemediationTask01' -PolicyAssignmentId $PolicyID.ResourceId
