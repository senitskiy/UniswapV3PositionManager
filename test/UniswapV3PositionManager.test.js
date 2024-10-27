// test/UniswapV3PositionManager.test.js

const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("UniswapV3PositionManager", function () {
    let positionManager;
    let poolMock;
    let token0;
    let token1;
    let deployer;
    let user;

    before(async () => {
        [deployer, user] = await ethers.getSigners();

        // Deploy ERC20 mock tokens
        const Token = await ethers.getContractFactory("MockERC20");
        token0 = await Token.deploy("Token0", "TK0", ethers.utils.parseUnits("1000", 18));
        token1 = await Token.deploy("Token1", "TK1", ethers.utils.parseUnits("1000", 18));

        // Deploy PoolMock
        poolMock = await (await ethers.getContractFactory("PoolMock")).deploy(token0.address, token1.address);

        // Deploy PositionManagerMock
        const PositionManagerMock = await ethers.getContractFactory("PositionManagerMock");
        const positionManagerMock = await PositionManagerMock.deploy();

        // Deploy UniswapV3PositionManager
        const UniswapV3PositionManager = await ethers.getContractFactory("UniswapV3PositionManager");
        positionManager = await UniswapV3PositionManager.deploy(positionManagerMock.address);
    });

    beforeEach(async () => {
        // Transfer some tokens to the user
        await token0.transfer(user.address, ethers.utils.parseUnits("100", 18));
        await token1.transfer(user.address, ethers.utils.parseUnits("100", 18));
    });


    
    it("should create a position correctly", async () => {
        await token0.connect(user).approve(positionManager.address, ethers.utils.parseUnits("100", 18));
        await token1.connect(user).approve(positionManager.address, ethers.utils.parseUnits("100", 18));

        const params = {
            pool: poolMock.address,
            amount0: ethers.utils.parseUnits("100", 18),
            amount1: ethers.utils.parseUnits("100", 18),
            width: 50 // 50%
        };

        // Call createPosition and check for emitted event
        await expect(positionManager.connect(user).createPosition(params))
            .to.emit(positionManager, "PositionCreated")
            .withArgs(1, user.address, ethers.utils.parseUnits("100", 18), ethers.utils.parseUnits("100", 18));

        expect(await token0.balanceOf(user.address)).to.equal(ethers.utils.parseUnits("0", 18));
        expect(await token1.balanceOf(user.address)).to.equal(ethers.utils.parseUnits("0", 18));
    });

    it("should return excess tokens back to the user", async () => {
        await token0.connect(user).approve(positionManager.address, ethers.utils.parseUnits("200", 18));
        await token1.connect(user).approve(positionManager.address, ethers.utils.parseUnits("200", 18));

        const params = {
            pool: poolMock.address,
            amount0: ethers.utils.parseUnits("300", 18), // Intended to exceed user's balance
            amount1: ethers.utils.parseUnits("500", 18), // Intended to exceed user's balance
            width: 50 // 50%
        };

        await positionManager.connect(user).createPosition(params);

        // Check user balance after the operation
        expect(await token0.balanceOf(user.address)).to.be.above(0);
        expect(await token1.balanceOf(user.address)).to.be.above(0);
    });
});