const { ethers } = require('hardhat');
const { assert } = require('chai');

describe('MultiSend', () => {
	let multiSendContract, MK, deployer, user1, user2;

	beforeEach(async () => {
		[deployer, user1, user2] = await ethers.getSigners();

		const TokenContract = await ethers.getContractFactory('MK');
		MK = await TokenContract.deploy();
		await MK.deployed();
		console.log(MK.address);

		const MultiSendContract = await ethers.getContractFactory('MultiSend');
		console.log('Deploying contract....');
		multiSendContract = await MultiSendContract.deploy(MK.address);
		await multiSendContract.deployed();
		console.log('Deployed contract to: ' + multiSendContract.address);
	});

	it('Check token is created', async () => {
		const expectedSymbolToken = 'MK';
		const realSymboltoken = await MK.symbol();
		assert(realSymboltoken, expectedSymbolToken);
	});

	it("Check transfer token to contract's pool", async () => {
		const initBalanceOfMultiContract = await MK.balanceOf(
			multiSendContract.address
		);
		await MK.transfer(multiSendContract.address, 1000);
		const finalBalanceOfMultiContract = await MK.balanceOf(
			multiSendContract.address
		);
		assert(finalBalanceOfMultiContract, initBalanceOfMultiContract + 1000);
	});

	it('check transfer from pool to other users', async () => {
		const initBalanceMultiSendContract = await MK.balanceOf(
			multiSendContract.address
		);

		const initBalanceOfUser1 = await MK.balanceOf(user1.address);
		const initBalanceOfUser2 = await MK.balanceOf(user2.address);
		assert(initBalanceOfUser1, initBalanceOfUser2);

		await MK.connect(deployer).approve(multiSendContract.address, 10000);
		await multiSendContract.connect(deployer).addTokenToPool(10000);

		const multiSendContractTokenAfterRecieve = await MK.balanceOf(
			multiSendContract.address
		);

		assert(
			multiSendContractTokenAfterRecieve,
			initBalanceMultiSendContract + 10000
		);

		await multiSendContract
			.connect(deployer)
			.withdrawlMulti([user1.address, user2.address], [1000, 1000]);

		const finalBalanceMultiSendContract = await MK.balanceOf(
			multiSendContract.address
		);
		const finalBalanceOfUser1 = await MK.balanceOf(user1.address);
		const finalBalanceOfUser2 = await MK.balanceOf(user2.address);

		assert(
			finalBalanceMultiSendContract,
			initBalanceMultiSendContract - 2000
		);
		assert(finalBalanceOfUser1, initBalanceOfUser1 + 1000);
		assert(finalBalanceOfUser2, initBalanceOfUser2 + 1000);
		console.log(finalBalanceOfUser1);
		console.log(finalBalanceMultiSendContract);
	});
});
