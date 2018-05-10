var Adoption = artifacts.require("Adoption");

module.exports = function(deployer) {
  deployer.deploy(Adoption, "0x4B32A4be088F9646dA39695cb857650CA787038c");
};
