// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract HashBallNFT is ERC721URIStorage, ERC2981 {

    address public owner;
    uint256 public nftindex = 1;
    mapping (address => uint256) private addressMintNFTCount;

    uint256 public NFTprice = 0.002 * 10 ** 18;
    uint256 public constant MAXSUPPLY = 10000;
    uint256 public constant FIRST_MAXSUPPLY = 3000;
    uint256 public constant ADDRESS_MAX = 5;
    bool public continue_mint = false;
    uint256 public start_time = 1741327200;

    string public _metadataURI = "https://variable-pink-nightingale.myfilebase.com/ipfs/QmdjBCRsrwJLRsUNZZVBb7RDbPFpXqMczmVXjGhWEekzWR";

    constructor(string memory name, string memory symbol, address _owner) ERC721(name, symbol) {
        owner = _owner;
        _setDefaultRoyalty(address(this), 500);
    }

    receive() external payable {}
    fallback() external payable {}

    function set_nft_price(uint256 _nft_price) public{
        require(msg.sender == owner, "not allow");
        NFTprice = _nft_price;
    }

    function set_continue_mint(bool _true_false) public{
        require(msg.sender == owner, "not allow");
        continue_mint = _true_false;
    }

    function set_metadataURI(string calldata _url) public{
        require(msg.sender == owner, "not allow");
        _metadataURI = _url;
    }

    function set_start_time(uint256 _time) public{
        require(msg.sender == owner, "not allow");
        start_time = _time;
    }

    function setFeeNumerator(uint96 feeNumerator) public {
        require(msg.sender == owner, "not allow");
        _setDefaultRoyalty(msg.sender, feeNumerator);
    }

    function mint(uint256 amount) public payable {
        require(block.timestamp > start_time, "not start");
        require(amount >= 1, "amount not allow");
        if(continue_mint){
            require(amount + nftindex <= MAXSUPPLY, "Exceed max supply");
        }else{
            require(amount + nftindex <= FIRST_MAXSUPPLY, "Exceed first max supply");
        }
        
        require(addressMintNFTCount[msg.sender] + amount <= ADDRESS_MAX, "amount Exceed");
        require(msg.value >= (amount * NFTprice), "not enough pay");
        (bool success, ) = (owner).call{value: msg.value}("");
        if(!success){
            revert('call failed');
        }
        for(uint256 i=0; i< amount; i++){
            addressMintNFTCount[msg.sender]++;
            _mint(msg.sender, nftindex + i);
            // emit Transfer(address(0), msg.sender, nftindex + i);//already emit
        }
        nftindex += amount;
    }

    function getmintInfo(address _owner) public view returns(uint256, uint256, uint256) {
        return (nftindex, addressMintNFTCount[_owner], start_time);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage) returns (string memory) {
        require(tokenId <= nftindex, "tokenId exceed");        
        return _metadataURI;

    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981, ERC721URIStorage) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
}
