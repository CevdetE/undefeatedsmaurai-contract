//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Undefeatedsamurai is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;

    string public samuraiBaseURI;

    // This much samurais, be ready!
    uint256 public freeSamuraiSupply = 1000;
    uint256 public almostFreeSamuraiSupply = 3200;

    // Being a samurai has price!
    uint256 public spliffCost = 0.0069 ether;

    uint256 public maxSamuraiPerWallet = 10;

    bool public hotbox = false;


    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721A(_name, _symbol) {
        setsamuraiBaseURI(_initBaseURI);
    }
    
    function spawnfreesamurais(uint256 _amount) external nonReentrant {
        uint256 totalSamurais = totalSupply();
        require(hotbox, "we are still sharpening our katanas.. Come back later");
        require(_numberMinted(msg.sender) + _amount <= maxSamuraiPerWallet, "you can't be more Samurai!");
        require(totalSamurais + _amount <= freeSamuraiSupply, "you missed out on the free ones, ngmi");
        _safeMint(msg.sender, _amount);
    }

    function spawnsamurais(uint256 _amount) external payable nonReentrant {
        uint256 totalSamurais = totalSupply();
        require(hotbox, "we are still sharpening our katanas.. come back later");
        require(_numberMinted(msg.sender) + _amount <= maxSamuraiPerWallet, "you cant mint more.");
        require(totalSamurais + _amount >= freeSamuraiSupply, "you can still mint for free, how many joints have you smoked??!");
        require(totalSamurais + _amount <= freeSamuraiSupply + almostFreeSamuraiSupply, "you missed the chance to being a Samurai, check marketplace");
        require(msg.value >= spliffCost * _amount, "you thought that was unchecked? Being a Samurai has a price");
        _safeMint(msg.sender, _amount);
    }

    function enableHotBox() public onlyOwner {
        hotbox = true;
    }

    function disableHotBox() public onlyOwner {
        hotbox = false;
    }

    function setsamuraiBaseURI(string memory _newBaseURI) public onlyOwner {
        samuraiBaseURI = _newBaseURI;
    }
    
    function getsamuraiBaseURI() public view returns (string memory) {
        return samuraiBaseURI;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "This samurai doesnt exist, huh");

        string memory baseURI = getsamuraiBaseURI();
        string memory json = ".json";
        
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(samuraiBaseURI, tokenId.toString(), json))
            : "";
    }

    function redeemweedprofits() public payable onlyOwner {
	    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
	    require(success);
	}
}