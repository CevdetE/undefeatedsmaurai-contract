import { expect } from "chai";
import { ethers } from "hardhat";

describe("Undefeatedsamurai", function () {
  it("should be able to free mint until 1000", async () => {
    // create signers
    const [owner, ...signers] = await ethers.getSigners();
    expect(signers).to.have.lengthOf.above(420);

    const freemintsigners = signers.slice(0, 100);
    const mintsigners = signers.slice(100, 420);

    // deploy contract
    const UndefeatedSamurai = await ethers.getContractFactory("Undefeatedsamurai");
    const undefeatedsamurai = await UndefeatedSamurai.connect(owner).deploy(
      "undefeatedsamurai",
      "$USNFT",
      "ipfs??"
    );
    await undefeatedsamurai.deployed();

    // enable minting
    const enableMintTX = await undefeatedsamurai.enableHotBox();
    await enableMintTX.wait();

    // 1000 free mints
    for (const signer of freemintsigners) {
      const freeMintTx = await undefeatedsamurai
        .connect(signer)
        .spawnfreesamurais(10);

      await freeMintTx.wait();
    }

    // should have 1000 supply now
    expect(await undefeatedsamurai.totalSupply()).to.equal(1000);

    // should fail afterwards
    await expect(
      undefeatedsamurai.connect(signers[101]).spawnfreesamurais(1)
    ).to.be.revertedWith("you missed out on the free ones, ngmi");

    await expect(
      undefeatedsamurai
        .connect(signers[200])
        .spawnsamurais(10, { value: ethers.utils.parseEther("0.050") })
    ).to.be.revertedWith("you thought that was unchecked? being a Samurai has a Price");

    // 4200 public mints
    for (const signer of mintsigners) {
      const mintTx = await undefeatedsamurai
        .connect(signer)
        .spawnsamurais(10, { value: ethers.utils.parseEther("0.069") });

      await mintTx.wait();
    }

    // should have 4200 supply now
    expect(await undefeatedsamurai.totalSupply()).to.equal(4200);

    const redeemProfits = await undefeatedsamurai
      .connect(owner)
      .redeemprofits();

    await redeemProfits.wait();
  });
});
