import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";


describe("MT contract", function () {
    const initialSupply = 100000;
    const admin2 = "0x66168F9d2c0E8edBB920f334d6F9384761fF9883"
    const admin = "0xBeFcc312CF77F7379B30aD939471DFCacB6e5EfE";
    const priceInWei = ethers.utils.parseEther("0.001");

    async function deployMTNFixture() {

        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const MT = await ethers.getContractFactory("MyTokenAdvancedOld");
        const mt = await MT.deploy(initialSupply, owner.address, priceInWei);
        await mt.deployed();

        const Uniswap = await ethers.getContractFactory('Uniswap');
        const uniswap = await Uniswap.deploy(mt.address);
        await uniswap.deployed();

        return {mt, uniswap, owner, otherAccount};
    }

    it("MT should be deployed", async function () {
        const {mt} = await loadFixture(deployMTNFixture);

        expect(await mt.symbol()).to.equal("MT");
        expect(await mt.name()).to.equal("MyToken");
    });

    it('Should mint the token ', async function () {
        const {mt, owner} = await loadFixture(deployMTNFixture);

        await mt.mint(owner.address, 100);
        expect(await mt.balanceOf(owner.address)).to.equal(100);
    });

    it('Should approve the uniswap contract', async () => {
        const {mt, uniswap, owner, otherAccount} = await loadFixture(deployMTNFixture);

        await mt
            .connect(otherAccount)
            .approve(uniswap.address, 100);
    });

    it('Should transfer the token to uniswap contract', async () => {
        const {mt, uniswap, owner, otherAccount} = await loadFixture(deployMTNFixture);

        await mt.mint(owner.address, 100);
        await mt
            .connect(owner)
            .approve(uniswap.address, 100);
        await mt
            .connect(owner)
            .transfer(uniswap.address, 100);
    });

    it('Should add liquidity', async function () {
        const {mt, uniswap, owner, otherAccount} = await loadFixture(deployMTNFixture);

        await mt.mint(owner.address, 100);
        await mt
            .connect(owner)
            .approve(uniswap.address, 100);
        await uniswap
            .connect(owner)
            .addLiquidity(100, {
                value: ethers.utils.parseEther("1"),
            });
    });

    it('Should swap token for ETH ', async () => {
        const {mt, uniswap, owner, otherAccount} = await loadFixture(deployMTNFixture);

        await mt.mint(owner.address, 10000);
        await mt
            .connect(owner)
            .approve(uniswap.address, 10000);
        await uniswap
            .connect(owner)
            .addLiquidity(1000, {
                value: ethers.utils.parseEther('2'),
            });
        await uniswap
            .connect(owner)
            .swapTokensForETH(1000);
    });

    it('Should add liquidity', async function () {
        const {mt, uniswap, owner, otherAccount} = await loadFixture(deployMTNFixture);

        await mt.mint(owner.address, 10000);
        await mt
            .connect(owner)
            .approve(uniswap.address, 10000);
        await uniswap
            .connect(owner)
            .addLiquidity(10000, {
                value: ethers.utils.parseEther('2'),
            });
        await uniswap
            .connect(owner)
            .swapTokensForETH(1000);

        const amountBefore = await uniswap.ETHStored(owner.address);
        await uniswap.connect(owner).withdrawETH(amountBefore);

        const amountAfter = await uniswap.ETHStored(owner.address);
        expect(amountBefore).to.be.not.equal(amountAfter);
    });


});