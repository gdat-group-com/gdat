const GDATToken = artifacts.require("GDATToken");
const GDATWallet = artifacts.require("GDATWallet");

module.exports = async function (deployer) {
  const gdatToken = await GDATToken.deployed();
  await deployer.deploy(GDATWallet, gdatToken.address);
};
