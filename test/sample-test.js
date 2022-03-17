const { expect } = require('chai');

describe('NFTDAO', function () {
  let Contract, contract, owner, addr1, addr2;

  beforeEach(async () => {
    Contract = await ethers.getContractFactory('NFTDAO');
    contract = await Contract.deploy();
    await contract.deployed();
    [owner, addr1, addr2, _] = await ethers.getSigners();
  });

  describe('Deployment', () => {
    it('should set the correct owner', async () => {
      expect(await contract.owner()).to.equal(owner.address);
    })

    it('should start with 0 for token Ids', async () => {
      expect(await contract.tokenIds()).to.equal(0);
    });

    it('should start with paused as false', async () => {
      expect(await contract._paused()).to.equal(false);
    });

    it('should set paused to true', async () => {
      await contract.setPaused(true);
      expect(await contract._paused()).to.equal(true);
    })
  })
  describe('Minting', () => {
    it('should mint token for owner', async () => {
      await contract.mint({ value: ethers.utils.parseEther("0.06") }); // msg.value is 0.05 eth
      expect(await contract.balanceOf(owner.address)).to.equal(1);
    })

    it("should say owner owns token 1", async () => {
      await contract.mint({ value: ethers.utils.parseEther("0.06") }); // msg.value is 0.05 eth
      expect(await contract.balanceOf(owner.address)).to.equal(1);
      expect(await contract.ownerOf(1)).to.equal(owner.address);
    })

    it("should transfer token", async () => {
      await contract.mint({ value: ethers.utils.parseEther("0.06") }); // msg.value is 0.05 eth
      await contract.transferFrom(owner.address, addr1.address, 1);
      const addr1Balance = await contract.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(1);
    })
    it("should transfer token for addr1 to addr2", async () => {
      await contract.mint({ value: ethers.utils.parseEther("0.06") }); // msg.value is 0.05 eth
      await contract.transferFrom(owner.address, addr1.address, 1);
      await contract.connect(addr1).transferFrom(addr1.address, addr2.address, 1);
      const addr2Balance = await contract.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(1);
    })
  })
  describe('Selling', async () => {
    beforeEach(async () => {
      await contract.mint({ value: ethers.utils.parseEther("0.06") }); // msg.value is 0.05 eth
    })
    it("balance should equal 1", async () => {
      expect(await contract.balanceOf(owner.address)).to.equal(1);
    })
    it("should add a sell struct to array", async () => {
      await contract.sellToken(1, 1000);
      const sale0 = await contract.sales(0);
      expect(sale0.price).to.equal(1000);
    })
    it("should purchase an item for sale", async () => {
      await contract.sellToken(1, 1000);
      await contract.connect(addr1).buyToken(1, { value: ethers.utils.parseEther("0.001") });
      expect(await contract.balanceOf(addr1.address)).to.equal(1);
    })
  })
  describe('Voting', async () => {
    beforeEach(async () => {
      await contract.mint({ value: ethers.utils.parseEther("0.06") }); // msg.value is 0.05 eth
    })
    it("should create vote struct", async () => {
      await contract.createProposal("New Leader", "Lets get a new leader");
      const proposal0 = await contract.proposals(0);
      expect(proposal0.name).to.equal("New Leader");
    })
    it("should vote on proposal", async () => {
      await contract.createProposal("New Leader", "Lets get a new leader");
      await contract.voteOnProposal(0, true);
      const proposal0 = await contract.proposals(0);
      expect(proposal0.yesVotes).to.equal(1);
    })
  })
});
