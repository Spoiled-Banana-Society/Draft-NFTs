// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

/**
 *    .--.--.       ,---,.   .--.--.
 *   /  /    '.   ,'  .'  \ /  /    '.
 *  |  :  /`. / ,---.' .' ||  :  /`. /
 *  ;  |  |--`  |   |  |: |;  |  |--`
 *  |  :  ;_    :   :  :  /|  :  ;_
 *   \  \    `. :   |    ;  \  \    `.
 *    `----.   \|   :     \  `----.   \
 *    __ \  \  ||   |   . |  __ \  \  |
 *   /  /`--'  /'   :  '; | /  /`--'  /
 *  '--'.     / |   |  | ; '--'.     /
 *    `--'---'  |   :   /    `--'---'
 *              |   | ,'
 *              `----'
 * @title Spoiled Banana Society Season 2 Draft Token ERC-721 Smart Contract
 */

contract SBSDraftTokenSeasonTwo is ERC721, Ownable, Pausable, ReentrancyGuard {

    string public SPOILEDBANANASOCIETY_PROVENANCE = "";
    string private baseURI;
    uint256 public constant RESERVED_TOKENS = 20;
    uint256 public constant TOKEN_PRICE = 10000000000000000; // 0.01 ETH
    uint256 public constant MAX_TOKENS_PURCHASE = 20;
    uint256 public numTokensMinted = 0;
    uint256 public numTokensBurned = 0;

    // PUBLIC MINT
    bool public mintIsActive = false;

    // WALLET BASED PRESALE MINT
    bool public presaleIsActive = false;
    mapping (address => bool) public presaleWalletList;

    // FREE WALLET BASED MINT
    bool public freeWalletIsActive = false;
    mapping (address => bool) public freeWalletList;

    constructor() ERC721("SBS Draft Token Season 2", "SBS") Ownable(msg.sender) {}

    // PUBLIC MINT
    function flipMintState() external onlyOwner {
        mintIsActive = !mintIsActive;
    }

    function mint(uint256 numberOfTokens) external payable nonReentrant {
        require(mintIsActive, "Mint is not active");
        require(numberOfTokens <= MAX_TOKENS_PURCHASE, "You went over max tokens per transaction");
        require(TOKEN_PRICE * numberOfTokens <= msg.value, "You sent the incorrect amount of ETH");
        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = numTokensMinted;
            numTokensMinted++;
            _safeMint(msg.sender, mintIndex);
        }
    }

    // WALLET BASED PRESALE MINT
    function flipPresaleState() external onlyOwner {
	    presaleIsActive = !presaleIsActive;
    }

    function initPresaleWalletList(address[] memory walletList) external onlyOwner {
	    for (uint256 i = 0; i < walletList.length; i++) {
		    presaleWalletList[walletList[i]] = true;
	    }
    }

    function mintPresaleWalletList(uint256 numberOfTokens) external payable nonReentrant {
        require(presaleIsActive, "Mint is not active");
	    require(numberOfTokens <= MAX_TOKENS_PURCHASE, "You went over max tokens per transaction");
	    require(presaleWalletList[msg.sender] == true, "You are not on the presale wallet list or have already minted");
        require(TOKEN_PRICE * numberOfTokens <= msg.value, "You sent the incorrect amount of ETH");
	    for (uint256 i = 0; i < numberOfTokens; i++) {
		    uint256 mintIndex = numTokensMinted;
			numTokensMinted++;
			_safeMint(msg.sender, mintIndex);
	    }
	    presaleWalletList[msg.sender] = false;
    }

    // FREE WALLET BASED GIVEAWAY MINT - Only Mint One
    function flipFreeWalletState() external onlyOwner {
	    freeWalletIsActive = !freeWalletIsActive;
    }

    function initFreeWalletList(address[] memory walletList) external onlyOwner {
	    for (uint256 i = 0; i < walletList.length; i++) {
		    freeWalletList[walletList[i]] = true;
	    }
    }

    function mintFreeWalletList() external nonReentrant {
        require(freeWalletIsActive, "Mint is not active");
	    require(freeWalletList[msg.sender] == true, "You are not on the free wallet list or have already minted");

        uint256 mintIndex = numTokensMinted;
        numTokensMinted++;
        _safeMint(msg.sender, mintIndex);

	    freeWalletList[msg.sender] = false;
    }

    // TOTAL SUPPLY
    function totalSupply() external view returns (uint) { 
        return numTokensMinted - numTokensBurned;
    }

    // BURN IT 
    function burn(uint256 tokenId) public virtual {
	    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
	    _burn(tokenId);
        numTokensBurned++;
    }

    // OWNER FUNCTIONS
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(owner()), balance);
    }

    function reserveTokens() external onlyOwner {
        uint256 mintIndex = numTokensMinted;
        for (uint256 i = 0; i < RESERVED_TOKENS; i++) {
            numTokensMinted++;
            _safeMint(msg.sender, mintIndex + i);
        }
    }

    function setPaused(bool _setPaused) external onlyOwner {
	    return (_setPaused) ? _pause() : _unpause();
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function setProvenanceHash(string memory provenanceHash) external onlyOwner {
        SPOILEDBANANASOCIETY_PROVENANCE = provenanceHash;
    }

    // function _beforeTokenTransfer(
	//     address from,
	//     address to,
	//     uint256 tokenId
    // ) internal virtual override(ERC721) {
	//     require(!paused(), "Pausable: paused");
	//     super._beforeTokenTransfer(from, to, tokenId);
    // }

}