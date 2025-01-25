![Biomapper SDK][logo]

[logo]: https://github.com/humanode-network/biomapper-sdk/assets/265507/2afffc2e-85c2-4410-9866-b3956c7e0baf

# Humanode Biomapper SDK

This is the SDK for the Humanode Biomapper - a biometrics-based sybil-resistance
utility for EVM smart contracts.

To learn more about the Humanode Biomapper itself (and not this SDK) see the [docs].

[docs]: https://link.humanode.io/docs/biomapper

## Contract Addresses

Find the up-to-date contract addresses [here][contract-addresses].

[contract-addresses]: https://link.humanode.io/docs/biomapper/contract-addresses

## Implementation Table

| Contract           | Implemented Interfaces                          |
| ------------------ | ----------------------------------------------- |
| `Biomapper`        | [`ICheckUniqueness`]                            |
| `BiomapperLog`     | [`IBiomapperLogRead`]                           |
| `BridgedBiomapper` | [`ICheckUniqueness`], [`IBridgedBiomapperRead`] |

[`ICheckUniqueness`]: core/ICheckUniqueness.sol/interface.ICheckUniqueness.html
[`IBiomapperLogRead`]: core/IBiomapperLogRead.sol/interface.IBiomapperLogRead.html
[`IBridgedBiomapperRead`]: core/IBridgedBiomapperRead.sol/interface.IBridgedBiomapperRead.html

## Installation

### With NPM/Yarn

Install the packages:

```shell
npm install --save @biomapper-sdk/core @biomapper-sdk/libraries @biomapper-sdk/events
```

or with yarn:

```shell
yarn add @biomapper-sdk/core @biomapper-sdk/libraries @biomapper-sdk/events
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

## Usage

See the [`usage`][usage] directory for the simple usage examples, and
the [`examples`][examples] directory for a more complete use cases
demonstration.

[usage]: https://github.com/humanode-network/biomapper-sdk/tree/master/usage
[examples]: https://github.com/humanode-network/biomapper-sdk/tree/master/examples
