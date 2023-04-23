import { ethers } from "hardhat";

async function main() {
  const initialSupply = 1000;
  const admin2 = "0x66168F9d2c0E8edBB920f334d6F9384761fF9883"
  const admin = "0xBeFcc312CF77F7379B30aD939471DFCacB6e5EfE";
  const priceInWei = ethers.utils.parseEther("0.001");

  const MT = await ethers.getContractFactory("MyTokenAdvanced");
  const mt = await MT.deploy(initialSupply, admin2, priceInWei);

  await mt.deployed();

  console.log(
    `MyTokenAdvanced deployed to ${mt.address} with ${initialSupply} initial supply and ${admin2} as admin`
  );

  const Uniswap = await ethers.getContractFactory('Uniswap');
  const uniswap = await Uniswap.deploy(mt.address);

  await uniswap.deployed();

  console.log(
      `Uniswap Token deployed to: ${uniswap.address}`
  );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
