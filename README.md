<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Issues][issues-shield]][issues-url]
[![Twitter][twitter-shield]][twitter-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://treasure.lol/">
    <img style="background-color: rgb(16 24 39); padding: 10px 20px" src="https://treasure.lol/build/_assets/logo-light-QKJXV52Z.png" alt="Logo" width="450" height="103">
  </a>

  <h3 align="center">Treasure Spellcaster Facets</h3>

  <p align="center">
    The source of truth for all facets related to the Spellcaster API suite of tools and game loops
    <br />
    <a href="https://treasure.lol/about"><strong>Learn about Treasure »</strong></a>
    <br />
    <br />
    <a href="https://treasure.lol/infrastructure">Infrastructure</a>
    ·
    <a href="https://treasure.lol/cartridges">The Treasureverse</a>
    ·
    <a href="https://github.com/othneildrew/Best-README-Template/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
* [Developer Resources](#developer-resources)
  * [Initial installation](#initial-installation)
  * [Building](#building)
  * [Testing](#testing)
  * [Recommended Setup](#recommended-setup)
* [Contact](#contact)



<!-- ABOUT THE PROJECT -->
## About The Project

<p align="center">
    <a href="https://treasure.lol/">
        <img src="https://treasure.lol/build/_assets/hero-ZQWGLR62.png" alt="Logo" width="540" height="400">
    </a>
</p>

Simplifying blockchain interactions and allowing for seamless developer and user experiences is what makes Treasure magical. With this grimoire, harnesing the Spellcaster API to delight Treasure ecosystem players is as effortless as using a regular API.

By working on the secure, customizable, and user-centric blockchain features and bundling the blockchain interactions into a developer friendly API, Spellcaster frees up valuable developer time and resources to focus on making the best gaming experience for all Treasure players

<!-- DEVELOPER RESOURCES -->
## Developer Resources

### Initial installation
*IMPORTANT: Use Node version 18.x*
1. Install [NodeJS](https://nodejs.org/en/download/package-manager/). You can also install/manage NodeJS via [nvm](https://nodejs.org/en/download/package-manager/#nvm), which helps with managing multiple repos with varying versions needed
2. Install [Yarn](https://yarnpkg.com/getting-started/install), the package manager that is used to build and cache dependencies as well as the `solhint/spellcaster` solhint plugin nested locally
3. (Optional) Install [act - Local GitHub Actions](https://github.com/nektos/act#installation), a local GitHub Action runner, to ensure code stability before PRing. This will save from PRs that get flagged with errors. You will need to install [Docker](https://docs.docker.com/engine/install/) if you have not already

### Install dependencies / initialize the repo
```sh
yarn init
```

To install Forge, go to https://book.getfoundry.sh/getting-started/installation

### Linting
The following command gets ran via ci and will block code that doesn't conform.
```
yarn lint:check
```
Run the following command to try to automatically fix linting errors.
```
yarn lint:fix
```

### Building
```
yarn build
```

### Testing
```
yarn test
```

### Commiting
When committing code, Husky will run 2 pre-commit hooks:
1. [commitlint](https://github.com/conventional-changelog/commitlint) - A conventional commit messaging enforcer. See https://www.conventionalcommits.org/en/v1.0.0/ for what conventional commits strive to achieve
2. Lint / format fixing - Runs solhint + forge fmt to ensure code style formats are consistent across the repo. Will prevent commits if any errors are found

### Running GitHub Actions
To run the `lint-build-test` GitHub Action job, execute the following script:
```sh
./run-gh-actions.sh -j lint-build-test 
```
This script will build and use the `Dockerfile` as the local runner with Node/Rust/Yarn preinstalled to bypass those slow steps. It will also reuse the previous run state (build/eslint state, etc) to only track changes between runs. It will always full copy the repo file state for anything not in the .gitignore file.

**NOTE1:** This requires `docker` and `act` to be installed and will prompt if they are missing.

**NOTE2:** If there are any weird issues, reset your act setup by deleting the container that starts with `act-spellcaster-facets` and optionally the `$HOME/.cache/actcache` directory (the local cache server location for the `actions/cache` package)

**NOTE3:** If you are running a Mac with an Apple Silicon CPU, some of the following settings should be considered for performance optimizations:
* Currently there is a crippling performance bug on Docker Desktop's latest version. If the `Virtual Machine Server` service is at max CPU usage, revert to [version 4.14.1 for now](https://desktop.docker.com/mac/main/arm64/91661/Docker.dmg).
* Enable `VirtioFS` for optimal volume file sharing (in Beta Features for verion 4.14.1 and General for latest versions)
* Disable `Open Docker Dashboard at startup`
* Do NOT use `-b` when running the `run-gh-actions.sh` script. Binding mounts for Mac Silicon is extremely slow.

### Recommended Setup
For optimal intellisense and NatSpec completion, it is recommended to use the Nomic Foundation's Solidity extension, in addition to adding the following VSCode snippet (since there isn't any native event/struct completion snippets)

To add the snippet on Mac: Open Command Palette -> Type Snippet -> Press "Snippets: Configure User Snippets" -> find the 'Solidity' language -> Paste the following
```
{
	"natspec event": {
		"prefix": "\/\/ nat_event",
		"body": "\/**\r\n * @notice \r\n * @param \r\n *\/",
		"description": "natspec for events"
	},
	"natspec struct": {
		"prefix": "\/\/ nat_struct",
		"body": "\/**\r\n * @dev \r\n * @param \r\n *\/",
		"description": "natspec for structs"
	}
}

Now you can find these completions whenever typing '/'. For non-events/structs, use the default completion, as it will generate based on params and return variables
```

<!-- CONTACT -->
## Contact

Treasure - [@Treasure_DAO](https://twitter.com/Treasure_DAO) - info@treasure.lol

Project Link: [https://treasure.lol](https://treasure.lol)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[issues-shield]: https://img.shields.io/github/issues/TreasureProject/interoperability
[issues-url]: https://github.com/TreasureProject/interoperability/issues
[twitter-shield]: https://img.shields.io/twitter/follow/Treasure_DAO?style=social
[twitter-url]: https://twitter.com/intent/follow?screen_name=Treasure_DAO
[product-screenshot]: https://treasure.lol/build/_assets/hero-ZQWGLR62.png