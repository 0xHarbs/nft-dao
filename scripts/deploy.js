const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {
  const NFTDAOContract = await ethers.getContractFactory("NFTDAO");
  const deployedNFTDAOContract = await NFTDAOContract.deploy(NFTDAOContract);
  console.log("NFTDAO deployed to address:", deployedNFTDAOContract.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });