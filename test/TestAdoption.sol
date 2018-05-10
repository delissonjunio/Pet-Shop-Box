pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./ThrowProxy.sol";
import "../contracts/Adoption.sol";


contract TestAdoption {
	Adoption adoption = Adoption(DeployedAddresses.Adoption());
	ThrowProxy throwProxy = new ThrowProxy(address(adoption)); 
	Adoption throwableAdoption = Adoption(address(throwProxy));

	// Testing the addPet() function
	function testUserCanAddPet() public {
		uint returnedId = adoption.addPet("Dog Test");
		uint expected = 0;
		Assert.equal(returnedId, expected, "pet ID 0 should be recorded.");
	}
	
	// Testing the getNumberOfPets() function
    function testUserCanGetTheNumberOfPets () public {
        uint expectedPetLength = 1;
        uint petLength = adoption.getNumberOfPets();
        Assert.equal(petLength, expectedPetLength, "Number of pets should be 1.");
    }
	
	// Testing the getPet() function
	function testUserCanGetPet() public {
		// Expected adopter is null
		address expectedAdopter = address(0);
		var (,adopter) = adoption.getPet(0);
		Assert.equal(adopter, expectedAdopter, "Adopter of pet ID 0 should be empty.");
	}
	
    // Testing invalid retrieval of a pet
	function testUserCannotGetAnInvalidPet() public {
		throwableAdoption.getPet(1);
		throwProxy.shouldThrow();
	}
	
	// Testing the adopt() function
	function testUserCanAdoptPet() public {
		uint returnedId = adoption.adopt(0);
		uint expectedId = 0;
		address expectedAdopter = this;
		Assert.equal(returnedId, expectedId, "Adoption of pet ID 0 should be recorded.");
		var (,adopter) = adoption.getPet(0);
		Assert.equal(adopter, expectedAdopter, "Adopter of pet ID 0 should be the TestAdoption contract.");
	}
	
	// Testing invalid adoption 
	function testUserCannotAdoptAnInvalidPet() public {
		throwableAdoption.adopt(1);
		throwProxy.shouldThrow();
	}
}