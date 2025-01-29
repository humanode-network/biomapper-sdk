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

| Contract           | Implemented Interfaces    |
| ------------------ | ------------------------- |
| `Biomapper`        | [`IBiomapperRead`]        |
| `BridgedBiomapper` | [`IBridgedBiomapperRead`] |

[`IBiomapperRead`]: core/IBiomapperRead.sol/interface.IBiomapperRead.html
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
import {IBiomapperRead} from "@biomapper-sdk/core/IBiomapperRead.sol";
import {IBridgedBiomapperRead} from "@biomapper-sdk/core/IBridgedBiomapperRead.sol";
import {BiomapperLib} from "@biomapper-sdk/libraries/BiomapperLib.sol";
```

### With Foundry

Install the dependency:

```shell
forge install humanode-network/biomapper-sdk
```

Import the dependencies from `biomapper-sdk` like this:

```solidity
import {IBiomapperRead} from "biomapper-sdk/core/IBiomapperRead.sol";
import {IBridgedBiomapperRead} from "biomapper-sdk/core/IBridgedBiomapperRead.sol";
import {BiomapperLib} from "biomapper-sdk/libraries/BiomapperLib.sol";
```

## Usage

See the [`usage`][usage] directory for the simple usage examples, and
the [`examples`][examples] directory for a more complete use cases
demonstration.

[usage]: https://github.com/humanode-network/biomapper-sdk/tree/master/usage
[examples]: https://github.com/humanode-network/biomapper-sdk/tree/master/examples
