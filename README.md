# Cutrix
A Cutrix is a 4X4 matrix representation of Ethereum addresses. 

The Cutrix representation is generated as an on-chain NFT in SVG format.

## Introduction
An Ethereum address contains 160 bits. It is normally represented as a string of 40 hex characters, each character represents 4 bits from the 160.

A Cutrix representation includes 16 characters, each character represents 10 bits of the 160. We call such a character a "Rich Character".
The 10 bits of a rich character define the following (from right-most bits to left-most bits):

- 4 bits: hex character
- 3 bits: a color (out of 8 options)
- 1 bit: if the character has a frame around it
- 1 bit: if the character is bold
- 1 bit: if the character blinks

## Files
The project contains two solidity contracts.
- **CutrixLibrary**. A Solidity library that generates SVG code of a Cutrix for a given Ethereum address
- **Cutrix**. An ERC721 contract for Cutrix NFTs.

## Compile
Cutrix is developed with [Foundry](https://getfoundry.sh/). To build it, first install Foundry, then run the following command:
```
forge build
```

## Deploy
To deploy Cutrix to Anvil, the local Ethereum development blockchain of the Foundry framework, first launch Anvil:
```
anvil
```

Create a .env file in Cutrix folder with a parameter 'PRIVATE_KEY_ANVIL' containing a private key of an account in Anvil, for example:
```
PRIVATE_KEY_ANVIL=0x86660b04835ab7bd97c8964fc5239f93f1160d76fd2afe8f9891082132197a7a
```

Now you can deploy the contract to Anvil.
```
forge script script/Cutrix.s.sol:CutrixScript --fork-url http://localhost:8545 --broadcast
```

You will see in the output of the deploy command that two contracts were deployed. The first is `CutrixLibrary` and the second is `Cutrix` ERC721 contract.

## Traits
Each Cutrix has traits determining its rarity. The traits are based on how many characters has the same color, or how many characters are blinking, bold or have a solid frame around them. 

There are five traints: color, blinking, frame, bold and total.

**Blinking, frame, bold traints**. We exaplin for blinking but the same methodoly is used for frame and bold properties.

Calculate how many characters are blinking, then use the Binomial Distribution Formula to calculate its rarity. The formula is: (16 x)* (1/2)^16.

**Colors**. Check which color most characters share, let X be the amount they share it (it can be more than one color of course). Calculate the probability for this using the Binomial Distribution Formula: (16 X)* (1/16)^X * (15/16)^{16-x}.

**Comment**. In order to have only integer rarities, if a rarity is a fractions it is being rounded to the closest integer. A half is being rounded to 1.

## Team
- Neiman (coding)
- R1der (design)
