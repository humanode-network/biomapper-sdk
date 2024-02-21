![Biomapper SDK][logo]

[logo]: https://github.com/humanode-network/biomapper-sdk/assets/265507/2afffc2e-85c2-4410-9866-b3956c7e0baf

# Humanode Biomapper SDK

This is the SDK for the Humanode Biomapper - a biometrics-based sybil-resistance
utility for EVM smart contracts.

Check out the [docs][1].

[1]: https://link.humanode.io/biomapper-docs

## Usage

### With NPM/Yarn

Install the dependency:

```shell
npm install --save @biomapper-sdk/core @biomapper-sdk/libraries
```

or with yarn:

```shell
yarn add @biomapper-sdk/core @biomapper-sdk/libraries
```

Import the dependencies from the `@biomapper-sdk` like this:

```solidity
import {ICheckUniqueness} from "@biomapper-sdk/core/ICheckUniqueness.sol";
import {IBiomapperLogRead} from "@biomapper-sdk/core/IBiomapperLogRead.sol";
import {BiomapperLogLib} from "@biomapper-sdk/libraries/BiomapperLogLib.sol";
```

### With Foundry

Install the dependency:

```shell
forge install humanode-network/biomapper-sdk
```

Import the dependencies from `biomapper-sdk` like this:

```solidity
import {ICheckUniqueness} from "biomapper-sdk/core/ICheckUniqueness.sol";
import {IBiomapperLogRead} from "biomapper-sdk/core/IBiomapperLogRead.sol";
import {BiomapperLogLib} from "biomapper-sdk/libraries/BiomapperLogLib.sol";
```
