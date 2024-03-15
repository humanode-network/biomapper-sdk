import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress, parseGwei } from "viem";

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

  describe("IMockBiomapperLogWrite", () => {
    describe("#biomap", () => {
      context("when unique data is supplied", () => {
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
    });
  });
});
