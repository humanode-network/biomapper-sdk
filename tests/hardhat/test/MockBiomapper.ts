import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import hre from "hardhat";

import { fixRevertError } from "../utils/revertError";

const BIOTOKEN =
  "0x1234567890123456789012345678901234567890123456789012345678901234";
const BIOTOKEN2 =
  "0x1234567890123456789012345678901234567890123456780000000000000000";

describe("MockBiomapper", () => {
  async function testFixture() {
    const [account0, account1] = await hre.viem.getWalletClients();

    const biomapper = await hre.viem.deployContract("MockBiomapper", []);

    const biomapperLogAddress =
      await biomapper.read.getMockBiomapperLogAddress();

    const biomapperLog = await hre.viem.getContractAt(
      "MockBiomapperLog",
      biomapperLogAddress,
    );

    const publicClient = await hre.viem.getPublicClient();

    return {
      biomapper,
      biomapperLog,
      account0,
      account1,
      publicClient,
    };
  }

  describe("Deployment", () => {
    it("Should have correct biomapperLog address", async () => {
      const { biomapper, biomapperLog } = await loadFixture(testFixture);

      expect(await biomapper.read.getMockBiomapperLogAddress()).to.equal(
        biomapperLog.address,
      );
    });
  });

  describe("IMockBiomapperControl", () => {
    describe("#biomap", () => {
      context("when the message contains unique data", () => {
        it("succeeds", async function () {
          const { biomapper, account0 } = await loadFixture(testFixture);

          await expect(
            biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          ).to.be.fulfilled;
        });

        it("sends the event", async function () {
          const { biomapper, account0, publicClient } =
            await loadFixture(testFixture);

          const hash = await biomapper.write.biomap([
            account0.account.address,
            BIOTOKEN,
          ]);
          await publicClient.waitForTransactionReceipt({ hash });

          const biomapperEvents = await biomapper.getEvents.NewBiomapping();

          expect(biomapperEvents).to.have.lengthOf(1);
          expect(biomapperEvents[0].args.account?.toLowerCase()).to.equal(
            account0.account.address,
          );
          expect(biomapperEvents[0].args.biotoken).to.equal(BIOTOKEN);
        });

        it("logs into MockBiomapperLog", async function () {
          const { biomapper, account0, publicClient, biomapperLog } =
            await loadFixture(testFixture);

          const hash = await biomapper.write.biomap([
            account0.account.address,
            BIOTOKEN,
          ]);
          await publicClient.waitForTransactionReceipt({ hash });

          const actualBlockNumber = await biomapperLog.read.biomappingsHead([
            account0.account.address,
          ]);

          const expectedBlockNumber = (
            await publicClient.getTransactionReceipt({
              hash,
            })
          ).blockNumber;

          expect(actualBlockNumber).to.be.equal(expectedBlockNumber);
        });
      });

      context("when the message contains non-unique address", () => {
        it("fails", async function () {
          const { biomapper, account0, account1 } =
            await loadFixture(testFixture);

          await expect(
            biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          ).to.be.fulfilled;

          let noErrorCaught = true;

          try {
            await biomapper.simulate.biomap([
              account1.account.address,
              BIOTOKEN,
            ]);
          } catch (err) {
            noErrorCaught = false;

            const error = fixRevertError(err);

            expect(error.data?.errorName).to.equal(
              "BiotokenAlreadyMappedToAnotherAccount",
            );
            expect(error.data?.args?.length).to.equal(1);

            const actualAddress = error.data?.args?.at(0) as string;
            expect(actualAddress.toLowerCase()).to.equal(
              account0.account.address,
            );
          }

          expect(noErrorCaught).to.be.false;
        });
      });

      context("when the message contains non-unique biotoken", () => {
        it("fails", async function () {
          const { biomapper, account0 } = await loadFixture(testFixture);

          await expect(
            biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          ).to.be.fulfilled;

          let noErrorCaught = true;

          try {
            await biomapper.simulate.biomap([
              account0.account.address,
              BIOTOKEN2,
            ]);
          } catch (err) {
            noErrorCaught = false;

            const error = fixRevertError(err);

            expect(error.data?.errorName).to.equal(
              "AccountHasAnotherBiotokenAttached",
            );
            expect(error.data?.args).to.be.undefined;
          }

          expect(noErrorCaught).to.be.false;
        });
      });

      context("when this exact mapping already exists", () => {
        it("fails", async function () {
          const { biomapper, account0 } = await loadFixture(testFixture);

          await expect(
            biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          ).to.be.fulfilled;

          let noErrorCaught = true;

          try {
            await biomapper.simulate.biomap([
              account0.account.address,
              BIOTOKEN,
            ]);
          } catch (err) {
            noErrorCaught = false;

            const error = fixRevertError(err);

            expect(error.data?.errorName).to.equal("BiomappingAlreadyExists");
            expect(error.data?.args).to.be.undefined;
          }

          expect(noErrorCaught).to.be.false;
        });
      });
    });

    describe("#initGeneration", () => {
      context("on generation change", () => {
        it("succeeds", async function () {
          const { biomapper } = await loadFixture(testFixture);

          await expect(biomapper.write.initGeneration()).to.be.fulfilled;
        });

        it("sends the event", async function () {
          const { biomapper, publicClient } = await loadFixture(testFixture);

          const hash = await biomapper.write.initGeneration();
          await publicClient.waitForTransactionReceipt({ hash });

          const biomapperEvents = await biomapper.getEvents.GenerationChanged();

          expect(biomapperEvents).to.have.lengthOf(1);
        });

        it("logs into MockBiomapperLog", async function () {
          const { biomapper, publicClient, biomapperLog } =
            await loadFixture(testFixture);

          const hash = await biomapper.write.initGeneration();
          await publicClient.waitForTransactionReceipt({ hash });

          const actualBlockNumber = await biomapperLog.read.generationsHead();

          const expectedBlockNumber = (
            await publicClient.getTransactionReceipt({
              hash,
            })
          ).blockNumber;

          expect(actualBlockNumber).to.be.equal(expectedBlockNumber);
        });
      });
    });
  });

  describe("IBiomapperRead", () => {
    describe("#generationsHead", () => {
      context("on deploy", () => {
        it("is initialized", async () => {
          const { biomapperLog } = await loadFixture(testFixture);

          const initGenerationHeadPtr =
            await biomapperLog.read.generationsHead();

          expect(initGenerationHeadPtr).to.not.equal(0n);
        });
      });

      context("on generation change", () => {
        it("updates", async () => {
          const { biomapper, biomapperLog } = await loadFixture(testFixture);

          const initGenerationHeadPtr =
            await biomapperLog.read.generationsHead();

          await biomapper.write.initGeneration();

          const updatedGenerationHeadPtr =
            await biomapperLog.read.generationsHead();

          expect(Number(updatedGenerationHeadPtr)).to.greaterThan(
            Number(initGenerationHeadPtr),
          );
        });
      });
    });

    describe("#generationsTail", () => {
      context("on deploy", () => {
        it("is initialized", async () => {
          const { biomapperLog } = await loadFixture(testFixture);

          const initGenerationTailPtr =
            await biomapperLog.read.generationsTail();

          expect(initGenerationTailPtr).to.not.equal(0);
        });

        it("equals to generationsHead", async () => {
          const { biomapperLog } = await loadFixture(testFixture);

          const initGenerationHeadPtr =
            await biomapperLog.read.generationsHead();
          const initGenerationTailPtr =
            await biomapperLog.read.generationsTail();

          expect(initGenerationTailPtr).to.equal(initGenerationHeadPtr);
        });
      });

      context("on generation change", () => {
        it("does not update", async () => {
          const { biomapper, biomapperLog } = await loadFixture(testFixture);

          const initGenerationTailPtr =
            await biomapperLog.read.generationsTail();

          await biomapper.write.initGeneration();

          const newGenerationTailPtr =
            await biomapperLog.read.generationsTail();

          expect(newGenerationTailPtr).to.equal(initGenerationTailPtr);
        });

        it("becomes different from generationsHead", async () => {
          const { biomapper, biomapperLog } = await loadFixture(testFixture);

          await biomapper.write.initGeneration();

          const newGenerationHeadPtr =
            await biomapperLog.read.generationsHead();
          const newGenerationTailPtr =
            await biomapperLog.read.generationsTail();

          expect(newGenerationTailPtr).to.not.equal(newGenerationHeadPtr);
        });
      });
    });

    describe("#generationsListItem", () => {
      context("after several generations", () => {
        it("returns correct data", async () => {
          const { biomapper, biomapperLog, publicClient } =
            await loadFixture(testFixture);

          const generationsListHashes = [];
          generationsListHashes.push(await biomapper.write.initGeneration());
          generationsListHashes.push(await biomapper.write.initGeneration());
          generationsListHashes.push(await biomapper.write.initGeneration());
          generationsListHashes.push(await biomapper.write.initGeneration());

          const generationsList = await Promise.all(
            generationsListHashes.map(
              async (hash) =>
                (
                  await publicClient.getTransactionReceipt({
                    hash: hash as `0x${string}`,
                  })
                ).blockNumber,
            ),
          );

          const item = await biomapperLog.read.generationsListItem([
            generationsList[2],
          ]);

          expect(item.nextPtr).to.equal(generationsList[3]);
          expect(item.prevPtr).to.equal(generationsList[1]);

          expect(await biomapperLog.read.generationsHead()).to.equal(
            generationsList.at(-1),
          );
        });
      });
    });

    describe("#biomappingsHead", () => {
      context("when unmapped", () => {
        it("is not initialized", async () => {
          const { biomapperLog, account0 } = await loadFixture(testFixture);

          const initBiomappingsHeadPtr =
            await biomapperLog.read.biomappingsHead([account0.account.address]);

          expect(initBiomappingsHeadPtr).to.equal(0n);
        });
      });

      context("when mapped", () => {
        it("equals to block number", async () => {
          const { biomapper, biomapperLog, account0, publicClient } =
            await loadFixture(testFixture);

          const hash = await biomapper.write.biomap([
            account0.account.address,
            BIOTOKEN,
          ]);

          const newBiomappingsHeadPtr = await biomapperLog.read.biomappingsHead(
            [account0.account.address],
          );

          const blockNumber = (
            await publicClient.getTransactionReceipt({
              hash,
            })
          ).blockNumber;

          expect(newBiomappingsHeadPtr).to.equal(blockNumber);
        });
      });

      context("on generation change", () => {
        it("still exists", async () => {
          const { biomapper, biomapperLog, account0 } =
            await loadFixture(testFixture);

          await biomapper.write.biomap([account0.account.address, BIOTOKEN]);

          await biomapper.write.initGeneration();

          const newBiomappingsHeadPtr = await biomapperLog.read.biomappingsHead(
            [account0.account.address],
          );

          expect(newBiomappingsHeadPtr).to.not.equal(0n);
        });
      });
    });

    describe("#biomappingsTail", () => {
      context("when unmapped", () => {
        it("is not initialized", async () => {
          const { biomapperLog, account0 } = await loadFixture(testFixture);

          const initBiomappingsTailPtr =
            await biomapperLog.read.biomappingsTail([account0.account.address]);

          expect(initBiomappingsTailPtr).to.equal(0n);
        });
      });

      context("when mapped", () => {
        it("equals to biomappingsHead", async () => {
          const { biomapper, biomapperLog, account0 } =
            await loadFixture(testFixture);

          await biomapper.write.biomap([account0.account.address, BIOTOKEN]);

          const newBiomappingsHeadPtr = await biomapperLog.read.biomappingsHead(
            [account0.account.address],
          );
          const newBiomappingsTailPtr = await biomapperLog.read.biomappingsTail(
            [account0.account.address],
          );

          expect(newBiomappingsTailPtr).to.equal(newBiomappingsHeadPtr);
        });
      });

      context("when mapped in several generations", () => {
        it("becomes different from biomappingsHead", async () => {
          const { biomapper, biomapperLog, account0 } =
            await loadFixture(testFixture);

          await biomapper.write.biomap([account0.account.address, BIOTOKEN]);

          await biomapper.write.initGeneration();

          await biomapper.write.biomap([account0.account.address, BIOTOKEN]);

          const newBiomappingsHeadPtr = await biomapperLog.read.biomappingsHead(
            [account0.account.address],
          );
          const newBiomappingsTailPtr = await biomapperLog.read.biomappingsTail(
            [account0.account.address],
          );

          expect(Number(newBiomappingsTailPtr)).to.lessThan(
            Number(newBiomappingsHeadPtr),
          );
        });
      });
    });

    describe("#biomappingsListItem", () => {
      context("when mapped in several generations", () => {
        it("returns correct data", async () => {
          const { biomapper, biomapperLog, account0, publicClient } =
            await loadFixture(testFixture);

          const biomappingsListHashes = [];
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );
          await biomapper.write.initGeneration();
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );
          await biomapper.write.initGeneration();
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );
          await biomapper.write.initGeneration();
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );

          const biomappingsList = await Promise.all(
            biomappingsListHashes.map(
              async (hash) =>
                (
                  await publicClient.getTransactionReceipt({
                    hash: hash as `0x${string}`,
                  })
                ).blockNumber,
            ),
          );

          const item = await biomapperLog.read.biomappingsListItem([
            account0.account.address,
            biomappingsList[2],
          ]);

          expect(item.nextPtr).to.equal(biomappingsList[3]);
          expect(item.prevPtr).to.equal(biomappingsList[1]);

          expect(
            await biomapperLog.read.biomappingsHead([account0.account.address]),
          ).to.equal(biomappingsList.at(-1));
          expect(
            await biomapperLog.read.biomappingsTail([account0.account.address]),
          ).to.equal(biomappingsList[0]);
        });
      });
    });

    describe("#generationBiomapping", () => {
      context("when mapped in several generations", () => {
        it("returns correct data", async () => {
          const { biomapper, biomapperLog, account0, publicClient } =
            await loadFixture(testFixture);

          const generationsListHashes = [];
          const biomappingsListHashes = [];
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );
          generationsListHashes.push(await biomapper.write.initGeneration());
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );
          generationsListHashes.push(await biomapper.write.initGeneration());
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );
          generationsListHashes.push(await biomapper.write.initGeneration());
          biomappingsListHashes.push(
            await biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          );

          const generationsList = await Promise.all(
            generationsListHashes.map(
              async (hash) =>
                (
                  await publicClient.getTransactionReceipt({
                    hash: hash as `0x${string}`,
                  })
                ).blockNumber,
            ),
          );

          const biomappingsList = await Promise.all(
            biomappingsListHashes.map(
              async (hash) =>
                (
                  await publicClient.getTransactionReceipt({
                    hash: hash as `0x${string}`,
                  })
                ).blockNumber,
            ),
          );

          expect(
            await biomapperLog.read.generationBiomapping([
              account0.account.address,
              generationsList[0],
            ]),
          ).to.equal(biomappingsList[1]);

          expect(
            await biomapperLog.read.generationBiomapping([
              account0.account.address,
              generationsList[1],
            ]),
          ).to.equal(biomappingsList[2]);

          expect(
            await biomapperLog.read.generationBiomapping([
              account0.account.address,
              generationsList[2],
            ]),
          ).to.equal(biomappingsList[3]);
        });
      });
    });
  });
});
