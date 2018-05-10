pragma solidity ^0.4.17;

contract Adoption {
    // Enum que usamos como os estados da maquina de estado de um pet
    // 1) Criado - disponivel para adocao
    // 2) Aguardando por aprovacao - Alguem pediu para adota-lo
    // 3) Adotado - Pedido aceitado pelo dono do contrato
    enum PetState { WAITING_FOR_ADOPTION, WAITING_FOR_APPROVAL, ADOPTED }

	struct Pet {
        bytes name;
        address adopter;

        // Aqui guardamos tambem a quantidade de valor que o endereco
        // que deseja adotar o pet enviou como doacao
        uint donationAmount;
        PetState state;
    }

    Pet[] public pets;
    address owner;

    // create the Adoption contract
    constructor(address _owner) public {
        owner = _owner;
    }

	// adding a pet
    function addPet(bytes name)
        public
        ownerOnly()
        returns(uint)
    {
        Pet memory newPet = Pet(name, address(0), 0, PetState.WAITING_FOR_ADOPTION);
        pets.push(newPet);
        return pets.length - 1;
    }

	// Retrieving a pet
    function getPet(uint petId)
        validPet(petId)
        public
        view
        returns(bytes, address, uint8, uint)
    {
        return (pets[petId].name, pets[petId].adopter, uint8(pets[petId].state), pets[petId].donationAmount);
    }

	// Adopting a pet
    // Adicionado modificador 'payable' que possibilita ao contrato receber valores
    // Os valores ficam salvos no contrato em si, acessiveis na variavel `this.balance`.

    // Usamos tambem os novos modificadores para garantir as pre-condicoes das nossas funcoes
    // Um pet so pode ser adotado se seu estado for WAITING_FOR_ADOPTION
    function adopt(uint petId)
        validPet(petId)
        petAvailableForAdoption(petId)
        public
        payable
        returns (uint)
    {
        uint donationAmount = msg.value;
        Pet storage pet = pets[petId];

        pet.adopter = msg.sender;
        pet.donationAmount = donationAmount;

        pet.state = PetState.WAITING_FOR_APPROVAL;
        pets[petId] = pet;
        return petId;
    }

	// Retrieving number of pets
    function getNumberOfPets() public view returns (uint) {
        return pets.length;
    }

    // Accept adoption
    // Um pet so pode ter seu pedido de adocao aceito se seu estado for WAITING_FOR_APPROVAL
    // Em seguida, o pet passa para o estado ADOPTED e os fundos sao transferidos para o dono do contrato
    function acceptAdoptionRequest(uint petId)
        validPet(petId)
        petWaitingForApproval(petId)
        ownerOnly()
        public
    {
        Pet storage pet = pets[petId];

        uint donationAmount = pet.donationAmount;

        pet.donationAmount = 0;
        pet.state = PetState.ADOPTED;

        owner.transfer(donationAmount);
    }

    // Deny adoption
    // Um pet so pode ter seu pedido de adocao negado se seu estado for WAITING_FOR_APPROVAL
    // Em seguida, ele passa de volta para o estado WAITING_FOR_ADOPTION e os fundos sao retornados
    // ao endereco que pediu a adocao originalmente
    function denyAdoptionRequest(uint petId)
        validPet(petId)
        petWaitingForApproval(petId)
        ownerOnly()
        public
    {
        Pet storage pet = pets[petId];

        uint donationAmount = pet.donationAmount;
        address adopter = pet.adopter;

        pet.donationAmount = 0;
        pet.state = PetState.WAITING_FOR_ADOPTION;
        pet.adopter = address(0);

        adopter.transfer(donationAmount);
    }

	modifier validPet(uint petId) {
        require(petId >= 0 && petId < pets.length);
        _;
    }

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    modifier petWaitingForApproval(uint petId) {
        require(pets[petId].state == PetState.WAITING_FOR_APPROVAL);
        _;
    }

    modifier petAvailableForAdoption(uint petId) {
        require(pets[petId].state == PetState.WAITING_FOR_ADOPTION);
        _;
    }
}
