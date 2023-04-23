import { ethers } from "hardhat";

async function main() {
  const initialSupply = 1000;
  const admin = "0xBeFcc312CF77F7379B30aD939471DFCacB6e5EfE";
  const priceInWei = ethers.utils.parseEther("0.001");

  const Lock = await ethers.getContractFactory("MyToken");
  const lock = await Lock.deploy(initialSupply, admin, priceInWei);

  await lock.deployed();

  console.log(
    `MyToken deployed to ${lock.address} with ${initialSupply} initial supply and ${admin} as admin`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
