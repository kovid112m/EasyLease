// SPDX-License-Identifier: MIT
// price = 2500000000000000000
// price sepoliaeth = 250000000000000000 = 0.25 ether

pragma solidity ^0.8.0;

contract PropertyMarket {
    address public owner;
    uint256 public propertyRent;
    address public tenant;
    address public firstTenant;
    bool public propertyLeased;
    uint256 public leaseDuration; // in months
    uint256 public leaseTracker;
    
    // Create a property for tenants to rent
    constructor(uint256 _price, uint256 _listedLeaseDuration) {
        owner = msg.sender;
        propertyRent = _price;
        propertyLeased = false;
        leaseDuration = _listedLeaseDuration;
        leaseTracker = _listedLeaseDuration;
    }

    // Check if the property chosen is available to rent
    modifier isPropertyLeased() {
        require(propertyLeased == true, "Property is available for renting"); // error msg 2nd param
        _;
    }
   
    // Check if the property chosen is already leased to other tenant
    modifier isPropertyNotLeased() {
            require(propertyLeased == false || firstTenant == msg.sender, "Property is not available for renting"); // if properttSold is false, then run the function else print the string
            require(leaseTracker > 0, "Lease Duration Exceeded");
            _;
            
        }

    // Transfer the funds from tenant to owner
    function withdrawFunds() internal isPropertyLeased {
        payable(owner).transfer(address(this).balance);
    }


    function rentProperty(uint256 rentDuration) external payable isPropertyNotLeased {
        
        require(msg.sender != owner, "Owner cannot rent the property");
        require(msg.value == propertyRent, "Incorrect rent tranferred");
        require(rentDuration == leaseDuration, "Incorrect lease duration to proceed with the contract");
        
        // Validate the transactions and handle edge cases
        firstTenant = msg.sender;
        leaseTracker --;
        
        require (msg.sender.balance >= propertyRent, "Insufficient funds to pay the rent");
        propertyLeased = true;
        withdrawFunds();
        tenant = msg.sender;

        if(msg.sender.balance < propertyRent || leaseTracker == 0) {
            tenant = address(0); // Tenant is no longer renting the property (set tenant address to null)
            propertyLeased = false; // Property is now available to rent
        }
    }

}