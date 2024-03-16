import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
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
        it("succeds", async function () {
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

          let noErrorCatched = true;

          try {
            await biomapper.simulate.biomap([
              account1.account.address,
              BIOTOKEN,
            ]);
          } catch (err) {
            noErrorCatched = false;

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

          expect(noErrorCatched).to.be.false;
        });
      });

      context("when the message contains non-unique biotoken", () => {
        it("fails", async function () {
          const { biomapper, account0 } = await loadFixture(testFixture);

          await expect(
            biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          ).to.be.fulfilled;

          let noErrorCatched = true;

          try {
            await biomapper.simulate.biomap([
              account0.account.address,
              BIOTOKEN2,
            ]);
          } catch (err) {
            noErrorCatched = false;

            const error = fixRevertError(err);

            expect(error.data?.errorName).to.equal(
              "AccountHasAnotherBiotokenAttached",
            );
            expect(error.data?.args).to.be.undefined;
          }

          expect(noErrorCatched).to.be.false;
        });
      });

      context("when this exact mapping already exists", () => {
        it("fails", async function () {
          const { biomapper, account0 } = await loadFixture(testFixture);

          await expect(
            biomapper.write.biomap([account0.account.address, BIOTOKEN]),
          ).to.be.fulfilled;

          let noErrorCatched = true;

          try {
            await biomapper.simulate.biomap([
              account0.account.address,
              BIOTOKEN,
            ]);
          } catch (err) {
            noErrorCatched = false;

            const error = fixRevertError(err);

            expect(error.data?.errorName).to.equal("BiomappingAlreadyExists");
            expect(error.data?.args).to.be.undefined;
          }

          expect(noErrorCatched).to.be.false;
        });
      });
    });

    describe("#initGeneration", () => {
      context("on generation change", () => {
        it("succeds", async function () {
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

  describe("ICheckUniqueness", () => {
    describe("#isUnique", () => {
      context("when not mapped", () => {
        it("returns false", async () => {
          const { biomapper, account0 } = await loadFixture(testFixture);

          expect(await biomapper.read.isUnique([account0.account.address])).to
            .be.false;
        });
      });

      context("when mapped", () => {
        it("returns true", async () => {
          const { biomapper, account0 } = await loadFixture(testFixture);

          await biomapper.write.biomap([account0.account.address, BIOTOKEN]);

          expect(await biomapper.read.isUnique([account0.account.address])).to
            .be.true;
        });
      });
    });
  });
});
